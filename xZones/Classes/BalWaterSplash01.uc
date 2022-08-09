class BalWaterSplash01 expands BalWaterSplash00;

////////////////////////////////////////////////////////////////////////////////
//Category NORMAL ballistic water fx
////////////////////////////////////////////////////////////////////////////////

#exec MESH IMPORT MESH=BalWaterSplash01 ANIVFILE=MODELS\WaterVertSplash_a.3d DATAFILE=MODELS\WaterVertSplash_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=BalWaterSplash01 STRENGTH=0.35
#exec MESH ORIGIN MESH=BalWaterSplash01 X=0 Y=0 Z=52

#exec MESH SEQUENCE MESH=BalWaterSplash01 SEQ=All STARTFRAME=0 NUMFRAMES=30
#exec MESH SEQUENCE MESH=BalWaterSplash01 SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=BalWaterSplash01 SEQ=End STARTFRAME=29 NUMFRAMES=1
#exec MESH SEQUENCE MESH=BalWaterSplash01 SEQ=Burst STARTFRAME=0 NUMFRAMES=30 RATE=30.0

#exec MESHMAP NEW MESHMAP=BalWaterSplash01 MESH=BalWaterSplash01
#exec MESHMAP SCALE MESHMAP=BalWaterSplash01 X=0.5 Y=0.5 Z=2.0

defaultproperties
{
	FinalDrawScale=0.750000
	InitSpeedMult=1.300000
	Mesh=LodMesh'xZones.BalWaterSplash01'
	DrawScale=0.155000
}
