systemsoundbuttonmodule = {name: "systemsoundbuttonmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["systembuttonmodule"]?  then console.log "[systembuttonmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
audio = null
systemSoundOn = false

############################################################
systemsoundbuttonmodule.initialize = ->
    log "systemsoundbuttonmodule.initialize"
    audio = allModules.audiomodule
    systemsoundbutton.addEventListener("click", systemSoundButtonClicked)
    return
    

############################################################
systemSoundButtonClicked = ->
    if systemSoundOn
        systemsoundbutton.classList.remove("on")
        audio.destroySystemSound()
        systemSoundOn = false
    else
        systemsoundbutton.classList.add("on")
        audio.createSystemSound()
        systemSoundOn = true

    return

module.exports = systemsoundbuttonmodule