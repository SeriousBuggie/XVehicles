//=============================================================================
// FixGunMutator.
//=============================================================================
class FixGunMutator expands Mutator;

function PostBeginPlay()
{
	local Mutator Other;
	
	Super.PostBeginPlay();
	
	foreach AllActors(class'Mutator', Other)
		if (Other.isA('FixGunMutator') && Other != self && string(Other.Name) < string(Name))
			break;
	
	if (Other == None)
		SetTimer(1.0, true);
	else
		Warn(self @ "disabled in favor of" @ Other);
}

function Timer()
{
	Local Pawn P;
	Local Inventory Inv;
	local FixGun FG;
	
	Super.Timer();

	for (P = Level.PawnList; P != None; P = P.nextPawn)
		if (P.bIsPlayer && !P.IsA('Spectator') && P.Weapon != None && P.Weapon.isA('DriverWeapon'))
		{
			for (Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
				if (FixGun(Inv) != None)
					break;
			if (Inv == None) // need get new
			{
				FG = P.Spawn(class'FixGun');
				FG.GiveTo(P);
				FG.GiveAmmo(P);
				if (FG.PickupMessageClass == None)
					P.ClientMessage(FG.PickupMessage, 'Pickup');
				else
					P.ReceiveLocalizedMessage( FG.PickupMessageClass, 0, None, None, FG.Class );
				if (PlayerPawn(P) != None)
					PlayerPawn(P).ClientPlaySound(FG.PickupSound);
			}
			else // need refill
			{
				FG = FixGun(Inv);
				if (FG.AmmoType == None)
					FG.GiveAmmo(P);
				if (FG.AmmoType != None && FG.AmmoType.AmmoAmount < FG.PickupAmmoCount)
					FG.AmmoType.AmmoAmount = FG.PickupAmmoCount;
			}
		}	
}

defaultproperties
{
}
