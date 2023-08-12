class WaterSplashRing expands Effects;

#exec MESH IMPORT MESH=WaterSplashRing ANIVFILE=MODELS\WaterSplashRing_a.3d DATAFILE=MODELS\WaterSplashRing_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=WaterSplashRing X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=WaterSplashRing SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterSplashRing SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=WaterSplashRing MESH=WaterSplashRing
#exec MESHMAP SCALE MESHMAP=WaterSplashRing X=0.15 Y=0.15 Z=0.3

#exec TEXTURE IMPORT NAME=WaterSplashRing FILE=PARTICLES\WaterSplashRing.bmp GROUP=Particles FLAGS=2
#exec MESHMAP SETTEXTURE MESHMAP=WaterSplashRing NUM=1 TEXTURE=WaterSplashRing

var float InitDrawScale;

simulated function Tick( float DeltaTime)
{
	DrawScale = (Default.LifeSpan - LifeSpan) * InitDrawScale / Default.LifeSpan;
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
}

defaultproperties
{
	Physics=PHYS_Rotating
	RemoteRole=ROLE_None
	LifeSpan=1.250000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=LodMesh'WaterSplashRing'
	DrawScale=3.000000
	ScaleGlow=1.800000
	bUnlit=True
	bFixedRotationDir=True
}
