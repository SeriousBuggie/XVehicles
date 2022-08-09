class KrahtCannon expands xTreadVehAttach;

//Mesh import
#exec MESH IMPORT MESH=KrahtCannon ANIVFILE=MODELS\KrahtCannon_a.3d DATAFILE=MODELS\KrahtCannon_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=KrahtCannon STRENGTH=0.85
#exec MESH ORIGIN MESH=KrahtCannon X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=KrahtCannon SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=KrahtCannon SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=KrahtCannon MESH=KrahtCannon
#exec MESHMAP SCALE MESHMAP=KrahtCannon X=0.3 Y=0.3 Z=0.6

//Skinning
#exec TEXTURE IMPORT NAME=KrahtCannonSk FILE=SKINS\KrahtCannonSk.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=KrahtCannon NUM=1 TEXTURE=KrahtCannonSk

defaultproperties
{
	Mesh=LodMesh'XTreadVeh.KrahtCannon'
}
