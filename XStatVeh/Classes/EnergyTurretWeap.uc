//=============================================================================
// EnergyTurretWeap.
//=============================================================================
class EnergyTurretWeap expands MinigunTurretWeap;

defaultproperties
{
      TraceActor=Class'XStatVeh.LaserBeam'
      LaserTexture=3
      PitchRange=(Min=-7500)
      TurretPitchActor=Class'XStatVeh.EnergyTurretGun'
      WeapSettings(0)=(FireStartOffset=(X=144.000000,Y=60.000000,Z=33.000000),FireSound=Sound'Botpack.ASMD.TazerFire',DualMode=1,hitdamage=30,HitType="Laser",HitError=0.000000)
      bPhysicalGunAimOnly=False
      HitMark=Class'Botpack.BoltScorch'
      Mesh=LodMesh'XStatVeh.CybDualSentinelTurret'
      DrawScale=6.000000
      CollisionRadius=84.000000
      CollisionHeight=84.000000
}
