class CybotHelicoFactory expands VehicleFactory;

defaultproperties
{
      VehicleClass=Class'XChopVeh.CybotHelico'
      AnimSequence="BothFire"
      Mesh=LodMesh'XChopVeh.CybHeli'
      DrawScale=8.000000
      MultiSkins(1)=Texture'XChopVeh.Skins.CybotSk'
      MultiSkins(4)=Texture'XChopVeh.Skins.CybotCoreRed'
      MultiSkins(5)=Texture'XChopVeh.LaserFX.SentinelLaserFXRed'
      CollisionRadius=88.000000
      CollisionHeight=112.000000
}
