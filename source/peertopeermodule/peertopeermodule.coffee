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

if (require './debugmodule').modulesToDebug["peertopeermodule"]
  require('debug').save('*')
else
  require('debug').save('')

############################################################

Libp2p = require('libp2p')
WStar = require('libp2p-webrtc-star')
WebSockets = require('libp2p-websockets')
{ NOISE } = require('libp2p-noise')
MPLEX = require('libp2p-mplex')
PeerId = require('peer-id')
Bootstrap = require('libp2p-bootstrap')
FloodSub = require('libp2p-floodsub')
GossipSub = require('libp2p-gossipsub')
TransportManager = require('libp2p/src/transport-manager')

{ Buffer } = require('buffer')

############################################################
node = null

setText = (id, val) ->
  # safety first
  tnode = document.createTextNode(val)
  elem = document.getElementById('p2p-' + id)
  elem.innerHTML = ''
  elem.appendChild tnode
  return

renderPeers = ->
  elem = document.getElementById 'p2p-peers'
  elem.innerHTML = ''

  node.connectionManager.connections.forEach (conns, id) ->
    conns.forEach (conn) ->
      p = document.createElement 'p'
      p.appendChild (
        document.createTextNode conn.remoteAddr.toString()
      )

      elem.appendChild p

############################################################
export initialize = ->
    log "peertopeermodule.initialize"

    peerIdStorage = localStorage.getItem('libp2pPeerId')

    if not peerIdStorage
      peerId = await PeerId.create()
      peerIdStorage = Buffer.from(peerId.marshal(false)).toString('hex')
      localStorage.setItem('libp2pPeerId', peerIdStorage)
    else
      peerId = await PeerId.createFromProtobuf(Buffer.from(peerIdStorage, 'hex'))

    p2pConfig = allModules.configmodule.p2p || {}

    node = new Libp2p {
      peerId
      modules:
        transport: [WebSockets, WStar]
        connEncryption: [NOISE]
        streamMuxer: [MPLEX]
        pubsub: GossipSub
      addresses:
        listen: p2pConfig.listenAddrs || []
      transportManager:
        faultTolerance: TransportManager.FaultTolerance.NO_FATAL
      config:
        pubsub:
          enabled: true
          emitSelf: false
        peerDiscovery:
          autoDial: true
          "#{Bootstrap.tag}":
            enabled: true
            list: p2pConfig.bootstrapPeers || []
    }

    await node.start()
    # debugging and stuff
    window.p2p = node

    node.connectionManager.on 'peer:disconnect', renderPeers
    node.connectionManager.on 'peer:connect', renderPeers

    setText('myid', peerId.toB58String())

    return

export getNode = ->
  if !node
    # TODO: return promise that will resolve to node
    throw new Error('Couldnt get node, not initialized yet')

  return node
