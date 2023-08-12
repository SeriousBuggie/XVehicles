class IncadescentPart expands xTreadVehEffects;

#exec MESH IMPORT MESH=IncadescentPart ANIVFILE=MODELS\IncadesPart_a.3d DATAFILE=MODELS\IncadesPart_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=IncadescentPart STRENGTH=0.75
#exec MESH ORIGIN MESH=IncadescentPart X=0 Y=0 Z=0 PITCH=64

#exec MESH SEQUENCE MESH=IncadescentPart SEQ=All STARTFRAME=0 NUMFRAMES=3
#exec MESH SEQUENCE MESH=IncadescentPart SEQ=Shrink STARTFRAME=0 NUMFRAMES=2 RATE=1.0
#exec MESH SEQUENCE MESH=IncadescentPart SEQ=Grow STARTFRAME=1 NUMFRAMES=2 RATE=1.0

#exec MESHMAP NEW MESHMAP=IncadescentPart MESH=IncadescentPart
#exec MESHMAP SCALE MESHMAP=IncadescentPart X=10.0 Y=5.0 Z=12.5

#exec TEXTURE IMPORT NAME=Incandescent01 FILE=EFFECTS\Incandescent01.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=Incandescent02 FILE=EFFECTS\Incandescent02.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=Incandescent03 FILE=EFFECTS\Incandescent03.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=Incandescent04 FILE=EFFECTS\Incandescent04.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=Incandescent05 FILE=EFFECTS\Incandescent05.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=Incandescent06 FILE=EFFECTS\Incandescent06.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=Incandescent07 FILE=EFFECTS\Incandescent07.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=Incandescent08 FILE=EFFECTS\Incandescent08.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=Incandescent09 FILE=EFFECTS\Incandescent09.bmp GROUP=Effects FLAGS=2

var() byte FrameScale;
var() float StartFadeInTime;
var() texture IncandesTex[9];
var float InitFrame;

simulated function PostBeginPlay()
{
local rotator RndRoll;
local byte i;

	RndRoll = Rotation;
	RndRoll.Roll = Rand(32768);
	SetRotation(RndRoll);

	Velocity = Region.Zone.ZoneGravity / 2.5;
	RotationRate.Pitch = Rand(2000) - 1000;
	RotationRate.Yaw = Rand(2000) - 1000;
	
	for (i = 0; i < 8; i++)
		MultiSkins[i] = IncandesTex[Rand(9)];
		
	LifeSpan += StartFadeInTime;
}

simulated function Tick(float Delta)
{
	if (AnimFrame > 0 && InitFrame > 0)
		AnimFrame = InitFrame/FrameScale + (Default.LifeSpan - LifeSpan)*(InitFrame/FrameScale*(FrameScale-1))/Default.LifeSpan;
	else if (AnimFrame > 0 && InitFrame == 0)
		InitFrame = AnimFrame;
	
	if (LifeSpan > Default.LifeSpan)
		ScaleGlow = (StartFadeInTime - (LifeSpan - Default.LifeSpan)) * Default.ScaleGlow / StartFadeInTime;
	else
		ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
}

defaultproperties
{
	FrameScale=3
	StartFadeInTime=0.100000
	IncandesTex(0)=Texture'XTreadVeh.Effects.Incandescent01'
	IncandesTex(1)=Texture'XTreadVeh.Effects.Incandescent02'
	IncandesTex(2)=Texture'XTreadVeh.Effects.Incandescent03'
	IncandesTex(3)=Texture'XTreadVeh.Effects.Incandescent04'
	IncandesTex(4)=Texture'XTreadVeh.Effects.Incandescent05'
	IncandesTex(5)=Texture'XTreadVeh.Effects.Incandescent06'
	IncandesTex(6)=Texture'XTreadVeh.Effects.Incandescent07'
	IncandesTex(7)=Texture'XTreadVeh.Effects.Incandescent08'
	IncandesTex(8)=Texture'XTreadVeh.Effects.Incandescent09'
	Physics=PHYS_Projectile
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=1.000000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=Texture'XTreadVeh.Effects.Incandescent01'
	Mesh=LodMesh'IncadescentPart'
	DrawScale=0.500000
	ScaleGlow=2.800000
	bUnlit=True
	bParticles=True
	bRandomFrame=True
	MultiSkins(0)=Texture'XTreadVeh.Effects.Incandescent01'
	MultiSkins(1)=Texture'XTreadVeh.Effects.Incandescent02'
	MultiSkins(2)=Texture'XTreadVeh.Effects.Incandescent03'
	MultiSkins(3)=Texture'XTreadVeh.Effects.Incandescent04'
	MultiSkins(4)=Texture'XTreadVeh.Effects.Incandescent05'
	MultiSkins(5)=Texture'XTreadVeh.Effects.Incandescent06'
	MultiSkins(6)=Texture'XTreadVeh.Effects.Incandescent07'
	MultiSkins(7)=Texture'XTreadVeh.Effects.Incandescent08'
	bFixedRotationDir=True
	RotationRate=(Pitch=500,Yaw=500)
}
