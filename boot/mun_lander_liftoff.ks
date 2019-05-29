
lock g to constant:g * body:mass / body:radius^2.
sas off.
rcs on.

print "Liftoff in 5".
wait 1.
print "4".
wait 1.
print "3".
wait 1.
print "2".
wait 1.
print "1".
wait 1.
print "Liftoff".

set pitch to 0.
set steer to Up + R(pitch, 0, 180).
set throt to 0.4.
lock steering to steer.
lock throttle to throt.

stage.

wait until stage:solidfuel < 1.
  stage.
  print "First stage separation".

set stage2 to ship:partsdubbed("stage2")[0].
for res IN stage2:resources {
  IF res:name = "LIQUIDFUEL" {
    SET stage2fuel to res.
    BREAK.
  }
}

wait until stage2fuel:amount < 1.
  stage.
  print "Second stage separation".

until ship:dynamicpressure <= 0 or pitch >= 90 {
  set pitch to pitch + 1.
  set steer to Up + R(pitch, 0, 180).
  wait 1.
  print "Pitching to " + pitch. 
}

set steer to Up + R(90, 0, 180).
print "Finalizing pitch to " + 90.

wait until alt:radar > 200000.