pianomodule = {name: "pianomodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["pianomodule"]?  then console.log "[pianomodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

# TODO: to counteract latency include timestamp slightly in the future and have nodes play back the event at an exact timestamp
# that creates delay but also harmony. might also be bad cause not real time and stuff

############################################################
audio = null

# global
devicesPerUser = {}
highestOctave = 12
channel = null

# local
numKeys = 12
octave = 4

############################################################
keyCodeToIndex =
    "192":  0   #^
    "49":   1   #1
    "50":   2   #2
    "51":   3   #3
    "52":   4   #4
    "53":   5   #5
    "54":   6   #6
    "55":   7   #7
    "56":   8   #8
    "57":   9   #9
    "48":   10  #0
    "219":  11  #ß

############################################################
baseFrequencies = [
    16.351,
    17.324,
    18.354,
    19.445,
    20.601,
    21.827,
    23.124,
    24.499,
    25.956,
    27.5,
    29.135,
    30.868
]

############################################################
export initialize = () ->
    log "pianomodule.initialize"
    audio = allModules.audiomodule

    piano.addEventListener("click", startPiano)
    piano.addEventListener("keydown", keyPressed)
    piano.addEventListener("keyup", keyReleased)

    setInterval(cleanup, 1000)

    return

export start = (channelId) ->
    channel = await allModules.eventexchangemodule.channel channelId
    channel.handle "piano", handler

############################################################
createDevices = ->
    device = {
      o: {}
    }

    i = 0
    while(i < highestOctave)
      i2 = 0
      e = []
      device.o[i] = e
      while(i2 < numKeys)
          freq = baseFrequencies[i2]
          freq = freq * Math.pow(2, i)
          e.push(audio.createSineOscillator(freq))
          i2++
      i++

    audio.startAllOscillators()

    device

############################################################
startPiano = ->
    log "startPiano"
    # audio.startAllOscillators()
    return

############################################################
keyPressed = (evt) ->
    index = keyCodeToIndex[evt.keyCode]
    channel.emit "piano", {octave, index, release: false} if index?
    return

############################################################
keyReleased = (evt) ->
    index = keyCodeToIndex[evt.keyCode]
    channel.emit "piano", {octave, index, release: true} if index?
    return

handler = (sender, evt) ->
    id = sender.toB58String()

    if not devicesPerUser[id]
        log "creating device for %s", id
        devicesPerUser[id] = createDevices()

    devicesPerUser[id].lastSeen = Date.now()

    if not devicesPerUser[id].o[evt.octave]
        return

    audio.setGainTo(devicesPerUser[id].o[evt.octave][evt.index], if evt.release then 0.0 else 0.2)

cleanup = () ->
    for id, state of devicesPerUser
      # clear up all old
      if state.lastSeen && Date.now() - state.lastSeen > 30 * 1000
        delete state.lastSeen
        for oct, oscils of state.o
          audio.setGainTo(oscil, 0.0) for oscil in oscils
