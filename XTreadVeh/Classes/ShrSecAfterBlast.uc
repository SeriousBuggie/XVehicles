class ShrSecAfterBlast expands ShrAfterBlast;

#exec MESH IMPORT MESH=ShrSecAfterBlast ANIVFILE=MODELS\ShrAfterBlast_a.3d DATAFILE=MODELS\ShrAfterBlast_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=ShrSecAfterBlast STRENGTH=0.5
#exec MESH ORIGIN MESH=ShrSecAfterBlast X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=ShrSecAfterBlast SEQ=All STARTFRAME=0 NUMFRAMES=3
#exec MESH SEQUENCE MESH=ShrSecAfterBlast SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ShrSecAfterBlast SEQ=Compress STARTFRAME=0 NUMFRAMES=2 RATE=1.0
#exec MESH SEQUENCE MESH=ShrSecAfterBlast SEQ=Expand STARTFRAME=1 NUMFRAMES=2 RATE=1.0

#exec MESHMAP NEW MESHMAP=ShrSecAfterBlast MESH=ShrSecAfterBlast
#exec MESHMAP SCALE MESHMAP=ShrSecAfterBlast X=0.2 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=ShrSecAfterBlast NUM=1 TEXTURE=ShrAfterBlast

defaultproperties
{
      AdvanceX=112.500000
      Mesh=LodMesh'XTreadVeh.ShrSecAfterBlast'
      DrawScale=12.500000
}
