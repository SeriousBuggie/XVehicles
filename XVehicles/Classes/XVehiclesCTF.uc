//=============================================================================
// XVehiclesCTF.
//=============================================================================
class XVehiclesCTF expands Mutator;

enum EPulseForHeal
{
	PFH_Auto,				// Detect by presence FixGun on map, or by use FixGunMutator
	PFH_Yes,				// Pulse Heal vehicles
	PFH_No,					// Pulse not heal vehicles
};
var() EPulseForHeal PulseForHeal;
var() bool bShowFlagBase;

event PreBeginPlay()
{
	local Actor A;
	local bool bPulseAltHeal;
	Local PulseGun Pulse;
	local Mutator M;
	local FlagBase FB;
	Local XFlagBase xFB;
	Local vector HL, HN;
	
	Super.PreBeginPlay();
	
	foreach AllActors(Class, A)
		break;
	if (A != self)
		return;
	
	if (PulseForHeal == PFH_Yes)
		bPulseAltHeal = true;
	else if (PulseForHeal == PFH_Auto)
	{
		foreach AllActors(class'PulseGun', Pulse)
			if (Pulse.isA('FixGun'))
				break;
		if (Pulse == None) // on map no any Fixgun?
		{
			foreach AllActors(class'Mutator', M)
				if (M.isA('FixGunMutator'))
					break;
			if (M == None) // FixGunMutator not loaded? (able give FixGun on enter to vehicle)
				bPulseAltHeal = true;
		}
	}
	
	class'VehiclesConfig'.default.bPulseAltHeal = bPulseAltHeal;
	
	if (bShowFlagBase)
		foreach AllActors(class'FlagBase', FB)
		{
			HL = FB.Location;
			HL -= vect(0,0,134.5)*FB.DrawScale/FB.default.DrawScale >> FB.Rotation;
			if (FB.Trace(HL, HN, HL) != None)
			{
				xFB = FB.Spawn(class'XFlagBase', FB, , HL + (vect(0,0,18) >> FB.Rotation), FB.Rotation);
				if (xFB != None && FB.Team != 0)
					xFB.MultiSkins[0] = Texture'FlagBaseSkinB';				
			}
		}
}

/*
function Tick(float delta)
{
	local Pawn P;
	local Inventory Inv, Lost;
	local string chain;
	local bool bBad;
	
	Super.Tick(delta);
	
	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if (!P.bIsPlayer || P.health <= 0 || P.isInState('Dying') || P.IsInState('PlayerWaiting') || Spectator(P) != None)
			continue;
		if (P.Inventory == None)
		{
			Log(P @ P.GetHumanName() @ "lost inventory!");
			foreach AllActors(class'Inventory', Lost)
				if (Lost.owner == P)
					Log("Found lost item:" @ Lost @ "which point to" @ Lost.Inventory);
		}
		else
		{
			bBad = false;
			chain = "";
			for (Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
			{
				chain @= ">" @ Inv;
				if (Inv.Owner != P)
					chain @= "(" $ Inv.Owner @ Inv.Owner.GetHumanName() $ ")";
				if (DriverWeapon(Inv) != None || DriverWNotifier(Inv) != None || Inv.Owner != P)
					bBad = true;
			}
			if (bBad)
				Log("Bad chain:" @ P @ P.GetHumanName() @ chain);
		}
	}
}
*/

defaultproperties
{
      PulseForHeal=PFH_Auto
      bShowFlagBase=True
}
