peertopeermodule = {name: "peertopeermodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["peertopeermodule"]?  then console.log "[peertopeermodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

# NOISE tries to access process.env.DUMP_SESSION_KEYS, just hack it in
if not window.process
  window.process = {
    env: {}
    nextTick: (f, a...) ->
      c = ->
        f(a...)
      setTimeout(c, 1)
  }

#if allModules.debugmodule.modulesToDebug["peertopeermodule"]
#  require('debug').save('*')

require('debug').save('*')

Libp2p = require('libp2p')
WStar = require('libp2p-webrtc-star')
WebSockets = require('libp2p-websockets')
{ NOISE } = require('libp2p-noise')
MPLEX = require('libp2p-mplex')
PeerId = require('peer-id')
Bootstrap = require('libp2p-bootstrap')
FloodSub = require('libp2p-floodsub')
GossipSub = require('libp2p-gossipsub')

node = null

setText = (id, val) ->
  # safety first
  tnode = document.createTextNode(val)
  elem = document.getElementById('p2p-' + id)
  elem.innerHTML = ''
  elem.appendChild tnode

############################################################
peertopeermodule.initialize = () ->
    log "peertopeermodule.initialize"

    peerIdStorage = localStorage.getItem('libp2pPeerId')

    b = require('buffer').Buffer

    if not peerIdStorage
      peerId = await PeerId.create()
      peerIdStorage = b.from(peerId.marshal(false)).toString('hex')
      localStorage.setItem('libp2pPeerId', peerIdStorage)
    else
      peerId = await PeerId.createFromProtobuf(b.from(peerIdStorage, 'hex'))

    node = new Libp2p {
      peerId
      modules:
        transport: [WebSockets, WStar]
        connEncryption: [NOISE]
        streamMuxer: [MPLEX]
        pubsub: GossipSub
      addresses:
        listen: [
          "/dns4/wrtc-star.mkg20001.io/tcp/443/wss/p2p-webrtc-star"
        ]
      config:
        pubsub:
          enabled: true
          emitSelf: false
        peerDiscovery:
          autoDial: true
          "#{Bootstrap.tag}":
            enabled: true
            list: allModules.configmodule.p2pBootstrapPeers || []
    }

    await node.start()

    # debugging and stuff
    window.p2p = node

    #for id in node.connectionManager.connections.keys()
    #  alert id

    setText('myid', peerId.toB58String())

    return

peertopeermodule.getNode = ->
  if !node
    # TODO: return promise that will resolve to node
    throw new Error('Couldnt get node, not initialized yet')

  return node

module.exports = peertopeermodule
