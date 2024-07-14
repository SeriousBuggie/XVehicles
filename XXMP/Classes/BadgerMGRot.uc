//=============================================================================
// BadgerMGRot.
//=============================================================================
class BadgerMGRot expands TankMGRot;

simulated function FireEffect()
{
	Super.FireEffect();
	if (Level.NetMode != NM_DedicatedServer)
		SpawnShell();
}

simulated function SpawnShell()
{
	local UT_Shellcase s;
	local vector X, Y, Z;

	if (PitchPart != None)
	{
		s = Spawn(class'MiniShellCase', WeaponController, '', PitchPart.Location + (vect(0, -8, 11) >> PitchPart.Rotation));
		if (s != None)
		{
			s.DrawScale = 0.5;
			GetAxes(PitchPart.Rotation, X, Y, Z);
			s.Eject(((FRand()*0.3+0.4)*X - (FRand()*0.2+2.2)*Y + (FRand()*0.5+1.0) * Z)*80);              
		}
	}
}

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
	PitchRange=(Max=14000,Min=-3000)
	bAltFireZooms=False
	TurretPitchActor=Class'BadgerMGun'
	PitchActorOffset=(X=4.000000,Y=0.000000,Z=9.000000)
	WeapSettings(0)=(FireStartOffset=(X=35.500000,Z=3.000000),FireSound=Sound'XXMP.Badger.BadgerMinigun',hitdamage=15)
	WeapSettings(1)=(ProjectileClass=Class'BadgerGrenade',FireStartOffset=(X=35.500000,Z=3.000000),RefireRate=2.400000,FireSound=Sound'XXMP.Badger.NewGrenadeShoot')
	Mesh=SkeletalMesh'BadgerMinigun'
	CollisionHeight=15.000000
}
