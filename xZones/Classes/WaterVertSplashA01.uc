class WaterVertSplashA01 expands WaterVertSplashA02;

////////////////////////////////////////////////////////////////////////////////
//Category SMALL + water fx
////////////////////////////////////////////////////////////////////////////////

#exec MESH IMPORT MESH=WaterVertSplashA01 ANIVFILE=MODELS\WaterVertSplash_a.3d DATAFILE=MODELS\WaterVertSplash_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=WaterVertSplashA01 STRENGTH=0.35
#exec MESH ORIGIN MESH=WaterVertSplashA01 X=0 Y=0 Z=48

#exec MESH SEQUENCE MESH=WaterVertSplashA01 SEQ=All STARTFRAME=0 NUMFRAMES=30
#exec MESH SEQUENCE MESH=WaterVertSplashA01 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA01 SEQ=End STARTFRAME=29 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA01 SEQ=Burst STARTFRAME=0 NUMFRAMES=30 RATE=30.0

#exec MESHMAP NEW MESHMAP=WaterVertSplashA01 MESH=WaterVertSplashA01
#exec MESHMAP SCALE MESHMAP=WaterVertSplashA01 X=0.5 Y=0.5 Z=0.875

defaultproperties
{
	FinalDrawScale=0.500000
	InitSpdMult=0.875000
	Mesh=LodMesh'xZones.WaterVertSplashA01'
	DrawScale=0.125000
}
