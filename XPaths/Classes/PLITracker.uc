//=============================================================================
// PLITracker.
//=============================================================================
class PLITracker expands Inventory;

var AlternatePath LastAlternatePath;

function BecomePickup();
function BecomeItem();
function inventory SpawnCopy( pawn Other );

auto state Pickup {
	singular function ZoneChange( ZoneInfo NewZone );
	function bool ValidTouch( actor Other );
	function Touch( actor Other );
	function Landed(Vector HitNormal);
	function CheckTouching();
	function Timer();
	function BeginState();
	function EndState() {
		GotoState('Pickup');
	}
Begin:
	if (Bot(Owner) == None)
		Destroy();
	Sleep(1);
	goto 'Begin';
}

event float BotDesireability(pawn InPawn)
{
	local Mutator XCTF;
	local Bot Bot;
	Bot = Bot(InPawn);
	if (Bot == Owner && Bot != None) {
		if (AlternatePathNode(Bot.MoveTarget) != None && Bot.MoveTarget == LastAlternatePath)
			AlternatePathNode(Bot.MoveTarget).CheckNext(Bot);
		XCTF = class'BotSpawnNotify'.default.XVehiclesCTF;
		if (XCTF != None && !Bot.IsInState('TacticalMove') && !Bot.IsInState('Hunting'))
			XCTF.KillCredit(self);
		LastAlternatePath = Bot.AlternatePath;
	}

	return -MaxDesireability;
}

defaultproperties
{
	bRotatingPickup=False
	MaxDesireability=4294967296.000000
	Physics=PHYS_Trailer
	RemoteRole=ROLE_None
	DrawType=DT_Sprite
	Texture=None
	bGameRelevant=True
	CollisionRadius=10.000000
	CollisionHeight=10.000000
	bFixedRotationDir=False
	RotationRate=(Pitch=0,Yaw=0)
	DesiredRotation=(Pitch=0,Yaw=0)
}
