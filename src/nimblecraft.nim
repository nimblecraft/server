import asyncnet, asyncdispatch, strutils
import logger, config, tick, input, networking/packet, networking/connection, networking/handshake

const
  saveFile = "server.json"

info("Starting server!")

loadConfig(saveFile)

startInputThread()

var connections: seq[Connection]

proc process(client: AsyncSocket){.async.} =
  while true:
    let line = await client.recvLine()
    echo line

proc serve(){.async.} =
  var server = newAsyncSocket()
  server.setSockOpt(OptReuseAddr, true)
  server.bindAddr(Port(25565))
  server.listen()

  while true:
    let client = await server.accept()
    echo "client joined from: ", client.getPeerAddr()[0]
    var connection: Connection = new Connection
    connection.socket = client
    connection.state = ConnectionState.Handshake
    connections.add(connection)

    #sendPacket(connection, 0, )
    discard connection.sendHandshake()

    asyncCheck process(client)

asyncCheck serve()
runForever()

startTicking()