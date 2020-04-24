import asyncnet, asyncdispatch, strutils
import logger, config, tick, input

const
  saveFile = "server.json"

info("Starting server!")

loadConfig(saveFile)

startInputThread()

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
    await client.send("")
    echo "client joined from: ", client.getPeerAddr()[0]

    asyncCheck process(client)

asyncCheck serve()
runForever()

startTicking()