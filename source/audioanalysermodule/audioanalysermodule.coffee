audioanalysermodule = {name: "audioanalysermodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["audioanalysermodule"]?  then console.log "[audioanalysermodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
audio = null

fftSize = 4096
analyser = null

############################################################
audioanalysermodule.initialize = ->
    log "audioanalysermodule.initialize"
    audio = allModules.audiomodule    
    return


############################################################
audioanalysermodule.start = ->
    log "audioanalysermodule.start"
    analyser = audio.createAnalyzer(fftSize)
    return

############################################################
audioanalysermodule.getBufferLength = -> analyser.frequencyBinCount

audioanalysermodule.fillTimeDomainData = (buffer) -> analyser.getByteTimeDomainData(buffer)

audioanalysermodule.fillFrequencyData = (buffer) -> analyser.getByteFrequencyData(buffer)

############################################################
# audioanalysermodule.getAnalyser = -> analyser


module.exports = audioanalysermodule