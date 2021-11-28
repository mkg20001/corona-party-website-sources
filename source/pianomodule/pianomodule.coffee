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

############################################################
audio = null

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
pianomodule.initialize = () ->
    log "pianomodule.initialize"
    audio = allModules.audiomodule
    createDevices()

    piano.addEventListener("click", startPiano)
    piano.addEventListener("keydown", keyPressed)
    piano.addEventListener("keyup", keyReleased)
    return

############################################################
createDevices = ->
    i = 0
    while(i < numKeys)
        freq = baseFrequencies[i]
        freq = freq * Math.pow(2, octave)
        j = audio.createSineOscillator(freq)
        i++
        throw new Error("Unexpected Index on Oscillator create for Piano!") unless i == j

    return

############################################################
startPiano = ->
    log "startPiano"
    audio.startAllOscillators()
    return

############################################################
keyPressed = (evt) ->
    index = keyCodeToIndex[evt.keyCode]
    audio.setGainTo(index, 0.2) if index?
    return

############################################################
keyReleased = (evt) ->
    index = keyCodeToIndex[evt.keyCode]    
    audio.setGainTo(index, 0.0) if index?
    return    


module.exports = pianomodule