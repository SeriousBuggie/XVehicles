//=============================================================================
// EnergyTurretFactory.
//=============================================================================
class EnergyTurretFactory expands VehicleFactory;

defaultproperties
{
	VehicleClass=Class'EnergyTurret'
	VehicleRespawnTime=30.000000
	AnimSequence="UnTransform"
	Texture=Texture'XVehicles.Skins.CybotMetal'
	Mesh=LodMesh'CybDualSentinelGun'
	DrawScale=6.000000
	PrePivot=(Z=-11.000000)
	AmbientGlow=17
	MultiSkins(3)=Texture'XVehicles.Skins.CybotCoreRed'
	MultiSkins(4)=Texture'XVehicles.LaserFX.SentinelLaserFXRed'
	CollisionRadius=84.000000
	CollisionHeight=83.000000
}
