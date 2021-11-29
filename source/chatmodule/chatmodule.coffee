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
# TODO: friends list?

day = require 'dayjs'
relativeTime = require('dayjs/plugin/relativeTime')
day.extend(relativeTime)

# self state
nick = window.localStorage.getItem('chat.nick')
us = null

# channel state - init everything as null so we detect uninitialized changes
channel = null
messages = null
present = null
id2nick = null
# unique session id for checking if a message is from "back then" or from this session
session = null

# helper
fmtNick = (id) ->
  "#{id2nick[id] || '(unnamed)'} #{id.substr(2, 18)}"

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
      if param
        sysmsg "Nick is now #{param}"
      else
        sysmsg "Nick has been cleared"
}

# TODO: append msgs as nodes directly, store nodes in array for poppin

showPresence = ->
  if channel
    channel.emit "chat.presence", {nick}

presence = setInterval(showPresence, 5000)


render = ->
  chatMessages.innerHTML = ''

  for msg in messages
    txt = document.createTextNode "<#{if msg.system then '#system#' else fmtNick msg.sender} @ #{day(msg.ts).fromNow()}> #{msg.msg}"
    p = document.createElement "p"
    p.appendChild txt

    if msg.session != session
      p.classList.add('inactive')

    chatMessages.appendChild p

renderPresence = ->
  pOut = document.getElementById "chat-present"
  pOut.innerHTML = ''

  for id, state of present
    # clear out old presences
    if Date.now() - state.lastSeen > 60 * 60 * 1000
      delete present[id]
      continue

    if Date.now() - state.lastSeen > 10 * 1000 and not state.inactive
      state.inactive = true
      sysmsg "#{fmtNick id} has left"

    txt = document.createTextNode "#{fmtNick id}"
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
  id2nick[sender.toB58String()] = data.nick

  messages.push {
    sender: sender.toB58String()
    msg: data.msg
    ts: Date.now()
    session
  }
  messages = messages.slice 0, 1024

  saveState 'messages', messages
  saveState 'id2nick', id2nick

handlerPresence = (sender, data) ->
  id2nick[sender.toB58String()] = data.nick

  if not present[sender.toB58String()] or present[sender.toB58String()].inactive
    sysmsg "#{fmtNick sender.toB58String()} has #{if present[sender.toB58String()] then 'returned' else 'joined'}"

  present[sender.toB58String()] = {
    lastSeen: Date.now()
  }

  saveState 'present', present, false
  saveState 'id2nick', id2nick

chatkeypress = () ->
    if not chatInput.value
      return
    chatmodule.chat chatInput.value
    chatInput.value = ''


############################################################
chatmodule.initialize = () ->
    log "chatmodule.initialize"
    chatForm.onsubmit = (e) ->
      e.preventDefault()
      chatkeypress()
    return

sysmsg = (msg) ->
  messages.push {
    system: true
    msg
    ts: Date.now()
    session
  }
  saveState 'messages', messages

_state = null

saveState = (key, value, persistent = true) ->
  (if persistent then _state.save else _state.set) "#{channel.id}.#{key}", value, true

loadState = (key, def) ->
  _state.load("#{channel.id}.#{key}") || def

listenState = (key, fnc) ->
  trueFnc = () -> true
  _state.setChangeDetectionFunction "#{channel.id}.#{key}", trueFnc
  _state.addOnChangeListener "#{channel.id}.#{key}", fnc

chatmodule.start = (channelId) ->
    _state = allModules.statemodule

    channel = await allModules.eventexchangemodule.channel channelId

    session = String(Math.random())
    messages = loadState 'messages', []
    present = {}
    id2nick = loadState 'id2nick', {}

    us = allModules.peertopeermodule.getNode().peerId.toB58String()

    channel.handle "chat", handler
    channel.handle "chat.presence", handlerPresence

    chatInput.disabled = false

    sysmsg "Connected via pubsub to #{channelId} as #{nick || '(unnamed)'}"

    listenState 'messages', render
    listenState 'present', renderPresence
    listenState 'id2nick', () ->
      render()
      renderPresence()

    # call immediatly to display self right away, this looks better
    showPresence()
    # render everything the first time
    render()
    renderPresence()

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

    # this will trigger rendering aswell
    channel.emit "chat", {msg, nick}

chatmodule.stop = ->
  # TODO: teardown channel
  sysmsg "Disconnected from #{channel.id}"
  channel = null
  present = {}
  chatInput.disabled = true

chatmodule.nick = (_nick) ->
  window.localStorage.setItem 'chat.nick', _nick
  id2nick[us] = _nick
  nick = _nick

  saveState 'id2nick', id2nick

chatmodule.getPresent = ->
  present

module.exports = chatmodule
