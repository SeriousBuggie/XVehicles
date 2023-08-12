class BigStonesPart expands xTreadVehEffects;

#exec MESH IMPORT MESH=BigStonesPart ANIVFILE=MODELS\BigStonesPart_a.3d DATAFILE=MODELS\BigStonesPart_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=BigStonesPart STRENGTH=0.75
#exec MESH ORIGIN MESH=BigStonesPart X=0 Y=0 Z=0 PITCH=64

#exec MESH SEQUENCE MESH=BigStonesPart SEQ=All STARTFRAME=0 NUMFRAMES=3
#exec MESH SEQUENCE MESH=BigStonesPart SEQ=Shrink STARTFRAME=0 NUMFRAMES=2 RATE=1.0
#exec MESH SEQUENCE MESH=BigStonesPart SEQ=Grow STARTFRAME=1 NUMFRAMES=2 RATE=1.0

#exec MESHMAP NEW MESHMAP=BigStonesPart MESH=BigStonesPart
#exec MESHMAP SCALE MESHMAP=BigStonesPart X=11.625 Y=11.625 Z=12.875

#exec TEXTURE IMPORT NAME=BigRock01 FILE=EFFECTS\BigRock01.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=BigRock02 FILE=EFFECTS\BigRock02.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=BigRock03 FILE=EFFECTS\BigRock03.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=BigRock04 FILE=EFFECTS\BigRock04.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=BigRock05 FILE=EFFECTS\BigRock05.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=BigRock06 FILE=EFFECTS\BigRock06.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=BigRock07 FILE=EFFECTS\BigRock07.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=BigRock08 FILE=EFFECTS\BigRock08.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=BigRock09 FILE=EFFECTS\BigRock09.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=BigRock10 FILE=EFFECTS\BigRock10.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=BigRock11 FILE=EFFECTS\BigRock11.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=BigRock12 FILE=EFFECTS\BigRock12.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=BigRock13 FILE=EFFECTS\BigRock13.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=BigRock14 FILE=EFFECTS\BigRock14.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=BigRock15 FILE=EFFECTS\BigRock15.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=BigRock16 FILE=EFFECTS\BigRock16.bmp GROUP=Effects FLAGS=2


var() texture RockTex[16];
var() byte FrameScale;
var float InitFrame;

simulated function PostBeginPlay()
{
local rotator RndRoll;
local byte i;

	RndRoll.Pitch = Rotation.Pitch + Rand(4000)-2000;
	RndRoll.Yaw = Rotation.Yaw + Rand(4000)-2000;
	RndRoll.Roll = Rand(32768);
	SetRotation(RndRoll);

	For (i=0; i<8; i++)
		MultiSkins[i] = RockTex[Rand(16)];

	Velocity = vector(Rotation)*(950+Rand(250));
	RotationRate.Pitch = Rand(2000) - 1000;
	RotationRate.Yaw = Rand(2000) - 1000;

	SetTimer(Default.LifeSpan/8, True);
}

simulated function Tick(float Delta)
{
	if (AnimFrame > 0 && InitFrame > 0)
		AnimFrame = InitFrame/FrameScale + (Default.LifeSpan - LifeSpan)*(InitFrame/FrameScale*(FrameScale-1))/Default.LifeSpan;
	else if (AnimFrame > 0 && InitFrame == 0)
		InitFrame = AnimFrame;
}

simulated function Timer()
{
	if (MultiSkins[0] != Texture'MaskInvis')
		MultiSkins[0] = Texture'MaskInvis';
	else if (MultiSkins[1] != Texture'MaskInvis')
		MultiSkins[1] = Texture'MaskInvis';
	else if (MultiSkins[2] != Texture'MaskInvis')
		MultiSkins[2] = Texture'MaskInvis';
	else if (MultiSkins[3] != Texture'MaskInvis')
		MultiSkins[3] = Texture'MaskInvis';
	else if (MultiSkins[4] != Texture'MaskInvis')
		MultiSkins[4] = Texture'MaskInvis';
	else if (MultiSkins[5] != Texture'MaskInvis')
		MultiSkins[5] = Texture'MaskInvis';
	else if (MultiSkins[6] != Texture'MaskInvis')
		MultiSkins[6] = Texture'MaskInvis';
	else if (MultiSkins[7] != Texture'MaskInvis')
		MultiSkins[7] = Texture'MaskInvis';
}

defaultproperties
{
	RockTex(0)=Texture'XTreadVeh.Effects.BigRock01'
	RockTex(1)=Texture'XTreadVeh.Effects.BigRock02'
	RockTex(2)=Texture'XTreadVeh.Effects.BigRock03'
	RockTex(3)=Texture'XTreadVeh.Effects.BigRock04'
	RockTex(4)=Texture'XTreadVeh.Effects.BigRock05'
	RockTex(5)=Texture'XTreadVeh.Effects.BigRock06'
	RockTex(6)=Texture'XTreadVeh.Effects.BigRock07'
	RockTex(7)=Texture'XTreadVeh.Effects.BigRock08'
	RockTex(8)=Texture'XTreadVeh.Effects.BigRock09'
	RockTex(9)=Texture'XTreadVeh.Effects.BigRock10'
	RockTex(10)=Texture'XTreadVeh.Effects.BigRock11'
	RockTex(11)=Texture'XTreadVeh.Effects.BigRock12'
	RockTex(12)=Texture'XTreadVeh.Effects.BigRock13'
	RockTex(13)=Texture'XTreadVeh.Effects.BigRock14'
	RockTex(14)=Texture'XTreadVeh.Effects.BigRock15'
	RockTex(15)=Texture'XTreadVeh.Effects.BigRock16'
	FrameScale=3
	Physics=PHYS_Falling
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=3.500000
	DrawType=DT_Mesh
	Style=STY_Masked
	Texture=Texture'XTreadVeh.Effects.BigRock01'
	Mesh=LodMesh'BigStonesPart'
	DrawScale=1.065000
	ScaleGlow=0.825000
	bParticles=True
	bRandomFrame=True
	MultiSkins(0)=Texture'XTreadVeh.Effects.BigRock01'
	MultiSkins(1)=Texture'XTreadVeh.Effects.BigRock01'
	MultiSkins(2)=Texture'XTreadVeh.Effects.BigRock01'
	MultiSkins(3)=Texture'XTreadVeh.Effects.BigRock01'
	MultiSkins(4)=Texture'XTreadVeh.Effects.BigRock01'
	MultiSkins(5)=Texture'XTreadVeh.Effects.BigRock01'
	MultiSkins(6)=Texture'XTreadVeh.Effects.BigRock01'
	MultiSkins(7)=Texture'XTreadVeh.Effects.BigRock01'
	bFixedRotationDir=True
	RotationRate=(Pitch=500,Yaw=500)
}
