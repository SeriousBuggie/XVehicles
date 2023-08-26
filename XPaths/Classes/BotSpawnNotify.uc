//=============================================================================
// BotSpawnNotify.
//=============================================================================
class BotSpawnNotify expands SpawnNotify;

var Mutator XVehiclesCTF;

event Actor SpawnNotification(Actor A) {
	local Bot Bot;
	local PLITracker PLITracker;
	Bot = Bot(A);
	if (Bot != None) {
		PLITracker = Bot.Spawn(class'PLITracker', Bot);
		if (default.XVehiclesCTF != None) {
			default.XVehiclesCTF.KillCredit(Bot);
			default.XVehiclesCTF.KillCredit(PLITracker);
		}
	}
	return A;
}

event Spawned() {
	if (default.XVehiclesCTF != None && default.XVehiclesCTF.Level != Level)
		default.XVehiclesCTF = None;
}

defaultproperties
{
	ActorClass=Class'Botpack.Bot'
	RemoteRole=ROLE_None
}
