//=============================================================================
// XTankGKOne2TankScorpion.
//=============================================================================
class XTankGKOne2TankScorpion expands Mutator config(XVehicles);

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
	local TankScorpionFactory TankScorpionFact;
	
	foreach AllActors(class'TankGKOneFactory', TankGKOneFact)
		TankGKOneFact.VehicleClass = Class'TankScorpionFactory'.default.VehicleClass;
		
	foreach AllActors(class'TankScorpionFactory', TankScorpionFact)
		TankScorpionFact.VehicleClass = Class'TankGKOneFactory'.default.VehicleClass;
}

defaultproperties
{
	Probality=0.500000
	RemoteRole=ROLE_None
}
