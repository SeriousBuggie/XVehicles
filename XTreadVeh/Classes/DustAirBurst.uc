class DustAirBurst expands xTreadVehEffects;

#exec TEXTURE IMPORT NAME=DustAirBurst FILE=EFFECTS\DustAirBurst.bmp GROUP=Effects FLAGS=2

simulated function Tick( float DeltaTime)
{
	DrawScale = (Default.LifeSpan - LifeSpan) * Default.DrawScale;
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
	SpriteProjForward = (Default.LifeSpan - LifeSpan) * Default.SpriteProjForward / Default.LifeSpan;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.450000
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'XTreadVeh.Effects.DustAirBurst'
	DrawScale=22.500000
	SpriteProjForward=640.000000
	bUnlit=True
}
