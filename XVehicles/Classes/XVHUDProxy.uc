//=============================================================================
// XVHUDProxy.
//=============================================================================
class XVHUDProxy expands Mutator;

simulated event PostRender(canvas Canvas)
{
	if (NextHUDMutator != None)
		NextHUDMutator.PostRender(Canvas);
		
	if (Mutator(Owner) != None)
		Mutator(Owner).PostRender(Canvas);
}

defaultproperties
{
	RemoteRole=ROLE_None
}
