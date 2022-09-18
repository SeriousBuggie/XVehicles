class GenVehExploB expands UT_FlameExplosion;

#exec obj load file=..\Textures\UExplosionsSet01.utx package=UExplosionsSet01

function PostBeginPlay()
{
	Super(AnimSpriteEffect).PostBeginPlay();
}

defaultproperties
{
	EffectSound1=None
	RemoteRole=ROLE_None
	Texture=Texture'UExplosionsSet01.ExplE01'
	DrawScale=1.000000
	ScaleGlow=2.500000
	SpriteProjForward=64.000000
	LightType=LT_None
	LightBrightness=0
	LightHue=0
	LightSaturation=0
	LightRadius=0
}
