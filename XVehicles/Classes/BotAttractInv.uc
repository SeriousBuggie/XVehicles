// This actor is used to attract bots to these vehicles.
// They are automatly spawned by the vehicle, so these should NOT be placed in the maps with editor.
Class BotAttractInv extends Inventory;

var Vehicle VehicleOwner;

function BecomePickup();
auto state Pickup
{
Ignores Touch,ZoneChange;

Begin:
	Stop;
}
event float BotDesireability( pawn Bot )
{
	if( VehicleOwner==None || VehicleOwner.bDeleteMe )
		Return -1;
	if( !VehicleOwner.CanEnter(Bot) || VehicleOwner.IsTeamLockedFor(Bot) || !VehicleOwner.VehicleAI.PawnCanDrive(Bot) )
		Return -1;
	Return VehicleOwner.VehicleAI.GetVehAIRating(Bot);
}

defaultproperties
{
      VehicleOwner=None
      Physics=PHYS_Trailer
      RemoteRole=ROLE_None
      DrawType=DT_None
      CollisionHeight=35.000000
}
