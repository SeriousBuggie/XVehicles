class xVehProjDummy expands Projectile;

simulated function PostBeginPlay()
{
	Velocity = vector(Rotation)*Speed;
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if (Other != Owner && (!Other.IsA('Projectile') || Other.CollisionRadius > 0))
		Destroy();
}

defaultproperties
{
	speed=50000.000000
	MaxSpeed=50000.000000
	bHidden=True
	LifeSpan=60.000000
	Mass=1.000000
}
