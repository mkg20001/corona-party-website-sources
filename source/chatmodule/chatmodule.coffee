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

channel = null
chatInput = null
chatForm = null

messages = []

# TODO: append msgs as nodes directly, store nodes in array for poppin

render = ->
  msgsOut = document.getElementById "chat-messages"
  msgsOut.innerHTML = ''

  for msg in messages
    txt = document.createTextNode("<#{msg.sender}> #{msg.msg}")
    p = document.createElement "p"
    p.appendChild txt
    msgsOut.appendChild p

handler = (sender, data) ->
  messages.push {
    sender: sender.toPrint()
    msg: data.msg
  }
  messages = messages.slice 0, 1024
  render()

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

chatmodule.start = (channelId) ->
    channel = await allModules.eventexchangemodule.channel channelId
    channel.handle "chat", handler
    messages.push {
      sender: '#SYSTEM#'
      msg: "Connected via pubsub to #{channelId}"
    }
    chatInput.disabled = false
    render()

chatmodule.chat = (msg) ->
    if not channel
        throw new Error "Not started"

    channel.emit "chat", {msg}

module.exports = chatmodule
