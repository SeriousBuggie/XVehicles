//=============================================================================
// XManta2Viper.
//=============================================================================
class XManta2Viper expands Mutator config(XVehicles);

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
	local ViperFactory ViperFact;
	
	foreach AllActors(class'MantaFactory', MantaFact)
		MantaFact.VehicleClass = Class'ViperFactory'.default.VehicleClass;
		
	foreach AllActors(class'ViperFactory', ViperFact)
		ViperFact.VehicleClass = Class'MantaFactory'.default.VehicleClass;
}

defaultproperties
{
	Probality=0.500000
	RemoteRole=ROLE_None
}
