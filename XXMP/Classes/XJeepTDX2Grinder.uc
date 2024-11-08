//=============================================================================
// XJeepTDX2Grinder.
//=============================================================================
class XJeepTDX2Grinder expands XVehiclesSwap config(XVehicles);

var() config float WarthogRLProbability;

function Swap()
{
	local JeepTDXFactory JeepTDXFact;
	local JeepSDXFactory JeepSDXFact;
	local GrinderFactory GrinderFact;
	local int Found;

	foreach AllActors(class'JeepTDXFactory', JeepTDXFact)
	{
		JeepTDXFact.VehicleClass = Class'GrinderFactory'.default.VehicleClass;
		Found = Found | 1;
	}
	
	foreach AllActors(class'GrinderFactory', GrinderFact)
	{
		GrinderFact.VehicleClass = Class'JeepTDXFactory'.default.VehicleClass;
		Found = Found | 2;
	}

	if (Found == 1)
	{ // swap JeepSDX to JeepTDX or WarthogRL, since alone JeepSDX is too weak for compete with Grinder
		if (FRand() < WarthogRLProbability)
			ToFsctoryClass = Class'WarthogRLFactory';
		else
			ToFsctoryClass = Class'JeepTDXFactory';
		foreach AllActors(class'JeepSDXFactory', JeepSDXFact)
			JeepSDXFact.VehicleClass = ToFsctoryClass.default.VehicleClass;
	}
}

defaultproperties
{
	WarthogRLProbability=0.500000
	FromFactoryClass=Class'XWheelVeh.JeepTDXFactory'
	ToFsctoryClass=Class'GrinderFactory'
	bAddToPackageMap=True
}
