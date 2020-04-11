import logger, config, tick, input

const
  saveFile = "server.json"

info("Starting server!")

loadConfig(saveFile)

startInputThread()

startTicking()