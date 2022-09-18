class VehDmgFire expands Effects;

#exec MESH IMPORT MESH=VehDmgFire ANIVFILE=MODELS\VehDmgFire_a.3d DATAFILE=MODELS\VehDmgFire_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VehDmgFire X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=VehDmgFire SEQ=All STARTFRAME=0 NUMFRAMES=5
#exec MESH SEQUENCE MESH=VehDmgFire SEQ=Pos01 STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VehDmgFire SEQ=Pos02 STARTFRAME=1 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VehDmgFire SEQ=Pos03 STARTFRAME=2 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VehDmgFire SEQ=Pos04 STARTFRAME=3 NUMFRAMES=1
#exec MESH SEQUENCE MESH=VehDmgFire SEQ=Pos05 STARTFRAME=4 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=VehDmgFire MESH=VehDmgFire
#exec MESHMAP SCALE MESHMAP=VehDmgFire X=0.35 Y=0.35 Z=0.7

#exec obj load file=..\Textures\UFire.utx package=UFire

var() name RndPos[5];
var() texture RndFlameTex[16];
var float GlowCount;

function PostBeginPlay()
{
	local vector Dir;
	local byte i;

	Velocity = Rand(200)*vect(0,0,1) + vect(0,0,100);
	AnimSequence = RndPos[Min(4,Rand(5))];

	For (i=0; i<8; i++)
		MultiSkins[i] = RndFlameTex[Min(15,Rand(16))];
}

function Tick(float Delta)
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
	RndPos(0)="Pos01"
	RndPos(1)="Pos02"
	RndPos(2)="Pos03"
	RndPos(3)="Pos04"
	RndPos(4)="Pos05"
	RndFlameTex(0)=Texture'UFire.FireB01'
	RndFlameTex(1)=Texture'UFire.FireB02'
	RndFlameTex(2)=Texture'UFire.FireB03'
	RndFlameTex(3)=Texture'UFire.FireB04'
	RndFlameTex(4)=Texture'UFire.FireB05'
	RndFlameTex(5)=Texture'UFire.FireB06'
	RndFlameTex(6)=Texture'UFire.FireB07'
	RndFlameTex(7)=Texture'UFire.FireB08'
	RndFlameTex(8)=Texture'UFire.FireB09'
	RndFlameTex(9)=Texture'UFire.FireB10'
	RndFlameTex(10)=Texture'UFire.FireB11'
	RndFlameTex(11)=Texture'UFire.FireB12'
	RndFlameTex(12)=Texture'UFire.FireB13'
	RndFlameTex(13)=Texture'UFire.FireB14'
	RndFlameTex(14)=Texture'UFire.FireB15'
	RndFlameTex(15)=Texture'UFire.FireB16'
	Physics=PHYS_Projectile
	RemoteRole=ROLE_None
	LifeSpan=0.280000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=Texture'UFire.FireB01'
	Mesh=LodMesh'XVehicles.VehDmgFire'
	DrawScale=0.480000
	ScaleGlow=1.500000
	bUnlit=True
	bParticles=True
	bRandomFrame=True
	MultiSkins(0)=Texture'UFire.FireB01'
	MultiSkins(1)=Texture'UFire.FireB01'
	MultiSkins(2)=Texture'UFire.FireB01'
	MultiSkins(3)=Texture'UFire.FireB01'
	MultiSkins(4)=Texture'UFire.FireB01'
	MultiSkins(5)=Texture'UFire.FireB01'
	MultiSkins(6)=Texture'UFire.FireB01'
	MultiSkins(7)=Texture'UFire.FireB01'
	LightType=LT_Steady
	LightBrightness=20
	LightRadius=3
}
