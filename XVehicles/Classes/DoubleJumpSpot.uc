//=============================================================================
// DoubleJumpSpot. Not use it. Use directly XPaths.DoubleJumpSpot. Left only for compatibility.
//=============================================================================
class DoubleJumpSpot expands XPaths.DoubleJumpSpot;

event int SpecialCost(Pawn Seeker)
{		
	return Super.SpecialCost(Seeker);
}

defaultproperties
{
}
