indexdomconnect = {name: "indexdomconnect"}

############################################################
indexdomconnect.initialize = () ->
    global.piano = document.getElementById("piano")
    global.visualsCanvas = document.getElementById("visuals-canvas")
    global.micbutton = document.getElementById("micbutton")
    return
    
module.exports = indexdomconnect