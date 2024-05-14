//=============================================================================
// Grinder.
//=============================================================================
class Grinder expands WheeledCarPhys;

/*
#forceexec MESH  MODELIMPORT MESH=Grinder MODELFILE=Z:\XV\Grinder.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=Grinder X=17 Y=0 Z=-13 YAW=128 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=Grinder STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=Grinder X=0.65 Y=0.65 Z=0.65
#forceexec MESHMAP SETTEXTURE MESHMAP=Grinder NUM=0 TEXTURE=GrinderNone
#forceexec MESHMAP SETTEXTURE MESHMAP=Grinder NUM=1 TEXTURE=GrinderNone
#forceexec MESHMAP SETTEXTURE MESHMAP=Grinder NUM=2 TEXTURE=GrinderNone
// */

/*
#forceexec MESH  MODELIMPORT MESH=GrinderGun MODELFILE=Z:\XV\GrinderGun.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=GrinderGun X=0 Y=0 Z=0 YAW=128 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=GrinderGun STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=GrinderGun X=0.65 Y=0.65 Z=0.65
#forceexec MESHMAP SETTEXTURE MESHMAP=GrinderGun NUM=0 TEXTURE=GrinderNone
// */

/*
#forceexec MESH  MODELIMPORT MESH=GrinderTurret MODELFILE=Z:\XV\GrinderTurret.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=GrinderTurret X=0 Y=0 Z=38 YAW=128 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=GrinderTurret STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=GrinderTurret X=0.65 Y=0.65 Z=0.65
#forceexec MESHMAP SETTEXTURE MESHMAP=GrinderTurret NUM=0 TEXTURE=GrinderNone
// */

/*
#forceexec MESH  MODELIMPORT MESH=GrinderWheel MODELFILE=Z:\XV\GrinderWheel.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=GrinderWheel X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=GrinderWheel STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=GrinderWheel X=0.65 Y=0.65 Z=0.65
#forceexec MESHMAP SETTEXTURE MESHMAP=GrinderWheel NUM=0 TEXTURE=GrinderNone
// */

/*
#forceexec MESH  MODELIMPORT MESH=GrinderWheelMir MODELFILE=Z:\XV\GrinderWheel.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=GrinderWheelMir X=0 Y=0 Z=0 YAW=128 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=GrinderWheelMir STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=GrinderWheelMir X=0.65 Y=0.65 Z=0.65
#forceexec MESHMAP SETTEXTURE MESHMAP=GrinderWheelMir NUM=0 TEXTURE=GrinderNone
// */

/*
#forceexec MESH  MODELIMPORT MESH=GrinderRotor MODELFILE=Z:\XV\GrinderRotor.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=GrinderRotor X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=GrinderRotor STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=GrinderRotor X=0.65 Y=0.65 Z=0.65
#forceexec MESHMAP SETTEXTURE MESHMAP=GrinderRotor NUM=0 TEXTURE=GrinderNone
// */


var byte CurrentTeamColor;

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
		case 0:
			Skin = Texture'GrinderRed';
			break;
		case 1:
			Skin = Texture'GrinderBlue';
			break;
		default: 
			Skin = Texture'GrinderNone';
			break;
	}
	MultiSkins[0] = Skin;
	MultiSkins[1] = Skin;
	if (GVT != None)
	{
		GVT.MultiSkins[0] = Skin;
		GVT.MultiSkins[1] = Skin;
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

defaultproperties
{
	CurrentTeamColor=42
	Wheels(0)=(WheelOffset=(X=80.000000,Y=-60.000000,Z=-32.000000),WheelClass=Class'GrinderWheel',WheelMesh=SkeletalMesh'GrinderWheel')
	Wheels(1)=(WheelOffset=(X=80.000000,Y=60.000000,Z=-32.000000),WheelClass=Class'GrinderWheel',WheelMesh=SkeletalMesh'GrinderWheelMir',bMirroredWheel=True)
	Wheels(2)=(WheelOffset=(X=-80.000000,Y=-60.000000,Z=-32.000000),WheelClass=Class'GrinderWheel',WheelMesh=SkeletalMesh'GrinderWheel')
	Wheels(3)=(WheelOffset=(X=-80.000000,Y=60.000000,Z=-32.000000),WheelClass=Class'GrinderWheel',WheelMesh=SkeletalMesh'GrinderWheelMir',bMirroredWheel=True)
	Wheels(4)=(WheelOffset=(X=109.820000,Y=19.440001,Z=-13.640000),WheelRot=(Pitch=-9464),WheelClass=Class'GrinderWheel',WheelMesh=SkeletalMesh'GrinderRotor',WheelType=TT_Rotor)
	Wheels(5)=(WheelOffset=(X=109.820000,Y=-19.440001,Z=-13.640000),WheelRot=(Pitch=23304),WheelClass=Class'GrinderWheel',WheelMesh=SkeletalMesh'GrinderRotor',WheelType=TT_Rotor,bMirroredWheel=True)
	MaxGroundSpeed=750.000000
	WheelTurnSpeed=16000.000000
	WheelsRadius=28.500000
	TractionWheelsPosition=-80.000000
	AIRating=2.000000
	VehicleGravityScale=2.350000
	WAccelRate=480.000000
	Health=900
	VehicleName="Grinder"
	ExitOffset=(X=0.000000,Y=150.000000)
	BehinViewViewOffset=(X=-220.000000,Y=0.000000,Z=112.500000)
	StartSound=Sound'RaptorStartup'
	EndSound=Sound'XWheelVeh.JeepSDX.JeepStop'
	EngineSound=Sound'RaptorIdle'
	bEngDynSndPitch=True
	MinEngPitch=32
	MaxEngPitch=96
	PassengerSeats(0)=(PassengerWeapon=Class'GrinderTurret',PassengerWOffset=(X=-62.500000,Z=42.000000),CameraOffset=(Z=37.500000),CamBehindviewOffset=(X=-75.000000,Z=57.500000),bIsAvailable=True,SeatName="Grinder Turret")
	VehicleKeyInfoStr="Grinder keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|1, 2 to switch seats|0 to toggle light|%mutate VehicleCamera% to change camera|%ThrowWeapon% to exit the vehicle"
	bSlopedPhys=True
	FrontWide=(X=80.000000,Y=60.000000,Z=-7.500000)
	BackWide=(X=-80.000000,Y=60.000000,Z=-7.500000)
	ZRange=220.000000
	MaxObstclHeight=25.000000
	HornSnd=Sound'RaptorHorn'
	bDriverHorn=True
	HornTimeInterval=2.000000
	PassCrosshairTex(0)=Texture'XWheelVeh.Icons.JeepSDXTurretCross'
	PassCrossColor(0)=(R=255,G=0,B=0)
	ArmorType(7)=(ArmorLevel=0.300000,ProtectionType="Burned")
	bUseVehicleLights=True
	HeadLights(0)=(VLightOffset=(X=43.000000,Y=52.500000,Z=13.000000),VLightTex=Texture'XWheelVeh.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(1)=(VLightOffset=(X=43.000000,Y=-52.500000,Z=13.000000),VLightTex=Texture'XWheelVeh.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	GroundPower=2.100000
	VehicleFlagOffset=(X=0.000000,Y=0.000000,Z=-15.000000)
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=60.000000),FXRange=13)
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=5.550000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="GrinderWheel")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="GrinderTurret")
	UseExplosionSnd2=False
	WreckPartColHeight=48.000000
	bEnableShield=True
	ShieldLevel=0.600000
	Mesh=SkeletalMesh'Grinder'
	SoundRadius=70
	SoundVolume=100
	CollisionRadius=80.000000
	CollisionHeight=60.000000
	Mass=2700.000000
}
