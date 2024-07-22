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
	PlaySound(Sound'CybTransformSnd',,12.0,,1200.0);
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
			DriverGun.LoopAnim('Rotating', 2.0);
		if (AttachmentList != None)
			AttachmentList.LoopAnim('Rotating', 4.0);
		Super.EndState();
	}
}

simulated function Tick(float delta)
{
	Super.Tick(delta);
	if (CurrentTeamColor != CurrentTeam)
		ChangeColor();
	if (AttachmentList != None && DriverGun != None && 
		DriverGun.AnimSequence != AttachmentList.AnimSequence)
	{
		if (DriverGun.AnimSequence == 'Rotating')
			AttachmentList.LoopAnim(DriverGun.AnimSequence, 4.0);
		else
			AttachmentList.PlayAnim(DriverGun.AnimSequence);
	}
}

function ChangeColor()
{
	local Texture Core, Laser;
	local Class<Projectile> Proj;
	CurrentTeamColor = CurrentTeam;
	switch (CurrentTeam)
	{
		case 1: 
			Core = Texture'XVehicles.Skins.CybotCoreBlue'; 
			Laser = Texture'XVehicles.LaserFX.SentinelLaserFXBlue';
			Proj = Class'CybProjB';
			break;
		case 2: 
			Core = Texture'XVehicles.Skins.CybotCoreGreen'; 
			Laser = Texture'XVehicles.LaserFX.SentinelLaserFXGreen'; 
			Proj = Class'CybProjG';
			break;
		case 3: 
			Core = Texture'XVehicles.Skins.CybotCoreYellow'; 
			Laser = Texture'XVehicles.LaserFX.SentinelLaserFXYellow'; 
			Proj = Class'CybProjY';
			break;
		case 0: 
		default: 
			Core = Texture'XVehicles.Skins.CybotCoreRed'; 
			Laser = Texture'XVehicles.LaserFX.SentinelLaserFXRed'; 
			Proj = Class'CybProj';
			break;
	}
	MultiSkins[4] = Core;
	MultiSkins[5] = Laser;
	if (DriverGun != None)
		DriverGun.WeapSettings[0].ProjectileClass = Proj;
}

defaultproperties
{
	MaxAirSpeed=2000.000000
	YawTurnSpeed=36000.000000
	AIRating=5.000000
	WAccelRate=1000.000000
	Health=360
	VehicleName="Cybot Helico"
	TranslatorDescription="This is a Cybot Helico, you can fire different firemodes using [Fire] and [AltFire] buttons. To move higher or lover use [Jump] and [Crouch] buttons and to move around use movement keys. To leave this vehicle press [ThrowWeapon] key."
	ExitOffset=(X=0.000000,Y=140.000000)
	BehinViewViewOffset=(X=-400.000000,Y=0.000000,Z=208.000000)
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
	DriverWeapon=(WeaponClass=Class'CybBlades',WeaponOffset=(X=0.000000))
	VehicleKeyInfoStr="Cybot Helico keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to strafe|%Jump%, %Duck% to move up/down|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%ThrowWeapon% to exit the vehicle"
	WDeAccelRate=200.000000
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=-32.000000,Z=20.000000),FXRange=15)
	DestroyedExplDmg=70
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=6.750000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=2.000000,AttachName="CybBlades")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=100.000000,Y=80.000000,Z=-5.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-64.000000,Y=80.000000,Z=-5.000000))
	bEnableShield=True
	ShieldLevel=0.600000
	AnimSequence="Still"
	Mesh=LodMesh'CybHeli'
	DrawScale=8.000000
	PrePivot=(X=0.000000,Y=0.000000,Z=-26.000000)
	AmbientGlow=17
	MultiSkins(1)=Texture'XVehicles.Skins.CybotSk'
	MultiSkins(4)=Texture'XVehicles.Skins.CybotCoreRed'
	MultiSkins(5)=Texture'XVehicles.LaserFX.SentinelLaserFXRed'
	SoundRadius=255
	SoundVolume=255
	SoundPitch=56
	CollisionRadius=112.000000
	CollisionHeight=88.000000
}
