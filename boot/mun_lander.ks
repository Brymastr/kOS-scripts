// Landing Burn

// Configuration
set radarOffset to 4.26493.                                     // Measure "alt:radar" of the vehicle when landed

set a to 30000.
wait until alt:radar > a.
print "Liftoff success. Sleeping until " + a + "m above Mun surface".
wait until alt:radar < a.


// Physics
lock trueRadar to alt:radar - radarOffset.                      // Distance from the bottom of vehicle to the ground
lock g to constant:g * body:mass / body:radius^2.               // Gravitational acceleration
lock maxDecel to (ship:availablethrust / ship:mass) - g.        // Maximum achievable deceleration of the vehicle
lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).         // Distance to kill all the velocity
lock idealThrottle to stopDist / trueRadar.                     // Hoverslam throttling setting

clearscreen.

wait until ship:verticalspeed < -5.
  print "Preparing for landing burn...".
  print body:name.
  rcs on.
  sas off.
  lock steering to srfretrograde.

wait until trueRadar < stopDist.
  print "Landing burn has begun!".
  lights on.
  lock throttle to idealThrottle.

wait until ship:verticalspeed > -0.01.
  print "Landed!".
  set ship:control:pilotmainthrottle to 0.
  rcs off.
  sas off.
  unlock steering.
  unlock throttle.
