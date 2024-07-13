//=============================================================================
// JuggernautFrontTurret.
//=============================================================================
class JuggernautFrontTurret expands xWheelVehWeapon;

function Timer()
{
	local int Mode;
	Super.Timer();
	// reset loop sound on stop fire
	if (WeaponController.bFire == 0 && WeaponController.bAltFire == 0)
		PlaySound(WeapSettings[Mode].FireDelaySnd, SLOT_Misc, WeapSettings[Mode].FireSndVolume,,
			WeapSettings[Mode].FireSndRange*62.5);
}

defaultproperties
{
	RotatingSpeed=22000.000000
	PitchRange=(Max=14000,Min=-6500)
	TurretPitchActor=Class'JuggernautFrontGun'
	WeapSettings(0)=(ProjectileClass=Class'JuggFlameBall',FireStartOffset=(X=56.000000,Z=15.000000),RefireRate=0.100000,FireSound=Sound'FT_FireLoop',FireDelaySnd=Sound'FT_FireEnd',FireDelaySndRange=32,FireDelaySndVolume=20)
	WeapSettings(1)=(ProjectileClass=Class'JuggFlameBall',FireStartOffset=(X=56.000000,Z=15.000000),RefireRate=0.100000,FireSound=Sound'FT_FireLoop',FireDelaySnd=Sound'FT_FireEnd',FireDelaySndRange=32,FireDelaySndVolume=20)
	CarTopAllowedPitch=(Max=14000,Min=-600)
	bPhysicalGunAimOnly=True
	Mesh=SkeletalMesh'JuggernautFrontTurret'
	SoundRadius=150
	SoundVolume=255
	CollisionRadius=18.000000
	CollisionHeight=4.000000
	NetPriority=3.000000
}
