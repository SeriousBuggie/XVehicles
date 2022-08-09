class ShraliFastShockB expands ShraliFastShock;

#exec MESH IMPORT MESH=ShraliFastShockB ANIVFILE=MODELS\NuclearShockI_a.3d DATAFILE=MODELS\NuclearShockI_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=ShraliFastShockB STRENGTH=0.75
#exec MESH ORIGIN MESH=ShraliFastShockB X=0 Y=0 Z=0 PITCH=-64

#exec MESH SEQUENCE MESH=ShraliFastShockB SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ShraliFastShockB SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=ShraliFastShockB MESH=ShraliFastShockB
#exec MESHMAP SCALE MESHMAP=ShraliFastShockB X=0.1 Y=0.1 Z=0.1

#exec MESHMAP SETTEXTURE MESHMAP=ShraliFastShockB NUM=1 TEXTURE=ShraliShock

simulated function Tick( float DeltaTime)
{
	LightBrightness = LifeSpan * Default.LightBrightness / Default.LifeSpan;
	Super.Tick(DeltaTime);
}

defaultproperties
{
	LifeSpan=0.750000
	Mesh=LodMesh'XTreadVeh.ShraliFastShockB'
	DrawScale=5.625000
	ScaleGlow=1.500000
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=80
	LightRadius=48
}
