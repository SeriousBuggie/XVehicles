//=============================================================================
// VehicleDefensePoint.
//=============================================================================
class VehicleDefensePoint expands DefensePoint;

var byte OrigPrio;

function PostBeginPlay() {
	SetTimer(1.0, true);
	if (priority == 0)
		priority = 10;
	OrigPrio = priority;
}

function Timer() {
	local Vehicle V;
	
	foreach RadiusActors(class'Vehicle', V, 100)
		if (V.Driver == None && (!V.bTeamLocked || V.CurrentTeam == Team) && !V.HealthTooLowFor(None))
			break;
		
	SetTaken(V == None);
}

function SetTaken(bool InTaken) {
	Taken = InTaken;
	if (Taken)
		priority = 0;
	else
		priority = OrigPrio;
}

function PreSelect(Pawn Seeker) {
	SetTaken(Taken || (Seeker != None && DriverWeapon(Seeker.Weapon) != None));
}

event Actor SpecialHandling(Pawn Other) {
	local Bot Bot;
	Bot = Bot(Other);
	if (Bot != None && DriverWeapon(Bot.Weapon) != None) {
		// Bot.AmbushSpot = None; // can make warning via Access to None in Bot.FindAmbushSpot
		return None;
	}
	return self;
}

event int SpecialCost(Pawn Seeker)
{
	if (Seeker != None && DriverWeapon(Seeker.Weapon) != None)
		return 100000000;
		
	return ExtraCost;
}

defaultproperties
{
	bSpecialCost=True
	bStatic=False
	bNoDelete=True
	RemoteRole=ROLE_None
}
