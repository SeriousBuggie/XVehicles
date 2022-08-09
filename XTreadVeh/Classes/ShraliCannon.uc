class ShraliCannon expands xTreadVehAttach;

//Mesh import
#exec MESH IMPORT MESH=ShraliCannon ANIVFILE=MODELS\ShraliCannon_a.3d DATAFILE=MODELS\ShraliCannon_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=ShraliCannon STRENGTH=0.85
#exec MESH ORIGIN MESH=ShraliCannon X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=ShraliCannon SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ShraliCannon SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=ShraliCannon MESH=ShraliCannon
#exec MESHMAP SCALE MESHMAP=ShraliCannon X=0.625 Y=0.625 Z=1.25

//Skinning
#exec TEXTURE IMPORT NAME=ShraliCannonSk FILE=SKINS\ShraliCannonSk.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=ShraliCannon NUM=1 TEXTURE=ShraliCannonSk

defaultproperties
{
	Mesh=LodMesh'XTreadVeh.ShraliCannon'
	CollisionRadius=64.000000
	CollisionHeight=16.000000
}
