class WaterVertSplashA00 expands WaterVertSplashA02;

////////////////////////////////////////////////////////////////////////////////
//Category SMALL water fx
////////////////////////////////////////////////////////////////////////////////

#exec MESH IMPORT MESH=WaterVertSplashA00 ANIVFILE=MODELS\WaterVertSplash_a.3d DATAFILE=MODELS\WaterVertSplash_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=WaterVertSplashA00 STRENGTH=0.35
#exec MESH ORIGIN MESH=WaterVertSplashA00 X=0 Y=0 Z=48

#exec MESH SEQUENCE MESH=WaterVertSplashA00 SEQ=All STARTFRAME=0 NUMFRAMES=30
#exec MESH SEQUENCE MESH=WaterVertSplashA00 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA00 SEQ=End STARTFRAME=29 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA00 SEQ=Burst STARTFRAME=0 NUMFRAMES=30 RATE=30.0

#exec MESHMAP NEW MESHMAP=WaterVertSplashA00 MESH=WaterVertSplashA00
#exec MESHMAP SCALE MESHMAP=WaterVertSplashA00 X=0.25 Y=0.25 Z=0.4375

defaultproperties
{
	FinalDrawScale=0.250000
	InitSpdMult=0.750000
	Mesh=LodMesh'xZones.WaterVertSplashA00'
	DrawScale=0.062500
}
