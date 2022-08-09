class TCBulOutFX expands UT_FlameExplosion;

#exec obj load file=..\Textures\UExplosionsSet01.utx package=UExplosionsSet01

var bool bReady;

simulated function PostBeginPlay()
{
	SetTimer(0.01,False);
	Super(AnimSpriteEffect).PostBeginPlay();
}

function Timer()
{
local TCBulOutFX xs;

	if (bReady)
	{
		xs = Spawn(Class'TCBulOutFX',,, Location + vector(Rotation)*DrawScale*20);
		xs.DrawScale = DrawScale - 0.25;
	}
	else
	{
		bReady = True;
		if (DrawScale >= 1.0)
			SetTimer(0.035,False);
	}
}

defaultproperties
{
	EffectSound1=None
	Texture=Texture'UExplosionsSet01.ExplE01'
	DrawScale=1.500000
	ScaleGlow=1.350000
	SpriteProjForward=15.000000
	LightType=LT_Steady
	LightBrightness=45
	LightHue=0
	LightSaturation=48
}
