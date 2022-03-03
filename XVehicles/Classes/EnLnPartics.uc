//Energy line particles (each actor has 12 particles, with 6 possible textures)
// It has explosion and implosion animations, as 30є and 60є spirals, clockwise and anti-clockwise
// For effects like "energy gathering" of weapons
// With this actor, instead of spawning 36 particles, you have to just spawn 3 (36/12 = 3), boosting the performance a lot :)
//*************************************************************************************
class EnLnPartics expands Effects;

//Energy Line Particles mesh import
#exec MESH IMPORT MESH=EnLnPartics ANIVFILE=MODELS\EnLnPartics_a.3d DATAFILE=MODELS\EnLnPartics_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=EnLnPartics STRENGTH=0.5
#exec MESH ORIGIN MESH=EnLnPartics X=0 Y=0 Z=0


//Energy Line Particles animations
#exec MESH SEQUENCE MESH=EnLnPartics SEQ=All STARTFRAME=0 NUMFRAMES=15
#exec MESH SEQUENCE MESH=EnLnPartics SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=EnLnPartics SEQ=Impl00 STARTFRAME=0 NUMFRAMES=2 RATE=1.0	//Straight implode
#exec MESH SEQUENCE MESH=EnLnPartics SEQ=Expl00 STARTFRAME=1 NUMFRAMES=2 RATE=1.0	//Straight explode
#exec MESH SEQUENCE MESH=EnLnPartics SEQ=ImplP30 STARTFRAME=3 NUMFRAMES=2 RATE=1.0	//Positive spiral 30є implode
#exec MESH SEQUENCE MESH=EnLnPartics SEQ=ExplP30 STARTFRAME=4 NUMFRAMES=2 RATE=1.0	//Positive spiral 30є explode
#exec MESH SEQUENCE MESH=EnLnPartics SEQ=ImplN30 STARTFRAME=6 NUMFRAMES=2 RATE=1.0	//Negative spiral 30є implode
#exec MESH SEQUENCE MESH=EnLnPartics SEQ=ExplN30 STARTFRAME=7 NUMFRAMES=2 RATE=1.0	//Negative spiral 30є explode
#exec MESH SEQUENCE MESH=EnLnPartics SEQ=ImplP60 STARTFRAME=9 NUMFRAMES=2 RATE=1.0	//Positive spiral 60є implode
#exec MESH SEQUENCE MESH=EnLnPartics SEQ=ExplP60 STARTFRAME=10 NUMFRAMES=2 RATE=1.0	//Positive spiral 60є explode
#exec MESH SEQUENCE MESH=EnLnPartics SEQ=ImplN30 STARTFRAME=12 NUMFRAMES=2 RATE=1.0	//Negative spiral 60є implode
#exec MESH SEQUENCE MESH=EnLnPartics SEQ=ExplN30 STARTFRAME=13 NUMFRAMES=2 RATE=1.0	//Negative spiral 60є explode

//Energy Line Particles animation
#exec MESHMAP NEW MESHMAP=EnLnPartics MESH=EnLnPartics
#exec MESHMAP SCALE MESHMAP=EnLnPartics X=0.1 Y=0.1 Z=0.2


//Basic texture skinning
#exec TEXTURE IMPORT NAME=EnLnDef FILE=EFFECTS\EnLnDef.bmp GROUP=Effects LODSET=2

#exec MESHMAP SETTEXTURE MESHMAP=EnLnPartics NUM=1 TEXTURE=EnLnDef
#exec MESHMAP SETTEXTURE MESHMAP=EnLnPartics NUM=2 TEXTURE=EnLnDef
#exec MESHMAP SETTEXTURE MESHMAP=EnLnPartics NUM=3 TEXTURE=EnLnDef
#exec MESHMAP SETTEXTURE MESHMAP=EnLnPartics NUM=4 TEXTURE=EnLnDef
#exec MESHMAP SETTEXTURE MESHMAP=EnLnPartics NUM=5 TEXTURE=EnLnDef
#exec MESHMAP SETTEXTURE MESHMAP=EnLnPartics NUM=6 TEXTURE=EnLnDef


var() float FXSpeed, ProgressiveFXSpeed;	//10 = 1s
var() byte RollRate;	// x4096 (22,5є/s) --> 60є settings :: x2048 (11,25є/s) --> 30є settings
var() bool bExtInitialized;	//Effect started only externally
var float LifeTime;
var name eAnimList[10];
var float rolling;
var float currentAnimR;
var vector eOffset;

var() enum EEffectStyle
{
	ES_ImplNormal00,
	ES_ImplPositive30,
	ES_ImplPositive60,
	ES_ImplNegative30,
	ES_ImplNegative60,
	ES_ExplNormal00,
	ES_ExplPositive30,
	ES_ExplPositive60,
	ES_ExplNegative30,
	ES_ExplNegative60,
} EffectStyle;


simulated function PostBeginPlay()
{
	if (!bExtInitialized)
	{
		LifeTime = 10/FXSpeed;
		LifeSpan = LifeTime;
		PlayAnim( eAnimList[EffectStyle], FXSpeed/10, 0.05);
	}

	if (EffectStyle==ES_ImplPositive30 || EffectStyle==ES_ExplNegative30)
		rolling = Float(RollRate) * 2048;
	else if (EffectStyle==ES_ImplNegative30 || EffectStyle==ES_ExplPositive30)
		rolling = -Float(RollRate) * 2048;
	else if (EffectStyle==ES_ImplPositive60 || EffectStyle==ES_ExplNegative60)
		rolling = Float(RollRate) * 4096;
	else if (EffectStyle==ES_ImplNegative60 || EffectStyle==ES_ExplPositive60)
		rolling = -Float(RollRate) * 4096;
}

static function float GetTimeExtend(float delaynow, int reptc, int repttot)
{
local float timeX;

	timex = delaynow / (Default.FXSpeed / Default.ProgressiveFXSpeed);
	return (timex * reptc / repttot);
}

simulated function ExtInit(float animr)
{
	currentAnimR = animr;
	LifeTime = 10 / (FXSpeed-ProgressiveFXSpeed*animr);
	LifeSpan = LifeTime;
	PlayAnim( eAnimList[EffectStyle], (FXSpeed-ProgressiveFXSpeed*animr)/10, 0.05);
}

simulated function Tick(float Delta)
{
local rotator tempR;

	if (LifeTime > 0)
		ScaleGlow = (LifeTime - LifeSpan) * Default.ScaleGlow / LifeTime;

	if (Owner != None)
	{
		tempR = Owner.Rotation;
		tempR.Roll = Rotation.Roll;

		if (EffectStyle != 0 && EffectStyle != 5)
		{
			if (!bExtInitialized)
				tempR.Roll += (rolling * Delta * (FXSpeed/10));
			else
				tempR.Roll += (rolling * Delta * ((FXSpeed-ProgressiveFXSpeed*currentAnimR) / 10));
		}
		else
			tempR.Roll = Rotation.Roll;

		SetRotation(tempR);

		SetLocation(Owner.Location + (eOffset >> Owner.Rotation));
	}
}

defaultproperties
{
      FXSpeed=10.000000
      ProgressiveFXSpeed=5.000000
      RollRate=16
      bExtInitialized=False
      Lifetime=0.000000
      eAnimList(0)="Impl00"
      eAnimList(1)="ImplP30"
      eAnimList(2)="ImplP60"
      eAnimList(3)="ImplN30"
      eAnimList(4)="ImplN60"
      eAnimList(5)="Expl00"
      eAnimList(6)="ExplP30"
      eAnimList(7)="ExplP60"
      eAnimList(8)="ExplN30"
      eAnimList(9)="ExplN60"
      rolling=0.000000
      currentAnimR=0.000000
      eOffset=(X=0.000000,Y=0.000000,Z=0.000000)
      EffectStyle=ES_ImplNormal00
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=10.000000
      DrawType=DT_Mesh
      Style=STY_Translucent
      Mesh=LodMesh'XVehicles.EnLnPartics'
      ScaleGlow=2.000000
      bUnlit=True
}
