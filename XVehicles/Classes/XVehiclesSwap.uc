//=============================================================================
// XVehiclesSwap.
//=============================================================================
class XVehiclesSwap expands Mutator config(XVehicles) abstract;

var() config float Probability;
var() Class<VehicleFactory> FromFactoryClass;
var() Class<VehicleFactory> ToFactoryClass;

function PreBeginPlay()
{
	local Actor A;
	
	Super.PreBeginPlay();

	foreach AllActors(Class, A)
		break;
	if (A != self)
		return;

	if (FRand() < Probability)
		Swap();
}

function Swap()
{
	local Actor Factory;
	
	foreach AllActors(FromFactoryClass, Factory)
		VehicleFactory(Factory).VehicleClass = ToFactoryClass.default.VehicleClass;
		
	foreach AllActors(ToFactoryClass, Factory)
		VehicleFactory(Factory).VehicleClass = FromFactoryClass.default.VehicleClass;
}

defaultproperties
{
	Probability=0.500000
	RemoteRole=ROLE_None
}
