const
  Second* = 20
  Minute* = Second * 60
  Hour*   = Minute * 60
  Day*    = Hour * 24
  Week*   = Day * 7

type
  CronjobCallback = proc(): void

  Cronjob* = object
    callback*: CronjobCallback
    tickDelay*: int
    tickLeft*: int

var
  cronjobs*: seq[Cronjob]

proc addCronjob*(callback: CronjobCallback, tickDelay: int) =
  cronjobs.add(Cronjob(callback: callback, tickDelay: tickDelay, tickLeft: tickDelay))