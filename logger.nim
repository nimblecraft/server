import logging

var
  consoleLogger = newConsoleLogger(fmtStr="[Server at $time][$levelname]: ")
  fileLogger = newFileLogger("log.txt", fmtStr="[Server at $time][$levelname]: ")

proc Info*(str: string) =
  consoleLogger.log(lvlInfo, str)
  fileLogger.log(lvlInfo, str)

proc Warn*(str: string) =
  consoleLogger.log(lvlWarn, str)
  fileLogger.log(lvlWarn, str)

proc Error*(str: string) =
  consoleLogger.log(lvlError, str)
  fileLogger.log(lvlWarn, str)