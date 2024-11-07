//=============================================================================
// WarthogMGTurret.
//=============================================================================
class WarthogMGTurret expands JSDXTurret;

defaultproperties
{
	PitchRange=(Max=8400,Min=-12000)
	TurretPitchActor=Class'WarthogMGGun'
	PitchActorOffset=(X=42.650002,Y=0.000000,Z=62.250000)
	WeapSettings(0)=(FireStartOffset=(X=72.000000,Y=0.000000,Z=17.000000),RefireRate=0.322700,FireAnim1="None",FireAnim2="None")
	WeapSettings(1)=(FireStartOffset=(X=72.000000,Y=2.000000,Z=13.650000),RefireRate=0.675000,FireAnim1="None")
	bFireRateByAnim=False
	CarTopAllowedPitch=(Max=8400,Min=-3200)
	Mesh=SkeletalMesh'WarthogMGTurret'
}
