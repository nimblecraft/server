import asyncnet, asyncdispatch, sequtils
import packet, packetutils, connection

var
  currentDataBuffer: seq[byte]
  currentDataBufferIndex: int

proc sendPacket*(connection: Connection, packet: Packet){.async.} =
  var bytes = packetToBytes(packet)
  var socket = connection.socket
  await socket.send(addr bytes, bytes.len)

proc sendPacket*(connection: Connection, packetID: int32, data: seq[byte]){.async.} =
  var packetid = writeVarInt(packetID)
  var length = writeVarInt(cast[int32](packetid.len + data.len))

  var packet = Packet(length: length, packetID: packetID, data: data)
  await sendPacket(connection, packet)

proc bindDataBuffer(data: seq[byte]) =
  currentDataBuffer = data
  currentDataBufferIndex = 0

proc bytesLeft(): int =
  return currentDataBuffer.len - (currentDataBufferIndex + 1)

proc buffReadVarInt(): int =
  var amountOfBytes = 4
  if bytesLeft() < 4:
    amountOfBytes = bytesLeft()

  let varint = readVarInt(currentDataBuffer[currentDataBufferIndex..currentDataBufferIndex+amountOfBytes])
  currentDataBufferIndex += varint[1]
  return varint[0]

proc buffReadVarLong(): int64 =
  var amountOfBytes = 4
  if bytesLeft() < 4:
    amountOfBytes = bytesLeft()

  let varlong = readVarLong(currentDataBuffer[currentDataBufferIndex..currentDataBufferIndex+amountOfBytes])
  currentDataBufferIndex += varlong[1]
  return varlong[0]

proc buffReadChar(): char =
  result = cast[char](currentDataBuffer[currentDataBufferIndex])
  inc currentDataBufferIndex

proc buffReadString(): string =
  let len = buffReadVarInt()

  for i in 0..len-1:
    result.add(buffReadChar())

# NOTE: shorts are Big Endian
proc buffReadUnsignedShort(): uint16 =
  var bytes = currentDataBuffer[currentDataBufferIndex..currentDataBufferIndex+1]

  result = result or bytes[1]
  result = result or (cast[uint16](bytes[0]) shl 8)

  currentDataBufferIndex += 2

proc handlePacket*(connection: Connection, packet: RawPacket){.async.} =
  bindDataBuffer(packet.data)

  if connection.state == ConnectionState.Handshake:
    if packet.packetID == PACKET_HANDSHAKE:
      let protocol = buffReadVarInt()
      echo "protocol version: ", protocol

      let hostname = buffReadString()
      echo "hostname or ip: ", hostname

      let port = buffReadUnsignedShort()
      echo "port: ", port

      let nextState: ConnectionState = cast[ConnectionState](buffReadVarInt())
      echo "nextState: ", nextState

      connection.state = nextState
  elif connection.state == ConnectionState.Login:
    if packet.packetID == PACKET_LOGIN_START:
      let username = buffReadString()
      echo "username: ", username

proc readPacket*(connection: Connection): Future[bool]{.async.} =
  var packet = new RawPacket

  # Create new seq, length = varint's max length
  var packetLengthBufferArray: array[5, byte]

  let readLen = await connection.socket.recvInto(addr packetLengthBufferArray, packetLengthBufferArray.len)

  # Check if socket is disconnected
  if readLen == 0: return true

  # Copy array into seq
  # TODO: Make overloaded readVarInt with array[byte] parameter
  let packetLengthBuffer = toSeq(packetLengthBufferArray)

  let len = readVarInt(packetLengthBuffer)

  # 2^16, no idea why
  var packetBuffer: array[65536, byte]

  # packet length - (5 - packet length's size)
  var tailLength = len[0] - (5 - len[1])

  let _ = await connection.socket.recvInto(addr packetBuffer, tailLength)

  # Create seq for whole packet
  var buffer: seq[byte]

  # Add packet length + a few bytes(length depends on packet length's size, there's a chance that no bytes are added) of packet
  buffer.add(packetLengthBuffer)

  # Add tail of packet
  buffer.add(packetBuffer[0..tailLength])

  var packetid = readVarInt(buffer[len[1]..5])

  packet.length = len[0]
  packet.packetID = packetid[0]
  packet.data = buffer[len[1] + packetid[1]..buffer.len-packetid[1]-1]

  printRawPacket(packet)
  await handlePacket(connection, packet)

  return false