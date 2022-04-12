class FastWSNotify expands SpawnNotify;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	class'WarShell'.default.Speed = 3000; // instead of 600
	class'WarShell'.default.MaxSpeed = 10000; // instead of 2000
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
      ActorClass=Class'Botpack.GuidedWarshell'
}
