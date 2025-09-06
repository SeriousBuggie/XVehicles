//=============================================================================
// Hellbender.
//=============================================================================
class Hellbender expands WheeledCarPhys;

/*
#forceexec MESH  MODELIMPORT MESH=Hellbender MODELFILE=Z:\XV\PRV_3.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=Hellbender X=-15 Y=0 Z=30 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=Hellbender STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=Hellbender X=0.625 Y=0.625 Z=0.625
#forceexec MESHMAP SETTEXTURE MESHMAP=Hellbender NUM=0 TEXTURE=PRVGreen
#forceexec MESHMAP SETTEXTURE MESHMAP=Hellbender NUM=1 TEXTURE=PRVEnergy3
#forceexec MESHMAP SETTEXTURE MESHMAP=Hellbender NUM=2 TEXTURE=RainFX.SGlass
#forceexec MESHMAP SETTEXTURE MESHMAP=Hellbender NUM=3 TEXTURE=PRVtagFallBack
// */

/*
#forceexec MESH  MODELIMPORT MESH=HellbenderWheel MODELFILE=Z:\XV\PRV_LF.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=HellbenderWheel X=118.2 Y=77 Z=-31.6 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=HellbenderWheel STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=HellbenderWheel X=0.625 Y=0.625 Z=0.625
#forceexec MESHMAP SETTEXTURE MESHMAP=HellbenderWheel NUM=0 TEXTURE=PRVGreen
#forceexec MESH BOUNDINGBOX MESH=HellbenderWheel XMIN=27.8494 YMIN=20 ZMIN=-120.432 XMAX=208.511 YMAX=154.295 ZMAX=57.1542
// */

/*
#forceexec MESH  MODELIMPORT MESH=HellbenderWheelMir MODELFILE=Z:\XV\PRV_RF.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=HellbenderWheelMir X=118.2 Y=-77 Z=-31.6 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=HellbenderWheelMir STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=HellbenderWheelMir X=0.625 Y=0.625 Z=0.625
#forceexec MESHMAP SETTEXTURE MESHMAP=HellbenderWheelMir NUM=0 TEXTURE=PRVGreen
#forceexec MESH BOUNDINGBOX MESH=HellbenderWheelMir XMIN=27.8494 YMIN=-154.295 ZMIN=-120.432 XMAX=208.511 YMAX=-20.1538 ZMAX=57.1542
// */

/*
#forceexec MESH  MODELIMPORT MESH=HellbenderSideGun MODELFILE=Z:\XV\PRV_SG.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=HellbenderSideGun X=5.75 Y=-0 Z=1.5 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=HellbenderSideGun STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=HellbenderSideGun X=0.625 Y=0.625 Z=0.625
#forceexec MESHMAP SETTEXTURE MESHMAP=HellbenderSideGun NUM=0 TEXTURE=PRVGreen
// */

/*
#forceexec MESH  MODELIMPORT MESH=HellbenderSideTurret MODELFILE=Z:\XV\PRV_ST.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=HellbenderSideTurret X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=HellbenderSideTurret STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=HellbenderSideTurret X=0.625 Y=0.625 Z=0.625
#forceexec MESHMAP SETTEXTURE MESHMAP=HellbenderSideTurret NUM=0 TEXTURE=PRVGreen
// */

/*
#forceexec MESH  MODELIMPORT MESH=HellbenderRearGun MODELFILE=Z:\XV\PRV_RG.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=HellbenderRearGun X=14 Y=0 Z=89 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=HellbenderRearGun STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=HellbenderRearGun X=0.625 Y=0.625 Z=0.625
#forceexec MESHMAP SETTEXTURE MESHMAP=HellbenderRearGun NUM=0 TEXTURE=PRVGreen
// */

/*
#forceexec MESH  MODELIMPORT MESH=HellbenderRearTurret MODELFILE=Z:\XV\PRV_RT.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=HellbenderRearTurret X=-5 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=HellbenderRearTurret STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=HellbenderRearTurret X=0.625 Y=0.625 Z=0.625
#forceexec MESHMAP SETTEXTURE MESHMAP=HellbenderRearTurret NUM=0 TEXTURE=PRVGreen
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
		case 1:
		case 2:
			Texture = Texture'PRVGreen';
			break;
		case 0:
		case 3:
		default:
			Texture = Texture'PRVYellow';
			break;
	}
	MultiSkins[0] = Texture;
	if (GVT != None)
	{
		GVT.MultiSkins[0] = MultiSkins[0];
	}
}

defaultproperties
{
	CurrentTeamColor=42
	Wheels(0)=(WheelOffset=(X=83.000000,Y=-48.000000,Z=-39.000000),WheelClass=Class'HellbenderWheel',WheelMesh=SkeletalMesh'HellbenderWheel')
	Wheels(1)=(WheelOffset=(X=83.000000,Y=48.000000,Z=-39.000000),WheelClass=Class'HellbenderWheel',WheelMesh=SkeletalMesh'HellbenderWheelMir',bMirroredWheel=True)
	Wheels(2)=(WheelOffset=(X=-82.000000,Y=-48.000000,Z=-39.000000),WheelClass=Class'HellbenderWheel',WheelMesh=SkeletalMesh'HellbenderWheel')
	Wheels(3)=(WheelOffset=(X=-82.000000,Y=48.000000,Z=-39.000000),WheelClass=Class'HellbenderWheel',WheelMesh=SkeletalMesh'HellbenderWheelMir',bMirroredWheel=True)
	MaxGroundSpeed=750.000000
	WheelTurnSpeed=16000.000000
	WheelsRadius=28.000000
	TractionWheelsPosition=-80.000000
	AIRating=2.000000
	VehicleGravityScale=2.350000
	WAccelRate=480.000000
	Health=900
	VehicleName="Hellbender"
	ExitOffset=(Y=150.000000)
	BehinViewViewOffset=(X=-220.000000,Z=112.500000)
	StartSound=Sound'XWheelVeh.JeepSDX.JeepStart'
	EndSound=Sound'XWheelVeh.JeepSDX.JeepStop'
	EngineSound=Sound'XWheelVeh.JeepSDX.JeepEng'
	bEngDynSndPitch=True
	MinEngPitch=16
	MaxEngPitch=75
	PassengerSeats(0)=(PassengerWeapon=Class'HellbenderSideTurret',PassengerWOffset=(X=17.000000,Y=24.000000,Z=48.000000),CameraOffset=(Z=37.500000),CamBehindviewOffset=(X=-120.000000,Z=17.500000),bIsAvailable=True,SeatName="Hellbender Side Turret")
	PassengerSeats(1)=(PassengerWeapon=Class'HellbenderRearTurret',PassengerWOffset=(X=-90.000000,Y=-2.000000,Z=-14.000000),CameraOffset=(Z=37.500000),CamBehindviewOffset=(X=-175.000000,Z=70.000000),bIsAvailable=True,SeatName="Hellbender Rear Turret")
	VehicleKeyInfoStr="Hellbender keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|1, 2 to switch seats|0 to toggle light|%mutate VehicleCamera% to change camera|%ThrowWeapon% to exit the vehicle"
	bSlopedPhys=True
	FrontWide=(X=80.000000,Y=60.000000,Z=-7.500000)
	BackWide=(X=-80.000000,Y=60.000000,Z=-7.500000)
	ZRange=220.000000
	MaxObstclHeight=25.000000
	HornSnd=Sound'XWheelVeh.JeepSDX.JeepHorn'
	bDriverHorn=True
	HornTimeInterval=2.000000
	PassCrosshairTex(0)=Texture'XWheelVeh.Icons.JeepSDXTurretCross'
	PassCrosshairTex(1)=Texture'XWheelVeh.Icons.JeepSDXTurretCross'
	ArmorType(7)=(ArmorLevel=0.300000,ProtectionType="Burned")
	bUseVehicleLights=True
	bUseSignalLights=True
	StopLights(0)=(VLightOffset=(X=-125.500000,Y=59.500000,Z=5.000000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	StopLights(1)=(VLightOffset=(X=-125.500000,Y=52.500000,Z=5.000000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	StopLights(2)=(VLightOffset=(X=-125.500000,Y=-62.500000,Z=5.000000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	StopLights(3)=(VLightOffset=(X=-125.500000,Y=-55.500000,Z=5.000000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(0)=(VLightOffset=(X=-125.500000,Y=52.500000,Z=5.000000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(1)=(VLightOffset=(X=-125.500000,Y=-55.500000,Z=5.000000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	HeadLights(0)=(VLightOffset=(X=120.000000,Y=29.500000,Z=-7.500000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000)
	HeadLights(1)=(VLightOffset=(X=120.000000,Y=-30.500000,Z=-7.500000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000)
	HeadLights(2)=(VLightOffset=(X=120.000000,Y=42.500000,Z=-7.500000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(3)=(VLightOffset=(X=120.000000,Y=-44.000000,Z=-7.500000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(4)=(VLightOffset=(X=120.000000,Y=29.500000,Z=-14.500000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000)
	HeadLights(5)=(VLightOffset=(X=120.000000,Y=-30.500000,Z=-14.500000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000)
	HeadLights(6)=(VLightOffset=(X=120.000000,Y=42.500000,Z=-14.500000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000)
	HeadLights(7)=(VLightOffset=(X=120.000000,Y=-44.000000,Z=-14.500000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000)
	GroundPower=2.100000
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=78.000000,Y=-10.000000,Z=14.000000),FXRange=13)
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=5.550000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="HellbenderWheel")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="JSDXTurret")
	UseExplosionSnd2=False
	WreckPartColHeight=48.000000
	bEnableShield=True
	ShieldLevel=0.600000
	Mesh=SkeletalMesh'Hellbender'
	SoundRadius=70
	SoundVolume=100
	CollisionRadius=80.000000
	CollisionHeight=66.000000
	Mass=2700.000000
}
