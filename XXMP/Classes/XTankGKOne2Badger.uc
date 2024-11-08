//=============================================================================
// XTankGKOne2Badger.
//=============================================================================
class XTankGKOne2Badger expands XVehiclesSwap config(XVehicles);

defaultproperties
{
	FromFactoryClass=Class'XTreadVeh.TankGKOneFactory'
	ToFactoryClass=Class'BadgerFactory'
	bAddToPackageMap=True
}
