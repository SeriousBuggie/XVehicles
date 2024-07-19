//=============================================================================
// DoubleJumpSpot.
//=============================================================================
class DoubleJumpSpot expands Teleporter;

var int Allowed;

var AmbushPoint AmbushSpot;
var bool AmbushSpot_Taken;

function PreBeginPlay()
{
	default.Allowed = 0;
	Super.PreBeginPlay();
}

event int SpecialCost(Pawn Seeker)
{
	if (Url == "")
		return ExtraCost;

	if (Seeker != None && Seeker.Weapon != None && Seeker.Weapon.IsA('DriverWeapon'))
		return 100000;
	
	if (default.Allowed == 0 || Allowed != 0)
		check();
		
	return ExtraCost;
}

function check() {
	local Mutator M;
	local Inventory Inv;
	local string str;
	
	if (default.Allowed == 0) { // try detect it
		default.Allowed = -1; // not found		

		foreach AllActors(class'Mutator', M) {
			str = Caps(string(M.Class.Name));
			if (InStr(str, "DOUBLEJUMP") != -1)
				break;
			if (InStr(str, "UTPURE") != -1 && M.GetPropertyText("bDoubleJump") ~= "True")
				break;
		}
		if (M != None)
			default.Allowed = 1;
		else {
			foreach AllActors(class'Inventory', Inv) {
				str = Caps(string(Inv.Class.Name));
				if (InStr(str, "DOUBLEJUMP") != -1 || InStr(str, "DJ_INVENTORY") != -1)
					break;
			}
			if (Inv != None)
				default.Allowed = 2;
			else {
				str = Caps(Level.ConsoleCommand("OBJ CLASSES"));
				if (InStr(str, "DJ_INVENTORY") != -1 || 
					InStr(str, "DOUBLEJUMPBOOTS") != -1 || 
					InStr(str, "DOUBLEJUMPITEM") != -1)
					default.Allowed = 3;
			}
		}
		Log("Try detect DoubleJump:" @ default.Allowed, Class.Name);
	}
	fix();
}

function fix()
{
	local DoubleJumpSpot NP;
	local int i, j, flags, dist;
	local Actor Start, End;
	const R_SPECIAL = 32;
	
	foreach AllActors(class'DoubleJumpSpot', NP) {
		NP.Allowed = 0;
		if (default.Allowed < 0)
		{
			NP.SetCollision(false, false, false);
			NP.Disable('Touch');
			for (i = 0; i < ArrayCount(NP.upstreamPaths); i++)
				if (NP.upstreamPaths[i] == -1)
					break;
				else {
					NP.describeSpec(NP.upstreamPaths[i], Start, End, flags, dist);
					if (flags == R_SPECIAL && DoubleJumpSpot(Start) != None && DoubleJumpSpot(End) != None)
					{
						for (j = i-- + 1; j < ArrayCount(NP.upstreamPaths); j++)
							NP.upstreamPaths[j - 1] = NP.upstreamPaths[j];
						NP.upstreamPaths[j - 1] = -1;
					}
				}
			for (i = 0; i < ArrayCount(NP.Paths); i++)
				if (NP.Paths[i] == -1)
					break;
				else {
					NP.describeSpec(NP.Paths[i], Start, End, flags, dist);
					if (flags == R_SPECIAL && DoubleJumpSpot(Start) != None && DoubleJumpSpot(End) != None)
					{
						for (j = i-- + 1; j < ArrayCount(NP.Paths); j++)
							NP.Paths[j - 1] = NP.Paths[j];
						NP.Paths[j - 1] = -1;
					}
				}
			for (i = 0; i < ArrayCount(NP.PrunedPaths); i++)
				if (NP.PrunedPaths[i] == -1)
					break;
				else {
					NP.describeSpec(NP.PrunedPaths[i], Start, End, flags, dist);
					if (flags == R_SPECIAL && DoubleJumpSpot(Start) != None && DoubleJumpSpot(End) != None)
					{
						for (j = i-- + 1; j < ArrayCount(NP.PrunedPaths); j++)
							NP.PrunedPaths[j - 1] = NP.PrunedPaths[j];
						NP.PrunedPaths[j - 1] = -1;
					}
				}
			}
	}
}

simulated function bool Accept( actor Incoming, Actor Source )
{
	return false;
}

simulated function Touch( actor Other )
{
	local Bot B;

	B = Bot(Other);
	if (B == None || B.MoveTarget != self || URL == "")
		return;
		
	PendingTouch = Other.PendingTouch;
	Other.PendingTouch = self;
}

simulated function PostTouch( Actor Other )
{
	local DoubleJumpSpot Dest;
	local Bot B;
	local int i;	
	
	B = Bot(Other);
	if (B == None || B.MoveTarget != self || URL == "")
		return;
		
	foreach AllActors(class'XPaths.DoubleJumpSpot', Dest)
		if (string(Dest.tag) ~= URL && Dest != Self)
			break;
		
	if (Dest == None)
		return;
		
	for (i = ArrayCount(B.RouteCache) - 1; i >= 0; i--)
		if (B.RouteCache[i] == Dest)
			break;

	if (i < 0 || (i > 0 && B.RouteCache[i - 1] != self) || 
		(i < ArrayCount(B.RouteCache) - 1 && B.RouteCache[i + 1] == self))
		return;
		
	PreserveAmbushSpot(B);
	B.bJumpOffPawn = true;
	B.SetFall();
	B.SetPhysics(PHYS_Falling);
		
	B.Focus = Dest.Location;
	B.MoveTarget = Dest;
	B.MoveTimer = VSize(Dest.Location - B.Location)/B.GroundSpeed;
	B.Destination = Dest.Location;
	
    B.Velocity = Dest.Location - B.Location;
    B.Velocity.Z = 0;
    B.Velocity = Normal(B.Velocity);
    B.Acceleration = B.Velocity*B.AccelRate; 
    B.Velocity *= B.GroundSpeed;
    B.Velocity.Z = 210*2.7;
    B.bBigJump = true;
    
	//B.DesiredRotation = rotator(Dest.Location - Location);
	B.PlaySound(B.JumpSound, SLOT_Talk, 1.0, true, 800, 1.0);
	B.MakeNoise(1.0);

	if ( (B.Weapon != None) && B.Weapon.bSplashDamage
		&& ((B.bFire != 0) || (B.bAltFire != 0)) && (B.Enemy != None)
		&& !B.FastTrace(B.Enemy.Location, Location)
		&& B.FastTrace(B.Enemy.Location, B.Location) )
	{
		B.bFire = 0;
		B.bAltFire = 0;
	}
	RestoreAmbushSpot(B);
}

function Actor SpecialHandling(Pawn Other)
{
	local DoubleJumpSpot DJS;
	local vector Dist2D;
	foreach Other.RadiusActors(class'XPaths.DoubleJumpSpot', DJS, Other.CollisionRadius)
		if (DJS != self && DJS.URL != "" && string(Tag) ~= DJS.URL && 
			Abs(DJS.Location.Z - Other.Location.Z) < DJS.CollisionHeight + Other.CollisionHeight)
		{
			Dist2D = DJS.Location - Other.Location;
			Dist2D.Z = 0;
			if (VSize(Dist2D) < DJS.CollisionRadius + Other.CollisionRadius)
			{
				DJS.Touch(Other);
				return DJS;
			}
		}
	return self;
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
	bSpecialCost=True
	RemoteRole=ROLE_None
}
