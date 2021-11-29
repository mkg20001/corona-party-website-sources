# API

- `channel(channelId: String)`: Subscribes to given channel and returns object with following properties
  - `.handle(type: String, handler: Function)`: Handle event with type using provided function
    - Function gets called with `(sender: PeerId, value: Object)`
  - `.emit(type: String, value: Object, echoSelf = true: Boolean)`
    - `echoSelf`: Emit this event locally aswell
