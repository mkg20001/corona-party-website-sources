authoritysymbolmodule = {name: "authoritysymbolmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["authoritysymbolmodule"]?  then console.log "[authoritysymbolmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
authoritysymbolmodule.initialize = () ->
    log "authoritysymbolmodule.initialize"
    return
    
module.exports = authoritysymbolmodule