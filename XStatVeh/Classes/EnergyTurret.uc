//=============================================================================
// EnergyTurret.
//=============================================================================
class EnergyTurret expands xTurret;

defaultproperties
{
      Health=450
      VehicleName="Energy Turret"
      ExitOffset=(Y=112.000000)
      BehinViewViewOffset=(X=20.000000,Z=10.000000)
      InsideViewOffset=(X=20.000000,Y=0.000000,Z=10.000000)
      DriverWeapon=(WeaponClass=Class'XStatVeh.EnergyTurretWeap')
      ExplosionGFX(1)=(AttachName="EnergyTurretWeap")
      Mesh=LodMesh'XStatVeh.CybDualSentinelBase'
      DrawScale=6.000000
      CollisionRadius=84.000000
      CollisionHeight=72.000000
}
