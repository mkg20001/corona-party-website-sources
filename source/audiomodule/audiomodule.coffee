audiomodule = {name: "audiomodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["audiomodule"]?  then console.log "[audiomodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
ctx = null

############################################################
oscillatorsRunning = false
oscillators = []
gains = []
analyser = null

mic = null 
micGain = null
micFilter = null
micConvolver = null

systemSound = null 
systemSoundGain = null
# micFilter = null
# micConvolver = null

############################################################
audiomodule.initialize = ->
    log "audiomodule.initialize"
    ctx = new window.AudioContext()

    return

############################################################
audiomodule.createSineOscillator = (freq) ->
    log "audiomodule.createSineOscillator"
    osc = ctx.createOscillator()
    # osc.type = "sawtooth"13
    #Type: "sine"(default), "square", "sawtooth", "triangle" and "custom"
    g = ctx.createGain()
    g.gain.setValueAtTime(0, ctx.currentTime)

    osc.frequency.value = freq
    
    osc.connect(g)
    g.connect(ctx.destination)
    # osc.start()

    i = oscillators.push(osc)
    j = gains.push(g)
    throw new Error("Inconsistent Array lengths for oscillators and gains") unless i == j
    return i

############################################################
audiomodule.startAllOscillators = ->
    return if oscillatorsRunning
    osc.start() for osc in oscillators
    oscillatorsRunning = true
    return

############################################################
audiomodule.setGainTo = (index, volume) ->
    g = gains[index]
    throw new Error("No gain found for index: " + index) unless g?    
    g.gain.setValueAtTime(volume, ctx.currentTime)
    
    # g.gain.exponentialRampToValueAtTime(0.1, ctx.currentTime)
    # g.gain.setValueAtTime(0.2, ctx.currentTime)
    # g.gain.exponentialRampToValueAtTime(0.0000001, ctx.currentTime+0.2)
    # g.gain.setValueAtTime(0.0, ctx.currentTime+0.2)

    return

############################################################
audiomodule.createAnalyzer = (fftSize) ->
    analyser = ctx.createAnalyser()
    analyser.fftSize = fftSize
    gain.connect(analyser) for gain in gains
    return analyser

############################################################
audiomodule.createMic = ->
    log "audimodule.createMic"

    micGain = ctx.createGain()
    micFilter = ctx.createBiquadFilter()
    micConvolver = ctx.createConvolver()

    constraints = {audio: true}
    try
        stream = await navigator.mediaDevices.getUserMedia(constraints)
        mic = ctx.createMediaStreamSource(stream)
        mic.connect(micFilter)
        micFilter.connect(micGain)
        micConvolver.connect(micGain)
        micGain.connect(analyser)
    catch err
        log('Error on getUserMedia: ' + err)
    return

############################################################
audiomodule.destroyMic = ->
    log "audiomodule.destroyMic"
    log "Not Implemented yet!"
    return
    
############################################################
audiomodule.createSystemSound = ->
    log "audiomodule.createSystemSound"

    systemSoundGain = ctx.createGain()
    
    constraintsMoz = {
        audio: {
           mediaSource: 'audioCapture'
        }
    }
    constraintsChrome = {
        audio: {
            mandatory: {
                chromeMediaSource: 'system',
            }        
        }
    }

    try
        if navigator.mozGetUserMedia?
            stream = await navigator.mozGetUserMedia(constraints)
        else if chrome?
            streamId = await chrome.desktopCapture.chooseDesktopMedia(['screen', 'window'])
            constraintsChrome.audio.chromeMediaSourceId = streamId
            stream = await navigator.webkitGetUserMedia(constraintsChrome)
        else
            throw new Error("Neither Firefox nor Chrome Environment detected!")

        systemSound = ctx.createMediaStreamSource(stream)
        systemSound.connect(systemSoundGain)
        systemSoundGain.connect(analyser)

    catch err
        log('Error on getUserMedia: ' + err)
    return

############################################################
audiomodule.destroySystemSound = ->
    log "audiomodule.destroySystemSound"
    log "Not Implemented yet!"
    return

    
module.exports = audiomodule