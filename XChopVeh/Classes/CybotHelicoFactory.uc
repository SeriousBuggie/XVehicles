class CybotHelicoFactory expands VehicleFactory;

defaultproperties
{
	VehicleClass=Class'CybotHelico'
	AnimSequence="BothFire"
	Texture=Texture'XVehicles.Skins.CybotMetal'
	Mesh=LodMesh'CybHeli'
	DrawScale=8.000000
	PrePivot=(X=0.000000,Y=0.000000,Z=-26.000000)
	MultiSkins(1)=Texture'XVehicles.Skins.CybotSk'
	MultiSkins(4)=Texture'XVehicles.Skins.CybotCoreRed'
	MultiSkins(5)=Texture'XVehicles.LaserFX.SentinelLaserFXRed'
	CollisionRadius=112.000000
	CollisionHeight=88.000000
}
