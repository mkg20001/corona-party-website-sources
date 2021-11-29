indexdomconnect = {name: "indexdomconnect"}

############################################################
indexdomconnect.initialize = () ->
    global.piano = document.getElementById("piano")
    global.visualsCanvas = document.getElementById("visuals-canvas")
    global.systemsoundbutton = document.getElementById("systemsoundbutton")
    global.chat = document.getElementById("chat")
    global.chatMessages = document.getElementById("chat-messages")
    global.chatForm = document.getElementById("chat-form")
    global.chatInput = document.getElementById("chat-input")
    global.micbutton = document.getElementById("micbutton")
    global.background = document.getElementById("background")
    return
    
module.exports = indexdomconnect