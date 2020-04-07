import json, logger

var node: JsonNode

proc LoadConfig*(config: string) =
    try:
        node = parseFile(config)
    except:
        error("failed to read config file")
        quit(-1)

proc GetValue(key: string): JsonNode =
    try:
        return node[key]
    except:
        error("failed to get value for key: " & key)
        quit(-1)

proc GetBoolValue*(key: string): bool =
    return GetValue(key).getBool()

proc GetStringValue*(key: string): string =
    return GetValue(key).getStr()

proc GetIntValue*(key: string): int =
    return GetValue(key).getInt()