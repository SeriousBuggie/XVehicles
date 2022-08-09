class TankMLSmkRing expands xTreadVehEffects;

#exec MESH IMPORT MESH=SmkRing ANIVFILE=MODELS\SmkRing_a.3d DATAFILE=MODELS\SmkRing_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=SmkRing STRENGTH=0.25
#exec MESH ORIGIN MESH=SmkRing X=0 Y=0 Z=0 PITCH=64

#exec MESH SEQUENCE MESH=SmkRing SEQ=All STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE MESH=SmkRing SEQ=Expand STARTFRAME=0 NUMFRAMES=2 RATE=1.0

#exec MESHMAP NEW MESHMAP=SmkRing MESH=SmkRing
#exec MESHMAP SCALE MESHMAP=SmkRing X=6.4 Y=6.4 Z=12.8

var() name AnimType;

simulated function Tick( float DeltaTime)
{
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
}

simulated function PostBeginPlay()
{
	PlayAnim(AnimType, 1/LifeSpan);
}

defaultproperties
{
	AnimType="Expand"
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=1.250000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=Texture'USmoke.SmkB01'
	Mesh=LodMesh'XTreadVeh.SmkRing'
	DrawScale=8.000000
	ScaleGlow=2.000000
	bParticles=True
	bRandomFrame=True
	MultiSkins(0)=Texture'USmoke.SmkB01'
	MultiSkins(1)=Texture'USmoke.SmkB02'
	MultiSkins(2)=Texture'USmoke.SmkB03'
	MultiSkins(3)=Texture'USmoke.SmkB04'
	MultiSkins(4)=Texture'USmoke.SmkB05'
	MultiSkins(5)=Texture'USmoke.SmkB06'
	MultiSkins(6)=Texture'USmoke.SmkB07'
	MultiSkins(7)=Texture'USmoke.SmkB08'
}
