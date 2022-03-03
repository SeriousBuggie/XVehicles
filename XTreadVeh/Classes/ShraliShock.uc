class ShraliShock expands xTreadVehEffects;

#exec MESH IMPORT MESH=ShraliShock ANIVFILE=MODELS\ShraliShock_a.3d DATAFILE=MODELS\ShraliShock_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ShraliShock X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=ShraliShock SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ShraliShock SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=ShraliShock MESH=ShraliShock
#exec MESHMAP SCALE MESHMAP=ShraliShock X=0.1 Y=0.1 Z=0.2

#exec TEXTURE IMPORT NAME=ShraliShockRing FILE=CORONAS\ShraliShockRing.bmp GROUP=Coronas FLAGS=2
#exec MESHMAP SETTEXTURE MESHMAP=ShraliShock NUM=1 TEXTURE=ShraliShockRing


simulated function Tick( float DeltaTime)
{
	DrawScale = (Default.LifeSpan - LifeSpan) * Default.DrawScale / Default.LifeSpan;
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
}

defaultproperties
{
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=0.650000
      DrawType=DT_Mesh
      Style=STY_Translucent
      Mesh=LodMesh'XTreadVeh.ShraliShock'
      DrawScale=56.250000
      bUnlit=True
}
