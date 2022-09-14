//=============================================================================
// BotSpawnNotify.
//=============================================================================
class BotSpawnNotify expands SpawnNotify;

simulated event Actor SpawnNotification(Actor A)
{
	if (XVehiclesCTF(Owner) != None)
		XVehiclesCTF(Owner).AddBot(Bot(A));
	return A;
}

defaultproperties
{
	ActorClass=Class'Botpack.Bot'
	RemoteRole=ROLE_None
}
