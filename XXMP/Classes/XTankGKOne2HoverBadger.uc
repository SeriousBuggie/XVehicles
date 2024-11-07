//=============================================================================
// XTankGKOne2HoverHoverBadger.
//=============================================================================
class XTankGKOne2HoverBadger expands XVehiclesSwap config(XVehicles);

defaultproperties
{
	FromFactoryClass=Class'XTreadVeh.TankGKOneFactory'
	ToFsctoryClass=Class'HoverBadgerFactory'
	bAddToPackageMap=True
}
