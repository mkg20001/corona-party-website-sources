import Modules from "./allmodules"
import domconnect from "./indexdomconnect"
domconnect.initialize()

global.allModules = Modules


timeMS = 1000
classIndex = -1

classes = [
    "muladhara",
    "svadhistana",
    "manipura",
    "anahata",
    "vissudha",
    "ajna",
    "sahasrara"
]

changeBackround = ->
    if classIndex >= 0 then document.body.classList.remove(classes[classIndex])
    
    classIndex  = (classIndex + 1) % classes.length
    document.body.classList.add(classes[classIndex])
    return


############################################################
appStartup = ->
    setInterval(changeBackround, timeMS)
    Modules.audioanalysermodule.visualize()
    return

############################################################
run = ->
    promises = (m.initialize() for n,m of Modules when m.initialize?) 
    await Promise.all(promises)
    appStartup()

############################################################
run()