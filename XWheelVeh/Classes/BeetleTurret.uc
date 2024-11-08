//=============================================================================
// BeetleTurret.
//=============================================================================
class BeetleTurret expands JSDXTurret;

defaultproperties
{
	PitchRange=(Min=-3500)
	TurretPitchActor=Class'BeetleGun'
	PitchActorOffset=(X=3.500000,Z=12.000000)
	WeapSettings(0)=(FireStartOffset=(X=38.000000,Y=4.000000,Z=0.000000),RefireRate=0.322700,FireAnim1="None",FireAnim2="None")
	WeapSettings(1)=(FireStartOffset=(X=38.000000,Y=4.000000,Z=0.000000),RefireRate=0.675000,FireAnim1="None")
	bFireRateByAnim=False
	bLimitPitchByCarTop=False
	Mesh=SkeletalMesh'BeetleTurret'
}
