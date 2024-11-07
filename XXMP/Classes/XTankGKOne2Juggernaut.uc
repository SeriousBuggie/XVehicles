//=============================================================================
// XTankGKOne2Juggernaut.
//=============================================================================
class XTankGKOne2Juggernaut expands XVehiclesSwap config(XVehicles);

defaultproperties
{
	FromFactoryClass=Class'XTreadVeh.TankGKOneFactory'
	ToFsctoryClass=Class'JuggernautFactory'
	bAddToPackageMap=True
}
