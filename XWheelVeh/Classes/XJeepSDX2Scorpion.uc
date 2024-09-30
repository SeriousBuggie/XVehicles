//=============================================================================
// XJeepSDX2Scorpion.
//=============================================================================
class XJeepSDX2Scorpion expands Mutator config(XVehicles);

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
	local ScorpionFactory ScorpionFact;
	
	foreach AllActors(class'JeepSDXFactory', JeepSDXFact)
		JeepSDXFact.VehicleClass = Class'ScorpionFactory'.default.VehicleClass;
		
	foreach AllActors(class'ScorpionFactory', ScorpionFact)
		ScorpionFact.VehicleClass = Class'JeepSDXFactory'.default.VehicleClass;
}

defaultproperties
{
	Probality=0.500000
	RemoteRole=ROLE_None
}
