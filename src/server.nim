import logger, config, tick

const
  saveFile = "server.json"

info("Starting server!")

loadConfig(saveFile)

startTicking()