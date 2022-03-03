class TCBulExpl expands UT_FlameExplosion;

#exec AUDIO IMPORT NAME="TExplSnd01" FILE=SOUNDS\TExplSnd01.wav GROUP="Explosions"
#exec AUDIO IMPORT NAME="TExplSnd02" FILE=SOUNDS\TExplSnd02.wav GROUP="Explosions"
#exec AUDIO IMPORT NAME="TExplSnd03" FILE=SOUNDS\TExplSnd03.wav GROUP="Explosions"

#exec obj load file=..\Textures\UExplosionsSet01.utx package=UExplosionsSet01

var() sound RndExplSnd1, RndExplSnd2, RndExplSnd3;

function MakeSound()
{
local int sR;

	sR = Rand(30);
	
	if (sR <= 10)
		PlaySound(RndExplSnd1,,60.0,,7750);
	else if (sR <= 20)
		PlaySound(RndExplSnd2,,60.0,,7750);
	else
		PlaySound(RndExplSnd3,,60.0,,7750);
}

simulated function PostBeginPlay()
{
	Super(AnimSpriteEffect).PostBeginPlay();
	MakeSound();
}

defaultproperties
{
      RndExplSnd1=Sound'XTreadVeh.Explosions.TExplSnd01'
      RndExplSnd2=Sound'XTreadVeh.Explosions.TExplSnd02'
      RndExplSnd3=Sound'XTreadVeh.Explosions.TExplSnd03'
      EffectSound1=None
      Texture=Texture'UExplosionsSet01.ExplB01'
      DrawScale=7.500000
      ScaleGlow=1.800000
      LightType=LT_Steady
      LightBrightness=100
      LightHue=0
      LightSaturation=128
      LightRadius=10
}
