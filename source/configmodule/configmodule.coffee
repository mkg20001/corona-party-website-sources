configmodule = {name: "configmodule", uimodule: false}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["configmodule"]?  then console.log "[configmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

########################################################
configmodule.initialize = ->
    log "configmodule.initialize"
    return

########################################################
#region exposedProperties
configmodule.prop = true
configmodule.appId = 'corona-party'
configmodule.p2pBootstrapPeers = [
  # libp2p peers to connect to
]

#endregion

export default configmodule
