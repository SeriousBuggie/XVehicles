class Kraht expands TreadCraftPhys;

//Mesh import
#exec MESH IMPORT MESH=Kraht ANIVFILE=MODELS\Kraht_a.3d DATAFILE=MODELS\Kraht_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=Kraht STRENGTH=0.85
#exec MESH ORIGIN MESH=Kraht X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=Kraht SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Kraht SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=Kraht MESH=Kraht
#exec MESHMAP SCALE MESHMAP=Kraht X=0.3 Y=0.3 Z=0.6

//Skinning
#exec TEXTURE IMPORT NAME=KrahtBodySk FILE=SKINS\KrahtBodySk.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=Kraht NUM=1 TEXTURE=KrahtBodySk

//Sounds import
#exec AUDIO IMPORT NAME="KrahtEng" FILE=SOUNDS\KrahtEng.wav GROUP="Kraht"
#exec AUDIO IMPORT NAME="KrahtEnd" FILE=SOUNDS\KrahtEnd.wav GROUP="Kraht"
#exec AUDIO IMPORT NAME="KrahtStart" FILE=SOUNDS\KrahtStart.wav GROUP="Kraht"


//*********************************************************************
// Treads import
//*********************************************************************

//Tread mesh
#exec MESH IMPORT MESH=KrahtTread ANIVFILE=MODELS\KrahtTread_a.3d DATAFILE=MODELS\KrahtTread_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=KrahtTread STRENGTH=0.85
#exec MESH ORIGIN MESH=KrahtTread X=0 Y=0 Z=0 YAW=128

#exec MESH IMPORT MESH=KrahtTreadMir ANIVFILE=MODELS\KrahtTread_a.3d DATAFILE=MODELS\KrahtTread_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=KrahtTreadMir STRENGTH=0.85
#exec MESH ORIGIN MESH=KrahtTreadMir X=0 Y=0 Z=0

//Tread anim
#exec MESH SEQUENCE MESH=KrahtTread SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=KrahtTread SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESH SEQUENCE MESH=KrahtTreadMir SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=KrahtTreadMir SEQ=Still STARTFRAME=0 NUMFRAMES=1


//Tread scale
#exec MESHMAP NEW MESHMAP=KrahtTread MESH=KrahtTread
#exec MESHMAP SCALE MESHMAP=KrahtTread X=0.3 Y=0.3 Z=0.6

#exec MESHMAP NEW MESHMAP=KrahtTreadMir MESH=KrahtTreadMir
#exec MESHMAP SCALE MESHMAP=KrahtTreadMir X=0.3 Y=0.3 Z=0.6


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

#exec MESHMAP SETTEXTURE MESHMAP=KrahtTread NUM=1 TEXTURE=ATread01
#exec MESHMAP SETTEXTURE MESHMAP=KrahtTreadMir NUM=1 TEXTURE=ATread01

#exec MESHMAP SETTEXTURE MESHMAP=KrahtTread NUM=2 TEXTURE=NaliTreadSys
#exec MESHMAP SETTEXTURE MESHMAP=KrahtTreadMir NUM=2 TEXTURE=NaliTreadSys

//Crosshair
#exec TEXTURE IMPORT NAME=KrahtCross FILE=ICONS\KrahtCross.bmp GROUP=Icons MIPS=OFF

defaultproperties
{
	MaxGroundSpeed=750.000000
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
	Treads(0)=(MovPerTreadCycle=17.500000,TreadMesh=LodMesh'KrahtTread',TreadSkinN=1,TreadOffset=(X=20.000000,Y=81.000000,Z=-27.000000),TrackFrontOffset=(X=80.000000),TrackBackOffset=(X=-80.000000))
	Treads(1)=(MovPerTreadCycle=17.500000,TreadMesh=LodMesh'KrahtTreadMir',TreadSkinN=1,TreadOffset=(X=20.000000,Y=-81.000000,Z=-27.000000),TrackFrontOffset=(X=80.000000),TrackBackOffset=(X=-80.000000))
	TreadsTraction=5.000000
	WreckTrackColHeight=32.000000
	WreckTrackColRadius=48.000000
	AIRating=4.000000
	VehicleGravityScale=2.800000
	WAccelRate=450.000000
	Health=1550
	VehicleName="Kraht"
	ExitOffset=(Y=250.000000)
	BehinViewViewOffset=(X=-225.000000,Z=75.000000)
	StartSound=Sound'XTreadVeh.Kraht.KrahtStart'
	EndSound=Sound'XTreadVeh.Kraht.KrahtEnd'
	EngineSound=Sound'XTreadVeh.Kraht.KrahtEng'
	bEngDynSndPitch=True
	MinEngPitch=24
	MaxEngPitch=80
	bDriverWOffset=True
	DriverWeapon=(WeaponClass=Class'KrahtTurret',WeaponOffset=(X=-38.500000,Z=41.250000))
	VehicleKeyInfoStr="Kraht keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|%mutate VehicleCamera% to change camera|%ThrowWeapon% to exit the vehicle"
	bSlopedPhys=True
	FrontWide=(X=103.000000,Y=80.000000,Z=-4.500000)
	BackWide=(X=-64.000000,Y=80.000000,Z=-4.500000)
	ZRange=250.000000
	MaxObstclHeight=26.000000
	DriverCrosshairTex=Texture'XTreadVeh.Icons.KrahtCross'
	DriverCrossColor=(R=255,G=140,B=0)
	GroundPower=4.100000
	RefMaxArcSpeed=150.000000
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=96.000000,Z=9.000000),FXRange=15)
	DestroyedExplDmg=350
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=6.750000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=2.000000,AttachName="KrahtTurret")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=100.000000,Y=80.000000,Z=-5.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-64.000000,Y=80.000000,Z=-5.000000))
	WreckPartColHeight=40.000000
	WreckPartColRadius=100.000000
	bEnableShield=True
	ShieldLevel=0.950000
	Mesh=LodMesh'Kraht'
	SoundRadius=55
	SoundVolume=150
	CollisionRadius=115.000000
	CollisionHeight=60.000000
	Mass=3100.000000
}
