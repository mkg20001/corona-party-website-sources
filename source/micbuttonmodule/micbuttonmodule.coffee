micbuttonmodule = {name: "micbuttonmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["micbuttonmodule"]?  then console.log "[micbuttonmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
audio = null
micOn = false

############################################################
micbuttonmodule.initialize = () ->
    log "micbuttonmodule.initialize"
    audio = allModules.audimodule
    micbutton.addEventListener("click", micButtonClicked)
    return

############################################################
micButtonClicked = ->
    log "micButtonClicked" 
    if micOn
        micbutton.classList.remove("on")
        audio.destroyMic()
        micOn = false
    else
        micbutton.classList.add("on")
        audio.createMic()
        micOn = true
    return

module.exports = micbuttonmodule