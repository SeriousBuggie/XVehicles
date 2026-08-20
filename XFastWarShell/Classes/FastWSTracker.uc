//=============================================================================
// FastWSTracker.
//
// Rides one GuidedWarShell and tops its speed up to TargetSpeed every frame.
//
// Why a top-up and not a second full physics step (what this class used to do):
// the number of integrations the shell already gets per frame is not constant -
// engine physics, MoveRocket from Tick, MoveRocket from a ServerMove RPC, plus
// the SavedMove replay after every ClientAdjustPosition - and which of them run
// depends on NetMode, Role/RemoteRole and on who fired. Neither is the speed
// being integrated: stock MoveRocket normalises Velocity to a hardcoded 550,
// while a rebuilt Redeemer (NewNet ST_GuidedWarshell) normalises to its own
// `speed`. An extra full step multiplied whatever was there, so the result
// ranged from 1x (standalone, listen host) to 4x+ (mod shell). Adding only the
// deficit lands on TargetSpeed in every combination, and gives a mod shell that
// is already faster than TargetSpeed no bonus at all.
//=============================================================================
class FastWSTracker expands Info;

var GuidedWarShell MyShell;
var float TargetSpeed;
var float SpawnTime;

// Seconds to wait for the replicated MyShell reference before giving up.
const REF_GRACE = 1.0;

replication
{
	reliable if (Role == ROLE_Authority)
		MyShell;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SpawnTime = Level.TimeSeconds;
}

simulated function Tick(float Delta)
{
	local vector SavedVel;
	local float Bonus;

	Super.Tick(Delta);

	if (MyShell == None)
	{
		// A client can receive MyShell as None when the shell's channel opens
		// after this property was sent: UE1 never resends a value that did not
		// change, so self-destructing on the first tick leaves the client
		// integrating at stock speed while the server does not - and the shell
		// spends its whole flight being yanked forward by ClientAdjustPosition,
		// which reads as an unflyable Redeemer. Give the reference a grace
		// window instead of dying on the race.
		if (Level.NetMode != NM_Client || Level.TimeSeconds - SpawnTime > REF_GRACE)
			Destroy();
		return;
	}
	if (MyShell.bDeleteMe)
	{
		Destroy();
		return;
	}

	if (Owner != MyShell.Owner)
		SetOwner(MyShell.Owner);

	// Somebody else's shell on a client is driven by replicated RealLocation /
	// RealVelocity rather than by local physics - stepping it here only fights
	// those corrections.
	if (Level.NetMode == NM_Client
		&& (PlayerPawn(MyShell.Instigator) == None
			|| ViewPort(PlayerPawn(MyShell.Instigator).Player) == None))
		return;

	Bonus = TargetSpeed - VSize(MyShell.Velocity);
	if (Bonus <= 0)
		return;

	// Step the shell with the deficit only. AutonomousPhysics is still the
	// mover so wall hits keep going through physProjectile -> Explode.
	SavedVel = MyShell.Velocity;
	MyShell.Velocity = Bonus * Normal(SavedVel);
	MyShell.AutonomousPhysics(Delta);
	if (MyShell != None && !MyShell.bDeleteMe)
		MyShell.Velocity = SavedVel;
}

defaultproperties
{
	TargetSpeed=1100.000000
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=3.000000
	NetUpdateFrequency=100.000000
}
