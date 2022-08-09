class WaterVertSplashA06 expands WaterVertSplashA02;

////////////////////////////////////////////////////////////////////////////////
//Category SUPER HUGE water fx
////////////////////////////////////////////////////////////////////////////////

#exec MESH IMPORT MESH=WaterVertSplashA06 ANIVFILE=MODELS\WaterVertSplash_a.3d DATAFILE=MODELS\WaterVertSplash_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=WaterVertSplashA06 STRENGTH=0.35
#exec MESH ORIGIN MESH=WaterVertSplashA06 X=0 Y=0 Z=48

#exec MESH SEQUENCE MESH=WaterVertSplashA06 SEQ=All STARTFRAME=0 NUMFRAMES=30
#exec MESH SEQUENCE MESH=WaterVertSplashA06 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA06 SEQ=End STARTFRAME=29 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA06 SEQ=Burst STARTFRAME=0 NUMFRAMES=30 RATE=30.0

#exec MESHMAP NEW MESHMAP=WaterVertSplashA06 MESH=WaterVertSplashA06
#exec MESHMAP SCALE MESHMAP=WaterVertSplashA06 X=16.0 Y=16.0 Z=28.0

defaultproperties
{
	FinalDrawScale=16.000000
	Mesh=LodMesh'xZones.WaterVertSplashA06'
	DrawScale=4.000000
}
