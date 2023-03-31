//=============================================================================
// HudSpawnNotify.
//=============================================================================
class HudSpawnNotify expands SpawnNotify;

var XVehiclesHUD HUDMutator;

event Actor SpawnNotification(Actor A)
{
	if (ChallengeHUD(A) != None)
	{
		ChallengeHUD(A).HUDMutator = HUDMutator;
		HUDMutator.FoundHuds++;
	}
	return A;
}

defaultproperties
{
	ActorClass=Class'Botpack.ChallengeHUD'
	RemoteRole=ROLE_None
}
