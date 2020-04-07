import logging

var
  consoleLogger = newConsoleLogger(fmtStr="[Server at $time][$levelname]: ")
  fileLogger = newFileLogger("log.txt", fmtStr="[Server at $time][$levelname]: ")

proc info*(str: string) =
  consoleLogger.log(lvlInfo, str)
  fileLogger.log(lvlInfo, str)

proc warn*(str: string) =
  consoleLogger.log(lvlWarn, str)
  fileLogger.log(lvlWarn, str)

proc error*(str: string) =
  consoleLogger.log(lvlError, str)
  fileLogger.log(lvlError, str)