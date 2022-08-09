class JSDXLPlasma expands xWheelVehProjectile;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	Velocity = Speed * vector(Rotation);
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if (Other != Owner && (!Other.IsA('Projectile') || Other.CollisionRadius > 0))
	{
		Explode(HitLocation, vect(0,0,1));
		Other.TakeDamage(Damage, Instigator, HitLocation, Normal(Other.Location - Location)*MomentumTransfer, MyDamageType);
	}
}

function BlowUp(vector HitLocation)
{
    //HurtRadius(Damage, 50, MyDamageType, MomentumTransfer, HitLocation);
	Spawn(Class'JSDXPlasmaExpl');
    MakeNoise(0.5);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	BlowUp(HitLocation);
	Destroy();
}

defaultproperties
{
	DamageRadius=50.000000
	speed=2000.000000
	MaxSpeed=4000.000000
	Damage=35.000000
	MomentumTransfer=6000
	MyDamageType="Energy"
	RemoteRole=ROLE_SimulatedProxy
	AmbientSound=Sound'UnrealShare.Dispersion.DispFly'
	Style=STY_Translucent
	Mesh=LodMesh'UnrealShare.DispM1'
	DrawScale=0.937500
	ScaleGlow=3.000000
	bUnlit=True
	MultiSkins(0)=FireTexture'UnrealShare.Effect1.FireEffect1a'
	MultiSkins(1)=FireTexture'UnrealShare.Effect1.fireeffect1'
	SoundRadius=80
	SoundVolume=60
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=150
	LightHue=85
	LightSaturation=64
	LightRadius=4
}
