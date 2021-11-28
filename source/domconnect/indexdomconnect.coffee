indexdomconnect = {name: "indexdomconnect"}

############################################################
indexdomconnect.initialize = () ->
    global.piano = document.getElementById("piano")
    global.visualsCanvas = document.getElementById("visuals-canvas")
    global.chatForm = document.getElementById("chat-form")
    global.chatInput = document.getElementById("chat-input")
    global.systemsoundbutton = document.getElementById("systemsoundbutton")
    global.micbutton = document.getElementById("micbutton")
    return

module.exports = indexdomconnect
