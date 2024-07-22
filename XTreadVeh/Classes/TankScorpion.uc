//=============================================================================
// TankScorpion.
//=============================================================================
class TankScorpion expands TreadCraftPhys;

/*
#forceexec MESH  MODELIMPORT MESH=TankScorpion MODELFILE=Z:\XV\Halo\SCORPION_2.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=TankScorpion X=0 Y=0 Z=0 YAW=-64 PITCH=0 ROLL=64
#forceexec MESH  LODPARAMS MESH=TankScorpion STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=TankScorpion X=1 Y=1 Z=1

#forceexec MESHMAP SETTEXTURE MESHMAP=TankScorpion NUM=0 TEXTURE=TankScorpion
#forceexec MESHMAP SETTEXTURE MESHMAP=TankScorpion NUM=1 TEXTURE=ETread01
#forceexec MESHMAP SETTEXTURE MESHMAP=TankScorpion NUM=2 TEXTURE=ETread01
// */

/*
#forceexec MESH  MODELIMPORT MESH=TankScorpionCanon MODELFILE=Z:\XV\Halo\Scorpion_T_.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=TankScorpionCanon X=0 Y=0 Z=0 YAW=-64 PITCH=0 ROLL=64
#forceexec MESH  LODPARAMS MESH=TankScorpionCanon STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=TankScorpionCanon X=1 Y=1 Z=1

#forceexec MESHMAP SETTEXTURE MESHMAP=TankScorpionCanon NUM=0 TEXTURE=TankScorpion
// */

/*
#forceexec MESH  MODELIMPORT MESH=TankScorpionCanonPitch MODELFILE=Z:\XV\Halo\Scorpion_T_gun.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=TankScorpionCanonPitch X=0 Y=0 Z=0 YAW=-64 PITCH=0 ROLL=64
#forceexec MESH  LODPARAMS MESH=TankScorpionCanonPitch STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=TankScorpionCanonPitch X=1 Y=1 Z=1

#forceexec MESHMAP SETTEXTURE MESHMAP=TankScorpionCanonPitch NUM=0 TEXTURE=TankScorpion
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
			Skin = Texture'TankScorpionMarsh';
			break;
		case 1:
			Skin = Texture'TankScorpionArctic';
			break;
		case 2:
			Skin = Texture'TankScorpionDesert';
			break;
		case 3:
			Skin = Texture'TankScorpionForest';
			break;
		default: 
			Skin = Texture'TankScorpion';
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
}

defaultproperties
{
	CurrentTeamColor=42
	MaxGroundSpeed=500.000000
	TreadPan(0)=Texture'XTreadVeh.TreadsE.ETread01'
	TreadPan(1)=Texture'XTreadVeh.TreadsE.ETread02'
	TreadPan(2)=Texture'XTreadVeh.TreadsE.ETread03'
	TreadPan(3)=Texture'XTreadVeh.TreadsE.ETread04'
	TreadPan(4)=Texture'XTreadVeh.TreadsE.ETread05'
	TreadPan(5)=Texture'XTreadVeh.TreadsE.ETread06'
	TreadPan(6)=Texture'XTreadVeh.TreadsE.ETread07'
	TreadPan(7)=Texture'XTreadVeh.TreadsE.ETread08'
	TreadPan(8)=Texture'XTreadVeh.TreadsE.ETread09'
	TreadPan(9)=Texture'XTreadVeh.TreadsE.ETread10'
	TreadPan(10)=Texture'XTreadVeh.TreadsE.ETread11'
	TreadPan(11)=Texture'XTreadVeh.TreadsE.ETread12'
	TreadPan(12)=Texture'XTreadVeh.TreadsE.ETread13'
	TreadPan(13)=Texture'XTreadVeh.TreadsE.ETread14'
	TreadPan(14)=Texture'XTreadVeh.TreadsE.ETread15'
	TreadPan(15)=Texture'XTreadVeh.TreadsE.ETread16'
	Treads(0)=(MovPerTreadCycle=13.500000,TreadMesh=LodMesh'Botpack.Smokebm',TreadSkinN=1,TreadOffset=(X=-12.500000,Y=-98.125000,Z=-43.000000),WheelFramesN=17,WheelAnimSet="WheelsMove",WheelSize=20.625000,TrackWidth=52.000000,TrackFrontOffset=(X=128.000000),TrackBackOffset=(X=-128.000000))
	Treads(1)=(MovPerTreadCycle=13.500000,TreadMesh=LodMesh'Botpack.Smokebm',TreadSkinN=2,TreadOffset=(X=-12.500000,Y=98.125000,Z=-43.000000),WheelFramesN=17,WheelAnimSet="WheelsMove",WheelSize=20.625000,TrackWidth=52.000000,TrackFrontOffset=(X=128.000000),TrackBackOffset=(X=-128.000000))
	WreckTrackColHeight=32.000000
	WreckTrackColRadius=64.000000
	AIRating=3.000000
	VehicleGravityScale=3.000000
	WAccelRate=350.000000
	Health=1350
	VehicleName="Tank Scorpion"
	ExitOffset=(X=0.000000,Y=203.000000)
	BehinViewViewOffset=(X=-250.000000,Y=0.000000,Z=100.000000)
	StartSound=Sound'XTreadVeh.TankScorpion.engine_start'
	EndSound=Sound'XTreadVeh.TankScorpion.engine_stop'
	EngineSound=Sound'XTreadVeh.TankScorpion.engine_loop1'
	bEngDynSndPitch=True
	MinEngPitch=32
	MaxEngPitch=96
	bDriverWOffset=True
	DriverWeapon=(WeaponClass=Class'TankScorpionTurret',WeaponOffset=(X=-87.000000,Z=40.000000))
	VehicleKeyInfoStr="Tank Scorpion keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%mutate VehicleCamera% to change camera|%ThrowWeapon% to exit the vehicle"
	bSlopedPhys=True
	FrontWide=(X=103.750000,Y=98.125000,Z=-10.000000)
	BackWide=(X=-138.750000,Y=98.125000,Z=-10.000000)
	ZRange=260.000000
	MaxObstclHeight=44.000000
	DriverCrosshairTex=Texture'XTreadVeh.Icons.TankGKOneMainCross'
	bUseVehicleLights=True
	HeadLights(0)=(VLightOffset=(X=136.500000,Y=15.000000,Z=-13.500000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(1)=(VLightOffset=(X=136.500000,Y=26.000000,Z=-13.500000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	GroundPower=2.500000
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=52.000000,Y=10.000000,Z=25.000000),FXRange=12)
	DestroyedExplDmg=420
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=8.125000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=3.440000,AttachName="TankScorpionTurret")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=103.750000,Y=98.125000,Z=-10.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-138.750000,Y=98.125000,Z=-10.000000))
	ExplosionGFX(4)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(Y=98.125000,Z=-10.000000))
	WreckPartColHeight=45.000000
	WreckPartColRadius=130.000000
	bEnableShield=True
	ShieldLevel=0.650000
	Mesh=SkeletalMesh'TankScorpion'
	SoundRadius=70
	SoundVolume=100
	CollisionRadius=132.500000
	CollisionHeight=75.000000
	Mass=4800.000000
}
