class EnLinesLineRed expands xTreadVehEffects;

#exec MESH IMPORT MESH=EnLinesLineRed ANIVFILE=MODELS\EnLinesLine_a.3d DATAFILE=MODELS\EnLinesLine_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=EnLinesLineRed STRENGTH=0.75
#exec MESH ORIGIN MESH=EnLinesLineRed X=520 Y=0 Z=0

#exec MESH SEQUENCE MESH=EnLinesLineRed SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=EnLinesLineRed SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=EnLinesLineRed MESH=EnLinesLine
#exec MESHMAP SCALE MESHMAP=EnLinesLineRed X=0.1 Y=0.1 Z=0.2

#exec TEXTURE IMPORT NAME=EnLinesLnRed FILE=EFFECTS\EnLinesLnRed.bmp GROUP=Effects LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=EnLinesLineRed NUM=1 TEXTURE=EnLinesLnRed

var() float LifeSError, InitDrawScale;
var float GlowCount, InitLifeSpan;

function PostBeginPlay()
{
	InitLifeSpan = Default.LifeSpan + FRand()*LifeSError;
	LifeSpan = InitLifeSpan;
	DrawScale = InitDrawScale*Default.DrawScale;
}

function Tick(float Delta)
{
	if (InitLifeSpan != 0)
	{

	if (InitLifeSpan - LifeSpan <= 0.1)
	{
		GlowCount += Delta;
		ScaleGlow = GlowCount * Default.ScaleGlow / 0.1;
	}
	else
		ScaleGlow = LifeSpan * Default.ScaleGlow / InitLifeSpan;
		DrawScale = Default.DrawScale + (LifeSpan * InitDrawScale*Default.DrawScale / InitLifeSpan);
	}
}

defaultproperties
{
	LifeSError=0.250000
	InitDrawScale=2.000000
	RemoteRole=ROLE_None
	LifeSpan=0.125000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=LodMesh'XTreadVeh.EnLinesLineRed'
	ScaleGlow=2.500000
	bUnlit=True
	bRandomFrame=True
}
