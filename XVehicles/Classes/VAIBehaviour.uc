// VAIBehaviour - Vehicle AI Behaviour, used by bot AI to tell them how to operate the vehicle and what to do in it.
Class VAIBehaviour extends Info;

var Vehicle VehicleOwner;

function bool HasFlag(Actor Other)
{
	return Pawn(Other) != None && Pawn(Other).PlayerReplicationInfo != None && Pawn(Other).PlayerReplicationInfo.HasFlag != None;
}

function bool InVehicle(Actor Other)
{
	return Pawn(Other) != None && DriverWeapon(Pawn(Other).Weapon) != None;
}

// Return the vehicle AI rating
function float GetVehAIRating( Pawn Seeker )
{
	local float ret;
	if (VehicleOwner.HealthTooLowFor(Seeker) || VehicleOwner.NeedStop(Seeker) || !VehicleOwner.CrewFit(Seeker))
		return -1;
	ret = VehicleOwner.AIRating*VehicleOwner.Health/VehicleOwner.Default.Health;
//	log("GetVehAIRating 1" @ ret @ VehicleOwner.AIRating);
	if (Seeker != None)	
	{
		if (HasFlag(Seeker))
		{
			if (VehicleOwner.DropFlag == VehicleOwner.EDropFlag.DF_All)
				return -1;
			if (VehicleOwner.DropFlag == VehicleOwner.EDropFlag.DF_Driver && VehicleOwner.Driver == None)
				return -1;
			ret *= 10;
		}
		else if (HasFlag(Seeker.Enemy) || HasFlag(Seeker.FaceTarget) ||
			InVehicle(Seeker.Enemy) || InVehicle(Seeker.FaceTarget))
			ret *= 10;
	}
//	log("GetVehAIRating 2" @ ret);
	return ret;
}

function vector GetNextMoveTarget()
{
	local int i, best;
	local float Dist, BestDist;
	Local vector V, HitLocation, HitNormal;
	local actor Visible[ArrayCount(VehicleOwner.Driver.RouteCache)];
	
	if( VehicleOwner.Driver.Target!=None && VehicleOwner.Driver.LineOfSightTo(VehicleOwner.Driver.Target) &&
		!VehicleOwner.Driver.IsInState('Fallback'))
	{
//		Log("Use driver Target" @ VehicleOwner.Driver.Target @ VehicleOwner.Driver.Target.getHumanName());
		Return VehicleOwner.Driver.Target.Location;
	}
	else if( VehicleOwner.Driver.MoveTarget!=None )
	{
		BestDist = -1;
		V.X = VehicleOwner.CollisionRadius;
		V.Y = VehicleOwner.CollisionRadius;
		V.Z = VehicleOwner.CollisionHeight;
		V.Z = 1;
		for (i = 0; i < ArrayCount(VehicleOwner.Driver.RouteCache); i++)
		{
			if (!VehicleOwner.Driver.LineOfSightTo(VehicleOwner.Driver.RouteCache[i]) || 
				VehicleOwner.Trace(HitLocation, HitNormal, VehicleOwner.Driver.RouteCache[i].Location, , true, V) != None)
				continue;
			Visible[i] = VehicleOwner.Driver.RouteCache[i];
			Dist = VSize(Visible[i].Location - VehicleOwner.Location);
			if (BestDist < 0 || dist < BestDist)
			{
				BestDist = dist;
				best = i;
			}				
		}		
		if (BestDist < 0)
		{
//			Log("Use driver MoveTarget" @ VehicleOwner.Driver.MoveTarget @ VehicleOwner.Driver.MoveTarget.getHumanName());
			Return VehicleOwner.Driver.MoveTarget.Location;
		}
			
//		v = Normal(VehicleOwner.Velocity);
		v = vector(VehicleOwner.Rotation);
			
		BestDist = V dot Normal(Visible[best].Location - Location);
		
		for (i = best + 1; i < ArrayCount(Visible); i++)
		{
			if (Visible[i] == None)
				continue;
			Dist = V dot Normal(Visible[i].Location - Location);
			if (dist > BestDist)
			{
				BestDist = dist;
				best = i;
			}				
		}
		
		if (i >= 14) // too old?
			VehicleOwner.Driver.MoveTimer = -1f; // time to refresh path
		
//		Log("Use driver RouteCache" @ best @ Visible[best] @ Visible[best].getHumanName());
		V = Visible[best].Location;
		if (FlagBase(Visible[best]) != None)
			V -= (Normal(VehicleOwner.ExitOffset)*(VehicleOwner.CollisionRadius + 10)) >> VehicleOwner.Rotation;
		return V;

			
		if (best + 1 < ArrayCount(VehicleOwner.Driver.RouteCache) && 
			VehicleOwner.Driver.LineOfSightTo(VehicleOwner.Driver.RouteCache[best + 1]))
			best++;
		
		if (best + 1 < ArrayCount(VehicleOwner.Driver.RouteCache) && 
			VehicleOwner.Driver.LineOfSightTo(VehicleOwner.Driver.RouteCache[best + 1]))
			best++;	
		
		//VehicleOwner.Driver.MoveTarget = VehicleOwner.Driver.RouteCache[best];
		return VehicleOwner.Driver.RouteCache[best].Location;
		/*
		if( VehicleOwner.Driver.RouteCache[2]!=None && VehicleOwner.Driver.LineOfSightTo(VehicleOwner.Driver.RouteCache[2]) )
			Return VehicleOwner.Driver.RouteCache[2].Location;
		else if( VehicleOwner.Driver.RouteCache[1]!=None && VehicleOwner.Driver.LineOfSightTo(VehicleOwner.Driver.RouteCache[1]) )
			Return VehicleOwner.Driver.RouteCache[1].Location;
		else if( VehicleOwner.Driver.RouteCache[0]!=None && VehicleOwner.Driver.LineOfSightTo(VehicleOwner.Driver.RouteCache[0]) )
			Return VehicleOwner.Driver.RouteCache[0].Location;
		*/
		Return VehicleOwner.Driver.MoveTarget.Location;
	}
//	Log("Use driver Destination" @ VehicleOwner.Driver.Destination);
	Return VehicleOwner.Driver.Destination;
}
function bool PawnCanDrive( Pawn Other )
{
	if (VehicleOwner.HealthTooLowFor(Other) || VehicleOwner.NeedStop(Other) || !VehicleOwner.CrewFit(Other))
		return false;
	if (Other.IsInState('Dying'))
		return false;
	Return Other.bIsPlayer;
}
function bool PawnCanPassenge( Pawn Other, byte SeatNumber )
{
	if (Other.IsInState('Dying'))
		return false;
	Return Other.bIsPlayer;
}

defaultproperties
{
      VehicleOwner=None
      RemoteRole=ROLE_None
}
