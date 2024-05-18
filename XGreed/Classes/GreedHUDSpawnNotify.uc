//=============================================================================
// GreedHUDSpawnNotify.
//=============================================================================
class GreedHUDSpawnNotify expands SpawnNotify;

var GreedHUD HUDMutator;

event Actor SpawnNotification(Actor A)
{
	local Mutator M;
	if (ChallengeHUD(A) != None)
	{
		M = ChallengeHUD(A).HUDMutator;
		if (M == None)
			ChallengeHUD(A).HUDMutator = Spawn(class'GreedHUDProxy', HUDMutator);
		else
		{
			while (GreedHUDProxy(M) == None && M.NextHUDMutator != None)
				M = M.NextHUDMutator;
			if (GreedHUDProxy(M) == None)
				M.NextHUDMutator = Spawn(class'GreedHUDProxy', HUDMutator);
		}
	}
	return A;
}

defaultproperties
{
	ActorClass=Class'Botpack.ChallengeHUD'
	RemoteRole=ROLE_None
	bGameRelevant=True
}
