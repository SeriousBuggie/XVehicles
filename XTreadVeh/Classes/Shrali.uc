class Shrali expands TreadCraftPhys;

//Mesh import
#exec MESH IMPORT MESH=Shrali ANIVFILE=MODELS\Shrali_a.3d DATAFILE=MODELS\Shrali_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=Shrali STRENGTH=0.85
#exec MESH ORIGIN MESH=Shrali X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=Shrali SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Shrali SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=Shrali MESH=Shrali
#exec MESHMAP SCALE MESHMAP=Shrali X=1.0 Y=1.0 Z=2.0

//Skinning
#exec TEXTURE IMPORT NAME=ShraliBodySk01 FILE=SKINS\ShraliBodySk01.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=Shrali NUM=1 TEXTURE=ShraliBodySk01

#exec TEXTURE IMPORT NAME=ShraliBodySk02 FILE=SKINS\ShraliBodySk02.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=Shrali NUM=2 TEXTURE=ShraliBodySk02


//Sounds import
#exec AUDIO IMPORT NAME="ShraliEng" FILE=SOUNDS\ShraliEng.wav GROUP="Shrali"
#exec AUDIO IMPORT NAME="ShraliEnd" FILE=SOUNDS\ShraliEnd.wav GROUP="Shrali"
#exec AUDIO IMPORT NAME="ShraliStart" FILE=SOUNDS\ShraliStart.wav GROUP="Shrali"


//*********************************************************************
// Treads import
//*********************************************************************

//Tread mesh
#exec MESH IMPORT MESH=TankTreadNB ANIVFILE=MODELS\TankTreadNB_a.3d DATAFILE=MODELS\TankTreadNB_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=TankTreadNB STRENGTH=0.85
#exec MESH ORIGIN MESH=TankTreadNB X=0 Y=0 Z=0 YAW=128

#exec MESH IMPORT MESH=TankTreadNBMir ANIVFILE=MODELS\TankTreadNB_a.3d DATAFILE=MODELS\TankTreadNB_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=TankTreadNBMir STRENGTH=0.85
#exec MESH ORIGIN MESH=TankTreadNBMir X=0 Y=0 Z=0

//Tread anim
#exec MESH SEQUENCE MESH=TankTreadNB SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankTreadNB SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESH SEQUENCE MESH=TankTreadNBMir SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankTreadNBMir SEQ=Still STARTFRAME=0 NUMFRAMES=1


//Tread scale
#exec MESHMAP NEW MESHMAP=TankTreadNB MESH=TankTreadNB
#exec MESHMAP SCALE MESHMAP=TankTreadNB X=0.5 Y=0.5 Z=1.0

#exec MESHMAP NEW MESHMAP=TankTreadNBMir MESH=TankTreadNBMir
#exec MESHMAP SCALE MESHMAP=TankTreadNBMir X=0.5 Y=0.5 Z=1.0


//Tread pan
#exec TEXTURE IMPORT NAME=ATread01 FILE=TreadPanNL\ATread01.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=ATread02 FILE=TreadPanNL\ATread02.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=ATread03 FILE=TreadPanNL\ATread03.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=ATread04 FILE=TreadPanNL\ATread04.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=ATread05 FILE=TreadPanNL\ATread05.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=ATread06 FILE=TreadPanNL\ATread06.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=ATread07 FILE=TreadPanNL\ATread07.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=ATread08 FILE=TreadPanNL\ATread08.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=ATread09 FILE=TreadPanNL\ATread09.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=ATread10 FILE=TreadPanNL\ATread10.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=ATread11 FILE=TreadPanNL\ATread11.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=ATread12 FILE=TreadPanNL\ATread12.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=ATread13 FILE=TreadPanNL\ATread13.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=ATread14 FILE=TreadPanNL\ATread14.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=ATread15 FILE=TreadPanNL\ATread15.bmp GROUP=Treads LODSET=2
#exec TEXTURE IMPORT NAME=ATread16 FILE=TreadPanNL\ATread16.bmp GROUP=Treads LODSET=2

#exec TEXTURE IMPORT NAME=NaliTreadSys FILE=SKINS\NaliTreadSys.bmp GROUP=Skins LODSET=2

#exec MESHMAP SETTEXTURE MESHMAP=TankTreadNB NUM=1 TEXTURE=ATread01
#exec MESHMAP SETTEXTURE MESHMAP=TankTreadNBMir NUM=1 TEXTURE=ATread01

#exec MESHMAP SETTEXTURE MESHMAP=TankTreadNB NUM=2 TEXTURE=NaliTreadSys
#exec MESHMAP SETTEXTURE MESHMAP=TankTreadNBMir NUM=2 TEXTURE=NaliTreadSys

//Crosshair
#exec TEXTURE IMPORT NAME=ShraliMainCross FILE=ICONS\ShraliMainCross.bmp GROUP=Icons MIPS=OFF
#exec TEXTURE IMPORT NAME=ShraliPassCross FILE=ICONS\ShraliPassCross.bmp GROUP=Icons MIPS=OFF

defaultproperties
{
	MaxGroundSpeed=560.000000
	TreadPan(0)=Texture'XTreadVeh.Treads.ATread01'
	TreadPan(1)=Texture'XTreadVeh.Treads.ATread02'
	TreadPan(2)=Texture'XTreadVeh.Treads.ATread03'
	TreadPan(3)=Texture'XTreadVeh.Treads.ATread04'
	TreadPan(4)=Texture'XTreadVeh.Treads.ATread05'
	TreadPan(5)=Texture'XTreadVeh.Treads.ATread06'
	TreadPan(6)=Texture'XTreadVeh.Treads.ATread07'
	TreadPan(7)=Texture'XTreadVeh.Treads.ATread08'
	TreadPan(8)=Texture'XTreadVeh.Treads.ATread09'
	TreadPan(9)=Texture'XTreadVeh.Treads.ATread10'
	TreadPan(10)=Texture'XTreadVeh.Treads.ATread11'
	TreadPan(11)=Texture'XTreadVeh.Treads.ATread12'
	TreadPan(12)=Texture'XTreadVeh.Treads.ATread13'
	TreadPan(13)=Texture'XTreadVeh.Treads.ATread14'
	TreadPan(14)=Texture'XTreadVeh.Treads.ATread15'
	TreadPan(15)=Texture'XTreadVeh.Treads.ATread16'
	Treads(0)=(MovPerTreadCycle=45.000000,TreadMesh=LodMesh'XTreadVeh.TankTreadNB',TreadSkinN=1,TreadOffset=(Y=167.500000,Z=-71.000000),TrackWidth=112.000000,TrackFrontOffset=(X=256.000000),TrackBackOffset=(X=-256.000000))
	Treads(1)=(MovPerTreadCycle=45.000000,TreadMesh=LodMesh'XTreadVeh.TankTreadNBMir',TreadSkinN=1,TreadOffset=(Y=-167.500000,Z=-71.000000),TrackWidth=112.000000,TrackFrontOffset=(X=256.000000),TrackBackOffset=(X=-256.000000))
	bEngDynSndPitch=True
	MinEngPitch=24
	MaxEngPitch=80
	TreadsTraction=5.000000
	WreckTrackColHeight=64.000000
	WreckTrackColRadius=96.000000
	AIRating=8.000000
	VehicleGravityScale=5.500000
	WAccelRate=320.000000
	Health=2800
	VehicleName="Shrali"
	ExitOffset=(X=0.000000,Y=320.000000)
	BehinViewViewOffset=(X=-312.000000,Y=0.000000,Z=150.000000)
	StartSound=Sound'XTreadVeh.Shrali.ShraliStart'
	EndSound=Sound'XTreadVeh.Shrali.ShraliEnd'
	EngineSound=Sound'XTreadVeh.Shrali.ShraliEng'
	bDriverWOffset=True
	DriverWeapon=(WeaponClass=Class'XTreadVeh.ShraliTurret',WeaponOffset=(X=-208.125000,Z=64.625000))
	PassengerSeats(0)=(PassengerWeapon=Class'XTreadVeh.ShraliIonRotSup',PassengerWOffset=(X=150.000000,Z=-7.250000),CameraOffset=(Z=37.500000),CamBehindviewOffset=(X=-168.750000,Z=80.000000),bIsAvailable=True,SeatName="Shrali Gunner")
	VehicleKeyInfoStr="Shrali keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%PrevWeapon%, %NextWeapon%, %SwitchToBestWeapon% to change camera|%ThrowWeapon% to exit the vehicle"
	bSlopedPhys=True
	FrontWide=(X=260.000000,Y=167.500000,Z=-10.000000)
	BackWide=(X=-260.000000,Y=167.500000,Z=-10.000000)
	ZRange=380.000000
	MaxObstclHeight=80.000000
	DriverCrosshairTex=Texture'XTreadVeh.Icons.ShraliMainCross'
	PassCrosshairTex(0)=Texture'XTreadVeh.Icons.ShraliPassCross'
	DriverCrossColor=(R=255,G=0,B=0,A=0)
	PassCrossColor(0)=(R=255,G=140,B=0)
	GroundPower=5.200000
	bBigVehicle=True
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=-81.250000,Y=122.500000,Z=10.000000),FXRange=25)
	DamageGFX(1)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=-81.250000,Y=-122.500000,Z=10.000000),FXRange=25)
	DestroyedExplDmg=700
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=17.500000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=6.875000,AttachName="ShraliTurret")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=5.625000,bUseCoordOffset=True,bSymetricalCoordX=True,bSymetricalCoordY=True,ExplFXOffSet=(X=250.000000,Y=167.500000,Z=-70.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=4.500000,bUseCoordOffset=True,bSymetricalCoordX=True,bSymetricalCoordY=True,ExplFXOffSet=(X=100.000000,Y=167.500000,Z=-70.000000))
	UseExplosionSnd1=False
	WreckPartColHeight=115.000000
	WreckPartColRadius=210.000000
	bEnableShield=True
	ShieldLevel=0.950000
	Mesh=LodMesh'XTreadVeh.Shrali'
	SoundRadius=80
	SoundVolume=125
	CollisionRadius=231.000000
	CollisionHeight=129.000000
	Mass=7600.000000
}
