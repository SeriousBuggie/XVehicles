class JSDXIceWheelSup expands xWheelVehEffects;

//Mesh import
#exec MESH IMPORT MESH=JSDXIceWheelSup ANIVFILE=MODELS\JSDXIceWheelSup_a.3d DATAFILE=MODELS\JSDXIceWheelSup_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=JSDXIceWheelSup STRENGTH=0.85
#exec MESH ORIGIN MESH=JSDXIceWheelSup X=0 Y=0 Z=0

#exec MESH IMPORT MESH=JSDXIceWheelSupMir ANIVFILE=MODELS\JSDXIceWheelSup_a.3d DATAFILE=MODELS\JSDXIceWheelSup_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=JSDXIceWheelSupMir STRENGTH=0.85
#exec MESH ORIGIN MESH=JSDXIceWheelSupMir X=0 Y=0 Z=0 YAW=128

//Mesh anim
#exec MESH SEQUENCE MESH=JSDXIceWheelSup SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=JSDXIceWheelSup SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESH SEQUENCE MESH=JSDXIceWheelSupMir SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=JSDXIceWheelSupMir SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=JSDXIceWheelSup MESH=JSDXIceWheelSup
#exec MESHMAP SCALE MESHMAP=JSDXIceWheelSup X=0.0625 Y=0.0625 Z=0.125

#exec MESHMAP NEW MESHMAP=JSDXIceWheelSupMir MESH=JSDXIceWheelSupMir
#exec MESHMAP SCALE MESHMAP=JSDXIceWheelSupMir X=0.0625 Y=0.0625 Z=0.125

//Skinning
#exec TEXTURE IMPORT NAME=DarkMetalShine FILE=SKINS\DarkMetalShine.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=JSDXIceWheelSup NUM=1 TEXTURE=DarkMetalShine
#exec MESHMAP SETTEXTURE MESHMAP=JSDXIceWheelSupMir NUM=1 TEXTURE=DarkMetalShine
#exec MESHMAP SETTEXTURE MESHMAP=JSDXIceWheelSup NUM=2 TEXTURE=DarkMetalShine
#exec MESHMAP SETTEXTURE MESHMAP=JSDXIceWheelSupMir NUM=2 TEXTURE=DarkMetalShine

function PostBeginPlay()
{
	SetTimer(0.2,True);
}

function Timer()
{

	If (VehicleWheel(Owner) == None)
		Destroy();
}

defaultproperties
{
      bNetTemporary=False
      bTrailerSameRotation=True
      Physics=PHYS_Trailer
      RemoteRole=ROLE_SimulatedProxy
      DrawType=DT_Mesh
      Texture=Texture'XWheelVeh.Skins.DarkMetalShine'
      Mesh=LodMesh'XWheelVeh.JSDXIceWheelSup'
      bMeshEnviroMap=True
}
