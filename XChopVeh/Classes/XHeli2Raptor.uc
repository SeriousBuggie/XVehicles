//=============================================================================
// XHeli2Raptor.
//=============================================================================
class XHeli2Raptor expands Mutator config(XVehicles);

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
	local RaptorFactory RaptorFact;
	
	foreach AllActors(class'CybotHelicoFactory', HeliFact)
		HeliFact.VehicleClass = Class'RaptorFactory'.default.VehicleClass;
		
	foreach AllActors(class'RaptorFactory', RaptorFact)
		RaptorFact.VehicleClass = Class'CybotHelicoFactory'.default.VehicleClass;
}

defaultproperties
{
	Probality=0.500000
	RemoteRole=ROLE_None
}
