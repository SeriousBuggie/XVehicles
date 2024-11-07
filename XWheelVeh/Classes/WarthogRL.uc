//=============================================================================
// WarthogRG.
//=============================================================================
class WarthogRL expands WheeledCarPhys;

/*
#forceexec MESH  MODELIMPORT MESH=WarthogRLGun MODELFILE=Z:\XV\halo\Warthog_RL_Gun.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=WarthogRLGun X=42.65 Y=0 Z=62.27 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=WarthogRLGun STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=WarthogRLGun X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogRLGun NUM=0 TEXTURE=WarthogRLGun
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogRLGun NUM=1 TEXTURE=WarthogRLGun
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogRLGun NUM=2 TEXTURE=WarthogRLGun
// */

/*
#forceexec MESH  MODELIMPORT MESH=WarthogRLTurret MODELFILE=Z:\XV\halo\Warthog_RL.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=WarthogRLTurret X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=WarthogRLTurret STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=WarthogRLTurret X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogRLTurret NUM=0 TEXTURE=WarthogRLGun
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogRLTurret NUM=1 TEXTURE=WarthogRLGun
#forceexec MESHMAP SETTEXTURE MESHMAP=WarthogRLTurret NUM=2 TEXTURE=WarthogRLGun
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
			MultiSkins[0] = Texture'WarthogRLRed';
			break;
		case 1:
			MultiSkins[0] = Texture'WarthogRLBlue';
			break;
		case 2:
			MultiSkins[0] = Texture'WarthogRLGreen';
			break;
		case 3:
		default:
			MultiSkins[0] = Texture'WarthogRLGold';
			break;
	}
	if (GVT != None)
		GVT.MultiSkins[0] = MultiSkins[0];
}

defaultproperties
{
	CurrentTeamColor=42
	Wheels(0)=(WheelOffset=(X=101.599998,Y=-27.100000,Z=-45.500000),WheelClass=Class'WarthogRLWheel',WheelMesh=SkeletalMesh'WarthogWheel')
	Wheels(1)=(WheelOffset=(X=101.599998,Y=27.100000,Z=-45.500000),WheelClass=Class'WarthogRLWheel',WheelMesh=SkeletalMesh'WarthogWheelMir',bMirroredWheel=True)
	Wheels(2)=(WheelOffset=(X=-98.500000,Y=-27.100000,Z=-45.500000),WheelClass=Class'WarthogRLWheel',WheelMesh=SkeletalMesh'WarthogWheel')
	Wheels(3)=(WheelOffset=(X=-98.500000,Y=27.100000,Z=-45.500000),WheelClass=Class'WarthogRLWheel',WheelMesh=SkeletalMesh'WarthogWheelMir',bMirroredWheel=True)
	MaxGroundSpeed=750.000000
	WheelTurnSpeed=16000.000000
	WheelsRadius=31.000000
	TractionWheelsPosition=-100.000000
	AIRating=2.000000
	VehicleGravityScale=2.350000
	WAccelRate=480.000000
	Health=900
	VehicleName="Warthog RL"
	ExitOffset=(X=0.000000,Y=150.000000)
	BehinViewViewOffset=(X=-220.000000,Y=0.000000,Z=112.500000)
	StartSound=Sound'XWheelVeh.Warthog.startup'
	EndSound=Sound'XWheelVeh.Warthog.Shutdown'
	EngineSound=Sound'XWheelVeh.Warthog.Running'
	bEngDynSndPitch=True
	MinEngPitch=16
	MaxEngPitch=75
	PassengerSeats(0)=(PassengerWeapon=Class'WarthogRLTurret',PassengerWOffset=(X=-78.410004,Z=-10.910000),CameraOffset=(Z=37.500000),CamBehindviewOffset=(X=-75.000000,Z=77.500000),bIsAvailable=True,SeatName="Heavy Plasma Cannon")
	VehicleKeyInfoStr="Warthog RL keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|1, 2 to switch seats|0 to toggle light|%mutate VehicleCamera% to change camera|%ThrowWeapon% to exit the vehicle"
	bSlopedPhys=True
	FrontWide=(X=100.000000,Y=75.000000,Z=-7.500000)
	BackWide=(X=-100.000000,Y=75.000000,Z=-7.500000)
	ZRange=220.000000
	MaxObstclHeight=25.000000
	HornSnd=Sound'XWheelVeh.JeepSDX.JeepHorn'
	bDriverHorn=True
	HornTimeInterval=2.000000
	PassCrosshairTex(0)=Texture'XWheelVeh.Icons.JeepSDXTurretCross'
	PassCrossColor(0)=(R=255,G=0,B=0)
	ArmorType(7)=(ArmorLevel=0.300000,ProtectionType="Burned")
	bUseVehicleLights=True
	bUseSignalLights=True
	StopLights(0)=(VLightOffset=(X=-143.449997,Y=-34.000000,Z=4.500000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	StopLights(1)=(VLightOffset=(X=-143.449997,Y=34.000000,Z=4.500000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(0)=(VLightOffset=(X=-143.449997,Y=-34.000000,Z=4.500000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(1)=(VLightOffset=(X=-143.449997,Y=34.000000,Z=4.500000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	HeadLights(0)=(VLightOffset=(X=37.799999,Y=21.700001,Z=38.750000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(1)=(VLightOffset=(X=37.799999,Y=-21.700001,Z=38.750000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(2)=(VLightOffset=(X=139.600006,Y=9.500000,Z=-5.730000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(3)=(VLightOffset=(X=139.600006,Y=-9.500000,Z=-5.730000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	GroundPower=2.100000
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=122.169998,Y=-8.000000,Z=6.780000),FXRange=13)
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=5.550000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="JSDXWheel")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="JSDXTurret")
	UseExplosionSnd2=False
	WreckPartColHeight=48.000000
	bEnableShield=True
	ShieldLevel=0.600000
	Texture=Texture'XVehicles.Skins.CybotMetal'
	Mesh=SkeletalMesh'Warthog'
	MultiSkins(0)=Texture'XWheelVeh.Warthog.WarthogRLBlue'
	SoundRadius=70
	SoundVolume=100
	CollisionRadius=75.000000
	CollisionHeight=75.000000
	Mass=2700.000000
}
