class ShraliProjSpirHead expands xTreadVehEffects;

#exec MESH IMPORT MESH=ShraliProjSpirHead ANIVFILE=MODELS\BulbFX_a.3d DATAFILE=MODELS\BulbFX_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=ShraliProjSpirHead STRENGTH=0.75
#exec MESH ORIGIN MESH=ShraliProjSpirHead X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=ShraliProjSpirHead SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ShraliProjSpirHead SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=ShraliProjSpirHead MESH=ShraliProjSpirHead
#exec MESHMAP SCALE MESHMAP=ShraliProjSpirHead X=0.5 Y=0.5 Z=1.0

#exec TEXTURE IMPORT NAME=SpiralBurst FILE=EFFECTS\SpiralBurst.bmp GROUP=Effects LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=ShraliProjSpirHead NUM=1 TEXTURE=SpiralBurst

var vector PrePivotRel;
var rotator OwnerRot;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		PrePivotRel;
}

simulated function Tick(float Delta)
{
	if (PrePivotRel != vect(0,0,0) && Owner != None && Owner.Rotation != OwnerRot)
	{
		PrePivot = (PrePivotRel >> Owner.Rotation);
		OwnerRot = Owner.Rotation;
	}
}

defaultproperties
{
	bNetTemporary=False
	bTrailerSameRotation=True
	bTrailerPrePivot=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=LodMesh'XTreadVeh.ShraliProjSpirHead'
	DrawScale=1.500000
	ScaleGlow=1.600000
	bUnlit=True
	bFixedRotationDir=True
}
