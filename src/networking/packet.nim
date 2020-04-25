import strutils

#PacketID's
const
  PACKET_HANDSHAKE*   = 0
  PACKET_LOGIN_START* = 0

type
  Packet* = ref object
    length*: seq[byte] # varint
    packetID*: seq[byte] # varint
    data*: seq[byte]

  RawPacket* = ref object
    length*: int # not varint, packetID + data
    packetID*: int # not varint
    data*: seq[byte]

proc printRawPacket*(packet: RawPacket) =
  echo repeat('-', 20)
  
  echo "packet:"
  echo "\tlength: ", packet.length
  echo "\tpacketID: 0x", toHex(packet.packetID)

  stdout.write("\tdata: [")
  
  for idx, b in packet.data:
    stdout.write("0x" & toHex(b))
    if idx != packet.data.len-1:
      stdout.write(", ")

  stdout.write("]\n")

proc packetToBytes*(packet: Packet): seq[byte] =
  result.add(packet.length)
  result.add(packet.packetID)
  result.add(packet.data)