//=============================================================================
// TankScorpionTurret.
//=============================================================================
class TankScorpionTurret expands TankGKOneTurret;

var TankMGMuz TMGMz;
var byte TracerCount;

function SpawnFireEffects( byte Mode )
{
local vector ROffset;
	if (Mode == 0)
		Super.SpawnFireEffects(Mode);
	else if (TMGMz == None && PitchPart != None && Mode == 1)
	{
		ROffset = WeapSettings[Mode].FireStartOffset + vect(-40,0,-5);
		TMGMz = Spawn(Class'TankMGMuz',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation), PitchPart.Rotation);
		TMGMz.PrePivotRel = ROffset;
	}
}

function SpawnTraceEffects(vector Dir)
{
local vector ROffset;

	if (PitchPart != None && TracerCount > 1)
	{
		ROffset = WeapSettings[1].FireStartOffset + vect(-20,0,0);
		Spawn(Class'TMGunTracer',,,PitchPart.Location + (ROffset >> PitchPart.Rotation), rotator(Dir));
		TracerCount = 0;
	}
	else
		TracerCount++;
}

function Timer()
{
	bFireRestrict = False;
	if( WeaponController==None )
	{
		if (TMGMz != None)
		{
			TMGMz.Destroy();
			TMGMz = None;
		}
		Return;
	}
	if( WeaponController.bAltFire!=0 )
		FireTurret(1);
	else if( WeaponController.bFire!=0 )
	{
		if (TMGMz != None)
		{
			TMGMz.Destroy();
			TMGMz = None;
		}

		FireTurret(0);
	}
	else if (TMGMz != None)
	{
		TMGMz.Destroy();
		TMGMz = None;
	}
}

simulated function Destroyed()
{
	if (TMGMz != None)
		TMGMz.Destroy();

	Super.Destroyed();
}

defaultproperties
{
	PitchRange=(Max=4500,Min=-2800)
	bAltFireZooms=False
	TurretPitchActor=Class'TankScorpionCannon'
	PitchActorOffset=(X=9.000000,Y=0.000000,Z=17.000000)
	WeapSettings(0)=(FireStartOffset=(X=235.000000,Z=2.500000),FireSound=Sound'XTreadVeh.TankScorpion.cannon_firing')
	WeapSettings(1)=(FireStartOffset=(X=124.000000,Y=19.500000,Z=3.500000),RefireRate=0.100000,FireSound=Sound'XTreadVeh.TankGKOne.TankGKMGunFire',bInstantHit=True,hitdamage=17,HitType="Ballistic",HitError=0.010000,HitMomentum=10000.000000,HitHeavyness=2)
	Mesh=SkeletalMesh'TankScorpionCanon'
	CollisionHeight=35.000000
}
