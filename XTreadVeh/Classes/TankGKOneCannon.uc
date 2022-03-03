class TankGKOneCannon expands xTreadVehAttach;

//Mesh import
#exec MESH IMPORT MESH=TankGKOneCannon ANIVFILE=MODELS\TankGKOneCannon_a.3d DATAFILE=MODELS\TankGKOneCannon_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=TankGKOneCannon STRENGTH=0.85
#exec MESH ORIGIN MESH=TankGKOneCannon X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=TankGKOneCannon SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankGKOneCannon SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=TankGKOneCannon MESH=TankGKOneCannon
#exec MESHMAP SCALE MESHMAP=TankGKOneCannon X=0.5 Y=0.5 Z=1.0

//Skinning
#exec TEXTURE IMPORT NAME=TankCannonSk_II FILE=SKINS\TankCannonSk_II.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=TankGKOneCannon NUM=1 TEXTURE=TankCannonSk_II

defaultproperties
{
      Mesh=LodMesh'XTreadVeh.TankGKOneCannon'
}
