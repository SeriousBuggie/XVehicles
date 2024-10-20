//=============================================================================
// XJeepTDX2Hellbender.
//=============================================================================
class XJeepTDX2Hellbender expands Mutator config(XVehicles);

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
	local JeepTDXFactory JeepTDXFact;
	local HellbenderFactory HellbenderFact;
	
	foreach AllActors(class'JeepTDXFactory', JeepTDXFact)
		JeepTDXFact.VehicleClass = Class'HellbenderFactory'.default.VehicleClass;
		
	foreach AllActors(class'HellbenderFactory', HellbenderFact)
		HellbenderFact.VehicleClass = Class'JeepTDXFactory'.default.VehicleClass;
}

defaultproperties
{
	Probality=0.500000
	RemoteRole=ROLE_None
}
