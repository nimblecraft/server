import asyncnet, asyncdispatch, strutils, rsa
import logger, config, tick, input, networking/packethandler, networking/connection

const
  saveFile = "server.json"

info("Starting server!")

loadConfig(saveFile)

startInputThread()

var connections: seq[Connection]

proc process(connection: Connection){.async.} =
  while true:
    let disconnected = await readPacket(connection)
    #TODO: Remove connection from connections
    if disconnected: 
      echo "disconnect"
      return

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

    asyncCheck process(connection)

asyncCheck serve()
runForever()

startTicking()