//=============================================================================
// JumpPadAirControl.
//
// Spawned by a UTJumpPad with each bot it launches, lives for the flight. A launched
// bot flies without air control (stock Bot.FallingState zeroes its Acceleration), so
// a wall that takes its horizontal speed drops it straight back onto the pad, and the
// pad launches it again, for ever. A player would hold forward. This does that for
// the bot: while its speed toward the target is gone it steers toward the target, so
// a bot sliding up a wall goes over the edge (or through a window) as soon as it can,
// and lets go once the speed is back, so a normal flight stays the pad's parabola.
//=============================================================================
class JumpPadAirControl expands Info;

var vector AimSpot;		// where the pad aims
var float StallSpeed;	// speed toward the target below this is lost: steer
var float ReleaseSpeed;	// back up to this: let go
var bool bSteering;

// Called by the pad right after spawning, owned by the bot
function Init(vector InAimSpot, float LaunchSpeed, float FlightTime)
{
	AimSpot = InAimSpot;
	StallSpeed = FMax(20, 0.25*LaunchSpeed);
	ReleaseSpeed = FMax(2*StallSpeed, LaunchSpeed);
	LifeSpan = FlightTime + 0.5;
}

function Tick(float DeltaTime)
{
	local Pawn P;
	local vector Dir;
	local float Speed;

	P = Pawn(Owner);
	// landed, dead or gone: the flight is over
	if (P == None || P.bDeleteMe || P.Health <= 0 || P.Physics != PHYS_Falling)
	{
		Destroy();
		return;
	}
	Dir = AimSpot - P.Location;
	Dir.Z = 0;
	Dir = Normal(Dir);
	Speed = P.Velocity dot Dir;
	if (Speed < StallSpeed)
		bSteering = true;
	else if (bSteering && Speed >= ReleaseSpeed)
	{
		bSteering = false;
		P.Acceleration = vect(0,0,0);
	}
	// set every tick: FallingState zeroes it once mid-flight. The engine limits it to the
	// pawn's AirControl, the same as for a player holding forward
	if (bSteering)
		P.Acceleration = Dir*P.AccelRate;
}

defaultproperties
{
	bHidden=True
	RemoteRole=ROLE_None
}
