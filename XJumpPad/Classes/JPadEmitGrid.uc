class JPadEmitGrid expands Effects;

#exec MESH IMPORT MESH=JPadEmitGrid ANIVFILE=MODELS\JPadEmitGrid_a.3d DATAFILE=MODELS\JPadEmitGrid_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=JPadEmitGrid X=0 Y=0 Z=0 PITCH=0

#exec MESH SEQUENCE MESH=JPadEmitGrid SEQ=All STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=JPadEmitGrid MESH=JPadEmitGrid
#exec MESHMAP SCALE MESHMAP=JPadEmitGrid X=0.3 Y=0.3 Z=0.6

#exec TEXTURE IMPORT NAME=YellowGrid FILE=JParticles\YellowGrid.bmp GROUP=Skins FLAGS=2
#exec MESHMAP SETTEXTURE MESHMAP=JPadEmitGrid NUM=1 TEXTURE=YellowGrid

var float Count;

simulated function Tick( float DeltaTime)
{
	if (Count < 0.1)
	{
		Count += DeltaTime;
		ScaleGlow = Count * Default.ScaleGlow / 0.1;
	}
	else
		ScaleGlow = LifeSpan * Default.ScaleGlow / (Default.LifeSpan - 0.1);
}

defaultproperties
{
	Physics=PHYS_Projectile
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=1.000000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=LodMesh'XJumpPad.JPadEmitGrid'
	ScaleGlow=1.750000
	bUnlit=True
}
