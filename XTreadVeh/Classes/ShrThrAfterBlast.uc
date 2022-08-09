class ShrThrAfterBlast expands ShrAfterBlast;

#exec MESH IMPORT MESH=ShrThrAfterBlast ANIVFILE=MODELS\ShrAfterBlast_a.3d DATAFILE=MODELS\ShrAfterBlast_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=ShrThrAfterBlast STRENGTH=0.5
#exec MESH ORIGIN MESH=ShrThrAfterBlast X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=ShrThrAfterBlast SEQ=All STARTFRAME=0 NUMFRAMES=3
#exec MESH SEQUENCE MESH=ShrThrAfterBlast SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ShrThrAfterBlast SEQ=Compress STARTFRAME=0 NUMFRAMES=2 RATE=1.0
#exec MESH SEQUENCE MESH=ShrThrAfterBlast SEQ=Expand STARTFRAME=1 NUMFRAMES=2 RATE=1.0

#exec MESHMAP NEW MESHMAP=ShrThrAfterBlast MESH=ShrThrAfterBlast
#exec MESHMAP SCALE MESHMAP=ShrThrAfterBlast X=0.025 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=ShrThrAfterBlast NUM=1 TEXTURE=ShrAfterBlast

defaultproperties
{
	AdvanceX=20.000000
	Mesh=LodMesh'XTreadVeh.ShrThrAfterBlast'
	DrawScale=18.750000
}
