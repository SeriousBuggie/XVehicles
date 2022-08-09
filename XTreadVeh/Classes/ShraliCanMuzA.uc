class ShraliCanMuzA expands xTreadVehEffects;

#exec MESH IMPORT MESH=ShraliCanMuzA ANIVFILE=MODELS\ShraliCanMuzA_a.3d DATAFILE=MODELS\ShraliCanMuzA_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=ShraliCanMuzA STRENGTH=0.5
#exec MESH ORIGIN MESH=ShraliCanMuzA X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=ShraliCanMuzA SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ShraliCanMuzA SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=ShraliCanMuzA MESH=ShraliCanMuzA
#exec MESHMAP SCALE MESHMAP=ShraliCanMuzA X=0.25 Y=0.2 Z=0.4

#exec TEXTURE IMPORT NAME=ShraliMuz01 FILE=EFFECTS\ShraliMuz01.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=ShraliMuz02 FILE=EFFECTS\ShraliMuz02.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=ShraliMuz03 FILE=EFFECTS\ShraliMuz03.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=ShraliMuz04 FILE=EFFECTS\ShraliMuz04.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=ShraliMuz05 FILE=EFFECTS\ShraliMuz05.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=ShraliMuz06 FILE=EFFECTS\ShraliMuz06.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=ShraliMuz07 FILE=EFFECTS\ShraliMuz07.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=ShraliMuz08 FILE=EFFECTS\ShraliMuz08.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=ShraliMuz09 FILE=EFFECTS\ShraliMuz09.bmp GROUP=Effects FLAGS=2


var() texture MuzTex[9];

simulated function PostBeginPlay()
{
local byte i;
	
	For(i=0; i<8; i++)
		MultiSkins[i] = MuzTex[Rand(9)];

	SetTimer(0.05,True);
}

simulated function Tick( float DeltaTime)
{
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
}

simulated function Timer()
{
local byte i;
	
	For(i=0; i<8; i++)
		MultiSkins[i] = MuzTex[Rand(9)];
}

defaultproperties
{
	MuzTex(0)=Texture'XTreadVeh.Effects.ShraliMuz01'
	MuzTex(1)=Texture'XTreadVeh.Effects.ShraliMuz02'
	MuzTex(2)=Texture'XTreadVeh.Effects.ShraliMuz03'
	MuzTex(3)=Texture'XTreadVeh.Effects.ShraliMuz04'
	MuzTex(4)=Texture'XTreadVeh.Effects.ShraliMuz05'
	MuzTex(5)=Texture'XTreadVeh.Effects.ShraliMuz06'
	MuzTex(6)=Texture'XTreadVeh.Effects.ShraliMuz07'
	MuzTex(7)=Texture'XTreadVeh.Effects.ShraliMuz08'
	MuzTex(8)=Texture'XTreadVeh.Effects.ShraliMuz09'
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.200000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=Texture'XTreadVeh.Effects.ShraliMuz01'
	Mesh=LodMesh'XTreadVeh.ShraliCanMuzA'
	DrawScale=2.800000
	ScaleGlow=5.000000
	bUnlit=True
	bParticles=True
	bRandomFrame=True
	MultiSkins(0)=Texture'XTreadVeh.Effects.ShraliMuz01'
	MultiSkins(1)=Texture'XTreadVeh.Effects.ShraliMuz01'
	MultiSkins(2)=Texture'XTreadVeh.Effects.ShraliMuz01'
	MultiSkins(3)=Texture'XTreadVeh.Effects.ShraliMuz01'
	MultiSkins(4)=Texture'XTreadVeh.Effects.ShraliMuz01'
	MultiSkins(5)=Texture'XTreadVeh.Effects.ShraliMuz01'
	MultiSkins(6)=Texture'XTreadVeh.Effects.ShraliMuz01'
	MultiSkins(7)=Texture'XTreadVeh.Effects.ShraliMuz01'
	LightEffect=LE_NonIncidence
	LightBrightness=100
	LightRadius=16
}
