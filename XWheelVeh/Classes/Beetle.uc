//=============================================================================
// Beetle.
//=============================================================================
class Beetle expands WheeledCarPhys;

/*
#forceexec MESH  MODELIMPORT MESH=Beetle MODELFILE=Z:\XV\beetle\bug68\Hull.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=Beetle X=150 Y=43 Z=19.5 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=Beetle STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=Beetle X=0.156 Y=0.156 Z=0.156
#forceexec MESHMAP SETTEXTURE MESHMAP=Beetle NUM=0 TEXTURE=BeetleFrontGold
#forceexec MESHMAP SETTEXTURE MESHMAP=Beetle NUM=1 TEXTURE=BeetleChrome
#forceexec MESHMAP SETTEXTURE MESHMAP=Beetle NUM=2 TEXTURE=BeetleSideGold
#forceexec MESHMAP SETTEXTURE MESHMAP=Beetle NUM=3 TEXTURE=BeetleRearGold
#forceexec MESHMAP SETPOLYFLAGS MESHMAP=Beetle NUM=1 POLYFLAGS=16
// */

/*
#forceexec MESH  MODELIMPORT MESH=BeetleWheel MODELFILE=Z:\XV\beetle\bug68\WheelL.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=BeetleWheel X=698 Y=348 Z=-224 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=BeetleWheel STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=BeetleWheel X=0.156 Y=0.156 Z=0.156
#forceexec MESHMAP SETTEXTURE MESHMAP=BeetleWheel NUM=4 TEXTURE=BeetleRim
#forceexec MESHMAP SETTEXTURE MESHMAP=BeetleWheel NUM=5 TEXTURE=BeetleProfile
// */

/*
#forceexec MESH  MODELIMPORT MESH=BeetleWheelMir MODELFILE=Z:\XV\beetle\bug68\WheelR.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=BeetleWheelMir X=698 Y=-246 Z=-224 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=BeetleWheelMir STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=BeetleWheelMir X=0.156 Y=0.156 Z=0.156
#forceexec MESHMAP SETTEXTURE MESHMAP=BeetleWheelMir NUM=4 TEXTURE=BeetleRim
#forceexec MESHMAP SETTEXTURE MESHMAP=BeetleWheelMir NUM=5 TEXTURE=BeetleProfile
// */

/*
#forceexec MESH  MODELIMPORT MESH=BeetleGun MODELFILE=Z:\XV\beetle\bug68\TankMachineGun_3.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=BeetleGun X=48 Y=1 Z=12 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=BeetleGun STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=BeetleGun X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=BeetleGun NUM=0 TEXTURE=BeetleTurret
// */

/*
#forceexec MESH  MODELIMPORT MESH=BeetleTurret MODELFILE=Z:\XV\beetle\bug68\BadgerMinigun_.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=BeetleTurret X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=BeetleTurret STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=BeetleTurret X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=BeetleTurret NUM=0 TEXTURE=BeetleTurret
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
			MultiSkins[0] = Texture'BeetleFrontRed';
			MultiSkins[2] = Texture'BeetleSideRed';
			MultiSkins[3] = Texture'BeetleRearRed';
			break;
		case 1:
			MultiSkins[0] = Texture'BeetleFrontBlue';
			MultiSkins[2] = Texture'BeetleSideBlue';
			MultiSkins[3] = Texture'BeetleRearBlue';
			break;
		case 2:
			MultiSkins[0] = Texture'BeetleFrontGreen';
			MultiSkins[2] = Texture'BeetleSideGreen';
			MultiSkins[3] = Texture'BeetleRearGreen';
			break;
		case 3:
		default:
			MultiSkins[0] = Texture'BeetleFrontGold';
			MultiSkins[2] = Texture'BeetleSideGold';
			MultiSkins[3] = Texture'BeetleRearGold';
			break;
	}
	if (GVT != None)
	{
		GVT.MultiSkins[0] = MultiSkins[0];
		GVT.MultiSkins[2] = MultiSkins[2];
		GVT.MultiSkins[3] = MultiSkins[3];
	}
}

defaultproperties
{
	CurrentTeamColor=42
	Wheels(0)=(WheelOffset=(X=85.500000,Y=-47.500000,Z=-38.000000),WheelClass=Class'BeetleWheel',WheelMesh=SkeletalMesh'BeetleWheel')
	Wheels(1)=(WheelOffset=(X=85.500000,Y=45.000000,Z=-38.000000),WheelClass=Class'BeetleWheel',WheelMesh=SkeletalMesh'BeetleWheelMir',bMirroredWheel=True)
	Wheels(2)=(WheelOffset=(X=-75.500000,Y=-47.500000,Z=-38.000000),WheelClass=Class'BeetleWheel',WheelMesh=SkeletalMesh'BeetleWheel')
	Wheels(3)=(WheelOffset=(X=-75.500000,Y=45.000000,Z=-38.000000),WheelClass=Class'BeetleWheel',WheelMesh=SkeletalMesh'BeetleWheelMir',bMirroredWheel=True)
	MaxGroundSpeed=875.000000
	WheelTurnSpeed=16000.000000
	WheelsRadius=25.000000
	TractionWheelsPosition=-80.000000
	VehicleGravityScale=2.000000
	WAccelRate=515.000000
	Health=600
	VehicleName="Beetle"
	ExitOffset=(X=0.000000,Y=150.000000)
	BehinViewViewOffset=(X=-220.000000,Y=0.000000,Z=100.000000)
	StartSound=Sound'XWheelVeh.Beetle.BeetleStart'
	EndSound=Sound'XWheelVeh.Beetle.BeetleStop'
	EngineSound=Sound'XWheelVeh.Beetle.BeetleEngine'
	bEngDynSndPitch=True
	MinEngPitch=32
	MaxEngPitch=96
	PassengerSeats(0)=(PassengerWeapon=Class'BeetleTurret',PassengerWOffset=(X=-19.000000,Z=39.500000),CameraOffset=(Z=37.500000),CamBehindviewOffset=(X=-75.000000,Z=7.500000),bIsAvailable=True,SeatName="Light Plasma Dual Cannon")
	VehicleKeyInfoStr="Beetle keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|1, 2 to switch seats|9 to toggle winter tires|0 to toggle light|%mutate VehicleCamera% to change camera|%ThrowWeapon% to exit the vehicle"
	bSlopedPhys=True
	FrontWide=(X=86.000000,Y=57.000000,Z=-7.500000)
	BackWide=(X=-76.000000,Y=57.000000,Z=-7.500000)
	ZRange=220.000000
	MaxObstclHeight=25.000000
	HornSnd=Sound'XWheelVeh.Beetle.BeetleHorn'
	bDriverHorn=True
	HornTimeInterval=2.000000
	PassCrosshairTex(0)=Texture'XWheelVeh.Icons.JeepSDXTurretCross'
	PassCrossColor(0)=(R=0,B=0)
	bUseVehicleLights=True
	bUseSignalLights=True
	StopLights(0)=(VLightOffset=(X=-110.000000,Y=42.000000,Z=-22.000000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	StopLights(1)=(VLightOffset=(X=-110.000000,Y=-42.000000,Z=-22.000000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(0)=(VLightOffset=(X=-110.000000,Y=42.000000,Z=-22.000000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(1)=(VLightOffset=(X=-110.000000,Y=-42.000000,Z=-22.000000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	HeadLights(0)=(VLightOffset=(X=114.000000,Y=41.000000,Z=-21.000000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(1)=(VLightOffset=(X=114.000000,Y=-41.000000,Z=-21.000000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	GroundPower=1.750000
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=-105.000000,Z=-3.500000),FXRange=13)
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=5.550000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="BeetleWheel")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="BeetleTurret")
	UseExplosionSnd2=False
	WreckPartColHeight=48.000000
	bEnableShield=True
	ShieldLevel=0.600000
	Texture=Texture'XVehicles.Skins.CybotMetal'
	Mesh=SkeletalMesh'Beetle'
	SoundRadius=70
	SoundVolume=255
	CollisionRadius=57.000000
	CollisionHeight=58.000000
	Mass=2200.000000
}
