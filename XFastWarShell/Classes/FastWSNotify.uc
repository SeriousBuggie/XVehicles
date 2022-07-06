class FastWSNotify expands SpawnNotify;

var bool bGameEnded;

replication
{
	reliable if( Role == ROLE_Authority )
		bGameEnded;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	class'WarShell'.default.Speed = 1200; // instead of 600
	class'WarShell'.default.MaxSpeed = 4000; // instead of 2000
	// repeat for GuidedWarShell
	class'GuidedWarShell'.default.Speed = class'WarShell'.default.Speed;
	class'GuidedWarShell'.default.MaxSpeed = class'WarShell'.default.MaxSpeed;
}

event Trigger( Actor Other, Pawn EventInstigator )
{
	bGameEnded = true;
	Restore();
}

simulated function Tick(float delta)
{
	Super.Tick(delta);
	Tag = 'EndGame'; // for call Trigger from GameInfo
	if (Role != ROLE_Authority && bGameEnded)
	{
		Restore();
		bGameEnded = false;
	}
}

simulated function Restore()
{
	class'WarShell'.default.Speed = 600;
	class'WarShell'.default.MaxSpeed = 2000;
	// repeat for GuidedWarShell
	class'GuidedWarShell'.default.Speed = class'WarShell'.default.Speed;
	class'GuidedWarShell'.default.MaxSpeed = class'WarShell'.default.MaxSpeed;
}

simulated event Actor SpawnNotification(Actor A)
{
	A.Spawn(class'FastWSTracker', A);
	return A;
}

defaultproperties
{
      bGameEnded=False
      ActorClass=Class'Botpack.GuidedWarshell'
      RemoteRole=ROLE_SimulatedProxy
}
