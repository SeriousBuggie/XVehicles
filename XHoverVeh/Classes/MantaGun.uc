//=============================================================================
// MantaGun.
//=============================================================================
class MantaGun expands xHoverVehWeapon;

function FireTurret( byte Mode, optional bool bForceFire )
{
	if (Mode == 1)
	{
		if (PLayerPawn(WeaponController) != None)
			return;
		Mode = 0;
	}
	Super.FireTurret(Mode);
}

defaultproperties
{
      PitchRange=(Max=5500,Min=-2800)
      WeapSettings(0)=(ProjectileClass=Class'XHoverVeh.MantaPlasma',FireStartOffset=(X=76.000000,Y=31.000000,Z=-24.000000),RefireRate=0.200000,FireSound=Sound'XHoverVeh.Manta.HoverBikeFire01',DualMode=1)
      WeapSettings(1)=(ProjectileClass=Class'XHoverVeh.MantaPlasma',FireSound=Sound'XHoverVeh.Manta.HoverBikeFire01')
      bPhysicalGunAimOnly=True
      CollisionRadius=92.000000
      CollisionHeight=46.000000
}
