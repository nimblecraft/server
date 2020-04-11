import strutils
import command
import help, stop

var
  commands*{.threadvar.}: seq[Command]

proc processCommand*(cmd: string, withPrefix=false): bool{.gcsafe.} =
  var args: seq[string]

  if withPrefix:
    if not cmd.startsWith(prefix): return false

    args = cmd.substr(prefix.len).split(" ")
  else:
    args = cmd.split(" ")

  var idx = -1

  for i, cmd in commands:
    if cmd.name == args[0]:
      idx = i

  if idx == -1: return false

  args.delete(0)

  commands[idx].callback(args)

  return true

proc initCommands*(){.gcsafe.} =
  commands.add(Command(name: "help", usage: "help", description: "shows help", callback: helpCallback))
  commands.add(Command(name: "stop", usage: "stop", description: "stops server", callback: stopCallback))