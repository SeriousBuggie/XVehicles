//=============================================================================
// GoliathMGRot.
//=============================================================================
class GoliathMGRot expands TankMGRot;

var() float BarrelYOffset;
var int Barrel;

function SpawnFireEffects( byte Mode )
{
	local vector ROffset;
	local TankMGMuz TMGMz2;

	if (TMGMz == None && PitchPart != None)
	{
		ROffset = WeapSettings[Mode].FireStartOffset + vect(-30,0,-3);
		ROffset.Y = BarrelYOffset*Barrel - 1.0;
		TMGMz = Spawn(Class'TankMGMuz',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation), PitchPart.Rotation);
		TMGMz.PrePivotRel = ROffset;
		
		ROffset.Y = -BarrelYOffset*Barrel - 1.0;
		TMGMz2 = Spawn(Class'TankMGMuz',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation), PitchPart.Rotation);
		TMGMz2.PrePivotRel = ROffset;
		TMGMz2.AnimFrame = 0.5;
		TMGMz.Target = TMGMz2;
	}
}

function SpawnTraceEffects(vector Dir)
{
	local vector ROffset;
	
	if (OwnerVehicle == None)
		return;

	if (PitchPart != None && TracerCount > 1)
	{
		ROffset = WeapSettings[0].FireStartOffset + vect(-20,0,0);
		ROffset.Y = BarrelYOffset*Barrel - 1.0;
		OwnerVehicle.Spawn(Class'TMGunTracer',OwnerVehicle,,PitchPart.Location + (ROffset >> PitchPart.Rotation), rotator(Dir));
		TracerCount = 0;
		Barrel *= -1;
	}
	else
		TracerCount++;
}

defaultproperties
{
	BarrelYOffset=3.700000
	Barrel=1
	ShellOffset=(X=15.000000,Y=-8.000000,Z=11.000000)
	TurretPitchActor=Class'GoliathMGun'
	PitchActorOffset=(X=0.000000,Y=0.000000,Z=1.500000)
	WeapSettings(0)=(FireStartOffset=(X=77.750000,Z=9.300000))
	Mesh=SkeletalMesh'GoliathMGRot'
}
