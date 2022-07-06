class FastWSTracker expands Info;

simulated function PostBeginPlay()
{
	local GuidedWarShell MyShell;
	Super.PostBeginPlay();
	
	MyShell = GuidedWarShell(Owner);
	
	if (MyShell == None)
		Destroy();
}

simulated function Tick(float Delta)
{
	local GuidedWarShell MyShell;
	Super.Tick(delta);
	
	MyShell = GuidedWarShell(Owner);
	
	if (MyShell == None)
		Destroy();
	else
		MyShell.AutonomousPhysics(Delta); //x2 speed
}

defaultproperties
{
      bAlwaysRelevant=True
      RemoteRole=ROLE_SimulatedProxy
      NetPriority=3.000000
      NetUpdateFrequency=100.000000
}
