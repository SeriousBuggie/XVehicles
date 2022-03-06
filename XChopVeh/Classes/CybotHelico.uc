class CybotHelico expands ChopperPhys;

var byte CurrentTeamColor;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (Level.NetMode != NM_DedicatedServer)
		AddAttachment(class'CybGuideBlades');
}

auto state StartingUp
{
Begin:
	PlaySound(Sound'MyLevel.CybTransformSnd',,12.0,,1200.0);
	PlayAnim('Transform', 5.0);
	Sleep(0.1);
	FinishAnim();
	GoToState('EmptyVehicle');
}

State EmptyVehicle
{
	function BeginState()
	{
		Super.BeginState();
		if (DriverGun != None && DriverGun.AnimSequence == 'Rotating')
			DriverGun.PlayAnim('Rotate');
		if (AttachmentList != None && AttachmentList.AnimSequence == 'Rotating')
			AttachmentList.PlayAnim('Rotate');
	}
	function EndState()
	{
		if (DriverGun != None)
			DriverGun.LoopAnim('Rotating');
		if (AttachmentList != None)
			AttachmentList.LoopAnim('Rotating');
		Super.EndState();
	}
}

simulated function Tick(float delta)
{
	Super.Tick(delta);
	if (CurrentTeamColor != CurrentTeam)
		ChangeColor();
}

function ChangeColor()
{
	local Texture Core, Laser;
	local Class<Projectile> Proj;
	CurrentTeamColor = CurrentTeam;
	switch (CurrentTeam)
	{
		case 1: 
			Core = Texture'MyLevel.CybotCoreBlue'; 
			Laser = Texture'MyLevel.SentinelLaserFXBlue';
			Proj = Class'MyLevel.CybProjB';
			break;
		case 2: 
			Core = Texture'MyLevel.CybotCoreGreen'; 
			Laser = Texture'MyLevel.SentinelLaserFXGreen'; 
			Proj = Class'MyLevel.CybProjG';
			break;
		case 3: 
			Core = Texture'MyLevel.CybotCoreYellow'; 
			Laser = Texture'MyLevel.SentinelLaserFXYellow'; 
			Proj = Class'MyLevel.CybProjY';
			break;
		case 0: 
		default: 
			Core = Texture'MyLevel.CybotCoreRed'; 
			Laser = Texture'MyLevel.SentinelLaserFXRed'; 
			Proj = Class'MyLevel.CybProj';
			break;
	}
	MultiSkins[4] = Core;
	MultiSkins[5] = Laser;
	if (DriverGun != None)
		DriverGun.WeapSettings[0].ProjectileClass = Proj;
}

defaultproperties
{
      CurrentTeamColor=0
      WAccelRate=660.000000
      Health=360
      VehicleName="Cybot Helico"
      TranslatorDescription="This is a Cybot Helico, you can fire different firemodes using [Fire] and [AltFire] buttons. To move higher or lover use [Jump] and [Crouch] buttons and to move around use movement keys. To leave this vehicle press [ThrowWeapon] key."
      ExitOffset=(Y=140.000000)
      BehinViewViewOffset=(X=-400.000000,Z=208.000000)
      StartSound=Sound'XChopVeh.Pickups.RessurectSnd'
      EngineSound=Sound'XChopVeh.Loop.CybHeliAmb'
      ImpactSounds(0)=Sound'XChopVeh.Damage.CybSndArmorDmg1'
      ImpactSounds(1)=Sound'XChopVeh.Damage.CybSndArmorDmg2'
      ImpactSounds(2)=Sound'XChopVeh.Damage.CybSndArmorDmg3'
      ImpactSounds(3)=Sound'XChopVeh.Hit.CybWreckMetalHit'
      ImpactSounds(4)=Sound'XChopVeh.Damage.CybSndArmorDmg1'
      ImpactSounds(5)=Sound'XChopVeh.Damage.CybSndArmorDmg2'
      ImpactSounds(6)=Sound'XChopVeh.Hit.CybWreckMetalHit'
      ImpactSounds(7)=Sound'XChopVeh.Fragments.FragSound01'
      BulletHitSounds(0)=Sound'XChopVeh.Damage.CybSndArmorDmg1'
      BulletHitSounds(1)=Sound'XChopVeh.Damage.CybSndArmorDmg2'
      BulletHitSounds(2)=Sound'XChopVeh.Damage.CybSndArmorDmg3'
      BulletHitSounds(3)=Sound'XChopVeh.Hit.CybWreckMetalHit'
      BulletHitSounds(4)=Sound'XChopVeh.Damage.CybSndArmorDmg1'
      BulletHitSounds(5)=Sound'XChopVeh.Damage.CybSndArmorDmg2'
      DriverWeapon=(WeaponClass=Class'XChopVeh.CybBlades')
      VehicleKeyInfoStr="Cybot Helico keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to strafe|%Jump%, %Duck% to move up/down|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%ThrowWeapon% to exit the vehicle"
      DropFlag=DF_All
      DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=-32.000000,Z=20.000000),FXRange=15)
      DestroyedExplDmg=70
      ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=6.750000)
      ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=2.000000,AttachName="CybBlades")
      ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=100.000000,Y=80.000000,Z=-5.000000))
      ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-64.000000,Y=80.000000,Z=-5.000000))
      AnimSequence="Still"
      Mesh=LodMesh'XChopVeh.CybHeli'
      DrawScale=8.000000
      PrePivot=(Z=-26.000000)
      AmbientGlow=17
      MultiSkins(1)=Texture'XChopVeh.Skins.CybotSk'
      MultiSkins(4)=Texture'XChopVeh.Skins.CybotCoreRed'
      MultiSkins(5)=Texture'XChopVeh.LaserFX.SentinelLaserFXRed'
      SoundRadius=96
      SoundVolume=192
      SoundPitch=56
      CollisionRadius=112.000000
      CollisionHeight=88.000000
}
