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

proc getPacketInBytes*(packet: Packet): string =
  var bytes: seq[byte]

  bytes.add(packet.length)
  bytes.add(packet.packetID)
  bytes.add(packet.data)

  echo bytes

  result &= bytesToString(packet.length)
  result &= bytesToString(packet.packetID)
  result &= bytesToString(packet.data)

proc sendPacket*(connection: Connection, packet: Packet){.async.} =
  var bytes: string = getPacketInBytes(packet)
  var socket = connection.socket
  await socket.send(bytes)

proc sendPacket*(connection: Connection, packetID: int32, data: seq[byte]){.async.} =
  var packetid = writeVarInt(packetID)
  var length = writeVarInt(cast[int32](packetid.len + data.len))

  var packet = Packet(length: length, packetID: packetID, data: data)
  await sendPacket(connection, packet)