//=============================================================================
// XTankGKOne2Juggernaut.
//=============================================================================
class XTankGKOne2Juggernaut expands Mutator config(XVehicles);

var() config float Probality;

function PreBeginPlay()
{
	local Actor A;
	
	Super.PreBeginPlay();

	foreach AllActors(Class, A)
		break;
	if (A != self)
		return;

	if (FRand() < Probality)
		Swap();
}

function Swap()
{
	local TankGKOneFactory TankGKOneFact;
	local JuggernautFactory JuggernautFact;
	
	foreach AllActors(class'TankGKOneFactory', TankGKOneFact)
		TankGKOneFact.VehicleClass = Class'JuggernautFactory'.default.VehicleClass;
		
	foreach AllActors(class'JuggernautFactory', JuggernautFact)
		JuggernautFact.VehicleClass = Class'TankGKOneFactory'.default.VehicleClass;
}

defaultproperties
{
	Probality=0.500000
	RemoteRole=ROLE_None
}
