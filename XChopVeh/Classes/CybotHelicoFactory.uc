class CybotHelicoFactory expands VehicleFactory;

defaultproperties
{
      VehicleClass=Class'XChopVeh.CybotHelico'
      AnimSequence="BothFire"
      Mesh=LodMesh'XChopVeh.CybHeli'
      DrawScale=8.000000
      PrePivot=(Z=-26.000000)
      MultiSkins(1)=Texture'XVehicles.Skins.CybotSk'
      MultiSkins(4)=Texture'XVehicles.Skins.CybotCoreRed'
      MultiSkins(5)=Texture'XVehicles.LaserFX.SentinelLaserFXRed'
      CollisionRadius=112.000000
      CollisionHeight=88.000000
}
