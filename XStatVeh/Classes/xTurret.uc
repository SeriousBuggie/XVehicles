//=============================================================================
// xTurret.
//=============================================================================
class xTurret expands StationaryPhys abstract;

auto state StartingUp
{
Begin:
	PlaySound(Sound'CybTransformSnd',,12.0,,1200.0);
	PlayAnim('Transform', 5.0);
	Sleep(0.1);
	FinishAnim();
	GoToState('EmptyVehicle');
}

defaultproperties
{
      Health=500
      TranslatorDescription="This is a stationary turret. You can fire using [Fire] and zoom in and out using movement keys and toggle zoom with [AltFire]. To leave this vehicle press [ThrowWeapon] key."
      StartSound=Sound'XStatVeh.Pickups.RessurectSnd'
      DriverWeapon=(WeaponClass=Class'XStatVeh.MinigunTurretWeap')
      VehicleKeyInfoStr="Turret keys:|%Fire% to fire, %AltFire% to toggle zoom|%ThrowWeapon% to exit the vehicle"
      DropFlag=DF_All
      DestroyedExplDmg=70
      ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=6.750000)
      ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=2.000000,AttachName="MinigunTurretWeap")
      ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=100.000000,Y=80.000000,Z=-5.000000))
      ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-64.000000,Y=80.000000,Z=-5.000000))
      bEnableShield=True
      ShieldLevel=0.600000
      AnimSequence="Still"
      Texture=Texture'XStatVeh.Skins.CybotMetal'
      Mesh=LodMesh'XStatVeh.CybSentinelBase'
      DrawScale=5.000000
      AmbientGlow=17
      MultiSkins(1)=Texture'XVehicles.Skins.CybotSk'
      CollisionRadius=70.000000
      CollisionHeight=60.000000
}
