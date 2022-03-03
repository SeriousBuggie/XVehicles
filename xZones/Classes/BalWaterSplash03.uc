class BalWaterSplash03 expands BalWaterSplash00;

////////////////////////////////////////////////////////////////////////////////
//Category WTF ballistic water fx
////////////////////////////////////////////////////////////////////////////////

#exec MESH IMPORT MESH=BalWaterSplash03 ANIVFILE=MODELS\WaterVertSplash_a.3d DATAFILE=MODELS\WaterVertSplash_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=BalWaterSplash03 STRENGTH=0.35
#exec MESH ORIGIN MESH=BalWaterSplash03 X=0 Y=0 Z=52

#exec MESH SEQUENCE MESH=BalWaterSplash03 SEQ=All STARTFRAME=0 NUMFRAMES=30
#exec MESH SEQUENCE MESH=BalWaterSplash03 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=BalWaterSplash03 SEQ=End STARTFRAME=29 NUMFRAMES=1
#exec MESH SEQUENCE MESH=BalWaterSplash03 SEQ=Burst STARTFRAME=0 NUMFRAMES=30 RATE=30.0

#exec MESHMAP NEW MESHMAP=BalWaterSplash03 MESH=BalWaterSplash03
#exec MESHMAP SCALE MESHMAP=BalWaterSplash03 X=2.0 Y=2.0 Z=8.0

defaultproperties
{
      FinalDrawScale=3.000000
      InitSpeedMult=1.550000
      Mesh=LodMesh'xZones.BalWaterSplash03'
      DrawScale=0.620000
}
