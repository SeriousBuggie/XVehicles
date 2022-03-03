// VAIBehaviour - Vehicle AI Behaviour, used by bot AI to tell them how to operate the vehicle and what to do in it.
Class VAIBehaviour extends Info;

var Vehicle VehicleOwner;

// Return the vehicle AI rating
function float GetVehAIRating( Pawn Seeker )
{
	Return VehicleOwner.AIRating*(VehicleOwner.Health/VehicleOwner.Default.Health);
}

function vector GetNextMoveTarget()
{
	if( VehicleOwner.Driver.Target!=None )
		Return VehicleOwner.Driver.Target.Location;
	else if( VehicleOwner.Driver.MoveTarget!=None )
	{
		if( VehicleOwner.Driver.RouteCache[1]!=None && VehicleOwner.Driver.LineOfSightTo(VehicleOwner.Driver.RouteCache[1]) )
			Return VehicleOwner.Driver.RouteCache[1].Location;
		else if( VehicleOwner.Driver.RouteCache[0]!=None && VehicleOwner.Driver.LineOfSightTo(VehicleOwner.Driver.RouteCache[0]) )
			Return VehicleOwner.Driver.RouteCache[0].Location;
		Return VehicleOwner.Driver.MoveTarget.Location;
	}
	Return VehicleOwner.Driver.Destination;
}
function bool PawnCanDrive( Pawn Other )
{
	Return Other.bIsPlayer;
}
function bool PawnCanPassenge( Pawn Other, byte SeatNumber )
{
	Return Other.bIsPlayer;
}

defaultproperties
{
      VehicleOwner=None
      RemoteRole=ROLE_None
}
