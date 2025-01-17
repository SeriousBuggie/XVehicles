//=============================================================================
// WarthogMG.
//=============================================================================
class WarthogMG expands WheeledCarPhys;

/*
#forceexec MESH  MODELIMPORT MESH=Warthog MODELFILE=Z:\XV\halo\Warthog.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=Warthog X=0 Y=0 Z=18 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=Warthog STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=Warthog X=0.8 Y=0.8 Z=0.8
#forceexec MESHMAP SETTEXTURE MESHMAP=Warthog NUM=0 TEXTURE=WarthogMGBlue
#forceexec MESHMAP SETTEXTURE MESHMAP=Warthog NUM=1 TEXTURE=WarthogMG_Tire
#forceexec MESHMAP SETTEXTURE MESHMAP=Warthog NUM=2 TEXTURE=RainFX.SGlass
// */

/*
#forceexec MESH  MODELIMPORT MESH=WarthogWheel MODELFILE=Z:\XV\halo\Warthog_LF.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=WarthogWheel X=0 Y=0 Z=-27.5 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=WarthogWheel STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=WarthogWheel X=0.8 Y=0.8 Z=0.8
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogWheel NUM=0 TEXTURE=WarthogMGBlue
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogWheel NUM=1 TEXTURE=WarthogMG_Tire
// */

/*
#forceexec MESH  MODELIMPORT MESH=WarthogWheelMir MODELFILE=Z:\XV\halo\Warthog_RF.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=WarthogWheelMir X=0 Y=0 Z=-27.5 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=WarthogWheelMir STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=WarthogWheelMir X=0.8 Y=0.8 Z=0.8
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogWheelMir NUM=0 TEXTURE=WarthogMGBlue
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogWheelMir NUM=1 TEXTURE=WarthogMG_Tire
// */

/*
#forceexec MESH  MODELIMPORT MESH=WarthogMGGun MODELFILE=Z:\XV\halo\Warthog_MG_Gun.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=WarthogMGGun X=42.65 Y=0 Z=62.27 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=WarthogMGGun STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=WarthogMGGun X=0.8 Y=0.8 Z=0.8
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogMGGun NUM=0 TEXTURE=WarthogMGGun
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogMGGun NUM=1 TEXTURE=WarthogMGGun
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogMGGun NUM=2 TEXTURE=WarthogMGGun
// */

/*
#forceexec MESH  MODELIMPORT MESH=WarthogMGTurret MODELFILE=Z:\XV\halo\Warthog_MG.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=WarthogMGTurret X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=WarthogMGTurret STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=WarthogMGTurret X=0.8 Y=0.8 Z=0.8
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogMGTurret NUM=0 TEXTURE=WarthogMGGun
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogMGTurret NUM=1 TEXTURE=WarthogMGGun
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogMGTurret NUM=2 TEXTURE=WarthogMGGun
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
	CurrentTeamColor = CurrentTeam;
	switch (CurrentTeamColor)
	{
		case 0:
			MultiSkins[0] = Texture'WarthogMGRed';
			break;
		case 1:
			MultiSkins[0] = Texture'WarthogMGBlue';
			break;
		case 3:
			MultiSkins[0] = Texture'WarthogMGGold';
			break;
		case 2:
		default:
			MultiSkins[0] = Texture'WarthogMGGreen';
			break;
	}
	if (GVT != None)
		GVT.MultiSkins[0] = MultiSkins[0];
}

defaultproperties
{
	CurrentTeamColor=42
	Wheels(0)=(WheelOffset=(X=81.279999,Y=-21.680000,Z=-36.400002),WheelClass=Class'WarthogMGWheel',WheelMesh=SkeletalMesh'WarthogWheel')
	Wheels(1)=(WheelOffset=(X=81.279999,Y=21.680000,Z=-36.400002),WheelClass=Class'WarthogMGWheel',WheelMesh=SkeletalMesh'WarthogWheelMir',bMirroredWheel=True)
	Wheels(2)=(WheelOffset=(X=-78.800003,Y=-21.680000,Z=-36.400002),WheelClass=Class'WarthogMGWheel',WheelMesh=SkeletalMesh'WarthogWheel')
	Wheels(3)=(WheelOffset=(X=-78.800003,Y=21.680000,Z=-36.400002),WheelClass=Class'WarthogMGWheel',WheelMesh=SkeletalMesh'WarthogWheelMir',bMirroredWheel=True)
	MaxGroundSpeed=875.000000
	WheelTurnSpeed=16000.000000
	WheelsRadius=24.799999
	TractionWheelsPosition=-80.000000
	VehicleGravityScale=2.000000
	WAccelRate=515.000000
	Health=600
	VehicleName="Warthog MG"
	ExitOffset=(Y=150.000000)
	BehinViewViewOffset=(X=-220.000000,Z=112.500000)
	StartSound=Sound'XWheelVeh.Warthog.startup'
	EndSound=Sound'XWheelVeh.Warthog.Shutdown'
	EngineSound=Sound'XWheelVeh.Warthog.Running'
	bEngDynSndPitch=True
	MinEngPitch=32
	MaxEngPitch=96
	PassengerSeats(0)=(PassengerWeapon=Class'WarthogMGTurret',PassengerWOffset=(X=-62.728001,Z=-8.728000),CameraOffset=(Z=37.500000),CamBehindviewOffset=(X=-75.000000,Z=57.500000),bIsAvailable=True,SeatName="Light Plasma Cannon")
	VehicleKeyInfoStr="Warthog MG keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|1, 2 to switch seats|0 to toggle light|%mutate VehicleCamera% to change camera|%ThrowWeapon% to exit the vehicle"
	bSlopedPhys=True
	FrontWide=(X=80.000000,Y=60.000000,Z=-7.500000)
	BackWide=(X=-80.000000,Y=60.000000,Z=-7.500000)
	ZRange=220.000000
	MaxObstclHeight=25.000000
	HornSnd=Sound'XWheelVeh.JeepSDX.JeepHorn'
	bDriverHorn=True
	HornTimeInterval=2.000000
	PassCrosshairTex(0)=Texture'XWheelVeh.Icons.JeepSDXTurretCross'
	PassCrossColor(0)=(R=0,B=0)
	bUseVehicleLights=True
	bUseSignalLights=True
	StopLights(0)=(VLightOffset=(X=-114.760002,Y=-27.200001,Z=3.600000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	StopLights(1)=(VLightOffset=(X=-114.760002,Y=27.200001,Z=3.600000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(0)=(VLightOffset=(X=-114.760002,Y=-27.200001,Z=3.600000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(1)=(VLightOffset=(X=-114.760002,Y=27.200001,Z=3.600000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	HeadLights(0)=(VLightOffset=(X=30.240000,Y=17.360001,Z=31.000000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(1)=(VLightOffset=(X=30.240000,Y=-17.360001,Z=31.000000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(2)=(VLightOffset=(X=111.680000,Y=7.600000,Z=-4.584000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(3)=(VLightOffset=(X=111.680000,Y=-7.600000,Z=-4.584000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	GroundPower=1.750000
	VehicleFlagOffset=(Z=-16.000000)
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=97.736000,Y=-6.400000,Z=5.424000),FXRange=13)
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=5.550000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="JSDXWheel")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="JSDXTurret")
	UseExplosionSnd2=False
	WreckPartColHeight=48.000000
	bEnableShield=True
	ShieldLevel=0.600000
	Texture=Texture'XVehicles.Skins.CybotMetal'
	Mesh=SkeletalMesh'Warthog'
	SoundRadius=70
	SoundVolume=100
	CollisionRadius=60.000000
	CollisionHeight=60.000000
	Mass=2200.000000
}
