class TankGKOne expands TreadCraftPhys;

//Mesh import
#exec MESH IMPORT MESH=TankGKOne ANIVFILE=MODELS\TankGKOne_a.3d DATAFILE=MODELS\TankGKOne_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=TankGKOne STRENGTH=0.85
#exec MESH ORIGIN MESH=TankGKOne X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=TankGKOne SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankGKOne SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=TankGKOne MESH=TankGKOne
#exec MESHMAP SCALE MESHMAP=TankGKOne X=0.5 Y=0.5 Z=1.0

//Skinning
#exec TEXTURE IMPORT NAME=TankBodySk01_II FILE=SKINS\TankBodySk01_II.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=TankGKOne NUM=1 TEXTURE=TankBodySk01_II

#exec TEXTURE IMPORT NAME=TankBodySk02_II FILE=SKINS\TankBodySk02_II.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=TankGKOne NUM=2 TEXTURE=TankBodySk02_II

//Sounds import
#exec AUDIO IMPORT NAME="TankGKOneEng" FILE=SOUNDS\TankGKOneEng.wav GROUP="TankGKOne"
#exec AUDIO IMPORT NAME="TankGKOneOff" FILE=SOUNDS\TankGKOneOff.wav GROUP="TankGKOne"
#exec AUDIO IMPORT NAME="TankGKOneOn" FILE=SOUNDS\TankGKOneOn.wav GROUP="TankGKOne"


//*********************************************************************
// Treads import
//*********************************************************************

//Tread mesh
#exec MESH IMPORT MESH=TankTreadA ANIVFILE=MODELS\TankTreadA_a.3d DATAFILE=MODELS\TankTreadA_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=TankTreadA STRENGTH=0.85
#exec MESH ORIGIN MESH=TankTreadA X=0 Y=0 Z=0 YAW=128

#exec MESH IMPORT MESH=TankTreadAMir ANIVFILE=MODELS\TankTreadA_a.3d DATAFILE=MODELS\TankTreadA_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=TankTreadAMir STRENGTH=0.85
#exec MESH ORIGIN MESH=TankTreadAMir X=0 Y=0 Z=0

//Tread anim
#exec MESH SEQUENCE MESH=TankTreadA SEQ=All STARTFRAME=0 NUMFRAMES=17
#exec MESH SEQUENCE MESH=TankTreadA SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankTreadA SEQ=WheelsMove STARTFRAME=0 NUMFRAMES=17 RATE=0.5

#exec MESH SEQUENCE MESH=TankTreadAMir SEQ=All STARTFRAME=0 NUMFRAMES=17
#exec MESH SEQUENCE MESH=TankTreadAMir SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankTreadAMir SEQ=WheelsMove STARTFRAME=0 NUMFRAMES=17 RATE=0.5

//Tread scale
#exec MESHMAP NEW MESHMAP=TankTreadA MESH=TankTreadA
#exec MESHMAP SCALE MESHMAP=TankTreadA X=0.5 Y=0.5 Z=1.0

#exec MESHMAP NEW MESHMAP=TankTreadAMir MESH=TankTreadAMir
#exec MESHMAP SCALE MESHMAP=TankTreadAMir X=0.5 Y=0.5 Z=1.0

//Tread pan
#exec TEXTURE IMPORT NAME=BTread01 FILE=TreadPan\BTread01.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=BTread02 FILE=TreadPan\BTread02.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=BTread03 FILE=TreadPan\BTread03.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=BTread04 FILE=TreadPan\BTread04.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=BTread05 FILE=TreadPan\BTread05.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=BTread06 FILE=TreadPan\BTread06.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=BTread07 FILE=TreadPan\BTread07.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=BTread08 FILE=TreadPan\BTread08.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=BTread09 FILE=TreadPan\BTread09.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=BTread10 FILE=TreadPan\BTread10.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=BTread11 FILE=TreadPan\BTread11.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=BTread12 FILE=TreadPan\BTread12.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=BTread13 FILE=TreadPan\BTread13.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=BTread14 FILE=TreadPan\BTread14.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=BTread15 FILE=TreadPan\BTread15.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=BTread16 FILE=TreadPan\BTread16.bmp GROUP=Treads LODSET=2

#exec TEXTURE IMPORT NAME=TreadWheels FILE=SKINS\TreadWheels.bmp GROUP=Skins LODSET=2

#exec MESHMAP SETTEXTURE MESHMAP=TankTreadA NUM=1 TEXTURE=BTread01
#exec MESHMAP SETTEXTURE MESHMAP=TankTreadAMir NUM=1 TEXTURE=BTread01

#exec MESHMAP SETTEXTURE MESHMAP=TankTreadA NUM=2 TEXTURE=TreadWheels
#exec MESHMAP SETTEXTURE MESHMAP=TankTreadAMir NUM=2 TEXTURE=TreadWheels

//Crosshair
#exec TEXTURE IMPORT NAME=TankGKOneMainCross FILE=ICONS\TankGKOneMainCross.bmp GROUP=Icons MIPS=OFF
#exec TEXTURE IMPORT NAME=TankGKOnePassCross FILE=ICONS\TankGKOnePassCross.bmp GROUP=Icons MIPS=OFF

defaultproperties
{
	MaxGroundSpeed=500.000000
	TreadPan(0)=Texture'XTreadVeh.Treads.BTread01'
	TreadPan(1)=Texture'XTreadVeh.Treads.BTread02'
	TreadPan(2)=Texture'XTreadVeh.Treads.BTread03'
	TreadPan(3)=Texture'XTreadVeh.Treads.BTread04'
	TreadPan(4)=Texture'XTreadVeh.Treads.BTread05'
	TreadPan(5)=Texture'XTreadVeh.Treads.BTread06'
	TreadPan(6)=Texture'XTreadVeh.Treads.BTread07'
	TreadPan(7)=Texture'XTreadVeh.Treads.BTread08'
	TreadPan(8)=Texture'XTreadVeh.Treads.BTread09'
	TreadPan(9)=Texture'XTreadVeh.Treads.BTread10'
	TreadPan(10)=Texture'XTreadVeh.Treads.BTread11'
	TreadPan(11)=Texture'XTreadVeh.Treads.BTread12'
	TreadPan(12)=Texture'XTreadVeh.Treads.BTread13'
	TreadPan(13)=Texture'XTreadVeh.Treads.BTread14'
	TreadPan(14)=Texture'XTreadVeh.Treads.BTread15'
	TreadPan(15)=Texture'XTreadVeh.Treads.BTread16'
	Treads(0)=(MovPerTreadCycle=19.375000,TreadMesh=LodMesh'TankTreadAMir',TreadSkinN=1,TreadOffset=(X=-12.500000,Y=-98.125000,Z=-43.000000),bHaveAnimTWheels=True,WheelFramesN=17,WheelAnimSet="WheelsMove",WheelSize=20.625000,TrackWidth=52.000000,TrackFrontOffset=(X=128.000000),TrackBackOffset=(X=-128.000000))
	Treads(1)=(MovPerTreadCycle=19.375000,TreadMesh=LodMesh'TankTreadA',TreadSkinN=1,TreadOffset=(X=-12.500000,Y=98.125000,Z=-43.000000),bHaveAnimTWheels=True,WheelFramesN=17,WheelAnimSet="WheelsMove",WheelSize=20.625000,TrackWidth=52.000000,TrackFrontOffset=(X=128.000000),TrackBackOffset=(X=-128.000000))
	WreckTrackColHeight=32.000000
	WreckTrackColRadius=64.000000
	AIRating=3.000000
	VehicleGravityScale=3.000000
	WAccelRate=350.000000
	Health=1350
	VehicleName="Tank GK-1"
	ExitOffset=(X=0.000000,Y=203.000000)
	BehinViewViewOffset=(X=-250.000000,Y=0.000000,Z=100.000000)
	StartSound=Sound'XTreadVeh.TankGKOne.TankGKOneOn'
	EndSound=Sound'XTreadVeh.TankGKOne.TankGKOneOff'
	EngineSound=Sound'XTreadVeh.TankGKOne.TankGKOneEng'
	bEngDynSndPitch=True
	MinEngPitch=32
	MaxEngPitch=96
	bDriverWOffset=True
	DriverWeapon=(WeaponClass=Class'TankGKOneTurret',WeaponOffset=(X=-63.750000,Z=48.875000))
	PassengerSeats(0)=(PassengerWeapon=Class'TankMGRot',PassengerWOffset=(X=-63.750000,Z=75.750000),CameraOffset=(Z=37.500000),CamBehindviewOffset=(X=-82.500000,Z=17.500000),bIsAvailable=True,SeatName="Machine Gun")
	VehicleKeyInfoStr="Tank GK-1 keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%mutate VehicleCamera% to change camera|%ThrowWeapon% to exit the vehicle"
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
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=3.440000,AttachName="TankGKOneTurret")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=103.750000,Y=98.125000,Z=-10.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-138.750000,Y=98.125000,Z=-10.000000))
	ExplosionGFX(4)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(Y=98.125000,Z=-10.000000))
	WreckPartColHeight=45.000000
	WreckPartColRadius=130.000000
	bEnableShield=True
	ShieldLevel=0.650000
	Mesh=LodMesh'TankGKOne'
	SoundRadius=70
	SoundVolume=100
	CollisionRadius=132.500000
	CollisionHeight=75.000000
	Mass=4800.000000
}
