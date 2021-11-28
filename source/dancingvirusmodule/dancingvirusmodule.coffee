dancingvirusmodule = {name: "dancingvirusmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["dancingvirusmodule"]?  then console.log "[dancingvirusmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
dancingvirusmodule.initialize = () ->
    log "dancingvirusmodule.initialize"
    return
    
module.exports = dancingvirusmodule