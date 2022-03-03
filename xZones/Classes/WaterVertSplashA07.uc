class WaterVertSplashA07 expands WaterVertSplashA02;

////////////////////////////////////////////////////////////////////////////////
//Category !FUCKING! HUGE water fx
////////////////////////////////////////////////////////////////////////////////

#exec MESH IMPORT MESH=WaterVertSplashA07 ANIVFILE=MODELS\WaterVertSplash_a.3d DATAFILE=MODELS\WaterVertSplash_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=WaterVertSplashA07 STRENGTH=0.35
#exec MESH ORIGIN MESH=WaterVertSplashA07 X=0 Y=0 Z=48

#exec MESH SEQUENCE MESH=WaterVertSplashA07 SEQ=All STARTFRAME=0 NUMFRAMES=30
#exec MESH SEQUENCE MESH=WaterVertSplashA07 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA07 SEQ=End STARTFRAME=29 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterVertSplashA07 SEQ=Burst STARTFRAME=0 NUMFRAMES=30 RATE=30.0

#exec MESHMAP NEW MESHMAP=WaterVertSplashA07 MESH=WaterVertSplashA07
#exec MESHMAP SCALE MESHMAP=WaterVertSplashA07 X=32.0 Y=32.0 Z=56.0

defaultproperties
{
      FinalDrawScale=32.000000
      Mesh=LodMesh'xZones.WaterVertSplashA07'
      DrawScale=8.000000
}
