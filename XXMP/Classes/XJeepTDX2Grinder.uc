//=============================================================================
// XJeepTDX2Grinder.
//=============================================================================
class XJeepTDX2Grinder expands Mutator config(XVehicles);

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
	local JeepSDXFactory JeepSDXFact;
	local GrinderFactory GrinderFact;
	local bool bGrinderFound;
	
	foreach AllActors(class'GrinderFactory', GrinderFact)
	{
		GrinderFact.VehicleClass = Class'JeepTDXFactory'.default.VehicleClass;
		bGrinderFound = true;
	}
	
	foreach AllActors(class'JeepTDXFactory', JeepTDXFact)
		JeepTDXFact.VehicleClass = Class'GrinderFactory'.default.VehicleClass;
		
	if (!bGrinderFound)
	{ // swap JeepSDX to JeepTDX, since alone JeepSDX is too weak for compete with Grinder
		foreach AllActors(class'JeepSDXFactory', JeepSDXFact)
		 JeepSDXFact.VehicleClass = Class'JeepTDXFactory'.default.VehicleClass;
	}
}

defaultproperties
{
	Probality=0.500000
	bAddToPackageMap=True
	RemoteRole=ROLE_None
}
