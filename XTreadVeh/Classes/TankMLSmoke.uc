class TankMLSmoke expands xTreadVehEffects;

#exec obj load file=..\Textures\USmoke.utx package=USmoke

var() texture RndSprite[8];
var() float RisingRate;

simulated function PostBeginPlay()
{
	Texture = RndSprite[Rand(8)];
	Velocity = Vect(0,0,1)*RisingRate;
}

simulated function Tick( float DeltaTime)
{
		ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
}

defaultproperties
{
	RndSprite(0)=Texture'USmoke.SmkB01'
	RndSprite(1)=Texture'USmoke.SmkB02'
	RndSprite(2)=Texture'USmoke.SmkB03'
	RndSprite(3)=Texture'USmoke.SmkB04'
	RndSprite(4)=Texture'USmoke.SmkB05'
	RndSprite(5)=Texture'USmoke.SmkB06'
	RndSprite(6)=Texture'USmoke.SmkB07'
	RndSprite(7)=Texture'USmoke.SmkB08'
	RisingRate=65.000000
	Physics=PHYS_Projectile
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=4.000000
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'USmoke.SmkB01'
	ScaleGlow=0.800000
	SpriteProjForward=16.000000
	bUnlit=True
}
