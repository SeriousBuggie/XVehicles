class ShrSpiralBeam expands xTreadVehEffects;

#exec MESH IMPORT MESH=SpiralBeam ANIVFILE=MODELS\SpiralBeam_a.3d DATAFILE=MODELS\SpiralBeam_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=SpiralBeam STRENGTH=0.45
#exec MESH ORIGIN MESH=SpiralBeam X=-640 Y=0 Z=0

#exec MESH SEQUENCE MESH=SpiralBeam SEQ=All STARTFRAME=0 NUMFRAMES=21
#exec MESH SEQUENCE MESH=SpiralBeam SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=SpiralBeam SEQ=Adjust STARTFRAME=0 NUMFRAMES=21 RATE=1.0

#exec MESHMAP NEW MESHMAP=SpiralBeam MESH=SpiralBeam
#exec MESHMAP SCALE MESHMAP=SpiralBeam X=0.5 Y=0.5 Z=1.0

/*#exec TEXTURE IMPORT NAME=EnergyBeamBlue01 FILE=EFFECTS\EnergyBeamBlue01.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=EnergyBeamBlue02 FILE=EFFECTS\EnergyBeamBlue02.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=EnergyBeamBlue03 FILE=EFFECTS\EnergyBeamBlue03.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=EnergyBeamBlue04 FILE=EFFECTS\EnergyBeamBlue04.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=EnergyBeamPurple01 FILE=EFFECTS\EnergyBeamPurple01.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=EnergyBeamPurple02 FILE=EFFECTS\EnergyBeamPurple02.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=EnergyBeamPurple03 FILE=EFFECTS\EnergyBeamPurple03.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=EnergyBeamPurple04 FILE=EFFECTS\EnergyBeamPurple04.bmp GROUP=Effects FLAGS=2*/
#exec TEXTURE IMPORT NAME=EnergyBeamRed01 FILE=EFFECTS\EnergyBeamRed01.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=EnergyBeamRed02 FILE=EFFECTS\EnergyBeamRed02.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=EnergyBeamRed03 FILE=EFFECTS\EnergyBeamRed03.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=EnergyBeamRed04 FILE=EFFECTS\EnergyBeamRed04.bmp GROUP=Effects FLAGS=2

#exec MESHMAP SETTEXTURE MESHMAP=SpiralBeam NUM=1 TEXTURE=EnergyBeamRed01
#exec MESHMAP SETTEXTURE MESHMAP=SpiralBeam NUM=2 TEXTURE=EnergyBeamRed02
#exec MESHMAP SETTEXTURE MESHMAP=SpiralBeam NUM=3 TEXTURE=EnergyBeamRed03
#exec MESHMAP SETTEXTURE MESHMAP=SpiralBeam NUM=4 TEXTURE=EnergyBeamRed04

var() texture RndFXTex1[4], RndFXTex2[4], RndFXTex3[4];
var() bool bAnimated;
var() float AnimSpeed;
var byte CurTex1, CurTex2, CurTex3, CurTex4;

simulated function PostBeginPlay()
{
	if (bAnimated && AnimSpeed > 0)
		SetTimer(1/AnimSpeed,True);
}

simulated function Timer()
{
	CurTex1++;
	CurTex2++;
	CurTex3++;
	CurTex4++;

	if (CurTex1 > 3)
		CurTex1 = 0;
	if (CurTex2 > 3)
		CurTex2 = 0;
	if (CurTex3 > 3)
		CurTex3 = 0;
	if (CurTex4 > 3)
		CurTex4 = 0;

	MultiSkins[1] = RndFXTex3[CurTex1];
	MultiSkins[2] = RndFXTex1[CurTex2];
	MultiSkins[3] = RndFXTex2[CurTex3];
	MultiSkins[4] = RndFXTex3[CurTex4];
}

simulated function Tick( float DeltaTime)
{
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
}

defaultproperties
{
	RndFXTex1(0)=Texture'XTreadVeh.Effects.EnergyBeamRed01'
	RndFXTex1(1)=Texture'XTreadVeh.Effects.EnergyBeamRed02'
	RndFXTex1(2)=Texture'XTreadVeh.Effects.EnergyBeamRed03'
	RndFXTex1(3)=Texture'XTreadVeh.Effects.EnergyBeamRed04'
	RndFXTex2(0)=Texture'XTreadVeh.Effects.EnergyBeamRed01'
	RndFXTex2(1)=Texture'XTreadVeh.Effects.EnergyBeamRed02'
	RndFXTex2(2)=Texture'XTreadVeh.Effects.EnergyBeamRed03'
	RndFXTex2(3)=Texture'XTreadVeh.Effects.EnergyBeamRed04'
	RndFXTex3(0)=Texture'XTreadVeh.Effects.EnergyBeamRed01'
	RndFXTex3(1)=Texture'XTreadVeh.Effects.EnergyBeamRed02'
	RndFXTex3(2)=Texture'XTreadVeh.Effects.EnergyBeamRed03'
	RndFXTex3(3)=Texture'XTreadVeh.Effects.EnergyBeamRed04'
	bAnimated=True
	animspeed=12.000000
	CurTex2=1
	CurTex3=2
	CurTex4=3
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.350000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=LodMesh'SpiralBeam'
	ScaleGlow=1.800000
	bUnlit=True
	LightType=LT_Steady
	LightBrightness=64
	LightHue=13
	LightSaturation=125
	LightRadius=16
}
