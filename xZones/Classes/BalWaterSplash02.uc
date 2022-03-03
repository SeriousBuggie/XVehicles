class BalWaterSplash02 expands BalWaterSplash00;

////////////////////////////////////////////////////////////////////////////////
//Category BIG ballistic water fx
////////////////////////////////////////////////////////////////////////////////

#exec MESH IMPORT MESH=BalWaterSplash02 ANIVFILE=MODELS\WaterVertSplash_a.3d DATAFILE=MODELS\WaterVertSplash_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=BalWaterSplash02 STRENGTH=0.35
#exec MESH ORIGIN MESH=BalWaterSplash02 X=0 Y=0 Z=52

#exec MESH SEQUENCE MESH=BalWaterSplash02 SEQ=All STARTFRAME=0 NUMFRAMES=30
#exec MESH SEQUENCE MESH=BalWaterSplash02 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=BalWaterSplash02 SEQ=End STARTFRAME=29 NUMFRAMES=1
#exec MESH SEQUENCE MESH=BalWaterSplash02 SEQ=Burst STARTFRAME=0 NUMFRAMES=30 RATE=30.0

#exec MESHMAP NEW MESHMAP=BalWaterSplash02 MESH=BalWaterSplash02
#exec MESHMAP SCALE MESHMAP=BalWaterSplash02 X=1.0 Y=1.0 Z=4.0

defaultproperties
{
      FinalDrawScale=1.500000
      InitSpeedMult=1.400000
      Mesh=LodMesh'xZones.BalWaterSplash02'
      DrawScale=0.310000
}
