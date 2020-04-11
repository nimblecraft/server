import ../terminate

proc stopCallback*(args: seq[string]){.gcsafe.} =
  terminate()