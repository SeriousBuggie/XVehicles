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
event float BotDesireability( pawn Bot )
{
	local vector L;
//	Log(VehicleOwner @ "BotDesireability 1" @ Bot.GetHumanName());
	if( VehicleOwner==None || VehicleOwner.bDeleteMe )
		Return -1;
//	Log(VehicleOwner @ "BotDesireability 2" @ Bot.GetHumanName() @ VehicleOwner.CurrentTeam @ VehicleOwner.CanEnter(Bot) @ 
//		VehicleOwner.IsTeamLockedFor(Bot) @ VehicleOwner.VehicleAI.PawnCanDrive(Bot) @ Bot.bIsPlayer);
	if( !VehicleOwner.CanEnter(Bot) || VehicleOwner.IsTeamLockedFor(Bot) || !VehicleOwner.VehicleAI.PawnCanDrive(Bot) )
		Return -1;
/*	if (!Bot.actorReachable(self))
	{
		L = Bot.Location - Location;
		L.z = 0;
		L = Normal(L)*(VehicleOwner.CollisionRadius + 10);
		Move(L);
		Log("Moved!" @ L);
	}*/
//	Log(VehicleOwner @ "BotDesireability 3" @ Bot.GetHumanName() @ VehicleOwner.VehicleAI.GetVehAIRating(Bot) @ Bot.actorReachable(self));
	Return VehicleOwner.VehicleAI.GetVehAIRating(Bot);
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
	RotationRate=(Pitch=0,Yaw=0)
	DesiredRotation=(Pitch=0,Yaw=0)
}
