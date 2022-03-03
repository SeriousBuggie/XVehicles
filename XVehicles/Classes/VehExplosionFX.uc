class VehExplosionFX expands UT_FlameExplosion;

#exec obj load file=..\Textures\UExplosionsSet01.utx package=UExplosionsSet01

simulated function PostBeginPlay()
{
	SetTimer(0.2,False);
	Super(AnimSpriteEffect).PostBeginPlay();
}

function Timer()
{
local GenVehExploA xs;
local vector vexpl;

	vexpl.X = FRand()*300 - 150;
	vexpl.Y = FRand()*300 - 150;
	vexpl.Z = FRand()*300 - 150;
	xs = Spawn(Class'GenVehExploA',,, Location + vexpl);
	xs.DrawScale = DrawScale * 1.15;
}

defaultproperties
{
      EffectSound1=None
      Texture=Texture'UExplosionsSet01.ExplE01'
      DrawScale=1.000000
      ScaleGlow=2.500000
      LightType=LT_Steady
      LightBrightness=50
      LightHue=0
      LightSaturation=192
      LightRadius=5
}
