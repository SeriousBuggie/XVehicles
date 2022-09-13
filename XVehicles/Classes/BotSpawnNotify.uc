//=============================================================================
// BotSpawnNotify.
//=============================================================================
class BotSpawnNotify expands SpawnNotify;

simulated event Actor SpawnNotification(Actor A)
{
	XVehiclesCTF(Owner).AddBot(Bot(A));
	return A;
}

defaultproperties
{
	ActorClass=Class'Botpack.Bot'
}
