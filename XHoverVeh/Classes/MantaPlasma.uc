//=============================================================================
// MantaPlasma.
//=============================================================================
class MantaPlasma expands Projectile;

var()   float           AccelerationMagnitude, DamageRadius;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Level.bDropDetail )
		LightType = LT_None;
	if (Vehicle(Owner) != None)
	{
		switch (Vehicle(Owner).CurrentTeam)
		{
			case 1: Texture = Texture'Tranglowb'; break;
			case 2: Texture = Texture'Tranglowg'; break;
			case 3: Texture = Texture'Tranglowy'; break;
			default: Texture = Texture'Tranglow'; break;
		}
	}
}

auto state Flying
{
	simulated function ProcessTouch (Actor Other, vector HitLocation)
	{
		If ( (Other!=Instigator) && Other != Owner && (!Other.IsA('Projectile') || (Other.CollisionRadius > 0)) )
			Explode(HitLocation, Normal(HitLocation - Other.Location));
	}

	simulated function BeginState()
	{
		Velocity = vector(Rotation) * speed;
		Acceleration = vector(Rotation) * AccelerationMagnitude;
	}
}


simulated function Explode(vector HitLocation,vector HitNormal)
{
	PlaySound(ImpactSound, SLOT_Misc, 0.5,,, 0.5+FRand());
	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, Location );
	Spawn(class'UT_SpriteSmokePuff',,, HitLocation+HitNormal*8,rotator(HitNormal));

	Destroy();
}

defaultproperties
{
	AccelerationMagnitude=16000.000000
	DamageRadius=170.000000
	speed=500.000000
	MaxSpeed=7000.000000
	Damage=30.000000
	MomentumTransfer=4000
	MyDamageType="MantaPlasma"
	ImpactSound=Sound'XHoverVeh.Manta.BioRifleGoo2'
	ExplosionDecal=Class'Botpack.BoltScorch'
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=1.600000
	DrawType=DT_Sprite
	Style=STY_Translucent
	DrawScale=0.800000
	AmbientGlow=100
	bUnlit=True
	CollisionRadius=12.000000
	CollisionHeight=12.000000
}
