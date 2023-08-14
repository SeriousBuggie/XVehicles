//=============================================================================
// DefensePointCache.
//=============================================================================
class DefensePointCache expands Info;

var DefensePoint List[2000];
var int Count;

function PreBeginPlay() {
	local DefensePoint DP;
	
	foreach AllActors(class'DefensePoint', DP)
		if (DP.isA('VehicleDefensePoint') && Count < ArrayCount(List))
			List[Count++] = DP;
}

function Update(Bot Bot) {
	local int i;
	local DefensePoint DP;
	
	for (i = 0; i < Count; i++) {
		DP = List[i];
		if (DP == None)
			continue;
		if (VehicleDefensePoint(DP) != None)
			VehicleDefensePoint(DP).PreSelect(Bot);
		else if (DP.isA('VehicleDefensePoint')) { // pre-release version embeded into the map
			DP.Taken = DP.Taken || (Bot != None && DriverWeapon(Bot.Weapon) != None);
			if (DP.Taken)
				DP.priority = 0;
			else if (DP.GetPropertyText("OrigPrio") != "")
				DP.priority = max(10, byte(DP.GetPropertyText("OrigPrio")));
			else
				DP.priority = 10;
		}
	}
}

defaultproperties
{
	RemoteRole=ROLE_None
}
