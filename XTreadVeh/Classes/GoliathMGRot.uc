//=============================================================================
// GoliathMGRot.
//=============================================================================
class GoliathMGRot expands TankMGRot;

var int Barrel;

function SpawnFireEffects( byte Mode )
{
	local vector ROffset;
	local TankMGMuz TMGMz2;

	if (TMGMz == None && PitchPart != None)
	{
		ROffset = WeapSettings[Mode].FireStartOffset + vect(-30,0,-3);
		ROffset.Y = 3.7*Barrel - 1.0;
		TMGMz = Spawn(Class'TankMGMuz',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation), PitchPart.Rotation);
		TMGMz.PrePivotRel = ROffset;
		
		ROffset.Y = -3.7*Barrel - 1.0;
		TMGMz2 = Spawn(Class'TankMGMuz',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation), PitchPart.Rotation);
		TMGMz2.PrePivotRel = ROffset;
		TMGMz2.AnimFrame = 0.5;
		TMGMz.Target = TMGMz2;
	}
}

simulated function FireEffect()
{
	Super.FireEffect();
	if (Level.netmode != NM_DedicatedServer)
		SpawnShell();
}

simulated function SpawnShell()
{
	local UT_Shellcase s;
	local vector X, Y, Z;

	if (PitchPart != None)
	{
		s = Spawn(class'MiniShellCase', WeaponController, '', PitchPart.Location + (vect(15, -8, 11) >> PitchPart.Rotation));
		if (s != None)
		{
			s.DrawScale = 0.5;
			GetAxes(PitchPart.Rotation, X, Y, Z);
			s.Eject(((FRand()*0.3+0.4)*X - (FRand()*0.2+2.2)*Y + (FRand()*0.5+1.0) * Z)*80);              
		}
	}
}

function SpawnTraceEffects(vector Dir)
{
	local vector ROffset;	

	if (PitchPart != None && TracerCount > 1)
	{
		ROffset = WeapSettings[0].FireStartOffset + vect(-20,0,0);
		ROffset.Y = 3.7*Barrel - 1.0;
		Spawn(Class'TMGunTracer',,,PitchPart.Location + (ROffset >> PitchPart.Rotation), rotator(Dir));
		TracerCount = 0;
		Barrel *= -1;
	}
	else
		TracerCount++;
}

defaultproperties
{
	Barrel=1
	TurretPitchActor=Class'GoliathMGun'
	PitchActorOffset=(X=0.000000,Y=0.000000,Z=1.500000)
	WeapSettings(0)=(FireStartOffset=(X=77.750000,Z=9.300000))
	Mesh=SkeletalMesh'GoliathMGRot'
}
