//=============================================================================
// IonTank.
//=============================================================================
class IonTank expands TreadCraftPhys;

/*
#forceexec MESH  MODELIMPORT MESH=IonTank MODELFILE=Z:\XV\AS\IonTankChassisSimple.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=IonTank X=0 Y=0 Z=79.1
#forceexec MESH  LODPARAMS MESH=IonTank STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=IonTank X=0.9 Y=0.9 Z=0.9

#forceexec MESHMAP SETTEXTURE MESHMAP=IonTank NUM=0 TEXTURE=IonTankBody
#forceexec MESHMAP SETTEXTURE MESHMAP=IonTank NUM=1 TEXTURE=FTread01
#forceexec MESHMAP SETTEXTURE MESHMAP=IonTank NUM=2 TEXTURE=FTread01
// */

/*
#forceexec MESH  MODELIMPORT MESH=IonTankCanon MODELFILE=Z:\XV\AS\IonTankTurretSimple_.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=IonTankCanon X=0 Y=0 Z=155
#forceexec MESH  LODPARAMS MESH=IonTankCanon STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=IonTankCanon X=0.9 Y=0.9 Z=0.9

#forceexec MESHMAP SETTEXTURE MESHMAP=IonTankCanon NUM=0 TEXTURE=IonTankTurret
// */

/*
#forceexec MESH  MODELIMPORT MESH=IonTankCanonPitch MODELFILE=Z:\XV\AS\IonTankTurretSimpleGun.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=IonTankCanonPitch X=12 Y=0 Z=146
#forceexec MESH  LODPARAMS MESH=IonTankCanonPitch STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=IonTankCanonPitch X=0.9 Y=0.9 Z=0.9

#forceexec MESHMAP SETTEXTURE MESHMAP=IonTankCanonPitch NUM=0 TEXTURE=IonTankTurret
// */

/*
#forceexec ANIM IMPORT ANIM=IonTankCanonAnim ANIMFILE=Z:\XV\AS\IonTankTurretSimpleGun.psa IMPORTSEQS=1
#forceexec MESH DEFAULTANIM MESH=IonTankCanonPitch ANIM=IonTankCanonAnim
#forceexec ANIM DIGEST ANIM=IonTankCanonAnim VERBOSE
// */

/*
#forceexec MESH  MODELIMPORT MESH=IonTankMGRot MODELFILE=Z:\XV\AS\IONTankMachineGun_.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=IonTankMGRot X=0 Y=0 Z=10
#forceexec MESH  LODPARAMS MESH=IonTankMGRot STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=IonTankMGRot X=0.9 Y=0.9 Z=0.9

#forceexec MESHMAP SETTEXTURE MESHMAP=IonTankMGRot NUM=0 TEXTURE=TankNoColor
// */

/*
#forceexec MESH  MODELIMPORT MESH=IonTankMGun MODELFILE=Z:\XV\AS\IONTankMachineGunGun.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=IonTankMGun X=19 Y=0 Z=26
#forceexec MESH  LODPARAMS MESH=IonTankMGun STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=IonTankMGun X=0.9 Y=0.9 Z=0.9

#forceexec MESHMAP SETTEXTURE MESHMAP=IonTankMGun NUM=0 TEXTURE=TankNoColor
// */

defaultproperties
{
	MaxGroundSpeed=500.000000
	TreadPan(0)=Texture'XTreadVeh.TreadsF.FTread01'
	TreadPan(1)=Texture'XTreadVeh.TreadsF.FTread02'
	TreadPan(2)=Texture'XTreadVeh.TreadsF.FTread03'
	TreadPan(3)=Texture'XTreadVeh.TreadsF.FTread04'
	TreadPan(4)=Texture'XTreadVeh.TreadsF.FTread05'
	TreadPan(5)=Texture'XTreadVeh.TreadsF.FTread06'
	TreadPan(6)=Texture'XTreadVeh.TreadsF.FTread07'
	TreadPan(7)=Texture'XTreadVeh.TreadsF.FTread08'
	TreadPan(8)=Texture'XTreadVeh.TreadsF.FTread09'
	TreadPan(9)=Texture'XTreadVeh.TreadsF.FTread10'
	TreadPan(10)=Texture'XTreadVeh.TreadsF.FTread11'
	TreadPan(11)=Texture'XTreadVeh.TreadsF.FTread12'
	TreadPan(12)=Texture'XTreadVeh.TreadsF.FTread13'
	TreadPan(13)=Texture'XTreadVeh.TreadsF.FTread14'
	TreadPan(14)=Texture'XTreadVeh.TreadsF.FTread15'
	TreadPan(15)=Texture'XTreadVeh.TreadsF.FTread16'
	Treads(0)=(MovPerTreadCycle=21.000000,TreadMesh=LodMesh'Botpack.Smokebm',TreadSkinN=1,TreadOffset=(X=-12.500000,Y=-98.125000,Z=-43.000000),WheelFramesN=17,WheelAnimSet="WheelsMove",WheelSize=20.625000,TrackWidth=52.000000,TrackFrontOffset=(X=128.000000),TrackBackOffset=(X=-128.000000))
	Treads(1)=(MovPerTreadCycle=21.000000,TreadMesh=LodMesh'Botpack.Smokebm',TreadSkinN=2,TreadOffset=(X=-12.500000,Y=98.125000,Z=-43.000000),WheelFramesN=17,WheelAnimSet="WheelsMove",WheelSize=20.625000,TrackWidth=52.000000,TrackFrontOffset=(X=128.000000),TrackBackOffset=(X=-128.000000))
	WreckTrackColHeight=32.000000
	WreckTrackColRadius=64.000000
	AIRating=3.000000
	VehicleGravityScale=3.000000
	WAccelRate=350.000000
	Health=1350
	VehicleName="Ion Tank"
	ExitOffset=(Y=203.000000)
	BehinViewViewOffset=(X=-300.000000,Z=150.000000)
	StartSound=Sound'XTreadVeh.Goliath.TankStart01'
	EndSound=Sound'XTreadVeh.Goliath.TankStop01'
	EngineSound=Sound'XTreadVeh.TankGKOne.TankGKOneEng'
	bEngDynSndPitch=True
	MinEngPitch=32
	MaxEngPitch=96
	bDriverWOffset=True
	DriverWeapon=(WeaponClass=Class'IonTankTurret',WeaponOffset=(X=-72.500000,Z=39.500000))
	PassengerSeats(0)=(PassengerWeapon=Class'IonTankMGRot',PassengerWOffset=(X=-72.500000,Z=80.500000),CameraOffset=(Z=37.500000),CamBehindviewOffset=(X=-82.500000,Z=17.500000),bIsAvailable=True,SeatName="Machine Gun")
	VehicleKeyInfoStr="Ion Tank keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%mutate VehicleCamera% to change camera|%ThrowWeapon% to exit the vehicle"
	bSlopedPhys=True
	FrontWide=(X=103.750000,Y=98.125000,Z=-10.000000)
	BackWide=(X=-138.750000,Y=98.125000,Z=-10.000000)
	ZRange=260.000000
	MaxObstclHeight=44.000000
	DriverCrosshairTex=Texture'XTreadVeh.Icons.TankGKOneMainCross'
	PassCrosshairTex(0)=Texture'XTreadVeh.Icons.TankGKOnePassCross'
	bUseVehicleLights=True
	bUseSignalLights=True
	StopLights(0)=(VLightOffset=(X=-186.300003,Y=-122.599998,Z=-22.400000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	StopLights(1)=(VLightOffset=(X=-186.300003,Y=-114.599998,Z=-22.400000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	StopLights(2)=(VLightOffset=(X=-186.300003,Y=-106.599998,Z=-22.400000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	StopLights(3)=(VLightOffset=(X=-186.300003,Y=107.400002,Z=-22.400000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	StopLights(4)=(VLightOffset=(X=-186.300003,Y=115.400002,Z=-22.400000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	StopLights(5)=(VLightOffset=(X=-186.300003,Y=123.400002,Z=-22.400000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(0)=(VLightOffset=(X=-186.300003,Y=-122.599998,Z=-22.400000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(1)=(VLightOffset=(X=-186.300003,Y=-114.599998,Z=-22.400000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(2)=(VLightOffset=(X=-186.300003,Y=-106.599998,Z=-22.400000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(3)=(VLightOffset=(X=-186.300003,Y=107.400002,Z=-22.400000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(4)=(VLightOffset=(X=-186.300003,Y=115.400002,Z=-22.400000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(5)=(VLightOffset=(X=-186.300003,Y=123.400002,Z=-22.400000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	HeadLights(0)=(VLightOffset=(X=187.500000,Y=53.599998,Z=-49.299999),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(1)=(VLightOffset=(X=187.500000,Y=-56.400002,Z=-49.299999),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(2)=(VLightOffset=(X=187.500000,Y=43.599998,Z=-48.299999),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000)
	HeadLights(3)=(VLightOffset=(X=187.500000,Y=-46.299999,Z=-48.299999),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000)
	GroundPower=2.500000
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=102.000000,Y=16.500000,Z=-18.000000),FXRange=12)
	DestroyedExplDmg=420
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=8.125000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=3.440000,AttachName="IonTankTurret")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=103.750000,Y=98.125000,Z=-10.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-138.750000,Y=98.125000,Z=-10.000000))
	ExplosionGFX(4)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(Y=98.125000,Z=-10.000000))
	WreckPartColHeight=45.000000
	WreckPartColRadius=130.000000
	bEnableShield=True
	ShieldLevel=0.650000
	Mesh=SkeletalMesh'IonTank'
	SoundRadius=70
	SoundVolume=100
	CollisionRadius=132.500000
	CollisionHeight=100.000000
	Mass=4800.000000
}
