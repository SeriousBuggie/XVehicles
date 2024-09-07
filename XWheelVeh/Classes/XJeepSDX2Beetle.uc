//=============================================================================
// XJeepSDX2Beetle.
//=============================================================================
class XJeepSDX2Beetle expands Mutator config(XVehicles);

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
	local JeepSDXFactory JeepSDXFact;
	local BeetleFactory BeetleFact;
	
	foreach AllActors(class'JeepSDXFactory', JeepSDXFact)
		JeepSDXFact.VehicleClass = Class'BeetleFactory'.default.VehicleClass;
		
	foreach AllActors(class'BeetleFactory', BeetleFact)
		BeetleFact.VehicleClass = Class'JeepSDXFactory'.default.VehicleClass;
}

defaultproperties
{
	Probality=0.500000
	RemoteRole=ROLE_None
}
