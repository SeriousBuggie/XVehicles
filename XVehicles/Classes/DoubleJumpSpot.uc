//=============================================================================
// DoubleJumpSpot. Not use it. Use directly XPaths.DoubleJumpSpot. Left only for compatibility.
//=============================================================================
class DoubleJumpSpot expands XPaths.DoubleJumpSpot;

var int Allowed; // not used, left for compat

event int SpecialCost(Pawn Seeker)
{		
	return Super.SpecialCost(Seeker);
}

defaultproperties
{
}
