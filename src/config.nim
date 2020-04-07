import json, logger

var node: JsonNode

proc loadConfig*(config: string) =
  try:
    node = parseFile(config)
  except:
    error("failed to read config file")
    quit(-1)

proc getValue(key: string): JsonNode =
  try:
    return node[key]
  except:
    error("failed to get value for key: " & key)
    quit(-1)

proc getBoolValue*(key: string): bool =
  return getValue(key).getBool()

proc getStringValue*(key: string): string =
  return getValue(key).getStr()

proc getIntValue*(key: string): int =
  return getValue(key).getInt()