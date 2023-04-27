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
			ChallengeHUD(A).HUDMutator = Spawn(class'XVHUDProxy', HUDMutator);
		else
		{
			while (XVHUDProxy(M) == None && M.NextHUDMutator != None)
				M = M.NextHUDMutator;
			if (XVHUDProxy(M) == None)
				M.NextHUDMutator = Spawn(class'XVHUDProxy', HUDMutator);
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
