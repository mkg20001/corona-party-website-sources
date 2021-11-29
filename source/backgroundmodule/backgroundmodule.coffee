backgroundmodule = {name: "backgroundmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["backgroundmodule"]?  then console.log "[backgroundmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
timeMS = 700
classIndex = -1

############################################################
classes = [
    "muladhara",
    "svadhistana",
    "manipura",
    "anahata",
    "vissudha",
    "ajna",
    "sahasrara"
]

############################################################
backgroundmodule.initialize = ->
    log "backgroundmodule.initialize"
    setInterval(changeBackround, timeMS)
    return
    
############################################################
changeBackround = ->
    if classIndex >= 0 then background.classList.remove(classes[classIndex])

    classIndex  = (classIndex + 1) % classes.length
    background.classList.add(classes[classIndex])
    return


module.exports = backgroundmodule