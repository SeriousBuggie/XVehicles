//=============================================================================
// MinigunTurretFactory.
//=============================================================================
class MinigunTurretFactory expands VehicleFactory;

defaultproperties
{
      VehicleClass=Class'XStatVeh.MinigunTurret'
      AnimSequence="UnTransform"
      Texture=Texture'XStatVeh.Skins.CybotMetal'
      Mesh=LodMesh'XStatVeh.CybSentinelGun'
      DrawScale=5.000000
      AmbientGlow=17
      MultiSkins(2)=Texture'XVehicles.Skins.CybotCoreRed'
      MultiSkins(3)=Texture'XVehicles.LaserFX.SentinelLaserFXRed'
      CollisionRadius=70.000000
      CollisionHeight=45.000000
}
