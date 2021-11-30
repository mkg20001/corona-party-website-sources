indexdomconnect = {name: "indexdomconnect"}

############################################################
indexdomconnect.initialize = () ->
    global.qrdisplayBackground = document.getElementById("qrdisplay-background")
    global.qrdisplayContent = document.getElementById("qrdisplay-content")
    global.qrdisplayQr = document.getElementById("qrdisplay-qr")
    global.messagebox = document.getElementById("messagebox")
    global.piano = document.getElementById("piano")
    global.visualsCanvas = document.getElementById("visuals-canvas")
    global.chat = document.getElementById("chat")
    global.chatMessages = document.getElementById("chat-messages")
    global.chatForm = document.getElementById("chat-form")
    global.chatInput = document.getElementById("chat-input")
    global.background = document.getElementById("background")
    return
    
module.exports = indexdomconnect