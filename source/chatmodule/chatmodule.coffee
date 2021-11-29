chatmodule = {name: "chatmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["chatmodule"]?  then console.log "[chatmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

# TODO: peer id based user color for spoofing and shit and put nick in message
# TODO: common nick & id format function
# TODO: cleanup old presences after some time
# TODO: nick storage and sync (use last nick recieved per peer and store kv)
# TODO: friends list?

nick = window.localStorage.getItem('chat.nick')
present = {}
channel = null
chatInput = null
chatForm = null
day = require 'dayjs'
relativeTime = require('dayjs/plugin/relativeTime')
day.extend(relativeTime)

messages = []

cmds = {
  help:
    desc: 'This helptext'
    cmd: ->
      sysmsg "Help:"

      for cmd, cval of cmds
        sysmsg " - /#{cmd}#{if cval.param then " #{cval.param}" else ""}: #{cval.desc}"
  nick:
    param: '<nick>'
    desc: 'Change nick'
    cmd: (param) ->
      chatmodule.nick param
      sysmsg "Nick is now #{param}"
}

# TODO: append msgs as nodes directly, store nodes in array for poppin

showPresence = ->
  if channel
    channel.emit "chat.presence", {nick}
    renderPresence()

presence = setInterval(showPresence, 1000)


render = ->
  msgsOut = document.getElementById "chat-messages"
  msgsOut.innerHTML = ''

  for msg in messages
    txt = document.createTextNode("<#{msg.nick || "(unnamed)"} - #{msg.sender}> #{msg.msg}")
    p = document.createElement "p"
    p.appendChild txt
    msgsOut.appendChild p

renderPresence = ->
  pOut = document.getElementById "chat-present"
  pOut.innerHTML = ''

  for id, state of present
    if Date.now() - state.lastSeen > 10 * 1000 and not state.inactive
      state.inactive = true
      sysmsg "#{state.nick || '(unnamed)'} #{state.id} has left"

    txt = document.createTextNode "#{state.nick || "(unnamed)"} #{state.id}"
    p = document.createElement "p"
    p.appendChild txt
    p.classList.add('present')
    if state.inactive
      p.classList.add('inactive')

    txt = document.createTextNode "#{day(state.lastSeen).fromNow()}"
    seen = document.createElement "p"
    seen.appendChild txt
    seen.classList.add('seen')
    p.appendChild seen

    pOut.appendChild p

handler = (sender, data) ->
  messages.push {
    sender: sender.toB58String().slice(2, 18)
    msg: data.msg
    nick: data.nick
  }
  messages = messages.slice 0, 1024
  render()

handlerPresence = (sender, data) ->
  if not present[sender.toB58String()] or present[sender.toB58String()].ghost
    sysmsg "#{data.nick || '(unnamed)'} #{sender.toB58String().slice(2, 18)} has #{if present[sender.toB58String()] then 'returned' else 'joined'}"

  present[sender.toB58String()] = {
    id: sender.toB58String().slice(2, 18)
    nick: data.nick
    lastSeen: Date.now()
  }
  renderPresence()

chatkeypress = () ->
    if not chatInput.value
      return
    chatmodule.chat chatInput.value
    chatInput.value = ''


############################################################
chatmodule.initialize = () ->
    log "chatmodule.initialize"
    chatInput = document.getElementById "chat-input"
    chatForm = document.getElementById "chat-form"
    chatForm.onsubmit = (e) ->
      e.preventDefault()
      chatkeypress()
    return

sysmsg = (msg) ->
  messages.push {
    sender: '#'
    nick: 'system'
    msg
  }
  render()

chatmodule.start = (channelId) ->
    channel = await allModules.eventexchangemodule.channel channelId
    channel.handle "chat", handler
    channel.handle "chat.presence", handlerPresence
    sysmsg "Connected via pubsub to #{channelId} as #{nick || '(unnamed)'}"
    chatInput.disabled = false

chatmodule.chat = (msg) ->
    if not channel
        throw new Error "Not started"

    if msg.startsWith '/'
      s = msg.split(' ')
      cmd = s[0].substr(1)
      if not cmds[cmd]
        sysmsg "Unknown command /#{cmd}. /help for help"
      cmds[cmd].cmd(s.slice(1).join(' '))
      return

    channel.emit "chat", {msg, nick}

chatmodule.stop = ->
  # TODO: teardown channel
  sysmsg "Disconnected from #{channel.id}"
  channel = null
  present = {}
  chatInput.disabled = true

chatmodule.nick = (_nick) ->
  window.localStorage.setItem 'chat.nick', _nick
  nick = _nick

chatmodule.getPresent = ->
  present

module.exports = chatmodule
