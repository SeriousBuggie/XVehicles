//=============================================================================
// CTFFlagSpawnNotify.
//=============================================================================
class CTFFlagSpawnNotify expands SpawnNotify;

event Actor SpawnNotification(Actor A)
{
	Local GreedFlag GF;
	if (GreedFlag(A) == None)
	{
		GF = A.Spawn(Class'GreedFlag', A.Owner);
		A.Destroy();
		A = GF;
	}
	return A;
}

defaultproperties
{
	ActorClass=Class'Botpack.CTFFlag'
	bGameRelevant=True
}
