// VAIBehaviour - Vehicle AI Behaviour, used by bot AI to tell them how to operate the vehicle and what to do in it.
Class VAIBehaviour extends Info;

var Vehicle VehicleOwner;
var Pawn TracePawn;

var float AirFlyScale;

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

function vector AdjustLocation(Actor NP, optional bool bInMid)
{
	local vector ret, HL, HN, pos;
	local float offset;
	ret = NP.Location;	
	if (VehicleOwner.bCanFly && NavigationPoint(NP) != None && 
		!NP.FastTrace(NP.Location - vect(0,0,1)*2*VehicleOwner.Collisionheight) &&
		(bInMid || PathNode(NP) != None || NP.isA('AirPath')))
	{
		offset = VehicleOwner.CollisionHeight*AirFlyScale;
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
	local float Dist, BestDist, Closest, HeightDiff;
	Local vector V, S, T, NextT, HitLocation, HitNormal;
	local string dbg;
	local NavigationPoint Visible[ArrayCount(VehicleOwner.Driver.RouteCache)], NP;
	local vector Pos[ArrayCount(VehicleOwner.Driver.RouteCache)];
	local bool bHasNext;
	
	if (VehicleOwner.Driver.Target != None && Vehicle(VehicleOwner.Driver.Target) == None &&
		!VehicleOwner.Driver.IsInState('Fallback') && !VehicleOwner.Driver.IsInState('RangedAttack') && 
		VehicleOwner.Driver.LineOfSightTo(VehicleOwner.Driver.Target) &&
		(VehicleOwner.bCanFly || CanReach(VehicleOwner.Driver.Target.Location)))
	{
		return AdjustLocation(VehicleOwner.Driver.Target);
	}
	else if (VehicleOwner.Driver.MoveTarget != None || 
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
		HeightDiff = VehicleOwner.CollisionHeight + VehicleOwner.MaxObstclHeight/2;
		for (i = ArrayCount(VehicleOwner.Driver.RouteCache) - 1; i >= 0; i--)
		{
			NP = VehicleOwner.Driver.RouteCache[i];
			if (NP == None)
				continue;
			T = AdjustLocation(NP, i == ArrayCount(VehicleOwner.Driver.RouteCache) - 1 || 
				VehicleOwner.Driver.RouteCache[i + 1] != None);
			if (T != NP.Location && (
				(bHasNext && !VehicleOwner.FastTrace(NextT, T)) ||
				(!bHasNext && i == 0)
				))
				//VehicleOwner.Trace(HitLocation, HitNormal, NextT, T - vect(0,0,1)*(NP.CollisionHeight - HeightDiff), true) != None)
				T = NP.Location;
			Pos[i] = T;
			T.Z -= NP.CollisionHeight - HeightDiff;
			NextT = T;
			bHasNext = true;
			if (//!VehicleOwner.Driver.LineOfSightTo(NP) || 
				VehicleOwner.Trace(HitLocation, HitNormal, T, S, true, V) != None)
			{
//				Log(i @ "!Trace" @ T @ NP);
//				if (i == 0) Log(i @ NP @ HitLocation @ HitNormal);
//				dbg = dbg @ "-";
				if (T.Z < S.Z && T.Z + VehicleOwner.CollisionHeight > S.Z && 
					VehicleOwner.Trace(HitLocation, HitNormal, T + vect(0,0,1)*(S.Z - T.Z), S, true, V) == None)
					; // skip it
				else
				{
//					Log(i @ "!Trace2" @ T @ NP);
					continue;
				}
			}
			if (!CanReach(T))
			{
//				Log(i @ "!CanReach" @ T @ NP);
				continue;
			}
//			Log(i @ "Visible" @ T @ NP);
			Visible[i] = NP;
			Dist = VSize(T - VehicleOwner.Driver.Location);
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
			return AdjustLocation(VehicleOwner.Driver.MoveTarget);
		}
		Closest = BestDist;
			
//		V = Normal(VehicleOwner.Velocity);
		V = vector(VehicleOwner.Rotation);
			
		BestDist = V dot Normal(Pos[best] - VehicleOwner.Driver.Location);
		
//		dbg = "";
		for (i = best + 1; i < ArrayCount(Visible); i++)
		{
			if (Visible[i] == None)
			{
				dbg = dbg @ ".";
				continue;
			}
			Dist = V dot Normal(Pos[i] - VehicleOwner.Driver.Location);
			if (VehicleOwner.bCanFly)
				Dist = i + 10;
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
		else if (VehicleOwner.bCanFly && Closest >= 400f)
			VehicleOwner.Driver.MoveTimer = 1f; // prevent refresh path in air
//		Log("Use driver RouteCache" @ best @ Visible[best] @ Visible[best].getHumanName());
		V = Pos[best];
		if (VSize(V - Location) < 100 && Vsize(V - Visible[best].Location) > 100)
			V = Visible[best].Location;
		if (FlagBase(Visible[best]) != None)
			V -= (Normal(VehicleOwner.ExitOffset)*(VehicleOwner.CollisionRadius + 10 - Visible[best].CollisionRadius/2)) >> VehicleOwner.Rotation;
		return V;
	}
//	Log("Use driver Destination" @ VehicleOwner.Driver.Destination @ VSize(VehicleOwner.Driver.Destination - VehicleOwner.Location) @ VSize(VehicleOwner.Driver.Destination - VehicleOwner.Driver.Location));
//	if (CanReach(VehicleOwner.Driver.Destination)
	if (VehicleOwner.Driver.IsInState('Wandering') && FixBot(Bot(VehicleOwner.Driver)))
		return AdjustLocation(VehicleOwner.Driver.MoveTarget);
	return VehicleOwner.Driver.Destination;	
}
function bool PawnCanDrive( Pawn Other )
{
	if (VehicleOwner.HealthTooLowFor(Other) || VehicleOwner.NeedStop(Other) || !VehicleOwner.CrewFit(Other))
		return false;
	if (Other.IsInState('Dying'))
		return false;
	if (PlayerPawn(Other) == None && HasFlag(Other) && VehicleOwner.DropFlag != VehicleOwner.EDropFlag.DF_None)
		return false;
	Return Other.bIsPlayer;
}
function bool PawnCanPassenge( Pawn Other, byte SeatNumber )
{
	if (Other.IsInState('Dying'))
		return false;
	if (PlayerPawn(Other) == None && HasFlag(Other) && VehicleOwner.DropFlag == VehicleOwner.EDropFlag.DF_All)
		return false;
	Return Other.bIsPlayer;
}

function bool FixBot(Bot Bot) {
	local int s, i;
	local NavigationPoint NP, Best;
	local float Dist, BestDist;

	if (Bot != None && Bot.IsInState('wandering')) {
		for (i = 0; i < ArrayCount(Bot.RouteCache) && Bot.RouteCache[i] != None; i++)
			if (VSize(Bot.RouteCache[i].Location - Bot.Location) < 800 && 
				Bot.actorReachable(Bot.RouteCache[i]))
				return false;
		foreach Bot.RadiusActors(class'NavigationPoint', NP, 800)
			if (Bot.actorReachable(NP))
				return false;
		foreach AllActors(class'NavigationPoint', NP) {
			Dist = Vsize(NP.Location - Bot.Location);
			if (Best != None && Dist > BestDist)
				continue;
			if (Dist < 800) {
				continue; // already check before
			} else {
/*				if (Scout == None)
					Scout = NP.Spawn(class'Scout');
				else
					scout.SetLocation(NP.Location);
				bCheck = Bot.actorReachable(scout);
*/
			}
			if (Best == None || Dist < BestDist) {
				BestDist = Dist;
				Best = NP;
			}
		}
		if (Best != None) {
//			log(Bot @ Bot.GetHumanName() @ "Sended to" @ Best @ BestDist);
			Bot.SpecialPause = 0;
			Bot.MoveTarget = Best;
			Bot.GotoState('Roaming', 'SpecialNavig');
			return true;
		} else {
//			log(Bot @ Bot.GetHumanName() @ "Failed send");
		}
	}
	return false;
}

defaultproperties
{
	AirFlyScale=6.000000
	RemoteRole=ROLE_None
}
