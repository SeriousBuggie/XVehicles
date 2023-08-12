class WaterVertSplashA05 expands WaterVertSplashA02;

////////////////////////////////////////////////////////////////////////////////
//Category HUGE water fx
////////////////////////////////////////////////////////////////////////////////

#exec MESH IMPORT MESH=WaterVertSplashA05 ANIVFILE=MODELS\WaterVertSplash_a.3d DATAFILE=MODELS\WaterVertSplash_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=WaterVertSplashA05 STRENGTH=0.35
#exec MESH ORIGIN MESH=WaterVertSplashA05 X=0 Y=0 Z=48

#exec MESH SEQUENCE MESH=WaterVertSplashA05 SEQ=All STARTFRAME=0 NUMFRAMES=30
#exec MESH SEQUENCE MESH=WaterVertSplashA05 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA05 SEQ=End STARTFRAME=29 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA05 SEQ=Burst STARTFRAME=0 NUMFRAMES=30 RATE=30.0

#exec MESHMAP NEW MESHMAP=WaterVertSplashA05 MESH=WaterVertSplashA05
#exec MESHMAP SCALE MESHMAP=WaterVertSplashA05 X=8.0 Y=8.0 Z=14.0

defaultproperties
{
	FinalDrawScale=8.000000
	Mesh=LodMesh'WaterVertSplashA05'
	DrawScale=2.000000
}
