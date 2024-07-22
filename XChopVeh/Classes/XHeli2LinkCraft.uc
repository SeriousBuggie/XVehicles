//=============================================================================
// XHeli2LinkCraft.
//=============================================================================
class XHeli2LinkCraft expands Mutator config(XVehicles);

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
	local CybotHelicoFactory HeliFact;
	local LinkCraftFactory LinkCraftFact;
	
	foreach AllActors(class'CybotHelicoFactory', HeliFact)
		HeliFact.VehicleClass = Class'LinkCraftFactory'.default.VehicleClass;
		
	foreach AllActors(class'LinkCraftFactory', LinkCraftFact)
		LinkCraftFact.VehicleClass = Class'CybotHelicoFactory'.default.VehicleClass;
}

defaultproperties
{
	Probality=0.500000
	RemoteRole=ROLE_None
}
