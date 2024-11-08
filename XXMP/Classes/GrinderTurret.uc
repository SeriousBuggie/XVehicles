//=============================================================================
// GrinderTurret.
//=============================================================================
class GrinderTurret expands TankMGRot;

defaultproperties
{
	RotatingSpeed=22000.000000
	PitchRange=(Max=14000,Min=-2400)
	TurretPitchActor=Class'GrinderGun'
	PitchActorOffset=(Z=0.000000)
	WeapSettings(0)=(FireStartOffset=(X=88.000000,Z=-6.000000),FireSound=Sound'P_AltFire',HitError=0.020000)
	bLimitPitchByCarTop=True
	CarTopRange=0.650000
	CarTopAllowedPitch=(Max=14000,Min=-1100)
	Mesh=SkeletalMesh'GrinderTurret'
}
