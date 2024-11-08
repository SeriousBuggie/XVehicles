//=============================================================================
// Goliath.
//=============================================================================
class Goliath expands TreadCraftPhys;

/*
#forceexec MESH  MODELIMPORT MESH=Goliath MODELFILE=Z:\XV\HoverTank.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=Goliath X=0 Y=0 Z=44.5
#forceexec MESH  LODPARAMS MESH=Goliath STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=Goliath X=0.9 Y=0.9 Z=0.9

#forceexec MESHMAP SETTEXTURE MESHMAP=Goliath NUM=0 TEXTURE=TankYellow
#forceexec MESHMAP SETTEXTURE MESHMAP=Goliath NUM=1 TEXTURE=DTread01
#forceexec MESHMAP SETTEXTURE MESHMAP=Goliath NUM=2 TEXTURE=DTread01
// */

/*
#forceexec MESH  MODELIMPORT MESH=GoliathCanon MODELFILE=Z:\XV\HoverTankCannon_1.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=GoliathCanon X=0 Y=0 Z=9
#forceexec MESH  LODPARAMS MESH=GoliathCanon STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=GoliathCanon X=0.9 Y=0.9 Z=0.9

#forceexec MESHMAP SETTEXTURE MESHMAP=GoliathCanon NUM=0 TEXTURE=TankYellow
// */

/*
#forceexec MESH  MODELIMPORT MESH=GoliathCanonPitch MODELFILE=Z:\XV\HoverTankCannon_2.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=GoliathCanonPitch X=50 Y=0 Z=9
#forceexec MESH  LODPARAMS MESH=GoliathCanonPitch STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=GoliathCanonPitch X=0.9 Y=0.9 Z=0.9

#forceexec MESHMAP SETTEXTURE MESHMAP=GoliathCanonPitch NUM=0 TEXTURE=TankYellow
// */

/*
#forceexec MESH  MODELIMPORT MESH=GoliathMGRot MODELFILE=Z:\XV\TankMachineGun_1.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=GoliathMGRot X=0 Y=0 Z=0
#forceexec MESH  LODPARAMS MESH=GoliathMGRot STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=GoliathMGRot X=0.9 Y=0.9 Z=0.9

#forceexec MESHMAP SETTEXTURE MESHMAP=GoliathMGRot NUM=0 TEXTURE=TankYellow
// */

/*
#forceexec MESH  MODELIMPORT MESH=GoliathMGun MODELFILE=Z:\XV\TankMachineGun_2.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=GoliathMGun X=0 Y=0 Z=2
#forceexec MESH  LODPARAMS MESH=GoliathMGun STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=GoliathMGun X=0.9 Y=0.9 Z=0.9

#forceexec MESHMAP SETTEXTURE MESHMAP=GoliathMGun NUM=0 TEXTURE=TankYellow
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
	switch (CurrentTeam)
	{
		case 1:
		case 2:
			MultiSkins[0] = Texture'TankGreen'; // green
			break;
		case 3:
		case 0:
		default: 
			MultiSkins[0] = Texture'TankYellow'; // yellow
			break;
	}
	if (GVT != None)
		GVT.MultiSkins[0] = MultiSkins[0];
}

defaultproperties
{
	MaxGroundSpeed=500.000000
	TreadPan(0)=Texture'XTreadVeh.TreadsD.DTread01'
	TreadPan(1)=Texture'XTreadVeh.TreadsD.DTread02'
	TreadPan(2)=Texture'XTreadVeh.TreadsD.DTread03'
	TreadPan(3)=Texture'XTreadVeh.TreadsD.DTread04'
	TreadPan(4)=Texture'XTreadVeh.TreadsD.DTread05'
	TreadPan(5)=Texture'XTreadVeh.TreadsD.DTread06'
	TreadPan(6)=Texture'XTreadVeh.TreadsD.DTread07'
	TreadPan(7)=Texture'XTreadVeh.TreadsD.DTread08'
	TreadPan(8)=Texture'XTreadVeh.TreadsD.DTread09'
	TreadPan(9)=Texture'XTreadVeh.TreadsD.DTread10'
	TreadPan(10)=Texture'XTreadVeh.TreadsD.DTread11'
	TreadPan(11)=Texture'XTreadVeh.TreadsD.DTread12'
	TreadPan(12)=Texture'XTreadVeh.TreadsD.DTread13'
	TreadPan(13)=Texture'XTreadVeh.TreadsD.DTread14'
	TreadPan(14)=Texture'XTreadVeh.TreadsD.DTread15'
	TreadPan(15)=Texture'XTreadVeh.TreadsD.DTread16'
	Treads(0)=(MovPerTreadCycle=30.000000,TreadMesh=LodMesh'Botpack.Smokebm',TreadSkinN=1,TreadOffset=(X=-12.500000,Y=-98.125000,Z=-43.000000),WheelFramesN=17,WheelAnimSet="WheelsMove",WheelSize=20.625000,TrackWidth=52.000000,TrackFrontOffset=(X=128.000000),TrackBackOffset=(X=-128.000000))
	Treads(1)=(MovPerTreadCycle=30.000000,TreadMesh=LodMesh'Botpack.Smokebm',TreadSkinN=2,TreadOffset=(X=-12.500000,Y=98.125000,Z=-43.000000),WheelFramesN=17,WheelAnimSet="WheelsMove",WheelSize=20.625000,TrackWidth=52.000000,TrackFrontOffset=(X=128.000000),TrackBackOffset=(X=-128.000000))
	WreckTrackColHeight=32.000000
	WreckTrackColRadius=64.000000
	AIRating=3.000000
	VehicleGravityScale=3.000000
	WAccelRate=350.000000
	Health=1350
	VehicleName="Goliath"
	ExitOffset=(Y=203.000000)
	BehinViewViewOffset=(X=-250.000000,Z=100.000000)
	StartSound=Sound'XTreadVeh.Goliath.TankStart01'
	EndSound=Sound'XTreadVeh.Goliath.TankStop01'
	EngineSound=Sound'XTreadVeh.TankGKOne.TankGKOneEng'
	bEngDynSndPitch=True
	MinEngPitch=32
	MaxEngPitch=96
	bDriverWOffset=True
	DriverWeapon=(WeaponClass=Class'GoliathTurret',WeaponOffset=(X=-63.000000,Z=46.000000))
	PassengerSeats(0)=(PassengerWeapon=Class'GoliathMGRot',PassengerWOffset=(X=-63.000000,Z=75.750000),CameraOffset=(Z=37.500000),CamBehindviewOffset=(X=-82.500000,Z=17.500000),bIsAvailable=True,SeatName="Machine Gun")
	VehicleKeyInfoStr="Goliath keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%mutate VehicleCamera% to change camera|%ThrowWeapon% to exit the vehicle"
	bSlopedPhys=True
	FrontWide=(X=103.750000,Y=98.125000,Z=-10.000000)
	BackWide=(X=-138.750000,Y=98.125000,Z=-10.000000)
	ZRange=260.000000
	MaxObstclHeight=44.000000
	DriverCrosshairTex=Texture'XTreadVeh.Icons.TankGKOneMainCross'
	PassCrosshairTex(0)=Texture'XTreadVeh.Icons.TankGKOnePassCross'
	GroundPower=2.500000
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=104.000000,Z=25.000000),FXRange=12)
	DestroyedExplDmg=420
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=8.125000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=3.440000,AttachName="GoliathTurret")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=103.750000,Y=98.125000,Z=-10.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-138.750000,Y=98.125000,Z=-10.000000))
	ExplosionGFX(4)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(Y=98.125000,Z=-10.000000))
	WreckPartColHeight=45.000000
	WreckPartColRadius=130.000000
	bEnableShield=True
	ShieldLevel=0.650000
	Mesh=SkeletalMesh'Goliath'
	SoundRadius=70
	SoundVolume=100
	CollisionRadius=132.500000
	CollisionHeight=75.000000
	Mass=4800.000000
}
