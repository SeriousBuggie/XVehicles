//=============================================================================
// XTankGKOne2IonTank.
//=============================================================================
class XTankGKOne2IonTank expands Mutator config(XVehicles);

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
	local TankGKOneFactory TankGKOneFact;
	local IonTankFactory IonTankFact;
	
	foreach AllActors(class'TankGKOneFactory', TankGKOneFact)
		TankGKOneFact.VehicleClass = Class'IonTankFactory'.default.VehicleClass;
		
	foreach AllActors(class'IonTankFactory', IonTankFact)
		IonTankFact.VehicleClass = Class'TankGKOneFactory'.default.VehicleClass;
}

defaultproperties
{
	Probality=0.500000
	RemoteRole=ROLE_None
}
