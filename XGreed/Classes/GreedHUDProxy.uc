//=============================================================================
// GreedHUDProxy.
//=============================================================================
class GreedHUDProxy expands Mutator;

simulated event PostRender(canvas Canvas) {
	if (NextHUDMutator != None)
		NextHUDMutator.PostRender(Canvas);
		
	if (Mutator(Owner) != None)
		Mutator(Owner).PostRender(Canvas);
}

defaultproperties
{
	bAddToPackageMap=True
	RemoteRole=ROLE_None
	bGameRelevant=True
}
