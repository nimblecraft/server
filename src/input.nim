import commands/commandmanager

var
  inputThread: Thread[void]

proc prompt(){.thread.} =
  initCommands()

  var input: string
  while true:
    stdout.write("-> ")
    stdout.flushFile()
    input = stdin.readLine()
    
    if input.len == 0: continue

    discard processCommand(input)

proc startInputThread*() =
  createThread(inputThread, prompt)