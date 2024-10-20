//=============================================================================
// HellbenderChargeFX.
//=============================================================================
class HellbenderChargeFX expands LPlasmaFireFX;

const LifeSpanBase = 100.0;

simulated function Tick(float DeltaTime)
{
	local float Scale;
	if (Owner == None)
	{
		Destroy();
		return;
	}
	if (LifeSpan < LifeSpanBase)
		LifeSpan = LifeSpanBase;
	Scale = (Default.LifeSpan - LifeSpan) / (Default.LifeSpan - LifeSpanBase);
	DrawScale = Default.DrawScale * Scale;
	ScaleGlow = Default.ScaleGlow * Scale;
	if (Level.NetMode != NM_DedicatedServer && Owner != None)
		PrePivot = PrePivotRel >> Owner.Rotation;
}

defaultproperties
{
	LifeSpan=102.500000
	Texture=FireTexture'UnrealShare.Effect2.FireEffect2'
	DrawScale=0.200000
	SpriteProjForward=0.000000
}
