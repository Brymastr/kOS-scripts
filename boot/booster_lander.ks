// Landing Burn

// Configuration
set radarOffset to 17.4012870788574.                                                                    // Measure "alt:radar" of the vehicle when landed

// Physics
lock trueRadar to alt:radar - radarOffset.                                      // Distance from the bottom of vehicle to the ground
lock g to constant:g * body:mass / body:radius^2.                       // Gravitational acceleration
lock maxDecel to (ship:availablethrust / ship:mass) - g.        // Maximum achievable deceleration of the vehicle
lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).         // Distance to kill all the velocity
lock idealThrottle to stopDist / trueRadar.                                     // Hoverslam throttling setting
lock impactTime to trueRadar / abs(ship:verticalspeed).         // Time to impact with the current velocity

// State variables
set burnStarted to 0.                                     // 1 if landing burn has started

clearscreen.

wait until ship:verticalspeed < -5.
  print "Preparing for landing burn...".
  rcs on.
  brakes on.
  lock steering to srfretrograde.

wait until trueRadar < stopDist.
  print "Landing burn has begun!".
  set burnStarted to 1.
  lock throttle to idealThrottle.

wait until burnStarted = 1.
  until impactTime < 4.
    print "Deploying landing legs...".
    gear on.

wait until ship:verticalspeed > -0.01.
  print "Landed!".
  set ship:control:pilotmainthrottle to 0.
  wait 1.
  rcs off.
  sas off.
  brakes off.