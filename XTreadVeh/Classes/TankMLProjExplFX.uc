class TankMLProjExplFX expands UT_FlameExplosion;

simulated function PostBeginPlay()
{
	if (Rand(100) < 20)
		Texture = Texture'UExplosionsSet01.ExplB05';
	else if (Rand(100) < 15)
		Texture = Texture'UExplosionsSet01.ExplE05';
		
	Super(AnimSpriteEffect).PostBeginPlay();
}

defaultproperties
{
	EffectSound1=None
	Texture=Texture'UExplosionsSet01.ExplF05'
	DrawScale=1.500000
	ScaleGlow=1.350000
	LightType=LT_None
}
