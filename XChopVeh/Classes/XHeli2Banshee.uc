//=============================================================================
// XHeli2Banshee.
//=============================================================================
class XHeli2Banshee expands Mutator config(XVehicles);

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
	local BansheeFactory BansheeFact;
	
	foreach AllActors(class'CybotHelicoFactory', HeliFact)
		HeliFact.VehicleClass = Class'BansheeFactory'.default.VehicleClass;
		
	foreach AllActors(class'BansheeFactory', BansheeFact)
		BansheeFact.VehicleClass = Class'CybotHelicoFactory'.default.VehicleClass;
}

defaultproperties
{
	Probality=0.500000
	RemoteRole=ROLE_None
}
