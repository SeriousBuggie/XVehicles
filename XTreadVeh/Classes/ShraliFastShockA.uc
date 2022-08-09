class ShraliFastShockA expands ShraliFastShock;

#exec MESH IMPORT MESH=ShraliFastShockA ANIVFILE=MODELS\NuclearShockI_a.3d DATAFILE=MODELS\NuclearShockI_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=ShraliFastShockA STRENGTH=0.75
#exec MESH ORIGIN MESH=ShraliFastShockA X=0 Y=0 Z=0 PITCH=-64

#exec MESH SEQUENCE MESH=ShraliFastShockA SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ShraliFastShockA SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=ShraliFastShockA MESH=ShraliFastShockA
#exec MESHMAP SCALE MESHMAP=ShraliFastShockA X=0.1 Y=0.1 Z=0.3

#exec MESHMAP SETTEXTURE MESHMAP=ShraliFastShockA NUM=1 TEXTURE=ShraliShock

defaultproperties
{
	LifeSpan=0.350000
	Mesh=LodMesh'XTreadVeh.ShraliFastShockA'
	DrawScale=11.100000
	ScaleGlow=1.850000
}
