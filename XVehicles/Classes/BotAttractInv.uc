// This actor is used to attract bots to these vehicles.
// They are automatly spawned by the vehicle, so these should NOT be placed in the maps with editor.
Class BotAttractInv extends Inventory;

var Vehicle VehicleOwner;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	VehicleOwner = Vehicle(Owner);
	MaxDesireability = VehicleOwner.AIRating*100;
	setCollisionSize(VehicleOwner.CollisionRadius + 10, CollisionHeight);
	PrePivot.Z = CollisionHeight - VehicleOwner.CollisionHeight;
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
//	Log(self @ "BotDesireability 1" @ Bot.GetHumanName() @ VehicleOwner);
	if( VehicleOwner==None || VehicleOwner.bDeleteMe )
		Return -1;
//	Log(self @ "BotDesireability 2" @ Bot.GetHumanName() @ VehicleOwner.CurrentTeam @ VehicleOwner.CanEnter(Bot) @ 
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
//	Log(self @ "BotDesireability 3" @ Bot.GetHumanName() @ VehicleOwner.VehicleAI.GetVehAIRating(Bot) @ Bot.actorReachable(self));
	Return VehicleOwner.VehicleAI.GetVehAIRating(Bot);
}

defaultproperties
{
      VehicleOwner=None
      MaxDesireability=10.000000
      bTrailerPrePivot=True
      Physics=PHYS_Trailer
      RemoteRole=ROLE_None
      DrawType=DT_None
      bGameRelevant=True
      CollisionHeight=35.000000
}
