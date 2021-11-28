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
    
    # bufferLength = analyser.frequencyBinCount
    # barWidth = (WIDTH / bufferLength) * 2.5
    # mirroredBarWidth = (WIDTH / bufferLength) * 1.25
    
    # byteFreqRange = maxFreq / bufferLength
    # byteFreq = byteFreqRange / 2
    # log byteFreq
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