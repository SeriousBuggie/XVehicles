class BalWaterSplash00 expands Effects;

////////////////////////////////////////////////////////////////////////////////
//Category SMALL ballistic water fx
////////////////////////////////////////////////////////////////////////////////

#exec MESH IMPORT MESH=BalWaterSplash00 ANIVFILE=MODELS\WaterVertSplash_a.3d DATAFILE=MODELS\WaterVertSplash_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=BalWaterSplash00 STRENGTH=0.35
#exec MESH ORIGIN MESH=BalWaterSplash00 X=0 Y=0 Z=52

#exec MESH SEQUENCE MESH=BalWaterSplash00 SEQ=All STARTFRAME=0 NUMFRAMES=30
#exec MESH SEQUENCE MESH=BalWaterSplash00 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=BalWaterSplash00 SEQ=End STARTFRAME=29 NUMFRAMES=1
#exec MESH SEQUENCE MESH=BalWaterSplash00 SEQ=Burst STARTFRAME=0 NUMFRAMES=30 RATE=30.0

#exec MESHMAP NEW MESHMAP=BalWaterSplash00 MESH=BalWaterSplash00
#exec MESHMAP SCALE MESHMAP=BalWaterSplash00 X=0.25 Y=0.25 Z=1.0

var() float FinalDrawScale, InitSpeedMult;
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
	Velocity += (InitSpeedMult*vect(0,0,300));
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
	FinalDrawScale=0.375000
	InitSpeedMult=1.100000
	SplashSnd(0)=Sound'xZones.WaterSplash.WaterSplashSnd01'
	SplashSnd(1)=Sound'xZones.WaterSplash.WaterSplashSnd02'
	SplashSnd(2)=Sound'xZones.WaterSplash.WaterSplashSnd03'
	SplashSnd(3)=Sound'xZones.WaterSplash.WaterSplashSnd04'
	Physics=PHYS_Falling
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.750000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=Texture'xZones.Particles.WSplsh'
	Mesh=LodMesh'BalWaterSplash00'
	DrawScale=0.077500
	ScaleGlow=1.500000
	SpriteProjForward=0.000000
	bUnlit=True
	bParticles=True
}
