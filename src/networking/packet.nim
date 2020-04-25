import asyncnet, asyncdispatch
import connection, packetutils

type
  Packet* = ref object
    length*: seq[byte] # varint
    packetID*: seq[byte] # varint
    data*: seq[byte]

  RawPacket* = ref object
    length*: int32 # not varint, packetID + data
    packetID*: int32 # not varint
    data*: seq[byte]

proc getPacketInBytes*(packet: Packet): seq[byte] =
  result.add(packet.length)
  result.add(packet.packetID)
  result.add(packet.data)

proc sendPacket*(connection: Connection, packet: Packet){.async.} =
  var bytes = getPacketInBytes(packet)
  var socket = connection.socket
  await socket.send(addr bytes, bytes.len)

proc sendPacket*(connection: Connection, packetID: int32, data: seq[byte]){.async.} =
  var packetid = writeVarInt(packetID)
  var length = writeVarInt(cast[int32](packetid.len + data.len))

  var packet = Packet(length: length, packetID: packetID, data: data)
  await sendPacket(connection, packet)