eventexchangemodule = {name: "eventexchangemodule"}
############################################################
#region printLogFunctions
log = (arg...) ->
    console.log arg...
    #if allModules.debugmodule.modulesToDebug["eventexchangemodule"]?  then console.log "[eventexchangemodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

channels = {}

PeerId = require('peer-id')
{Buffer} = require('buffer')

Channel = (channelId, node) ->
  handlers = {}

  topic = "#{allModules.configmodule.appId}.#{channelId}"

  await node.pubsub.subscribe topic

  safeHandle = (sender, type, value) ->
    if not handlers[type]
      console.warn "eventexchangemodule.handler received unkown event %s from %s", type, sender
      return

    try
      handlers[type](sender, value)
    catch error
      console.error "eventexchangemodule.handler handler failure for %s from %s: %s", sender, type, error
      return

  handler = (msg) ->
    data = null
    type = null
    value = null
    try
      data = JSON.parse(msg.data.toString())
      type = data.type
      value = data.value
      if typeof type != "string"
        throw new Error "No valid type"
      if typeof value != "object"
        throw new Error "No valid value"
    catch error
      console.error "eventexchangemodule.handler readError %s %s %o", topic, error, data,

    safeHandle(PeerId.createFromB58String(msg.from), type, value)

  node.pubsub.on(topic, handler)

  return {
    # echoSelf -> whether we get our own events
    emit: (type, value, echoSelf = true) ->
      if echoSelf
        safeHandle(node.peerId, type, value)

      node.pubsub.publish topic, new TextEncoder().encode(JSON.stringify({type, value}))

    handle: (type, handler) ->
      handlers[type] = handler

    id: channelId
  }

############################################################
eventexchangemodule.initialize = () ->
    log "eventexchangemodule.initialize"
    return

eventexchangemodule.channel = (channelId) ->
  if not channels[channelId]
    channels[channelId] = await Channel(channelId, allModules.peertopeermodule.getNode())

  return channels[channelId]

module.exports = eventexchangemodule
