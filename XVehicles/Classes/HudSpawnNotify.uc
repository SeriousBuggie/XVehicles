//=============================================================================
// HudSpawnNotify.
//=============================================================================
class HudSpawnNotify expands SpawnNotify;

var Mutator HUDMutator;

event Actor SpawnNotification(Actor A)
{
	local Mutator M;
	local ENetRole OldRole;
	if (ChallengeHUD(A) != None)
	{
		M = ChallengeHUD(A).HUDMutator;
		if (M == None)
			ChallengeHUD(A).HUDMutator = Spawn(class'XVHUDProxy', HUDMutator);
		else
		{
			while (M.NextHUDMutator != None && (XVHUDProxy(M) == None || M.Owner != HUDMutator))
				M = M.NextHUDMutator;
			if (XVHUDProxy(M) == None || M.Owner != HUDMutator)
				M.NextHUDMutator = Spawn(class'XVHUDProxy', HUDMutator);
		}
		OldRole = HUDMutator.Role;
		HUDMutator.Role = ROLE_Authority;
		HUDMutator.SetPropertyText("FoundHuds", string(int(HUDMutator.GetPropertyText("FoundHuds")) + 1));
		HUDMutator.Role = OldRole;
	}
	return A;
}

defaultproperties
{
	ActorClass=Class'Botpack.ChallengeHUD'
	RemoteRole=ROLE_None
}
