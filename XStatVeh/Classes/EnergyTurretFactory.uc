//=============================================================================
// EnergyTurretFactory.
//=============================================================================
class EnergyTurretFactory expands VehicleFactory;

defaultproperties
{
      VehicleClass=Class'XStatVeh.EnergyTurret'
      AnimSequence="UnTransform"
      Texture=Texture'XStatVeh.Skins.CybotMetal'
      Mesh=LodMesh'XStatVeh.CybDualSentinelGun'
      DrawScale=6.000000
      AmbientGlow=17
      MultiSkins(3)=Texture'XStatVeh.Skins.CybotCoreRed'
      MultiSkins(4)=Texture'XStatVeh.Skins.CybotCoreRed'
      CollisionRadius=84.000000
      CollisionHeight=72.000000
}
