class SmkTrace expands xTreadVehEffects;

#exec MESH IMPORT MESH=SmkTrace ANIVFILE=MODELS\SmkTrace_a.3d DATAFILE=MODELS\SmkTrace_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=SmkTrace STRENGTH=0.4
#exec MESH ORIGIN MESH=SmkTrace X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=SmkTrace SEQ=All STARTFRAME=0 NUMFRAMES=4
#exec MESH SEQUENCE MESH=SmkTrace SEQ=SmkFX1 STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=SmkTrace SEQ=SmkFX2 STARTFRAME=1 NUMFRAMES=1
#exec MESH SEQUENCE MESH=SmkTrace SEQ=SmkFX3 STARTFRAME=2 NUMFRAMES=1
#exec MESH SEQUENCE MESH=SmkTrace SEQ=SmkFX4 STARTFRAME=3 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=SmkTrace MESH=SmkTrace
#exec MESHMAP SCALE MESHMAP=SmkTrace X=0.5 Y=0.5 Z=1.0

#exec obj load file=..\Textures\USmoke.utx package=USmoke

var() texture RndSmk[16];
var() name RndAnimFX[4];
var float GlowCount;

simulated function PostBeginPlay()
{
local byte i;

	AnimSequence = RndAnimFX[Min(Rand(4),3)];
	For (i=0; i<8; i++)
		MultiSkins[i] = RndSmk[Min(Rand(16),15)];

	/*if (AnimSequence == RndAnimFX[0])
		TweenAnim(RndAnimFX[1], 3.0);
	else if (AnimSequence == RndAnimFX[1])
		TweenAnim(RndAnimFX[2], 3.0);
	else if (AnimSequence == RndAnimFX[2])
		TweenAnim(RndAnimFX[3], 3.0);
	else if (AnimSequence == RndAnimFX[3])
		TweenAnim(RndAnimFX[0], 3.0);*/
}

simulated function Tick(float Delta)
{
	if (Default.LifeSpan - LifeSpan <= 0.1)
	{
		GlowCount += Delta;
		ScaleGlow = GlowCount * Default.ScaleGlow / 0.1;
	}
	else
		ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
}

defaultproperties
{
	RndSmk(0)=Texture'USmoke.SmkA01'
	RndSmk(1)=Texture'USmoke.SmkA02'
	RndSmk(2)=Texture'USmoke.SmkA03'
	RndSmk(3)=Texture'USmoke.SmkA04'
	RndSmk(4)=Texture'USmoke.SmkA05'
	RndSmk(5)=Texture'USmoke.SmkA06'
	RndSmk(6)=Texture'USmoke.SmkA07'
	RndSmk(7)=Texture'USmoke.SmkA08'
	RndSmk(8)=Texture'USmoke.SmkA09'
	RndSmk(9)=Texture'USmoke.SmkA10'
	RndSmk(10)=Texture'USmoke.SmkA11'
	RndSmk(11)=Texture'USmoke.SmkA12'
	RndSmk(12)=Texture'USmoke.SmkA13'
	RndSmk(13)=Texture'USmoke.SmkA14'
	RndSmk(14)=Texture'USmoke.SmkA15'
	RndSmk(15)=Texture'USmoke.SmkA16'
	RndAnimFX(0)="SmkFX1"
	RndAnimFX(1)="SmkFX2"
	RndAnimFX(2)="SmkFX3"
	RndAnimFX(3)="SmkFX4"
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=3.100000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=Texture'USmoke.SmkA01'
	Mesh=LodMesh'XTreadVeh.SmkTrace'
	DrawScale=0.440000
	bUnlit=True
	bParticles=True
	bRandomFrame=True
	MultiSkins(0)=Texture'USmoke.SmkA01'
	MultiSkins(1)=Texture'USmoke.SmkA02'
	MultiSkins(2)=Texture'USmoke.SmkA03'
	MultiSkins(3)=Texture'USmoke.SmkA04'
	MultiSkins(4)=Texture'USmoke.SmkA05'
	MultiSkins(5)=Texture'USmoke.SmkA06'
	MultiSkins(6)=Texture'USmoke.SmkA07'
	MultiSkins(7)=Texture'USmoke.SmkA08'
}
