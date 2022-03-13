//=============================================================================
// XVehiclesCTF.
//=============================================================================
class XVehiclesCTF expands Mutator;

event PreBeginPlay()
{	
	Super.PreBeginPlay();
	
//	SetShield();
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
}
