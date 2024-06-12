class FastWSTracker expands Info;

var GuidedWarShell MyShell;

replication
{
	reliable if (Role == ROLE_Authority)
		MyShell;
}

simulated function Tick(float Delta)
{
	Super.Tick(Delta);
	
	if (MyShell == None || MyShell.bDeleteMe)
		Destroy();
	else
	{
		if (Owner != MyShell.Owner)
			SetOwner(MyShell.Owner);
		if (Level.NetMode == NM_Client && 
			(PlayerPawn(MyShell.Instigator) == None || ViewPort(PlayerPawn(MyShell.Instigator).Player) == None))
			return;
		if ( (Level.NetMode != NM_Standalone)
			&& ((Level.NetMode != NM_ListenServer) || (Instigator == None) 
				|| (Instigator.IsA('PlayerPawn') && (PlayerPawn(Instigator).Player != None)
					&& (ViewPort(PlayerPawn(Instigator).Player) == None))) )
			MyShell.AutonomousPhysics(Delta); //x2 speed
	}
}

defaultproperties
{
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=3.000000
	NetUpdateFrequency=100.000000
}
