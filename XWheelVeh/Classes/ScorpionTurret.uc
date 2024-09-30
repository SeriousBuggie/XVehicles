//=============================================================================
// ScorpionTurret.
//=============================================================================
class ScorpionTurret expands JSDXTurret;

function FireTurret( byte Mode, optional bool bForceFire )
{
	if (Mode == 1 && Scorpion(OwnerVehicle) != None && OwnerVehicle.Driver == WeaponController &&
		Scorpion(OwnerVehicle).BladesNotBroken)
	{
		if (PlayerPawn(WeaponController) == None)
			Super(xWheelVehWeapon).FireTurret(0);
		return; // use Blades instead
	}
	Super.FireTurret(Mode);
}

defaultproperties
{
	PitchRange=(Max=8400,Min=-3500)
	TurretPitchActor=Class'ScorpionGun'
	PitchActorOffset=(X=0.000000,Y=0.000000,Z=4.000000)
	WeapSettings(0)=(FireStartOffset=(X=52.000000,Y=0.000000,Z=9.000000),RefireRate=0.322700,FireAnim1="None",FireAnim2="None")
	WeapSettings(1)=(FireStartOffset=(X=52.000000,Y=0.000000,Z=9.000000),RefireRate=0.675000,FireAnim1="None")
	bFireRateByAnim=False
	CarTopAllowedPitch=(Max=8400,Min=-5000)
	Mesh=SkeletalMesh'ScorpionTurret'
}
