import logging

var
  consoleLogger = newConsoleLogger(fmtStr="[Server at $time][$levelname]: ")
  fileLogger = newFileLogger("log.txt", fmtStr="[Server at $time][$levelname]: ")

proc logToConsole(lvl: Level, str: string) =
  consoleLogger.log(lvlInfo, str)
  stdout.flushFile()

proc info*(str: string) =
  logToConsole(lvlInfo, str)
  fileLogger.log(lvlInfo, str)

proc warn*(str: string) =
  logToConsole(lvlWarn, str)
  fileLogger.log(lvlWarn, str)

proc error*(str: string) =
  logToConsole(lvlError, str)
  fileLogger.log(lvlError, str)