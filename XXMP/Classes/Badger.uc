//=============================================================================
// Badger.
//=============================================================================
class Badger expands WheeledCarPhys;

/*
#forceexec MESH  MODELIMPORT MESH=Badger MODELFILE=Z:\XV\Badger\BadgerChassis_.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=Badger X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=Badger STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=Badger X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=Badger NUM=0 TEXTURE=BadgerRed
// */

/*
#forceexec MESH  MODELIMPORT MESH=BadgerWheel MODELFILE=Z:\XV\Badger\BadgerWheel.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=BadgerWheel X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=BadgerWheel STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=BadgerWheel X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=BadgerWheel NUM=0 TEXTURE=BadgerRed
// */

/*
#forceexec MESH  MODELIMPORT MESH=BadgerWheelMir MODELFILE=Z:\XV\Badger\BadgerWheelMir.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=BadgerWheelMir X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=BadgerWheelMir STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=BadgerWheelMir X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=BadgerWheelMir NUM=0 TEXTURE=BadgerRed
// */

/*
#forceexec MESH  MODELIMPORT MESH=BadgerGun MODELFILE=Z:\XV\Badger\BadgerTurretGun.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=BadgerGun X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=BadgerGun STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=BadgerGun X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=BadgerGun NUM=0 TEXTURE=BadgerRed
// */

/*
#forceexec MESH  MODELIMPORT MESH=BadgerTurret MODELFILE=Z:\XV\Badger\BadgerTurret_.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=BadgerTurret X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=BadgerTurret STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=BadgerTurret X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=BadgerTurret NUM=0 TEXTURE=BadgerRed
// */

/*
#forceexec MESH  MODELIMPORT MESH=BadgerMinigunGun MODELFILE=Z:\XV\Badger\BadgerMinigunGun.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=BadgerMinigunGun X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=BadgerMinigunGun STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=BadgerMinigunGun X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=BadgerMinigunGun NUM=0 TEXTURE=BadgerRed
// */

/*
#forceexec MESH  MODELIMPORT MESH=BadgerMinigun MODELFILE=Z:\XV\Badger\BadgerMinigun_.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=BadgerMinigun X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=BadgerMinigun STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=BadgerMinigun X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=BadgerMinigun NUM=0 TEXTURE=BadgerRed
// */

var byte CurrentTeamColor;
var() vector SmokeOffset;

simulated function Tick(float delta)
{
	Super.Tick(delta);
	if (CurrentTeamColor != CurrentTeam)
		ChangeColor();
}

simulated function ChangeColor()
{
	local int i;
	CurrentTeamColor = CurrentTeam;
	switch (CurrentTeamColor)
	{
		case 1:
			Skin = Texture'BadgerBlue';
			break;
		case 0:
		default: 
			Skin = Texture'BadgerRed';
			break;
	}
	MultiSkins[0] = Skin;
	if (GVT != None)
	{
		GVT.MultiSkins[0] = Skin;
	}
	if (DriverGun != None)
	{
		DriverGun.MultiSkins[0] = Skin;
		if (DriverGun.PitchPart != None)
			DriverGun.PitchPart.MultiSkins[0] = Skin;
	}
	if (PassengerSeats[0].PGun != None)
	{
		PassengerSeats[0].PGun.MultiSkins[0] = Skin;
		if (PassengerSeats[0].PGun.PitchPart != None)
			PassengerSeats[0].PGun.PitchPart.MultiSkins[0] = Skin;
	}
	for (i = 0; i < NumWheels; i++)
		MyWheels[i].MultiSkins[0] = Skin;
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	SetTimer(0.5, true);
}

simulated function Timer()
{
	local Effects E;
	Super.Timer();
	if (Level.NetMode != NM_DedicatedServer && Driver != None)
	{
		E = spawn(class'UT_SpriteSmokePuff',,,Location + (SmokeOffset >> Rotation));
		E.RemoteRole = ROLE_None;
		E.DrawScale = 0.5;
	}
}

defaultproperties
{
	CurrentTeamColor=42
	SmokeOffset=(X=-93.000000,Y=11.000000,Z=18.500000)
	Wheels(0)=(WheelOffset=(X=44.000000,Y=-51.500000,Z=-43.500000),WheelClass=Class'BadgerWheel',WheelMesh=SkeletalMesh'BadgerWheel')
	Wheels(1)=(WheelOffset=(X=44.000000,Y=51.500000,Z=-43.500000),WheelRot=(Yaw=32768),WheelClass=Class'BadgerWheel',WheelMesh=SkeletalMesh'BadgerWheelMir',bMirroredWheel=True)
	Wheels(2)=(WheelOffset=(X=-44.000000,Y=-51.500000,Z=-43.500000),WheelClass=Class'BadgerWheel',WheelMesh=SkeletalMesh'BadgerWheel')
	Wheels(3)=(WheelOffset=(X=-44.000000,Y=51.500000,Z=-43.500000),WheelRot=(Yaw=32768),WheelClass=Class'BadgerWheel',WheelMesh=SkeletalMesh'BadgerWheelMir',bMirroredWheel=True)
	MaxGroundSpeed=780.000000
	WheelsRadius=62.000000
	TractionWheelsPosition=-44.000000
	AIRating=3.000000
	VehicleGravityScale=3.000000
	WAccelRate=350.000000
	Health=900
	VehicleName="Badger"
	ExitOffset=(X=0.000000,Y=140.000000)
	BehinViewViewOffset=(X=-250.000000,Y=0.000000,Z=100.000000)
	StartSound=Sound'XXMP.Badger.BadgerStart'
	EndSound=Sound'XXMP.Badger.BadgerStop'
	EngineSound=Sound'XXMP.Badger.BadgerEngine'
	bEngDynSndPitch=True
	MinEngPitch=32
	MaxEngPitch=96
	bDriverWOffset=True
	DriverWeapon=(WeaponClass=Class'BadgerMGRot',WeaponOffset=(X=-20.000000,Z=60.000000))
	PassengerSeats(0)=(PassengerWeapon=Class'BadgerTurret',PassengerWOffset=(X=-20.000000,Z=44.000000),CameraOffset=(Z=50.000000),CamBehindviewOffset=(X=-250.000000,Z=50.000000),bIsAvailable=True,SeatName="Badger Canon")
	VehicleKeyInfoStr="Badger keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%mutate VehicleCamera% to change camera|%ThrowWeapon% to exit the vehicle"
	bSlopedPhys=True
	FrontWide=(X=95.000000,Y=69.000000,Z=-10.000000)
	BackWide=(X=-85.000000,Y=69.000000,Z=-10.000000)
	ZRange=260.000000
	MaxObstclHeight=44.000000
	DriverCrosshairTex=Texture'XTreadVeh.Icons.TankGKOnePassCross'
	PassCrosshairTex(0)=Texture'XTreadVeh.Icons.TankGKOneMainCross'
	bUseVehicleLights=True
	bUseSignalLights=True
	StopLights(0)=(VLightOffset=(X=-57.750000,Y=54.000000,Z=5.000000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	StopLights(1)=(VLightOffset=(X=-57.750000,Y=-56.000000,Z=5.000000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(0)=(VLightOffset=(X=-56.750000,Y=48.000000,Z=7.500000),VLightTex=Texture'XWheelVeh.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(1)=(VLightOffset=(X=-56.750000,Y=-50.000000,Z=7.500000),VLightTex=Texture'XWheelVeh.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	HeadLights(0)=(VLightOffset=(X=82.000000,Y=13.500000,Z=-12.000000),VLightTex=Texture'XWheelVeh.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(1)=(VLightOffset=(X=82.000000,Y=-15.000000,Z=-12.000000),VLightTex=Texture'XWheelVeh.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	GroundPower=2.500000
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=52.000000,Y=5.000000),FXRange=12)
	DestroyedExplDmg=420
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=8.125000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=3.440000,AttachName="BadgerTurret")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=103.750000,Y=98.125000,Z=-10.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-138.750000,Y=98.125000,Z=-10.000000))
	ExplosionGFX(4)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(Y=98.125000,Z=-10.000000))
	WreckPartColHeight=45.000000
	WreckPartColRadius=71.000000
	bEnableShield=True
	ShieldLevel=0.650000
	Mesh=SkeletalMesh'Badger'
	SoundRadius=70
	SoundVolume=100
	CollisionRadius=71.000000
	CollisionHeight=75.000000
	Mass=2900.000000
}
