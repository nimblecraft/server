import logger, config, tick, input, cronjob

const
  saveFile = "server.json"

info("Starting server!")

loadConfig(saveFile)

startInputThread()

startTicking()