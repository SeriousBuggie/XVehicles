//=============================================================================
// WarthogMGTurret.
//=============================================================================
class WarthogMGTurret expands JSDXTurret;

defaultproperties
{
	PitchRange=(Max=8400,Min=-12000)
	TurretPitchActor=Class'WarthogMGGun'
	PitchActorOffset=(X=34.119999,Z=49.799999)
	WeapSettings(0)=(FireStartOffset=(X=57.599998,Y=0.000000,Z=13.600000),RefireRate=0.322700,FireAnim1="None",FireAnim2="None")
	WeapSettings(1)=(FireStartOffset=(X=57.599998,Y=1.600000,Z=10.920000),RefireRate=0.675000,FireAnim1="None")
	bFireRateByAnim=False
	CarTopAllowedPitch=(Max=8400,Min=-3200)
	Mesh=SkeletalMesh'WarthogMGTurret'
}
