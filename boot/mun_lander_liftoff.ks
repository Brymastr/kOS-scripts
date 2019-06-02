// 179.651t

lock g to constant:g * body:mass / body:radius^2.
lock realAltitude to alt:radar.
set targetAltitude to 0.
set yaw to 0.
set throt to 0.
lock steer to Up + R(0, yaw * -1, 180).
lock currentStage to stage:number.
lock steering to steer.
lock throttle to throt.

clearscreen.

print "liftoff script v9".

preflight().
liftoff().
burnToApoapsis().
circularize().
spaceMode().
print "complete".
unlock steering.
unlock throttle.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
wait 10.

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
  set targetAltitude to 150000.
  set numStages to currentStage.
  sas off.
  rcs on.

  print "Waiting for manual initiation".
  wait until currentStage = numStages - 1.
  print "Ships computers have taken control".

  countdown().
  set throt to 0.25.
  stage.
}

function liftoff {
  print "Begin stage 1".
  wait until realAltitude > 500.
  set yaw to 3.
  wait 10.
  wait until getFuelRemaining("stage1", "SOLIDFUEL") < 0.5.
  stage.
  print "First stage separation".
}

function burnToApoapsis {
  print "Begin burn to target apoapsis of " + targetAltitude + "m".
  set throt to 0.5.

  wait until realAltitude > 10001.
  print "Begin gravity turn".

  until ship:apoapsis >= targetAltitude - 1000 {
    gravityTurn().
    if currentStage = numStages - 3 {
      set stage2fuel to getFuelRemaining("stage2").
      if stage2fuel < 0.5 {
        stage.
        print "Second stage separation".
        wait 0.5.
        set throt to 1.
      }
    }
  }

  // accel slower to make apoapsis target more accurate
  until ship:apoapsis >= targetAltitude {
    set throt to 0.1.
  }

  // coast to ap
  set throt to 0.
  set yaw to 90.
}

function gravityTurn {
  local startAlt is 10000.
  local endAlt is 70000.
  local startPitch is 3.
  local endPitch is 75.

  local percentOfBurn is (realAltitude - startAlt) / (endAlt - startAlt).
  local desiredPitch is percentOfBurn * (endPitch - startPitch) + startPitch.
  set yaw to desiredPitch.
}

function circularize {
  print "Cicularizing orbit".
  local targetV is sqrt(ship:body:mu/(ship:orbit:body:radius + ship:orbit:apoapsis)). //this is the velocity that we need to be going at AP to be circular
  local apVel is sqrt(((1 - ship:orbit:ECCENTRICITY) * ship:orbit:body:mu) / ((1 + ship:orbit:ECCENTRICITY) * ship:orbit:SEMIMAJORAXIS)). //this is how fast we will be going
  local dv is targetV - apVel. // this is the deltaV
  local burnNode is node(time:seconds + eta:apoapsis, 0, 0, dv).
  add burnNode.
  local burnDuration is calculateBurnDuration(burnNode).
  local np is burnNode:deltav.

  // TODO: face toward node
  wait 3.
  wait until alt:radar > 70000.
  SET WARPMODE TO "RAILS".
  SET WARP TO 2.
  // wait until realAltitude >= targetAltitude - 1000.
  wait until burnNode:eta <= (burnDuration/2 + 20).
  set warp to 0.
  lock steer to np.
  wait until vang(np, ship:facing:vector) < 0.25 and burnNode:eta <= (burnDuration/2).

  executeManeuver(burnNode).
 
  set throt to 0.
  remove burnNode.
  print "Orbit burn complete.".
}

function spaceMode {
  wait 3.
  stage.
  wait 3.
  stage.
  wait 3.
  lights off.
  lights on.
  ag9 on.
  ag10 on.
}

function getFuelRemaining {
  parameter partName, fuelType is "LIQUIDFUEL".
  local part is ship:partsdubbed(partName)[0].
  local remainingFuel is -1.
  for resource in part:resources {
    if resource:name = fuelType {
      set remainingFuel to resource.
      break.
    }
  }
  return remainingFuel:amount.
}

function calculateBurnDuration {
  parameter nd.

  print "Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).
  local max_acc is ship:maxthrust/ship:mass.
  local burnDuration is nd:deltav:mag/max_acc.
  print "Crude Estimated burn duration: " + round(burnDuration) + "s".
  return burnDuration.
}

function executeManeuver {
  parameter nd.

  print "Executing maneuver".

  local done is False.
  //initial deltav
  local dv0 is nd:deltav.
  until done
  {
    //recalculate current max_acceleration, as it changes while we burn through fuel
    local maxAcc is ship:maxthrust/ship:mass.

    //throttle is 100% until there is less than 1 second of time left to burn
    //when there is less than 1 second - decrease the throttle linearly
    set throt to min(nd:deltav:mag/maxAcc, 1).

    //here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions
    //this check is done via checking the dot product of those 2 vectors
    if vdot(dv0, nd:deltav) < 0
    {
        print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        set throt to 0.
        break.
    }

    //we have very little left to burn, less then 0.1m/s
    if nd:deltav:mag < 0.1
    {
        print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        //we burn slowly until our node vector starts to drift significantly from initial vector
        //this usually means we are on point
        wait until vdot(dv0, nd:deltav) < 0.5.

        set throt to 0.
        print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        set done to True.
    }
  }
}