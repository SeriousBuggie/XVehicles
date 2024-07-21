//=============================================================================
// XTankGKOne2HoverHoverBadger.
//=============================================================================
class XTankGKOne2HoverBadger expands Mutator config(XVehicles);

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
	local HoverBadgerFactory HoverBadgerFact;
	
	foreach AllActors(class'TankGKOneFactory', TankGKOneFact)
		TankGKOneFact.VehicleClass = Class'HoverBadgerFactory'.default.VehicleClass;
		
	foreach AllActors(class'HoverBadgerFactory', HoverBadgerFact)
		HoverBadgerFact.VehicleClass = Class'TankGKOneFactory'.default.VehicleClass;
}

defaultproperties
{
	Probality=0.500000
}
