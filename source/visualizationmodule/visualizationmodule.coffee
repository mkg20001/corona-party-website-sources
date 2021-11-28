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

lastTime = null
objectStorage = []

############################################################
colors = [
    {
        r: 255
        g: 0 
        b: 0
        hex: "#ff0000"
    },
    {
        r: 255
        g: 127
        b: 0
        "#FF7F00"
    },
    {
        r: 255
        g: 255 
        b: 0
        hex: "#FFFF00"
    },
    {
        r: 51
        g: 204
        b: 51
        hex: "#ff0000"
    },
    {
        r: 195
        g: 242 
        b: 255
        hex: "#C3F2FF"
    },
    {
        r: 142
        g: 201 
        b: 255
        hex: "#ff0000"
    },
    {
        r: 127
        g: 139
        b: 253
        hex: "#7F8BFD"
    },
    {
        r: 144
        g: 0 
        b: 255
        hex: "#9000FF"
    },
    {
        r: 187
        g: 117
        b: 252
        hex: "#BB75FC"
    },
    {
        r: 183
        g: 70
        b: 139
        hex: "#B7468B"
    },
    {
        r: 169
        g: 103
        b: 124
        hex: "#A9677C"
    },
    {
        r: 171
        g: 0 
        b: 52
        hex: "#AB0034"
    }
]

############################################################
visualizationmodule.initialize = ->
    log "visualizationmodule.initialize"
    analyser = allModules.audioanalysermodule

    ctx = visualsCanvas.getContext("2d")
    visualsCanvas.width = WIDTH
    visualsCanvas.height = HEIGHT

    return


############################################################
randNum = (min, max) ->
  return Math.random() * (max - min) + min

randHex = ->
  return Math.floor(randNum(0, 256)).toString(16)

randColor = ->
  return '#' + "#{randHex()}#{randHex()}#{randHex()}"

createObjectsMoveObjects = (diff) ->
  objectStorage = objectStorage.filter (d) ->
      return d.y < visualsCanvas.height - d.h

  while objectStorage.length < 100
    w = 10
    h = 10

    objectStorage.push({
      x: randNum(-w, visualsCanvas.width + (w / 2))
      y: randNum(-h, 0)
      s: randNum(0.1, 1),
      w: w
      h: h
      color: randColor()
    })

  for object in objectStorage
      object.y += diff * object.s

drawCoronaThings = (frequencyArray, diff) ->
  createObjectsMoveObjects(diff)

  for object in objectStorage
    ctx.fillStyle = object.color
    ctx.fillRect(object.x, object.y, object.w, object.h)


############################################################
visualizationUpdate = ->
    requestAnimationFrame(visualizationUpdate)

    analyser.fillTimeDomainData(timeDomainArray)
    analyser.fillFrequencyData(frequencyArray)

    ctx.clearRect(0, 0, WIDTH, HEIGHT)

    currentTime = Date.now()
    diff = currentTime - lastTime
    drawCoronaThings(frequencyArray, diff)
    # drawCenteredLine(timeDomainArray)

    # drawBarChart(frequencyArray)
    drawSoundColoredRect(frequencyArray)
    drawMirroredBarChart(frequencyArray)
    
    lastTime = currentTime
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
    x = 0
    i = 0 

    while(i++ < bufferLength)
        barHeight = data[i];

        ctx.fillStyle = 'rgb(' + (barHeight+100) + ',50,50)'
        ctx.fillRect(
            x,
            HEIGHT-barHeight/2,
            barWidth,
            barHeight/2
        )

        x += barWidth + 1
    return

drawMirroredBarChart = (data) ->
    x = 0
    i = 0 

    while(i++ < bufferLength)
        barHeight = data[i]

        ctx.fillStyle = 'rgb(' + (barHeight+100) + ',50,50)'
        
        ctx.fillRect(
            halfX - x,
            HEIGHT-barHeight/2,
            mirroredBarWidth,
            barHeight/2
        )
        
        ctx.fillRect(
            halfX + x,
            HEIGHT-barHeight/2,
            mirroredBarWidth,
            barHeight/2
        )

        x += mirroredBarWidth + 1
    return

############################################################
drawSoundColoredRect = (data) ->
    loudness = 0
    
    r = 0
    g = 0
    b = 0
    a = 0

    i = 0
    mi = 0

    ctx.fillStyle = 'rgb(0,0,0)'
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
            )
            ctx.fillRect(
                halfX - x,
                0,
                mirroredBarWidth,
                HEIGHT
            )

        x += mirroredBarWidth + 1;

    maximaArray[mi] = 0


    ctx.fillStyle = 'rgba('+r+','+g+','+b+','+a+')';
    ctx.fillRect(0,0, WIDTH, HEIGHT);
    return

#endregion


############################################################
visualizationmodule.start = ->
    bufferLength = analyser.getBufferLength()

    barWidth = (WIDTH / bufferLength) * 2.5
    mirroredBarWidth = (WIDTH / bufferLength) * 1.25
    
    byteFreqRange = maxFreq / bufferLength
    byteFreq = byteFreqRange / 2
    log byteFreqRange
    log byteFreq

    timeDomainArray = new Uint8Array(bufferLength)
    frequencyArray = new Uint8Array(bufferLength)
    maximaArray = new Uint16Array(bufferLength)

    lastTime = Date.now()

    visualizationUpdate()
    return

module.exports = visualizationmodule