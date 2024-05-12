//=============================================================================
// RaptorGun.
//=============================================================================
class RaptorGun expands xChopVehWeapon;

function FireTurret( byte Mode, optional bool bForceFire )
{
	if (Bot(WeaponController) != None)
	{
		if (Mode == 0 && class'XV_SeekingRocket'.static.IsGoodTarget(WeaponController, WeaponController.Target))
			Mode = 1; // use alt fire for rocket
		else
			Mode = 0;
	}

	Super.FireTurret(Mode, bForceFire);	
}

function float GetProjSpeed(byte Mode, vector P, rotator R)
{
	local vector HL, HN;
	local float Speed, S, S1, Vm, V0, a;
	local Class<NaliProjectile> ProjCls;
	
	Speed = Super.GetProjSpeed(Mode, P, R);
	ProjCls = Class<NaliProjectile>(WeapSettings[Mode].ProjectileClass);
	if (ProjCls != None && ProjCls.default.ProjAccel != 0 && Speed < ProjCls.default.MaxSpeed)
	{
		HL = P + vector(R)*40000;
		Trace(HL, HN, HL, P, true);
		S = VSize(HL - P);
		Vm = ProjCls.default.MaxSpeed;
		V0 = Speed;
		a = ProjCls.default.ProjAccel;
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
	RotatingSpeed=16000000.000000
	PitchRange=(Max=32767,Min=-32767)
	TurretPitchActor=Class'CybPitch'
	PitchActorOffset=(X=67.000000,Y=0.000000,Z=-36.000000)
	WeapSettings(0)=(ProjectileClass=Class'CybProj',FireStartOffset=(Y=49.000000),RefireRate=0.200000,FireSound=Sound'rfire',DualMode=1)
	WeapSettings(1)=(ProjectileClass=Class'XV_SeekingRocket',FireStartOffset=(Y=49.000000),RefireRate=3.000000,FireSound=Sound'AvrilFire01',DualMode=1)
	DrawScale=0.000100
	CollisionHeight=88.000000
}
