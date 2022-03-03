//=============================================================================
// FixScorch.
//=============================================================================
class FixScorch expands BoltScorch;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(10.0, false);
}

defaultproperties
{
}
