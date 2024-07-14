//=============================================================================
// BadgerTurret.
//=============================================================================
class BadgerTurret expands TankGKOneTurret;

simulated function FireEffect()
{
	Super.FireEffect();
	if (Role == ROLE_Authority)
		SpawnSmoke();
}

function SpawnSmoke()
{
	local Effects s;
	local vector X, Y, Z, FireStart;
	local int i;

	if (PitchPart != None)
	{
		FireStart = PitchPart.Location + (WeapSettings[0].FireStartOffset >> PitchPart.Rotation);
		for (i = 0; i < 32; i++)
		{
			s = Spawn(class'UT_BlackSmoke', , '', FireStart);
			if (s != None)
			{
				s.DrawScale = 4;
				GetAxes(PitchPart.Rotation, X, Y, Z);
				s.Velocity = (FRand()*2.0 - 1.0)*100*Z + (FRand()*2.0 - 1.0)*300*Y;
			}
		}
	}
}

defaultproperties
{
	TurretPitchActor=Class'BadgerGun'
	PitchActorOffset=(X=36.000000,Y=0.000000,Z=-6.000000)
	WeapSettings(0)=(FireStartOffset=(X=59.500000),FireSound=Sound'XXMP.Badger.BadgerCannon')
	Mesh=SkeletalMesh'BadgerTurret'
}
