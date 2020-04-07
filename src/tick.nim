import times

const 
  ticksPerSecond = 20
  ns = 1_000_000_000 / ticksPerSecond

proc getNanoseconds(): float64 = 
  return epochTime() * 1_000_000_000

proc tick() =
  echo "tick"

proc startTicking*() =
  var 
    delta: float = 0
    now: float64
    last: float64 = getNanoseconds()

  while true:
    delta += (now - last) / ns
    last = now
    now = getNanoseconds()

    if delta >= 1:
      tick()
      delta = 0