class ShraliFastShock expands xTreadVehEffects;

#exec MESH IMPORT MESH=ShraliFastShock ANIVFILE=MODELS\NuclearShockI_a.3d DATAFILE=MODELS\NuclearShockI_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=ShraliFastShock STRENGTH=0.75
#exec MESH ORIGIN MESH=ShraliFastShock X=0 Y=0 Z=0 PITCH=-64

#exec MESH SEQUENCE MESH=ShraliFastShock SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ShraliFastShock SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=ShraliFastShock MESH=ShraliFastShock
#exec MESHMAP SCALE MESHMAP=ShraliFastShock X=0.1 Y=0.1 Z=0.2

#exec TEXTURE IMPORT NAME=ShraliShock FILE=EFFECTS\ShraliShock.bmp GROUP=Effects FLAGS=2 LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=ShraliFastShock NUM=1 TEXTURE=ShraliShock

//const ScaleCoef = 80.000000;

simulated function Tick( float DeltaTime)
{
	DrawScale = (Default.LifeSpan - LifeSpan) * Default.DrawScale / Default.LifeSpan;
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.500000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=LodMesh'XTreadVeh.ShraliFastShock'
	DrawScale=8.600000
	ScaleGlow=1.800000
	bUnlit=True
}
