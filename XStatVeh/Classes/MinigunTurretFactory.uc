//=============================================================================
// MinigunTurretFactory.
//=============================================================================
class MinigunTurretFactory expands VehicleFactory;

defaultproperties
{
	VehicleClass=Class'MinigunTurret'
	AnimSequence="UnTransform"
	Texture=Texture'XVehicles.Skins.CybotMetal'
	Mesh=LodMesh'CybSentinelGun'
	DrawScale=5.000000
	PrePivot=(Z=3.000000)
	AmbientGlow=17
	MultiSkins(2)=Texture'XVehicles.Skins.CybotCoreRed'
	MultiSkins(3)=Texture'XVehicles.LaserFX.SentinelLaserFXRed'
	CollisionRadius=70.000000
	CollisionHeight=57.000000
}
