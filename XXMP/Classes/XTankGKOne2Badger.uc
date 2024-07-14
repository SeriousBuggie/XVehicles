//=============================================================================
// XTankGKOne2Badger.
//=============================================================================
class XTankGKOne2Badger expands Mutator config(XVehicles);

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
	local BadgerFactory BadgerFact;
	
	foreach AllActors(class'TankGKOneFactory', TankGKOneFact)
		TankGKOneFact.VehicleClass = Class'BadgerFactory'.default.VehicleClass;
		
	foreach AllActors(class'BadgerFactory', BadgerFact)
		BadgerFact.VehicleClass = Class'TankGKOneFactory'.default.VehicleClass;
}

defaultproperties
{
	Probality=0.500000
}
