//=============================================================================
// XTankGKOne2Goliath.
//=============================================================================
class XTankGKOne2Goliath expands Mutator config(XVehicles);

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
	local GoliathFactory GoliathFact;
	
	foreach AllActors(class'TankGKOneFactory', TankGKOneFact)
		TankGKOneFact.VehicleClass = Class'GoliathFactory'.default.VehicleClass;
		
	foreach AllActors(class'GoliathFactory', GoliathFact)
		GoliathFact.VehicleClass = Class'TankGKOneFactory'.default.VehicleClass;
}

defaultproperties
{
	Probality=0.500000
	RemoteRole=ROLE_None
}
