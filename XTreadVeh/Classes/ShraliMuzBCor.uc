class ShraliMuzBCor expands xTreadVehEffects;

#exec TEXTURE IMPORT NAME=ShraliMuzBCor FILE=EFFECTS\ShraliMuzBCor.bmp GROUP=Effects FLAGS=2

simulated function Tick( float DeltaTime)
{
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.750000
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'XTreadVeh.Effects.ShraliMuzBCor'
	DrawScale=4.000000
	ScaleGlow=1.500000
	SpriteProjForward=4.500000
	bUnlit=True
	LightType=LT_Steady
	LightBrightness=74
	LightRadius=25
}
