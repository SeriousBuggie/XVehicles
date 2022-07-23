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

function float GetProjSpeed(byte Mode, vector P, rotator R)
{
	local vector HL, HN;
	local float Speed, S, S1, Vm, V0, a;
	local Class<MantaPlasma> ProjCls;
	
	Speed = Super.GetProjSpeed(Mode, P, R);
	ProjCls = Class<MantaPlasma>(WeapSettings[Mode].ProjectileClass);
	if (ProjCls != None && ProjCls.default.AccelerationMagnitude != 0 && Speed < ProjCls.default.MaxSpeed)
	{
		HL = P + vector(R)*40000;
		Trace(HL, HN, HL, P, true);
		S = VSize(HL - P);
		Vm = ProjCls.default.MaxSpeed;
		V0 = Speed;
		a = ProjCls.default.AccelerationMagnitude;
		S1 = (Vm - V0)*(Vm + V0)/2/a;
		if (S >= S1)
			Speed = S/((Vm - V0)/a + (S - S1)/Vm);
		else
			Speed = a*S/(Sqrt(V0*V0 + 2*a*S) - V0);
	}

	return Speed;
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
