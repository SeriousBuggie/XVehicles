//=============================================================================
// EnergyTurretFactory.
//=============================================================================
class EnergyTurretFactory expands VehicleFactory;

defaultproperties
{
      VehicleClass=Class'XStatVeh.EnergyTurret'
      VehicleRespawnTime=30.000000
      AnimSequence="UnTransform"
      Texture=Texture'XStatVeh.Skins.CybotMetal'
      Mesh=LodMesh'XStatVeh.CybDualSentinelGun'
      DrawScale=6.000000
      AmbientGlow=17
      MultiSkins(3)=Texture'XVehicles.Skins.CybotCoreRed'
      MultiSkins(4)=Texture'XVehicles.LaserFX.SentinelLaserFXRed'
      CollisionRadius=84.000000
      CollisionHeight=72.000000
}
