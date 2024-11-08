//=============================================================================
// XTankGKOne2Juggernaut.
//=============================================================================
class XTankGKOne2Juggernaut expands XVehiclesSwap config(XVehicles);

defaultproperties
{
	FromFactoryClass=Class'XTreadVeh.TankGKOneFactory'
	ToFactoryClass=Class'JuggernautFactory'
	bAddToPackageMap=True
}
