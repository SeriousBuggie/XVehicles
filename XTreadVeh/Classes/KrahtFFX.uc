class KrahtFFX expands xTreadVehEffects;

#exec TEXTURE IMPORT NAME=KrahtFFX FILE=Effects\KrahtFFX.bmp GROUP=Effects FLAGS=2

var vector PrePivotRel;
var() bool bFadeIn;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		PrePivotRel;
}

simulated function Tick( float DeltaTime)
{
	if (bFadeIn)
	{
		DrawScale = (Default.LifeSpan - LifeSpan) * Default.DrawScale / Default.LifeSpan;
		ScaleGlow = (Default.LifeSpan - LifeSpan) * Default.ScaleGlow / Default.LifeSpan;
	}
	else
	{
		DrawScale = LifeSpan * Default.DrawScale / Default.LifeSpan;
		ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
	}

	if (Owner != None)
		PrePivot = PrePivotRel >> Owner.Rotation;
}

defaultproperties
{
      PrePivotRel=(X=0.000000,Y=0.000000,Z=0.000000)
      bFadeIn=True
      bNetTemporary=False
      bTrailerSameRotation=True
      bTrailerPrePivot=True
      Physics=PHYS_Trailer
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=1.000000
      DrawType=DT_Sprite
      Style=STY_Translucent
      Texture=Texture'XTreadVeh.Effects.KrahtFFX'
      DrawScale=1.350000
      ScaleGlow=1.500000
      SpriteProjForward=16.000000
      bUnlit=True
      LightType=LT_Steady
      LightBrightness=80
      LightHue=40
      LightSaturation=240
      LightRadius=10
}
