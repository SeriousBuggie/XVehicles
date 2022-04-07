// VAIBehaviour - Vehicle AI Behaviour, used by bot AI to tell them how to operate the vehicle and what to do in it.
Class VAIBehaviour extends Info;

var Vehicle VehicleOwner;
var Pawn TracePawn;

const AimError = 0.001;

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
//	log(VehicleOwner @ "GetVehAIRating1" @ Seeker);
	if (VehicleOwner.Driver == None && Level.TimeSeconds - VehicleOwner.LastFix <= 5 && 
		Seeker.PlayerReplicationInfo != None && Seeker.PlayerReplicationInfo.Team == VehicleOwner.CurrentTeam)
		return -1; // prevent take it if someone heal it
//	log(VehicleOwner @ "GetVehAIRating2" @ Seeker);
	if (VehicleOwner.LastDriver == Seeker && Level.TimeSeconds - VehicleOwner.LastDriverTime < 1)
		return -1; // for avoid bot loops exit/enter
//	log(VehicleOwner @ "GetVehAIRating3" @ Seeker);
	if (VehicleOwner.HealthTooLowFor(Seeker) || VehicleOwner.NeedStop(Seeker) || !VehicleOwner.CrewFit(Seeker))
		return -1;
//	log(VehicleOwner @ "GetVehAIRating4" @ Seeker);
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

function vector AdjustLocation(Actor NP)
{
	local vector ret, HL, HN, pos;
	local float offset;
	ret = NP.Location;	
	if (VehicleOwner.bCanFly && PathNode(NP) != None)
	{
		offset = VehicleOwner.CollisionHeight*6;
		pos = ret + offset*vect(0,0,1);
		if (NP.Trace(HL, HN, pos) != None)
		{
			offset = VSize(HL - ret) - VehicleOwner.CollisionHeight*1.5;
			if (offset > 0)
				ret += offset*vect(0,0,1);
		}
		else ret = pos;
	}
	return ret;
}

function bool CanReach(vector Point)
{
	local bool ret;
	if (VSize(Point - VehicleOwner.Driver.Location) < 800)
		return VehicleOwner.Driver.PointReachable(Point);
		
	if (TracePawn == None)
	{
		TracePawn = Spawn(class'HorseFly');
		if (TracePawn == None)
			return false;
		TracePawn.RemoteRole = ROLE_None;
		TracePawn.AmbientSound = None;
		TracePawn.DrawScale = 0.0001;
		TracePawn.SetCollisionSize(1, 1);
	}
	TracePawn.SetLocation(Point);
	return VehicleOwner.Driver.ActorReachable(TracePawn);
}

function vector GetNextMoveTarget()
{
	local int i, best;
	local float Dist, BestDist;
	Local vector V, S, T, HitLocation, HitNormal;
	local string dbg;
	local NavigationPoint Visible[ArrayCount(VehicleOwner.Driver.RouteCache)], NP;
	local vector Pos[ArrayCount(VehicleOwner.Driver.RouteCache)];
	
	if( VehicleOwner.Driver.Target!=None && VehicleOwner.Driver.LineOfSightTo(VehicleOwner.Driver.Target) &&
		!VehicleOwner.Driver.IsInState('Fallback'))
	{
//		Log("Use driver Target" @ VehicleOwner.Driver.Target @ VehicleOwner.Driver.Target.getHumanName());
		Return AdjustLocation(VehicleOwner.Driver.Target);
	}
	else if( VehicleOwner.Driver.MoveTarget!=None || 
		(VehicleOwner.Driver.RouteCache[0] != None && 
		Vsize(VehicleOwner.Driver.RouteCache[0].Location - VehicleOwner.Driver.Destination) < 10))
	{
		BestDist = -1;
		V.X = VehicleOwner.CollisionRadius;
		V.Y = VehicleOwner.CollisionRadius;
		V.Z = VehicleOwner.CollisionHeight - VehicleOwner.MaxObstclHeight/2;
		S = VehicleOwner.Location;
		S.Z += VehicleOwner.MaxObstclHeight/2;		
//		dbg = "";
		for (i = 0; i < ArrayCount(VehicleOwner.Driver.RouteCache); i++)
		{
			NP = VehicleOwner.Driver.RouteCache[i];
			if (NP == None)
				break;
			T = AdjustLocation(NP);
			Pos[i] = T;
			T.Z -= NP.CollisionHeight - VehicleOwner.CollisionHeight - VehicleOwner.MaxObstclHeight/2;
			if (//!VehicleOwner.Driver.LineOfSightTo(NP) || 
				VehicleOwner.Trace(HitLocation, HitNormal, T, S, true, V) != None)
			{				
//				if (i == 0) Log(i @ NP @ HitLocation @ HitNormal);
//				dbg = dbg @ "-";
				if (T.Z < S.Z && T.Z + VehicleOwner.CollisionHeight > S.Z && 
					VehicleOwner.Trace(HitLocation, HitNormal, T + vect(0,0,1)*(S.Z - T.Z), S, true, V) == None)
					; // skip it
				else				
					continue;
			}
			if (!CanReach(T))
				continue;
			Visible[i] = NP;
			Dist = VSize(T - VehicleOwner.Location);
			if (BestDist < 0 || dist < BestDist)
			{
				BestDist = dist;
				best = i;
//				dbg = dbg @ "X";
			}
//			else dbg = dbg @ "+";
		}
//		log(VehicleOwner.Driver @ 1 @ dbg);
		if (BestDist < 0)
		{
//			Log("Use driver MoveTarget" @ VehicleOwner.Driver.MoveTarget @ VehicleOwner.Driver.MoveTarget.getHumanName());
			if( VehicleOwner.Driver.MoveTarget == None)
			{
//				Log("Use driver Destination 2" @ VehicleOwner.Driver.Destination);
				VehicleOwner.Driver.MoveTimer = -1f; // time to refresh path
				return VehicleOwner.Driver.Destination;
			}
			if (VehicleOwner.Driver.RouteCache[0] != None && 
				Inventory(VehicleOwner.Driver.MoveTarget) != None)
				return Pos[0];
			Return AdjustLocation(VehicleOwner.Driver.MoveTarget);
		}
			
//		V = Normal(VehicleOwner.Velocity);
		V = vector(VehicleOwner.Rotation);
			
		BestDist = V dot Normal(Pos[best] - Location);
		
//		dbg = "";
		for (i = best + 1; i < ArrayCount(Visible); i++)
		{
			if (Visible[i] == None)
			{
				dbg = dbg @ ".";
				continue;
			}
			Dist = V dot Normal(Pos[i] - Location);
//			dbg = dbg @ "+";
			if (dist >= BestDist - AimError)
			{
				if (dist > BestDist)
					BestDist = dist;
				best = i;
//				dbg = dbg @ "!";
			}				
		}
//		log(VehicleOwner.Driver @ 2 @ dbg);
		
		if (i >= 14) // too old?
			VehicleOwner.Driver.MoveTimer = -1f; // time to refresh path
		
//		Log("Use driver RouteCache" @ best @ Visible[best] @ Visible[best].getHumanName());
		V = Pos[best];
		if (FlagBase(Visible[best]) != None)
			V -= (Normal(VehicleOwner.ExitOffset)*(VehicleOwner.CollisionRadius + 10 - Visible[best].CollisionRadius/2)) >> VehicleOwner.Rotation;
		return V;
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
      TracePawn=None
      RemoteRole=ROLE_None
}
