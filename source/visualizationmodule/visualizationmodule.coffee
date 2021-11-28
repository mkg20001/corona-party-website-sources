visualizationmodule = {name: "visualizationmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["visualizationmodule"]?  then console.log "[visualizationmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
analyser = null
ctx = null

maxFreq = 24000
WIDTH = 2048
HEIGHT = 600


halfX = WIDTH / 2
barWidth = null
mirroredBarWidth = null
byteFreqRange = null

bufferLength = null
timeDomainArray = null
frequencyArray = null
maximaArray = null

############################################################
visualizationmodule.initialize = ->
    log "visualizationmodule.initialize"
    analyser = allModules.audioanalysermodule

    ctx = visualsCanvas.getContext("2d")
    visualsCanvas.width = WIDTH
    visualsCanvas.height = HEIGHT

    return
    

############################################################
visualizationUpdate = ->
    requestAnimationFrame(visualizationUpdate)
    analyser.fillTimeDomainData(timeDomainArray)
    analyser.fillFrequencyData(frequencyArray)


    ctx.clearRect(0, 0, WIDTH, HEIGHT)

    drawCenteredLine(timeDomainArray)

    drawBarChart(frequencyArray)
    # drawSoundColoredRect(frequencyArray)
    # drawMirroredBarChart(frequencyArray)
    return


############################################################
drawCenteredLine = (data) ->
    ctx.lineWidth = 2
    ctx.strokeStyle = 'rgb(0, 0, 0)'

    ctx.beginPath()
    sliceWidth = WIDTH * 1.0 / bufferLength
    
    x = 0
    i = 0 

    while(i++ < bufferLength)
        v = data[i] / 128.0
        y = v * HEIGHT / 2

        if(i == 0) then ctx.moveTo(x, y)
        else ctx.lineTo(x, y)

        x += sliceWidth

    ctx.lineTo(visualsCanvas.width, visualsCanvas.height / 2)
    ctx.stroke()
    return

############################################################
drawBarChart = (data) ->
    x = 0;
    i = 0 

    while(i++ < bufferLength)
        barHeight = data[i];

        ctx.fillStyle = 'rgb(' + (barHeight+100) + ',50,50)';
        ctx.fillRect(x,HEIGHT-barHeight/2,barWidth,barHeight/2);

        x += barWidth + 1;
    return

drawMirroredBarChart = (data) ->
    x = 0;
    i = 0 

    while(i++ < bufferLength)
        barHeight = data[i];

        ctx.fillStyle = 'rgb(' + (barHeight+100) + ',50,50)';
        
        ctx.fillRect(
            halfX - x,
            HEIGHT-barHeight/2,
            mirroredBarWidth,
            barHeight/2
        );
        
        ctx.fillRect(
            halfX + x,
            HEIGHT-barHeight/2,
            mirroredBarWidth,
            barHeight/2
        );

        x += mirroredBarWidth + 1;
    return

############################################################
drawSoundColoredRect = (data) ->
    loudness = 0
    
    r = 0
    g = 0
    b = 0
    a = 1

    i = 0
    mi = 0

    ctx.fillStyle = 'rgb(0,0,0)';
    x = 0
    while(i++ < bufferLength)
        loudness += data[i]
        if (i && data[i-1] < data[i] && data[i+1] < data[i])
            maximaArray[mi++] = i
            ctx.fillRect(
                halfX + x,
                0,
                mirroredBarWidth,
                HEIGHT
            );
            ctx.fillRect(
                halfX - x,
                0,
                mirroredBarWidth,
                HEIGHT
            );

        x += mirroredBarWidth + 1;

    maximaArray[mi] = 0

    ctx.fillStyle = 'rgba('+r+','+g+','+b+','+a+')';
    ctx.fillRect(0,0, WIDTH, HEIGHT);
    return

#endregion


############################################################
visualizationmodule.start = ->
    bufferLength = analyser.getBufferLength()
    timeDomainArray = new Uint8Array(bufferLength)
    frequencyArray = new Uint8Array(bufferLength)
    maximaArray = new Uint16Array(bufferLength)

    visualizationUpdate()
    return

module.exports = visualizationmodule