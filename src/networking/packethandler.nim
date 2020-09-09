import asyncnet, asyncdispatch, sequtils
import sysrandom
import packet, packetutils, connection, ../rsa

var
  # Read
  currentDataBuffer: seq[byte]
  currentDataBufferIndex: int
  # Write
  currentPacket: RawPacket

proc sendPacket*(connection: Connection, packet: Packet){.async.} =
  var bytes = packetToBytes(packet)
  var socket = connection.socket
  await socket.send(addr bytes, bytes.len)
  echo "packet sent"

proc sendRawPacket*(connection: Connection, packet: RawPacket){.async.} =
  var p: Packet
  p.packetID = writeVarInt(packet.packetID)
  p.data = packet.data
  p.length = writeVarInt(p.packetID.len + p.data.len)
  #printRawPacket(packet)
  await sendPacket(connection, p)

proc sendCurrentPacket*(connection: Connection){.async.} =
  await sendRawPacket(connection, currentPacket)

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

proc makePacket(packetID: int) =
  currentPacket.packetID = packetID

proc buffWriteVarInt(val: int) =
  currentPacket.data.add(writeVarInt(cast[int32](val)))

proc buffWriteVarLong(val: int64) =
  currentPacket.data.add(writeVarLong(val))

proc buffWriteString(str: string) =
  currentPacket.data.add(writeString(str))

proc buffWriteBytes(bytes: seq[byte]) =
  currentPacket.data.add(bytes)

# NOTE: shorts are Big Endian
proc buffReadUnsignedShort(): uint16 =
  var bytes = currentDataBuffer[currentDataBufferIndex..currentDataBufferIndex+1]

  result = result or bytes[1]
  result = result or (cast[uint16](bytes[0]) shl 8)

  currentDataBufferIndex += 2

# TODO: Better packet system

proc handlePacket*(connection: Connection, packet: RawPacket){.async.} =
  bindDataBuffer(packet.data)

  if connection.state == ConnectionState.Handshake:
    if packet.packetID == PACKET_HANDSHAKE:
      # Parse protocol version
      let protocol = buffReadVarInt()
      echo "protocol version: ", protocol

      # Parse hostname/ip
      let hostname = buffReadString()
      echo "hostname or ip: ", hostname

      # Parse port
      let port = buffReadUnsignedShort()
      echo "port: ", port

      # Parse next state
      let nextState: ConnectionState = cast[ConnectionState](buffReadVarInt())
      echo "nextState: ", nextState

      connection.state = nextState
  elif connection.state == ConnectionState.Login:
    if packet.packetID == PACKET_LOGIN_START:
      let username = buffReadString()
      echo "username: ", username

      # Make packet for requesting encryption key
      makePacket(PACKET_REQUEST_ENCRYPTION)
      
      # Server ID - empty
      buffWriteString("")

      # Write length of public key
      buffWriteVarInt(publicKey.len)

      # Write public key
      buffWriteBytes(publicKey)

      # Generate verify key
      connection.verifyToken = toSeq(getRandomBytes(4))

      # Write length of verify token
      buffWriteVarInt(connection.verifyToken.len)

      # Write verify token
      buffWriteBytes(connection.verifyToken)

      await sendCurrentPacket(connection)

proc readPacket*(connection: Connection): Future[bool]{.async.} =
  var packet: RawPacket

  # Create new seq, length = varint's max length
  var packetLengthBufferArray: array[5, byte]

  let readLen = await connection.socket.recvInto(addr packetLengthBufferArray, packetLengthBufferArray.len)
  echo "packet received"

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

  var bytesRead = await connection.socket.recvInto(addr packetBuffer, tailLength)

  if bytesRead == 0:
    return true
  
  # Create seq for whole packet
  var buffer: seq[byte]

  # Add packet length + a few bytes(length depends on packet length's size, there's a chance that no bytes are added) of packet
  buffer.add(packetLengthBuffer)

  # Add tail of packet
  buffer.add(packetBuffer[0..tailLength])

  var packetid = readVarInt(buffer[len[1]..buffer.len-1])

  packet.length = len[0]
  packet.packetID = packetid[0]
  packet.data = buffer[len[1] + packetid[1]..buffer.len-packetid[1]-1]

  printRawPacket(packet)
  await handlePacket(connection, packet)

  return false