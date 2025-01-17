//=============================================================================
// WarthogRLTurret.
//=============================================================================
class WarthogRLTurret expands JSDXTurret;

function SpawnFireEffects(byte Mode)
{
local vector ROffset;
local LPlasmaFireFX LPl;

	if (PitchPart != None)
	{
		ROffset = WeapSettings[Mode].FireStartOffset;
	
		if (Mode == 0)
		{
			if (bTurnFire)
				ROffset.Y = -ROffset.Y;
			LPl = Spawn(Class'HPlasmaFireFX',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation));
			LPl.PrePivotRel = ROffSet;
			
		}
		else
		{
			LPl = Spawn(Class'HPlasmaFireFX',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation));
			LPl.PrePivotRel = ROffSet;
			ROffset.Y = -ROffset.Y;
			LPl = Spawn(Class'HPlasmaFireFX',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation));
			LPl.PrePivotRel = ROffSet;
		}
	}
}

defaultproperties
{
	PitchRange=(Max=8400,Min=-12000)
	TurretPitchActor=Class'WarthogRLGun'
	PitchActorOffset=(X=34.119999,Z=49.180000)
	WeapSettings(0)=(ProjectileClass=Class'JTDXLPlasma',FireStartOffset=(X=39.200001,Y=0.000000,Z=12.000000),RefireRate=0.420000,FireAnim1="None",FireAnim2="None",FireSound=Sound'XWheelVeh.Fire.JTDXLFire')
	WeapSettings(1)=(ProjectileClass=Class'JTDXLPlasma',FireStartOffset=(X=39.200001,Y=3.200000,Z=12.000000),RefireRate=0.850000,FireAnim1="None",FireSound=Sound'XWheelVeh.Fire.JTDXLDualFire')
	bFireRateByAnim=False
	CarTopAllowedPitch=(Max=8400,Min=-3200)
	Mesh=SkeletalMesh'WarthogRLTurret'
}
