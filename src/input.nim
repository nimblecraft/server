var
  inputThread: Thread[void]

proc prompt(){.thread.} =
  var input: string
  while true:
    stdout.write("-> ")
    stdout.flushFile()
    input = stdin.readLine()
    
    if input.len == 0: continue



proc startInputThread*() =
  createThread(inputThread, prompt)