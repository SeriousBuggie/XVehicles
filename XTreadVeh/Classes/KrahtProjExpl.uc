class KrahtProjExpl expands UT_FlameExplosion;

#exec AUDIO IMPORT NAME="KrahtExpl" FILE=SOUNDS\KrahtExpl.wav GROUP="Explosions"
#exec obj load file=..\Textures\UExplEffects01.utx package=UExplEffects01

function MakeSound()
{
	PlaySound(EffectSound1,,60.0,,8000);
}

simulated function Tick( float DeltaTime)
{
	DrawScale = LifeSpan * Default.DrawScale / Default.LifeSpan + 5;
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
}

simulated function PostBeginPlay()
{
	Super(AnimSpriteEffect).PostBeginPlay();
	MakeSound();
}

defaultproperties
{
      EffectSound1=Sound'XTreadVeh.Explosions.KrahtExpl'
      LifeSpan=1.500000
      Texture=Texture'UExplEffects01.GFXA01'
      DrawScale=10.000000
      ScaleGlow=1.800000
      SpriteProjForward=0.000000
      LightType=LT_Steady
      LightBrightness=100
      LightHue=40
      LightSaturation=240
      LightRadius=10
}
