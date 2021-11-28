startupmodule = {name: "startupmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["startupmodule"]?  then console.log "[startupmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
timeMS = 1000
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
changeBackround = ->
    if classIndex >= 0 then document.body.classList.remove(classes[classIndex])
    
    classIndex  = (classIndex + 1) % classes.length
    document.body.classList.add(classes[classIndex])
    return

############################################################
startupmodule.initialize = ->
    log "startupmodule.initialize"
    return

startupmodule.startUp = ->
    setInterval(changeBackround, timeMS)
    allModules.audioanalysermodule.start()
    # analyser = allModules.audioanalysermodule.getAnalyser()
    # allModules.pianomodule.connect(analyser)
    allModules.visualizationmodule.start()

    return

    
module.exports = startupmodule