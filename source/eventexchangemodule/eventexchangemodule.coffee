eventexchangemodule = {name: "eventexchangemodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["eventexchangemodule"]?  then console.log "[eventexchangemodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

channels = {}

Channel = (channelId, node) ->
  handlers = {}

  topic = "#{allModules.configmodule.appId}.#{channelId}"

  await node.pubsub.subscribe topic

  safeHandle = (sender, type, value) ->
    if not handlers[type]
      log "eventexchangemodule.handler recieved unkown event %s from %s", sender, type
      return

    try
      handlers[type](sender, value)
    catch error
      console.error error
      log "eventexchangemodule.handler handler failure for %s from %s: %s", sender, type, error
      return

  handler = (msg) ->
    data = null
    type = null
    value = null
    try
      data = JSON.parse(msg.data.toString())
      topic = data.type
      value = data.value
      if typeof topic != "string"
        throw new Error "No valid type"
      if typeof value != "object"
        throw new Error "No valid value"
    catch error
      log "eventexchangemodule.handler readError %s %o", topic, data

    safeHandle(msg.sender, topic, value)

  node.pubsub.on(topic, handler)

  return {
    # echoSelf -> whether we get our own events
    emit: (type, value, echoSelf = true) ->
      if echoSelf
        safeHandle(node.peerId, type, value)

    handle: (type, handler) ->
      handlers[type] = handler
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
