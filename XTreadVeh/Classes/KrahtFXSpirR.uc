class KrahtFXSpirR expands xTreadVehEffects;

#exec MESH IMPORT MESH=KrahtFXSpirR ANIVFILE=MODELS\BulbAnim_a.3d DATAFILE=MODELS\BulbAnim_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=KrahtFXSpirR STRENGTH=0.75
#exec MESH ORIGIN MESH=KrahtFXSpirR X=0 Y=0 Z=0

#exec MESH IMPORT MESH=KrahtFXSpirL ANIVFILE=MODELS\BulbAnim_a.3d DATAFILE=MODELS\BulbAnim_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=KrahtFXSpirL STRENGTH=0.75
#exec MESH ORIGIN MESH=KrahtFXSpirL X=0 Y=0 Z=0 YAW=128

#exec MESH SEQUENCE MESH=KrahtFXSpirR SEQ=All STARTFRAME=0 NUMFRAMES=25
#exec MESH SEQUENCE MESH=KrahtFXSpirR SEQ=Rotate STARTFRAME=0 NUMFRAMES=24 RATE=24.0

#exec MESH SEQUENCE MESH=KrahtFXSpirL SEQ=All STARTFRAME=0 NUMFRAMES=25
#exec MESH SEQUENCE MESH=KrahtFXSpirL SEQ=Rotate STARTFRAME=0 NUMFRAMES=24 RATE=24.0

#exec MESHMAP NEW MESHMAP=KrahtFXSpirR MESH=KrahtFXSpirR
#exec MESHMAP SCALE MESHMAP=KrahtFXSpirR X=0.5 Y=0.5 Z=1.0

#exec MESHMAP NEW MESHMAP=KrahtFXSpirL MESH=KrahtFXSpirL
#exec MESHMAP SCALE MESHMAP=KrahtFXSpirL X=0.5 Y=0.5 Z=1.0

#exec TEXTURE IMPORT NAME=KrahtFXSpir FILE=EFFECTS\KrahtFXSpir.bmp GROUP=Effects LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=KrahtFXSpirR NUM=1 TEXTURE=KrahtFXSpir
#exec MESHMAP SETTEXTURE MESHMAP=KrahtFXSpirL NUM=1 TEXTURE=KrahtFXSpir

var vector PrePivotRel;
var() float RotRate;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		PrePivotRel;
}

simulated function PostBeginPlay()
{
	LoopAnim('Rotate',RotRate);
}

simulated function Tick( float DeltaTime)
{
	DrawScale = LifeSpan * Default.DrawScale / Default.LifeSpan;
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;

	if (PrePivotRel != vect(0,0,0) && Owner != None)
		PrePivot = PrePivotRel >> Owner.Rotation;
}

defaultproperties
{
	RotRate=3.000000
	bNetTemporary=False
	bTrailerSameRotation=True
	bTrailerPrePivot=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.750000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=LodMesh'KrahtFXSpirR'
	DrawScale=0.450000
	ScaleGlow=1.500000
	bUnlit=True
}
