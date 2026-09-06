//=============================================================================
// XFix.
//=============================================================================
class XFix expands Info;

function PreBeginPlay() {
	Destroy();
	if (int(Level.EngineVersion) < 469) {
		RelinkNavigationPointList();
	}
}

function RelinkNavigationPointList() {
	local NavigationPoint NP;
	Level.NavigationPointList = None;
	foreach AllActors(Class'NavigationPoint', NP) {
		NP.nextNavigationPoint = Level.NavigationPointList;
		Level.NavigationPointList = NP;
	}
}

defaultproperties
{
}
