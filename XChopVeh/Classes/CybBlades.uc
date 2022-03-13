class CybBlades expands xChopVehWeapon;

auto state StartingUp
{
Begin:
	PlaySound(Sound'CybTransformSnd',,12.0,,1200.0);
	PlayAnim('Transform', 5.0);
	Sleep(0.1);
	FinishAnim();
}

function SpawnFireEffects(byte Mode)
{
	local name Anim;
	Super.SpawnFireEffects(Mode);
	
	if (OwnerVehicle == None)
		return;
	if (bTurnFire)
		Anim = 'LeftFire';
	else
		Anim = 'RightFire';
	OwnerVehicle.PlayAnim(Anim, 10.0 - Mode*8);
}

function FireTurret( byte Mode, optional bool bForceFire )
{
	if (Bot(WeaponController) != None && Mode == 0 && 
		class'XV_SeekingRocket'.static.IsGoodTarget(WeaponController, WeaponController.Target))
		Mode = 1; // use alt fire for rocket

	Super.FireTurret(Mode, bForceFire);	
}

defaultproperties
{
      RotatingSpeed=16000000.000000
      PitchRange=(Max=32767,Min=-32767)
      TurretPitchActor=Class'XChopVeh.CybPitch'
      PitchActorOffset=(X=188.000000,Z=-58.000000)
      WeapSettings(0)=(ProjectileClass=Class'XChopVeh.CybProj',FireStartOffset=(Y=96.000000),RefireRate=0.200000,FireSound=Sound'XChopVeh.rfire',DualMode=1)
      WeapSettings(1)=(ProjectileClass=Class'XChopVeh.XV_SeekingRocket',FireStartOffset=(Y=96.000000),RefireRate=3.000000,FireSound=Sound'UnrealShare.Eightball.Ignite',DualMode=1)
      AnimSequence="Still"
      Mesh=LodMesh'XChopVeh.CybHeliBlades'
      DrawScale=8.000000
      PrePivot=(Z=-30.000000)
      SoundRadius=80
      SoundVolume=210
      CollisionHeight=88.000000
}