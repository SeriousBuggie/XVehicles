class ShrRedIonExplSparksA expands xTreadVehEffects;

#exec TEXTURE IMPORT NAME=RedIonEnFX FILE=Effects\RedIonEnFX.bmp GROUP=Effects FLAGS=2

simulated function PostBeginPlay()
{
	PlayAnim('Expl00', 1/Default.LifeSpan, 0.05);
}

simulated function Tick(float DeltaTime)
{
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.300000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=LodMesh'EnLnPartRedA'
	DrawScale=2.000000
	bUnlit=True
	MultiSkins(1)=Texture'XTreadVeh.Effects.RedIonEnFX'
	MultiSkins(2)=Texture'XTreadVeh.Effects.RedIonEnFX'
	MultiSkins(3)=Texture'XTreadVeh.Effects.RedIonEnFX'
	MultiSkins(4)=Texture'XTreadVeh.Effects.RedIonEnFX'
	MultiSkins(5)=Texture'XTreadVeh.Effects.RedIonEnFX'
	MultiSkins(6)=Texture'XTreadVeh.Effects.RedIonEnFX'
}
