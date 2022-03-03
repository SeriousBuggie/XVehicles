class ShrAfterBlast expands xTreadVehEffects;

#exec MESH IMPORT MESH=ShrAfterBlast ANIVFILE=MODELS\ShrAfterBlast_a.3d DATAFILE=MODELS\ShrAfterBlast_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=ShrAfterBlast STRENGTH=0.5
#exec MESH ORIGIN MESH=ShrAfterBlast X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=ShrAfterBlast SEQ=All STARTFRAME=0 NUMFRAMES=3
#exec MESH SEQUENCE MESH=ShrAfterBlast SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ShrAfterBlast SEQ=Compress STARTFRAME=0 NUMFRAMES=2 RATE=1.0
#exec MESH SEQUENCE MESH=ShrAfterBlast SEQ=Expand STARTFRAME=1 NUMFRAMES=2 RATE=1.0

#exec MESHMAP NEW MESHMAP=ShrAfterBlast MESH=ShrAfterBlast
#exec MESHMAP SCALE MESHMAP=ShrAfterBlast X=0.125 Y=0.125 Z=0.25

#exec TEXTURE IMPORT NAME=ShrAfterBlast FILE=EFFECTS\ShrAfterBlast.bmp GROUP=Effects FLAGS=2
#exec MESHMAP SETTEXTURE MESHMAP=ShrAfterBlast NUM=1 TEXTURE=ShrAfterBlast

var() float AdvanceX;

simulated function PostBeginPlay()
{
	PlayAnim('Expand', 1/Default.LifeSpan, 0.05);
	Velocity = vector(Rotation)*(AdvanceX/Default.LifeSpan);
}

simulated function Tick( float DeltaTime)
{
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
	DrawScale = (Default.LifeSpan - LifeSpan) * Default.DrawScale / Default.LifeSpan;
}

defaultproperties
{
      AdvanceX=320.000000
      Physics=PHYS_Projectile
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=0.750000
      DrawType=DT_Mesh
      Style=STY_Translucent
      Mesh=LodMesh'XTreadVeh.ShrAfterBlast'
      DrawScale=6.250000
      ScaleGlow=1.500000
      bUnlit=True
}
