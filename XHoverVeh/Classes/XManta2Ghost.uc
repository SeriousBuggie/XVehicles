//=============================================================================
// XManta2Ghost.
//=============================================================================
class XManta2Ghost expands Mutator config(XVehicles);

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
	local MantaFactory MantaFact;
	local GhostFactory GhostFact;
	
	foreach AllActors(class'MantaFactory', MantaFact)
		MantaFact.VehicleClass = Class'GhostFactory'.default.VehicleClass;
		
	foreach AllActors(class'GhostFactory', GhostFact)
		GhostFact.VehicleClass = Class'MantaFactory'.default.VehicleClass;
}

defaultproperties
{
	Probality=0.500000
	RemoteRole=ROLE_None
}
