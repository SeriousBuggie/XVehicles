//=============================================================================
// BadgerGrenade.
//=============================================================================
class BadgerGrenade expands UT_Grenade;

/*
#forceexec MESH  MODELIMPORT MESH=BadgerGrenade MODELFILE=Z:\XV\Badger\VMGrenade_.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=BadgerGrenade X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=BadgerGrenade STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=BadgerGrenade X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=BadgerGrenade NUM=0 TEXTURE=GrenadeTex
// */

simulated function PostBeginPlay()
{
	local vector X,Y,Z;

	Super(Projectile).PostBeginPlay();
	SetTimer(2.5+FRand()*0.5,false);                  //Grenade begins unarmed

	if ( Role == ROLE_Authority )
	{
		GetAxes(Instigator.ViewRotation,X,Y,Z);	
		Velocity = X * (Instigator.Velocity Dot X)*0.4 + Vector(Rotation) * (Speed +
			FRand() * 100);
		Velocity.z += 210;
		RandSpin(50000);
		if (Region.Zone.bWaterZone)
		{
			bHitWater = True;
			Disable('Tick');
			Velocity=0.6*Velocity;			
		}
	}	
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	if (!bCanHitOwner && Vehicle(Other) != None && Vehicle(Other).Driver == Instigator)
		return;
	Super.ProcessTouch(Other, HitLocation);
}

simulated static function bool IsGoodTarget(Pawn Instigator, Actor Other)
{
	local float Dist;
	if (Other == None)
		return false;
	Dist = VSize(Other.Location - Instigator.Location);
	if (Dist > 2.5*default.MaxSpeed)
		return false;
	if (Pawn(Other) != None && DriverWeapon(Pawn(Other).Weapon) != None)
		Other = DriverWeapon(Pawn(Other).Weapon).VehicleOwner;
	if (Vehicle(Other) == None && Vehicle(Other.Base) != None)
		Other = Vehicle(Other.Base);
	if (Vehicle(Other) != None && Vehicle(Other).bCanFly && Vehicle(Other).Driver != None)
		return false;
	/*
	if (Dist < 270 + Other.CollisionRadius)
		return false; // prevent hurt self
	*/
	return true;
}

defaultproperties
{
	speed=1450.000000
	MaxSpeed=1450.000000
	Damage=250.000000
	MomentumTransfer=100000
	Mesh=SkeletalMesh'BadgerGrenade'
	DrawScale=0.150000
	AmbientGlow=150
}
