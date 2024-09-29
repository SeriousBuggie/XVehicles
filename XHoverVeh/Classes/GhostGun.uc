//=============================================================================
// GhostGun.
//=============================================================================
class GhostGun expands MantaGun;

function FireTurret( byte Mode, optional bool bForceFire )
{	
	if ((PlayerPawn(WeaponController) == None || Mode == 1) && Ghost(OwnerVehicle) != None)
		Ghost(OwnerVehicle).InvisOn();
	if (Mode == 1)
		return;
	Super.FireTurret(Mode, bForceFire);
}

function SpawnFireEffects(byte Mode)
{
	local GhostMuzzle Muzzle;
	local vector RealFireOffset;
	RealFireOffset = WeapSettings[Mode].FireStartOffset;
	if (bTurnFire)
		RealFireOffset.Y = -RealFireOffset.Y;
		
	Muzzle = OwnerVehicle.Spawn(Class'GhostMuzzle', OwnerVehicle);
	Muzzle.POffSet = RealFireOffset;
	Muzzle.DrawScale = WeapSettings[Mode].ProjectileClass.default.DrawScale;
	Muzzle.Mass = Muzzle.DrawScale;
}

defaultproperties
{
	WeapSettings(0)=(ProjectileClass=Class'GhostPlasma',FireStartOffset=(X=112.500000,Y=30.000000,Z=-18.000000),FireSound=Sound'XHoverVeh.Ghost.fireplasmarifle2')
	WeapSettings(1)=(ProjectileClass=Class'GhostPlasma',FireSound=Sound'XHoverVeh.Ghost.fireplasmarifle2')
}
