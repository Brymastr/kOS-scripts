set a to 70000.

gravityTurn(a).


function gravityTurn {
  parameter a.
  local startAlt is 15000.
  local endAlt is 75000.
  local startPitch is 3.
  local endPitch is 90.

  local percentOfBurn is (a - startAlt) / (endAlt - startAlt).

  local desiredPitch is percentOfBurn * (endPitch - startPitch) + startPitch.
  print startAlt + " " + endAlt + " " + startPitch + " " + endPitch.
  print a + " " + percentOfBurn + " " + desiredPitch.
}