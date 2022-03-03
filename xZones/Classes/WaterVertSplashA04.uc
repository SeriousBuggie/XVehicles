class WaterVertSplashA04 expands WaterVertSplashA02;

////////////////////////////////////////////////////////////////////////////////
//Category SUPER BIG water fx
////////////////////////////////////////////////////////////////////////////////

#exec MESH IMPORT MESH=WaterVertSplashA04 ANIVFILE=MODELS\WaterVertSplash_a.3d DATAFILE=MODELS\WaterVertSplash_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=WaterVertSplashA04 STRENGTH=0.35
#exec MESH ORIGIN MESH=WaterVertSplashA04 X=0 Y=0 Z=48

#exec MESH SEQUENCE MESH=WaterVertSplashA04 SEQ=All STARTFRAME=0 NUMFRAMES=30
#exec MESH SEQUENCE MESH=WaterVertSplashA04 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA04 SEQ=End STARTFRAME=29 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA04 SEQ=Burst STARTFRAME=0 NUMFRAMES=30 RATE=30.0

#exec MESHMAP NEW MESHMAP=WaterVertSplashA04 MESH=WaterVertSplashA04
#exec MESHMAP SCALE MESHMAP=WaterVertSplashA04 X=4.0 Y=4.0 Z=7.0

defaultproperties
{
      FinalDrawScale=4.000000
      Mesh=LodMesh'xZones.WaterVertSplashA04'
      DrawScale=1.000000
}
