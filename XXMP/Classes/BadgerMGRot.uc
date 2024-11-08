//=============================================================================
// BadgerMGRot.
//=============================================================================
class BadgerMGRot expands TankMGRot;

function SpawnFireEffects( byte Mode )
{
	if (Mode == 1)
		return;
	Super.SpawnFireEffects(Mode);
}

function FireTurret( byte Mode, optional bool bForceFire )
{
	if (Bot(WeaponController) != None)
	{
		if (Mode == 1 && !class'BadgerGrenade'.static.IsGoodTarget(WeaponController, WeaponController.Target))
			Mode = 0; // use minigun instead
	}

	Super.FireTurret(Mode, bForceFire);	
}

defaultproperties
{
	ShellOffset=(Y=-8.000000,Z=11.000000)
	PitchRange=(Max=14000)
	bAltFireZooms=False
	TurretPitchActor=Class'BadgerMGun'
	PitchActorOffset=(X=4.000000,Z=9.000000)
	WeapSettings(0)=(FireStartOffset=(X=35.500000,Z=3.000000),FireSound=Sound'XXMP.Badger.BadgerMinigun',hitdamage=15)
	WeapSettings(1)=(ProjectileClass=Class'BadgerGrenade',FireStartOffset=(X=35.500000,Z=3.000000),RefireRate=2.400000,FireSound=Sound'XXMP.Badger.NewGrenadeShoot')
	Mesh=SkeletalMesh'BadgerMinigun'
	CollisionHeight=15.000000
}
