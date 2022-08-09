class DustParticles expands xTreadVehEffects;

#exec MESH IMPORT MESH=DustParticles ANIVFILE=MODELS\DustParticles_a.3d DATAFILE=MODELS\DustParticles_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=DustParticles X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=DustParticles SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=DustParticles SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=DustParticles MESH=DustParticles
#exec MESHMAP SCALE MESHMAP=DustParticles X=4.685 Y=4.685 Z=9.37

#exec TEXTURE IMPORT NAME=DustPart01 FILE=EFFECTS\DustPart01.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=DustPart02 FILE=EFFECTS\DustPart02.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=DustPart03 FILE=EFFECTS\DustPart03.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=DustPart04 FILE=EFFECTS\DustPart04.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=DustPart05 FILE=EFFECTS\DustPart05.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=DustPart06 FILE=EFFECTS\DustPart06.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=DustPart07 FILE=EFFECTS\DustPart07.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=DustPart08 FILE=EFFECTS\DustPart08.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=DustPart09 FILE=EFFECTS\DustPart09.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=DustPart10 FILE=EFFECTS\DustPart10.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=DustPart11 FILE=EFFECTS\DustPart11.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=DustPart12 FILE=EFFECTS\DustPart12.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=DustPart13 FILE=EFFECTS\DustPart13.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=DustPart14 FILE=EFFECTS\DustPart14.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=DustPart15 FILE=EFFECTS\DustPart15.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=DustPart16 FILE=EFFECTS\DustPart16.bmp GROUP=Effects FLAGS=2

var() texture DustTex[16];

simulated function PostBeginPlay()
{
local rotator RndRoll;
local byte i;

	RndRoll.Pitch = Rotation.Pitch + Rand(4000)-2000;
	RndRoll.Yaw = Rotation.Yaw + Rand(4000)-2000;
	RndRoll.Roll = Rand(32768);
	SetRotation(RndRoll);

	For (i=0; i<8; i++)
		MultiSkins[i] = DustTex[Rand(16)];

	Velocity = vector(Rotation)*(300+Rand(900));
	RotationRate.Pitch = Rand(2000) - 1000;
	RotationRate.Yaw = Rand(2000) - 1000;

	SetTimer(Default.LifeSpan/8, True);
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
	DustTex(0)=Texture'XTreadVeh.Effects.DustPart01'
	DustTex(1)=Texture'XTreadVeh.Effects.DustPart02'
	DustTex(2)=Texture'XTreadVeh.Effects.DustPart03'
	DustTex(3)=Texture'XTreadVeh.Effects.DustPart04'
	DustTex(4)=Texture'XTreadVeh.Effects.DustPart05'
	DustTex(5)=Texture'XTreadVeh.Effects.DustPart06'
	DustTex(6)=Texture'XTreadVeh.Effects.DustPart07'
	DustTex(7)=Texture'XTreadVeh.Effects.DustPart08'
	DustTex(8)=Texture'XTreadVeh.Effects.DustPart09'
	DustTex(9)=Texture'XTreadVeh.Effects.DustPart10'
	DustTex(10)=Texture'XTreadVeh.Effects.DustPart11'
	DustTex(11)=Texture'XTreadVeh.Effects.DustPart12'
	DustTex(12)=Texture'XTreadVeh.Effects.DustPart13'
	DustTex(13)=Texture'XTreadVeh.Effects.DustPart14'
	DustTex(14)=Texture'XTreadVeh.Effects.DustPart15'
	DustTex(15)=Texture'XTreadVeh.Effects.DustPart16'
	Physics=PHYS_Falling
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=3.500000
	DrawType=DT_Mesh
	Style=STY_Masked
	Texture=Texture'XTreadVeh.Effects.DustPart01'
	Mesh=LodMesh'XTreadVeh.DustParticles'
	bParticles=True
	bRandomFrame=True
	MultiSkins(0)=Texture'XTreadVeh.Effects.DustPart01'
	MultiSkins(1)=Texture'XTreadVeh.Effects.DustPart01'
	MultiSkins(2)=Texture'XTreadVeh.Effects.DustPart01'
	MultiSkins(3)=Texture'XTreadVeh.Effects.DustPart01'
	MultiSkins(4)=Texture'XTreadVeh.Effects.DustPart01'
	MultiSkins(5)=Texture'XTreadVeh.Effects.DustPart01'
	MultiSkins(6)=Texture'XTreadVeh.Effects.DustPart01'
	MultiSkins(7)=Texture'XTreadVeh.Effects.DustPart01'
	bFixedRotationDir=True
	RotationRate=(Pitch=500,Yaw=500)
}
