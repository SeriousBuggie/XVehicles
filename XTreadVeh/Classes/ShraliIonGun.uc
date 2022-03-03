class ShraliIonGun expands xTreadVehAttach;

//Mesh import
#exec MESH IMPORT MESH=ShraliIonGun ANIVFILE=MODELS\ShraliIonGun_a.3d DATAFILE=MODELS\ShraliIonGun_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=ShraliIonGun STRENGTH=0.85
#exec MESH ORIGIN MESH=ShraliIonGun X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=ShraliIonGun SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ShraliIonGun SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=ShraliIonGun MESH=ShraliIonGun
#exec MESHMAP SCALE MESHMAP=ShraliIonGun X=0.25 Y=0.25 Z=0.5

//Skinning
#exec TEXTURE IMPORT NAME=ShraliIonGunSk FILE=SKINS\ShraliIonGunSk.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=ShraliIonGun NUM=1 TEXTURE=ShraliIonGunSk

defaultproperties
{
      Mesh=LodMesh'XTreadVeh.ShraliIonGun'
}
