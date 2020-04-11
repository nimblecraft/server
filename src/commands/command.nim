const 
  prefix* = "/"

type
  CommandCallback* = proc(args: seq[string]){.gcsafe.}

  Command* = ref object
    name*: string
    description*: string
    usage*: string
    callback*: CommandCallback