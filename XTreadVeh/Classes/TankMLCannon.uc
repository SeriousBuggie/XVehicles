class TankMLCannon expands xTreadVehAttach;

//Mesh import
#exec MESH IMPORT MESH=TankMLCannon ANIVFILE=MODELS\TankMLCannon_a.3d DATAFILE=MODELS\TankMLCannon_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=TankMLCannon STRENGTH=0.85
#exec MESH ORIGIN MESH=TankMLCannon X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=TankMLCannon SEQ=All STARTFRAME=0 NUMFRAMES=8
#exec MESH SEQUENCE MESH=TankMLCannon SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankMLCannon SEQ=Fire STARTFRAME=0 NUMFRAMES=8 RATE=1.0

//Mesh scale
#exec MESHMAP NEW MESHMAP=TankMLCannon MESH=TankMLCannon
#exec MESHMAP SCALE MESHMAP=TankMLCannon X=0.5 Y=0.5 Z=1.0

//Skinning
#exec TEXTURE IMPORT NAME=TankCannon_I FILE=SKINS\TankCannon_I.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=TankMLCannon NUM=1 TEXTURE=TankCannon_I

defaultproperties
{
	Mesh=LodMesh'XTreadVeh.TankMLCannon'
}
