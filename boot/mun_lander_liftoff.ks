copyPath("0:/test", "").

lock g to constant:g * body:mass / body:radius^2.
lock realAltitude to alt:radar.
set targetApoapsis to 0.
set targetPeriapsis to 0.
set yaw to 0.
set throt to 0.
lock steer to Up + R(0, yaw * -1, 180).
lock currentStage to stage:number.
lock steering to steer.
lock throttle to throt.

clearscreen.

print "liftoff script v8".

preflight().
liftoff().
burnToApoapsis().
print "complete".
wait 60.

function countdown {
  print "Begin countdown".
  print "Liftoff in 5".
  wait 0.8.
  print "4".
  wait 0.8.
  print "3".
  wait 0.8.
  print "2".
  wait 0.8.
  print "1".
  wait 1.
  print "Liftoff".
}

function preflight {
  set targetApoapsis to 200000.
  set targetPeriapsis to 200000.
  sas off.
  rcs on.

  print "Waiting for manual initiation".
  wait until currentStage = 8.
  print "Ships computers have taken control".

  countdown().
  set throt to 0.35.
  stage.
}

function liftoff {
  print "Begin stage 1".
  wait until realAltitude > 500.
  set yaw to 3.
  wait 10.
  print steer + " " + steering.
  wait until stage:solidfuel < 0.5.
  stage.
  print "First stage separation".
}

function burnToApoapsis {
  print "Begin burn to target apoapsis of " + targetApoapsis + "m".
  set throt to 0.45.

  wait until realAltitude > 15001.
  print "Begin gravity turn".

  until ship:apoapsis >= targetApoapsis - 300 {
    gravityTurn().
    if currentStage = 6 {
      set stage2fuel to getLiquidFuelRemaining("stage2").
      if stage2fuel:amount < 0.5 {
        stage.
        print "Second stage separation".
        wait 0.5.
        set throt to 0.75.
      }
    }
  }

  // accel slower to make apoapsis target more accurate
  until ship:apoapsis >= targetApoapsis {
    set throt to 0.1.
  }

  // coast to ap
  set throt to 0.
  set yaw to 90.
}

function gravityTurn {
  local startAlt is 15000.
  local endAlt is 75000.
  local startPitch is 3.
  local endPitch is 75.

  local percentOfBurn is (realAltitude - startAlt) / (endAlt - startAlt).
  local desiredPitch is percentOfBurn * (endPitch - startPitch) + startPitch.
  set yaw to desiredPitch.
}

function circularize {

}

function getLiquidFuelRemaining {
  parameter partName.
  local part is ship:partsdubbed(partName)[0].
  local remainingFuel is -1.
  for resource in part:resources {
    if resource:name = "LIQUIDFUEL" {
      set remainingFuel to resource.
      break.
    }
  }
  return remainingFuel.
}