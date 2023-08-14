//=============================================================================
// DiagonalDodgeSpot.
//=============================================================================
class DiagonalDodgeSpot expands JumpSpot;

var AmbushPoint AmbushSpot;
var bool AmbushSpot_Taken;

function PostBeginPlay()
{
	const DodgeDiagonal = 1.8; //Sqrt(1.5*1.5 + 1) - speed of diagonal dodge
	const R_Special_Dist = 500; // engine hardcode
	ExtraCost = (2*R_Special_Dist + ExtraCost)/DodgeDiagonal - 2*R_Special_Dist; // adjust for apply fast movement
	Super.PostBeginPlay();
}

event int SpecialCost(Pawn Seeker)
{
	local Bot B;
	
	if ( Seeker != None && Seeker.Weapon != None && Seeker.Weapon.IsA('DriverWeapon'))
		return 100000000;

	B = Bot(Seeker);
	if ( B == None )
		return 100000000;
		
	return ExtraCost;
}

/* SpecialHandling is called by the navigation code when the next path has been found.  
It gives that path an opportunity to modify the result based on any special considerations
*/
function Actor SpecialHandling(Pawn Other)
{
	local Bot B;

	if ( !Other.IsA('Bot') )
		return None;

	if ( (VSize(Location - Other.Location) < 200) 
		 && (Abs(Location.Z - Other.Location.Z) < Other.CollisionHeight) )
		return self;

	B = Bot(Other);

	PendingBot = B;
	GotoState('PendingJump');

	return self;
}

// don't do jumps right away because a state change here could be dangerous during navigation
State PendingJump
{
	function Actor SpecialHandling(Pawn Other)
	{
		if ( PendingBot != None )
		{
			PreserveAmbushSpot(PendingBot);
			PendingBot.BigJump(self);
			TryToDuck(Location - PendingBot.Location, FRand() < 0.5);
			PendingBot = None;
		}
		return Super(LiftCenter).SpecialHandling(Other);
	}

	function Tick(float DeltaTime)
	{
		if ( PendingBot != None )
		{
			PreserveAmbushSpot(PendingBot);
			PendingBot.BigJump(self);
			TryToDuck(Normal(Location - PendingBot.Location), FRand() < 0.5);
			PendingBot = None;
		}
		GotoState('');
	}
}

// copied from Bot with some changes
function TryToDuck(vector duckDir, bool bReversed)
{
	local bool bDuckLeft;
	
	duckDir.Z = 0;

	//PendingBot.SetFall(); // already call in BigJump
	PendingBot.Velocity = Normal(duckDir) * PendingBot.GroundSpeed * 
		Sqrt(1.5*1.5 + 1)* // speed of diagonal dodge
		(1 - FRand()*5/100); // not perfect jump each time
	PendingBot.Velocity.Z = 160;
	PendingBot.PlayDodge(!bReversed);
	PendingBot.PlaySound(PendingBot.JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
	//PendingBot.SetPhysics(PHYS_Falling); // already call in BigJump
	if ( (PendingBot.Weapon != None) && PendingBot.Weapon.bSplashDamage
		&& ((PendingBot.bFire != 0) || (PendingBot.bAltFire != 0)) && (PendingBot.Enemy != None)
		&& !PendingBot.FastTrace(PendingBot.Enemy.Location, Location)
		&& PendingBot.FastTrace(PendingBot.Enemy.Location, PendingBot.Location) )
	{
		PendingBot.bFire = 0;
		PendingBot.bAltFire = 0;
	}
	PendingBot.GotoState('FallingState','Ducking');
	RestoreAmbushSpot(PendingBot);
}

// EndState Roaming clear it, so we preserve it, for avoid pick another one
function PreserveAmbushSpot(Bot Bot) {
	if (Bot.IsInState('Roaming') && Bot.AmbushSpot != None) {
		AmbushSpot = Bot.AmbushSpot;
		AmbushSpot_Taken = AmbushSpot.taken;
	} else
		AmbushSpot = None;
}

function RestoreAmbushSpot(Bot Bot) {
	if (AmbushSpot != None) {
		Bot.AmbushSpot = AmbushSpot;
		AmbushSpot.taken = AmbushSpot_Taken;
	}
}

defaultproperties
{
}
