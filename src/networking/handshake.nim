import asyncnet, asyncdispatch
import connection, packet, packetutils, ../globals

proc sendHandshake*(connection: Connection){.async.} =
  var data: seq[byte]
  data.add(writeVarInt(ProtocolVersion))
  data.add(writeString(HostName))
  data.add(unsShortToBytes(bigEndianUnsignedShort(ServerPort)))
  data.add(writeVarInt(cast[int32](ConnectionState.Login)))

  await connection.sendPacket(0, data)
