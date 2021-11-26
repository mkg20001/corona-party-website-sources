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
ctx = null
analyser = null

fftSize = 512
WIDTH = 1024
HEIGHT = 600

bufferLength = null
dataArray = null

canvasCtx = null

############################################################
audioanalysermodule.initialize = ->
    log "audioanalysermodule.initialize"
    
    ctx = new window.AudioContext()

    analyser = ctx.createAnalyser()
    analyser.fftSize = fftSize
    distortion = ctx.createWaveShaper();
    gainNode = ctx.createGain();
    biquadFilter = ctx.createBiquadFilter();
    convolver = ctx.createConvolver();
    
    
    bufferLength = analyser.frequencyBinCount
    dataArray = new Uint8Array(bufferLength)
    canvasCtx = visualsCanvas.getContext("2d")
    visualsCanvas.width = WIDTH
    visualsCanvas.height = HEIGHT

    if (navigator.mediaDevices.getUserMedia)
        constraints = {audio: true}
        try
            stream = await navigator.mediaDevices.getUserMedia(constraints)
            source = ctx.createMediaStreamSource(stream)
            source.connect(gainNode)
            convolver.connect(gainNode)
            gainNode.connect(analyser)
            # analyser.connect(ctx.destination)

            # visualize();
            # voiceChange();
        catch err
            log('The following gUM error occured: ' + err)
    else
        log('getUserMedia not supported on your browser!')
    return


############################################################
audioanalysermodule.visualize = ->
    requestAnimationFrame(audioanalysermodule.visualize)
    # drawVisual = requestAnimationFrame(audioanalysermodule.visualize)
    # analyser.getByteTimeDomainData(dataArray)
    analyser.getByteFrequencyData(dataArray)

    # canvasCtx.fillStyle = 'rgba(200, 200, 200, 0)'
    # canvasCtx.fillRect(0, 0, WIDTH, HEIGHT)
    canvasCtx.clearRect(0, 0, WIDTH, HEIGHT)
    canvasCtx.lineWidth = 2
    canvasCtx.strokeStyle = 'rgb(0, 0, 0)'

    canvasCtx.beginPath()
    sliceWidth = WIDTH * 1.0 / bufferLength
    
    x = 0
    i = 0 

    while(i++ < bufferLength)
        v = dataArray[i] / 128.0
        y = v * HEIGHT / 2

        if(i == 0) then canvasCtx.moveTo(x, y)
        else canvasCtx.lineTo(x, y)

        x += sliceWidth

    canvasCtx.lineTo(visualsCanvas.width, visualsCanvas.height / 2)
    canvasCtx.stroke()

module.exports = audioanalysermodule