import asyncnet

type
  ConnectionState* = enum
    Handshake, Status, Login, Play, Closed

  Connection* = ref object
    socket*: AsyncSocket
    state*: ConnectionState
    verifyToken*: seq[byte]