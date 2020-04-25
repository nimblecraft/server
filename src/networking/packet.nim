import asyncnet, asyncdispatch, sequtils, strutils
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

proc printRawPacket*(packet: RawPacket) =
  echo repeat('-', 20)
  echo "packet:"
  echo "\tlength: ", packet.data.len
  echo "\tpacketID: ", toHex(packet.packetID)
  stdout.write("\tdata: [")
  for idx, b in packet.data:
    stdout.write("0x" & toHex(b))
    if idx != packet.data.len-1:
      stdout.write(", ")

  stdout.write("]\n")


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

proc readPacket*(connection: Connection): Future[bool]{.async.} =
  var packet = new RawPacket

  # Create new seq, length = varint's max length
  var packetLengthBufferArray: array[5, byte]

  # Read packet's length
  let readLen = await connection.socket.recvInto(addr packetLengthBufferArray, packetLengthBufferArray.len)

  # Check if socket is disconnected
  if readLen == 0: return true

  # Copy array into seq
  # TODO: Make overloaded readVarInt with array[byte] parameter
  let packetLengthBuffer = toSeq(packetLengthBufferArray)

  # Read packet length
  let len = readVarInt(packetLengthBuffer)

  # 2^16, no idea why
  var packetBuffer: array[65536, byte]

  # packet length - (5 - packet length's size)
  let tailLength = len[0] - (5 - len[1])

  echo tailLength

  # Read packet
  let _ = await connection.socket.recvInto(addr packetBuffer, tailLength)

  # Create seq for whole packet
  var buffer: seq[byte]

  # Add packet length + a few bytes(length depends on packet length's size, there's a chance that no bytes are added) of packet
  buffer.add(packetLengthBuffer)

  # Add tail of packet
  buffer.add(packetBuffer[0..tailLength])

  echo buffer

  var packetid = readVarInt(buffer[len[1]..5])

  packet.length = len[0]
  packet.packetID = packetid[0]
  packet.data = buffer[len[1] + packetid[1]..buffer.len-packetid[1]]

  printRawPacket(packet)

  return false