class TankML expands TreadCraftPhys;

//Mesh import
#exec MESH IMPORT MESH=TankML ANIVFILE=MODELS\TankML_a.3d DATAFILE=MODELS\TankML_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=TankML STRENGTH=0.85
#exec MESH ORIGIN MESH=TankML X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=TankML SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankML SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=TankML MESH=TankML
#exec MESHMAP SCALE MESHMAP=TankML X=0.5 Y=0.5 Z=1.0

//Skinning
#exec TEXTURE IMPORT NAME=TankBodySk01_I FILE=SKINS\TankBodySk01_I.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=TankML NUM=1 TEXTURE=TankBodySk01_I

#exec TEXTURE IMPORT NAME=TankBodySk02_I FILE=SKINS\TankBodySk02_I.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=TankML NUM=2 TEXTURE=TankBodySk02_I

//*********************************************************************
// Treads import
//*********************************************************************

//Tread mesh
#exec MESH IMPORT MESH=TankTreadB ANIVFILE=MODELS\TankTreadA_a.3d DATAFILE=MODELS\TankTreadA_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=TankTreadB STRENGTH=0.85
#exec MESH ORIGIN MESH=TankTreadB X=0 Y=0 Z=0 YAW=128

#exec MESH IMPORT MESH=TankTreadBMir ANIVFILE=MODELS\TankTreadA_a.3d DATAFILE=MODELS\TankTreadA_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=TankTreadBMir STRENGTH=0.85
#exec MESH ORIGIN MESH=TankTreadBMir X=0 Y=0 Z=0

//Tread anim
#exec MESH SEQUENCE MESH=TankTreadB SEQ=All STARTFRAME=0 NUMFRAMES=17
#exec MESH SEQUENCE MESH=TankTreadB SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankTreadB SEQ=WheelsMove STARTFRAME=0 NUMFRAMES=17 RATE=0.5

#exec MESH SEQUENCE MESH=TankTreadBMir SEQ=All STARTFRAME=0 NUMFRAMES=17
#exec MESH SEQUENCE MESH=TankTreadBMir SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankTreadBMir SEQ=WheelsMove STARTFRAME=0 NUMFRAMES=17 RATE=0.5

//Tread scale
#exec MESHMAP NEW MESHMAP=TankTreadB MESH=TankTreadB
#exec MESHMAP SCALE MESHMAP=TankTreadB X=0.5 Y=0.425 Z=1.0

#exec MESHMAP NEW MESHMAP=TankTreadBMir MESH=TankTreadBMir
#exec MESHMAP SCALE MESHMAP=TankTreadBMir X=0.5 Y=0.425 Z=1.0

//Tread pan
#exec TEXTURE IMPORT NAME=CTread01 FILE=TreadPanC\CTread01.bmp GROUP=TreadsC LODSET=2
#exec TEXTURE IMPORT NAME=CTread02 FILE=TreadPanC\CTread02.bmp GROUP=TreadsC LODSET=2
#exec TEXTURE IMPORT NAME=CTread03 FILE=TreadPanC\CTread03.bmp GROUP=TreadsC LODSET=2
#exec TEXTURE IMPORT NAME=CTread04 FILE=TreadPanC\CTread04.bmp GROUP=TreadsC LODSET=2
#exec TEXTURE IMPORT NAME=CTread05 FILE=TreadPanC\CTread05.bmp GROUP=TreadsC LODSET=2
#exec TEXTURE IMPORT NAME=CTread06 FILE=TreadPanC\CTread06.bmp GROUP=TreadsC LODSET=2
#exec TEXTURE IMPORT NAME=CTread07 FILE=TreadPanC\CTread07.bmp GROUP=TreadsC LODSET=2
#exec TEXTURE IMPORT NAME=CTread08 FILE=TreadPanC\CTread08.bmp GROUP=TreadsC LODSET=2
#exec TEXTURE IMPORT NAME=CTread09 FILE=TreadPanC\CTread09.bmp GROUP=TreadsC LODSET=2
#exec TEXTURE IMPORT NAME=CTread10 FILE=TreadPanC\CTread10.bmp GROUP=TreadsC LODSET=2
#exec TEXTURE IMPORT NAME=CTread11 FILE=TreadPanC\CTread11.bmp GROUP=TreadsC LODSET=2
#exec TEXTURE IMPORT NAME=CTread12 FILE=TreadPanC\CTread12.bmp GROUP=TreadsC LODSET=2
#exec TEXTURE IMPORT NAME=CTread13 FILE=TreadPanC\CTread13.bmp GROUP=TreadsC LODSET=2
#exec TEXTURE IMPORT NAME=CTread14 FILE=TreadPanC\CTread14.bmp GROUP=TreadsC LODSET=2
#exec TEXTURE IMPORT NAME=CTread15 FILE=TreadPanC\CTread15.bmp GROUP=TreadsC LODSET=2
#exec TEXTURE IMPORT NAME=CTread16 FILE=TreadPanC\CTread16.bmp GROUP=TreadsC LODSET=2

#exec TEXTURE IMPORT NAME=TreadWheelsB FILE=SKINS\TreadWheelsB.bmp GROUP=Skins LODSET=2

#exec MESHMAP SETTEXTURE MESHMAP=TankTreadB NUM=1 TEXTURE=CTread01
#exec MESHMAP SETTEXTURE MESHMAP=TankTreadBMir NUM=1 TEXTURE=CTread01

#exec MESHMAP SETTEXTURE MESHMAP=TankTreadB NUM=2 TEXTURE=TreadWheelsB
#exec MESHMAP SETTEXTURE MESHMAP=TankTreadBMir NUM=2 TEXTURE=TreadWheelsB

//Crosshair
#exec TEXTURE IMPORT NAME=TankMLCross FILE=ICONS\TankMLCross.bmp GROUP=Icons MIPS=OFF

//Sounds import
#exec AUDIO IMPORT NAME="TankMLEng" FILE=SOUNDS\TankMLEng.wav GROUP="TankML"
#exec AUDIO IMPORT NAME="TankMLEnd" FILE=SOUNDS\TankMLEnd.wav GROUP="TankML"
#exec AUDIO IMPORT NAME="TankMLStart" FILE=SOUNDS\TankMLStart.wav GROUP="TankML"

//Overlayers
#exec TEXTURE IMPORT NAME=TankMLBodyOv01 FILE=SKINS\TankMLBodyOv01.bmp GROUP=Overlayers LODSET=2
#exec TEXTURE IMPORT NAME=TankMLBodyOv02 FILE=SKINS\TankMLBodyOv02.bmp GROUP=Overlayers LODSET=2
#exec TEXTURE IMPORT NAME=TankMLTurretOver FILE=SKINS\TankMLTurretOver.bmp GROUP=Overlayers LODSET=2
#exec TEXTURE IMPORT NAME=TankMLCannonOver FILE=SKINS\TankMLCannonOver.bmp GROUP=Overlayers LODSET=2

var TankOver BodyOv, TurretOv, CannonOv;

function SpawnShotOverlayer()
{
	local VehicleAttachment W,NW;
	
	BodyOv = Spawn(Class'TankOver', Self);
	BodyOv.Mesh = Mesh;
	BodyOv.DrawScale = DrawScale;
	BodyOv.MultiSkins[1] = Texture'TankMLBodyOv01';
	BodyOv.MultiSkins[2] = Texture'TankMLBodyOv02';
	BodyOv.SlopedPart = self;
	BodyOv.bTrailerPrePivot = True;
	BodyOv.LodBias = LodBias;
	
	For( W=AttachmentList; W!=None; W=NW )
	{
		if (W.IsA('TankMLTurret'))
		{
			TurretOv = Spawn(Class'TankOver', W,, W.Location, W.Rotation);
			TurretOv.Mesh = W.Mesh;
			TurretOv.DrawScale = W.DrawScale;
			TurretOv.MultiSkins[1] = Texture'TankMLTurretOver';
			TurretOv.LodBias = LodBias;
			
			if (WeaponAttachment(W).PitchPart != None)
			{
				CannonOv = Spawn(Class'TankOver', WeaponAttachment(W).PitchPart,, WeaponAttachment(W).PitchPart.Location, WeaponAttachment(W).PitchPart.Rotation);
				CannonOv.Mesh = WeaponAttachment(W).PitchPart.Mesh;
				CannonOv.DrawScale = WeaponAttachment(W).PitchPart.DrawScale;
				CannonOv.MultiSkins[1] = Texture'TankMLCannonOver';
				CannonOv.LodBias = LodBias;
			}
		}
		
		NW = W.NextAttachment;
	}
}

simulated function Destroyed()
{
	if (BodyOv != None)
		BodyOv.Destroy();
	if (TurretOv != None)
		TurretOv.Destroy();
	if (CannonOv != None)
		CannonOv.Destroy();
		
	Super.Destroyed();
}

defaultproperties
{
	MaxGroundSpeed=625.000000
	TreadPan(0)=Texture'XTreadVeh.TreadsC.CTread01'
	TreadPan(1)=Texture'XTreadVeh.TreadsC.CTread02'
	TreadPan(2)=Texture'XTreadVeh.TreadsC.CTread03'
	TreadPan(3)=Texture'XTreadVeh.TreadsC.CTread04'
	TreadPan(4)=Texture'XTreadVeh.TreadsC.CTread05'
	TreadPan(5)=Texture'XTreadVeh.TreadsC.CTread06'
	TreadPan(6)=Texture'XTreadVeh.TreadsC.CTread07'
	TreadPan(7)=Texture'XTreadVeh.TreadsC.CTread08'
	TreadPan(8)=Texture'XTreadVeh.TreadsC.CTread09'
	TreadPan(9)=Texture'XTreadVeh.TreadsC.CTread10'
	TreadPan(10)=Texture'XTreadVeh.TreadsC.CTread11'
	TreadPan(11)=Texture'XTreadVeh.TreadsC.CTread12'
	TreadPan(12)=Texture'XTreadVeh.TreadsC.CTread13'
	TreadPan(13)=Texture'XTreadVeh.TreadsC.CTread14'
	TreadPan(14)=Texture'XTreadVeh.TreadsC.CTread15'
	TreadPan(15)=Texture'XTreadVeh.TreadsC.CTread16'
	Treads(0)=(MovPerTreadCycle=19.375000,TreadMesh=LodMesh'XTreadVeh.TankTreadBMir',TreadSkinN=1,TreadOffset=(X=-5.000000,Y=-94.500000,Z=-36.000000),bHaveAnimTWheels=True,WheelFramesN=17,WheelAnimSet="WheelsMove",WheelSize=20.625000,TrackWidth=52.000000,TrackFrontOffset=(X=128.000000),TrackBackOffset=(X=-128.000000))
	Treads(1)=(MovPerTreadCycle=19.375000,TreadMesh=LodMesh'XTreadVeh.TankTreadB',TreadSkinN=1,TreadOffset=(X=-5.000000,Y=94.500000,Z=-36.000000),bHaveAnimTWheels=True,WheelFramesN=17,WheelAnimSet="WheelsMove",WheelSize=20.625000,TrackWidth=52.000000,TrackFrontOffset=(X=128.000000),TrackBackOffset=(X=-128.000000))
	bEngDynSndPitch=True
	MinEngPitch=32
	MaxEngPitch=96
	WreckTrackColHeight=32.000000
	WreckTrackColRadius=64.000000
	AIRating=8.000000
	VehicleGravityScale=3.500000
	WAccelRate=375.000000
	Health=1800
	VehicleName="Tank ML-102"
	ExitOffset=(X=0.000000,Y=203.000000)
	BehinViewViewOffset=(X=-250.000000,Y=0.000000,Z=100.000000)
	StartSound=Sound'XTreadVeh.TankML.TankMLStart'
	EndSound=Sound'XTreadVeh.TankML.TankMLEnd'
	EngineSound=Sound'XTreadVeh.TankML.TankMLEng'
	bDriverWOffset=True
	DriverWeapon=(WeaponClass=Class'XTreadVeh.TankMLTurret',WeaponOffset=(X=-68.000000,Z=43.000000))
	VehicleKeyInfoStr="Tank ML-102 keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|%PrevWeapon%, %NextWeapon%, %SwitchToBestWeapon% to change camera|%ThrowWeapon% to exit the vehicle"
	bSlopedPhys=True
	FrontWide=(X=111.250000,Y=90.000000,Z=-5.000000)
	BackWide=(X=-131.250000,Y=90.000000,Z=-5.000000)
	ZRange=260.000000
	MaxObstclHeight=44.000000
	DriverCrosshairTex=Texture'XTreadVeh.Icons.TankMLCross'
	DriverCrossColor=(R=255,G=0,B=0,A=0)
	ArmorType(7)=(ArmorLevel=0.950000,ProtectionType="Burned")
	GroundPower=3.250000
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=128.000000,Z=25.000000),FXRange=12)
	DestroyedExplDmg=525
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=8.125000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=3.440000,AttachName="TankMLTurret")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=111.250000,Y=90.000000,Z=-5.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-131.250000,Y=90.000000,Z=-5.000000))
	ExplosionGFX(4)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(Y=90.000000,Z=-5.000000))
	WreckPartColHeight=42.000000
	WreckPartColRadius=128.000000
	bEnableShield=True
	ShieldLevel=0.800000
	Mesh=LodMesh'XTreadVeh.TankML'
	SoundRadius=70
	SoundVolume=100
	CollisionRadius=125.000000
	CollisionHeight=69.000000
	Mass=5800.000000
}
