proc sendPacket(socket: ref AsyncSocket, packetID: int, data: seq[Byte]) =
  discard