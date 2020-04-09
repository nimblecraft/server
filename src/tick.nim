import times, os
import cronjob

const 
  ticksPerSecond = 20
  ms = 1_000 / ticksPerSecond

proc getMilliseconds(): float64 = 
  return epochTime() * 1_000

proc tick() =
  for i in 0..cronjobs.len - 1:
    dec cronjobs[i].tickLeft
    if cronjobs[i].tickLeft <= 0:
      cronjobs[i].callback()
      cronjobs[i].tickLeft = cronjobs[i].tickDelay

proc startTicking*() =
  var 
    last: float64 = getMilliseconds()

  while true:
    if getMilliseconds() - last >= ms:
      tick()
      last = getMilliseconds()

    sleep(1)