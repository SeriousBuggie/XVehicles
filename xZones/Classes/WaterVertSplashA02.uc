class WaterVertSplashA02 expands Effects;

////////////////////////////////////////////////////////////////////////////////
//Category NORMAL water fx
////////////////////////////////////////////////////////////////////////////////

#exec MESH IMPORT MESH=WaterVertSplashA02 ANIVFILE=MODELS\WaterVertSplash_a.3d DATAFILE=MODELS\WaterVertSplash_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=WaterVertSplashA02 STRENGTH=0.35
#exec MESH ORIGIN MESH=WaterVertSplashA02 X=0 Y=0 Z=48

#exec MESH SEQUENCE MESH=WaterVertSplashA02 SEQ=All STARTFRAME=0 NUMFRAMES=30
#exec MESH SEQUENCE MESH=WaterVertSplashA02 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA02 SEQ=End STARTFRAME=29 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA02 SEQ=Burst STARTFRAME=0 NUMFRAMES=30 RATE=30.0

#exec MESHMAP NEW MESHMAP=WaterVertSplashA02 MESH=WaterVertSplashA02
#exec MESHMAP SCALE MESHMAP=WaterVertSplashA02 X=1.0 Y=1.0 Z=1.75


#exec TEXTURE IMPORT NAME=WSplsh FILE=PARTICLES\WSplsh.bmp GROUP=Particles FLAGS=2
#exec TEXTURE IMPORT NAME=TransInvis FILE=PARTICLES\TransInvis.bmp GROUP=Particles FLAGS=2

#exec AUDIO IMPORT NAME="WaterSplashSnd01" FILE=SOUNDS\WaterSplashSnd01.wav GROUP="WaterSplash"
#exec AUDIO IMPORT NAME="WaterSplashSnd02" FILE=SOUNDS\WaterSplashSnd02.wav GROUP="WaterSplash"
#exec AUDIO IMPORT NAME="WaterSplashSnd03" FILE=SOUNDS\WaterSplashSnd03.wav GROUP="WaterSplash"
#exec AUDIO IMPORT NAME="WaterSplashSnd04" FILE=SOUNDS\WaterSplashSnd04.wav GROUP="WaterSplash"

var() float FinalDrawScale, InitSpdMult;
var() sound SplashSnd[4];

simulated function PostBeginPlay()
{
local byte i;

	if (Class'xZoneInfo'.default.WaterZoneFXDetail < 7)
	{
		For (i = 0; i < 8; i++)
		{
			if (i <= Class'xZoneInfo'.default.WaterZoneFXDetail)
				MultiSkins[i] = Texture;
			else
				MultiSkins[i] = Texture'TransInvis';
		}

		bRandomFrame = True;
	}

	PlayAnim('Burst', 1/Default.LifeSpan, 0.05);
	Velocity += (InitSpdMult*vect(0,0,300));
}

simulated function Tick(float Delta)
{
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
	DrawScale = (Default.LifeSpan - LifeSpan) * Default.DrawScale / Default.LifeSpan + FinalDrawScale;
}

auto state IgnoringWorld
{
	ignores FellOutOfWorld, HitWall, Touch, Bump, Landed;
}

defaultproperties
{
	FinalDrawScale=1.000000
	InitSpdMult=1.000000
	SplashSnd(0)=Sound'xZones.WaterSplash.WaterSplashSnd01'
	SplashSnd(1)=Sound'xZones.WaterSplash.WaterSplashSnd02'
	SplashSnd(2)=Sound'xZones.WaterSplash.WaterSplashSnd03'
	SplashSnd(3)=Sound'xZones.WaterSplash.WaterSplashSnd04'
	Physics=PHYS_Falling
	RemoteRole=ROLE_None
	LifeSpan=0.750000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=Texture'xZones.Particles.WSplsh'
	Mesh=LodMesh'WaterVertSplashA02'
	DrawScale=0.250000
	ScaleGlow=1.500000
	SpriteProjForward=0.000000
	bUnlit=True
	bParticles=True
}
