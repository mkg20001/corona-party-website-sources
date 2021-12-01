startupmodule = {name: "startupmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["startupmodule"]?  then console.log "[startupmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
partyId = '123456'

############################################################
startupmodule.initialize = ->
    log "startupmodule.initialize"
    c = allModules.configmodule

    queryString = window.location.search
    urlParams = new URLSearchParams(queryString)
    urlId = urlParams.get("partyId")
    partyId = urlId || c.partyId || partyId

    return


############################################################
startupmodule.startUp = ->
    allModules.audioanalysermodule.start()
    # analyser = allModules.audioanalysermodule.getAnalyser()
    # allModules.pianomodule.connect(analyser)
    allModules.visualizationmodule.start()

    allModules.chatmodule.start partyId
    allModules.pianomodule.start partyId

    return


module.exports = startupmodule
