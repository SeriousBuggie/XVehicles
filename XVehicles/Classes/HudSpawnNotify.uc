//=============================================================================
// HudSpawnNotify.
//=============================================================================
class HudSpawnNotify expands SpawnNotify;

var XVehiclesHUD HUDMutator;

event Actor SpawnNotification(Actor A)
{
	local Mutator M;
	if (ChallengeHUD(A) != None)
	{
		M = ChallengeHUD(A).HUDMutator;
		if (M == None)
			ChallengeHUD(A).HUDMutator = HUDMutator;
		else
		{
			while (M != HUDMutator && M.NextHUDMutator != None)
				M = M.NextHUDMutator;
			if (M != HUDMutator)
				M.NextHUDMutator = HUDMutator;
		}
		HUDMutator.FoundHuds++;
	}
	return A;
}

defaultproperties
{
	ActorClass=Class'Botpack.ChallengeHUD'
	RemoteRole=ROLE_None
}
