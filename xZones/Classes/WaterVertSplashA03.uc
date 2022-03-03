class WaterVertSplashA03 expands WaterVertSplashA02;

////////////////////////////////////////////////////////////////////////////////
//Category BIG water fx
////////////////////////////////////////////////////////////////////////////////

#exec MESH IMPORT MESH=WaterVertSplashA03 ANIVFILE=MODELS\WaterVertSplash_a.3d DATAFILE=MODELS\WaterVertSplash_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=WaterVertSplashA03 STRENGTH=0.35
#exec MESH ORIGIN MESH=WaterVertSplashA03 X=0 Y=0 Z=48

#exec MESH SEQUENCE MESH=WaterVertSplashA03 SEQ=All STARTFRAME=0 NUMFRAMES=30
#exec MESH SEQUENCE MESH=WaterVertSplashA03 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA03 SEQ=End STARTFRAME=29 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA03 SEQ=Burst STARTFRAME=0 NUMFRAMES=30 RATE=30.0

#exec MESHMAP NEW MESHMAP=WaterVertSplashA03 MESH=WaterVertSplashA03
#exec MESHMAP SCALE MESHMAP=WaterVertSplashA03 X=2.0 Y=2.0 Z=3.5

defaultproperties
{
      FinalDrawScale=2.000000
      Mesh=LodMesh'xZones.WaterVertSplashA03'
      DrawScale=0.500000
}
