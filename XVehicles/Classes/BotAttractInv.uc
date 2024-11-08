// This actor is used to attract bots to these vehicles.
// They are automatly spawned by the vehicle, so these should NOT be placed in the maps with editor.
Class BotAttractInv extends Inventory;

var Vehicle VehicleOwner;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	VehicleOwner = Vehicle(Owner);
	VehicleOwner.InitInventory(self);
}

function BecomePickup();

auto state Pickup
{
Ignores Touch,ZoneChange;

Begin:
	Stop;
}

event float BotDesireability(Pawn Bot)
{
	if (VehicleOwner != None)
		return VehicleOwner.BotDesireability2(Bot);
	return -1;
}

defaultproperties
{
	bRotatingPickup=False
	MaxDesireability=10.000000
	bTrailerPrePivot=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_None
	DrawType=DT_Sprite
	Texture=None
	bGameRelevant=True
	CollisionRadius=17.000000
	CollisionHeight=24.000000
	bFixedRotationDir=False
	RotationRate=(Yaw=0)
	DesiredRotation=(Yaw=0)
}
