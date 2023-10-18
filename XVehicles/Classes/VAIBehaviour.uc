// VAIBehaviour - Vehicle AI Behaviour, used by bot AI to tell them how to operate the vehicle and what to do in it.
Class VAIBehaviour extends Info;

var Vehicle VehicleOwner;
var Pawn TracePawn;

var float AirFlyScale;

const AimError = 0.001;
const bDebug = false;

static function bool HasFlag(Actor Other)
{
	return Pawn(Other) != None && Pawn(Other).PlayerReplicationInfo != None && Pawn(Other).PlayerReplicationInfo.HasFlag != None;
}

static function bool InVehicle(Actor Other)
{
	return Pawn(Other) != None && DriverWeapon(Pawn(Other).Weapon) != None;
}

// Return the vehicle AI rating
function float GetVehAIRating( Pawn Seeker )
{
	local float ret;
	local bool bLockedAndLoaded;
//	log(VehicleOwner @ "GetVehAIRating1" @ Seeker);
	if (VehicleOwner.Driver == None && Level.TimeSeconds - VehicleOwner.LastFix <= 5 && 
		Seeker.PlayerReplicationInfo != None && Seeker.PlayerReplicationInfo.Team == VehicleOwner.CurrentTeam &&
		Seeker.PlayerReplicationInfo.HasFlag == None)
		return -1; // prevent take it if someone heal it
//	log(VehicleOwner @ "GetVehAIRating2" @ Seeker @ VehicleOwner.LastDriver @ Level.TimeSeconds - VehicleOwner.LastDriverTime);
	if (VehicleOwner.LastDriver == Seeker && Level.TimeSeconds - VehicleOwner.LastDriverTime < 1)
		return -1; // for avoid bot loops exit/enter
//	log(VehicleOwner @ "GetVehAIRating3" @ Seeker);
	if (VehicleOwner.HealthTooLowFor(Seeker) || VehicleOwner.NeedStop(Seeker) || !VehicleOwner.CrewFit(Seeker))
		return -1;
	if (VehicleOwner.Driver != None && !VehicleOwner.HasFreePassengerSeat())
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
			ret *= 100;
		}
		else 
		{
			// stop use second seat, if this take gun from non-human driver
			if (VehicleOwner.DriverGun == None &&
				VehicleOwner.Driver != None && PlayerPawn(VehicleOwner.Driver) == None)
				return 0.0001;
			if (HasFlag(Seeker.Enemy) || HasFlag(Seeker.FaceTarget) ||
				InVehicle(Seeker.Enemy) || InVehicle(Seeker.FaceTarget))
				ret *= 10;
			bLockedAndLoaded = ((Seeker.Weapon != None) && (Seeker.Weapon.AIRating > 0.4) && (Seeker.Health > 60));
			if (bLockedAndLoaded)
				ret *= 10;
		}
		ret *= VehicleOwner.GetVehAIRatingScale(Seeker);
	}
//	log("GetVehAIRating 2" @ ret);
	return ret;
}

function vector AdjustLocation(Actor NP, optional bool bInMid)
{
	local vector ret, HL, HN, pos, V;
	local float offset, k;
	ret = NP.Location;	
	if (VehicleOwner.bCanFly && NavigationPoint(NP) != None && 
		!NP.FastTrace(NP.Location - vect(0,0,1)*2*VehicleOwner.CollisionHeight) &&
		(VSize(NP.Location - VehicleOwner.Location) > 2*AirFlyScale*VehicleOwner.CollisionRadius || 
		bInMid || PathNode(NP) != None || InventorySpot(NP) != None || PlayerStart(NP) != None || 
		Spawnpoint(NP) != None || NP.Class.Name == 'NavigationPoint' || NP.isA('AirPath')))
	{
		offset = VehicleOwner.CollisionHeight*(AirFlyScale + 1);
		pos = ret + offset*vect(0,0,1);
		V.X = VehicleOwner.CollisionRadius;
		V.Y = VehicleOwner.CollisionRadius;
		V.Z = 1;
		if (VehicleOwner.Trace(HL, HN, pos, NP.Location, true, V) != None)
		{
			if (HoverCraftPhys(VehicleOwner) != None)
				k = 1;
			else
				k = 2;
			offset = VSize(HL - ret) - VehicleOwner.CollisionHeight*k;
			if (offset > 0)
				ret += offset*vect(0,0,1);
		}
		else ret = pos - VehicleOwner.CollisionHeight*vect(0,0,1);
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
	local float Z, Dist, BestDist, Closest, HeightDiff;
	Local vector V, S, T, T2, NextT, HitLocation, HitNormal;
	local string dbg;
	local NavigationPoint Visible[ArrayCount(VehicleOwner.Driver.RouteCache)], NP;
	local vector Pos[ArrayCount(VehicleOwner.Driver.RouteCache)];
	local bool bHasNext;
	
	local vector D;
	local rotator Dir;
	local bool bMovePawn, bFlagBase, bJumpPad;
	local Actor Hit;
	
	if (VehicleOwner.Driver.Target != None && Vehicle(VehicleOwner.Driver.Target) == None &&
		(Pawn(VehicleOwner.Driver.Target) == None || !VehicleOwner.Driver.Target.IsInState('Dying')) &&
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
				T = NP.location;
			Pos[i] = T;
			T.Z -= NP.CollisionHeight - HeightDiff;
			NextT = T;
			bHasNext = true;
			
			if (!VehicleOwner.bCanFly)
			{
				T2 = T - VehicleOwner.Location;
				T2.Z -= VehicleOwner.MaxObstclHeight/2;
				T2 = Normal(T2);
				if (Abs(T2.Z) > 0.71)
					continue;
				Z = Abs(T2.Z);	
				T2.Z = 0;
				Z = Z*VehicleOwner.CollisionRadius/VSize(T2);
			}
			T2 = T;
			if (!VehicleOwner.bCanFly)
				T2.Z += Z;
			
			Hit = VehicleOwner.Trace(HitLocation, HitNormal, T2, S, true, V);
			if (Hit != None && VSize(HitLocation - T2) >= VehicleOwner.CollisionRadius)
			{
				if (bDebug) Log(i @ "!Trace" @ VehicleOwner.CollisionRadius @ VSize(HitLocation - T2) @ T @ NP @ Hit);
//				if (i == 0) Log(i @ NP @ HitLocation @ HitNormal);
//				dbg = dbg @ "-";
				if (T2.Z < S.Z && T2.Z + VehicleOwner.CollisionHeight > S.Z && 
					(VehicleOwner.Trace(HitLocation, HitNormal, T2 + vect(0,0,1)*(S.Z - T2.Z), S, true, V) == None ||
					VSize(HitLocation - T2) < VehicleOwner.CollisionRadius))
					; // skip it
				else
				{
					if (bDebug) Log(i @ "!Trace2" @ VSize(HitLocation - T2) @ T2 @ NP);
					continue;
				}
			}

			if (false && !bMovePawn)
			{
				bMovePawn = true;
				if (!VehicleOwner.bCanFly && VehicleOwner.bOnGround && 
					VehicleOwner.ActualFloorNormal.Z < 0.999)
				{
					D.X = VehicleOwner.CollisionRadius - VehicleOwner.Driver.Default.CollisionRadius - 10;
					Dir.Yaw = rotator(VehicleOwner.ActualFloorNormal).Yaw + 32768;
					D = D >> Dir;
//					log("MovePawn:" @ D);
					//VehicleOwner.Driver.Move(D);
					//VehicleOwner.Driver.Move(vect(0,0,20));
				}
			}
			
			T2 = T;
			T2.Z -= VehicleOwner.CollisionHeight - VehicleOwner.Driver.Default.CollisionHeight;
			if (!CanReach(T2) && 
				!CanReach(T2 - vect(0,0,0.25)*NP.CollisionHeight) && 
				!CanReach(T2 - vect(0,0,0.5)*NP.CollisionHeight))
			{
				if (bDebug)
				{
					Hit = Spawn(class'Flag1',,, T2);
					Hit.LifeSpan = 1;
					Hit.Style = STY_Translucent;
					Log(Level.TimeSeconds @ i @ "!CanReach" @ T @ NP @ T - NP.Location @ 
						VehicleOwner.CollisionHeight - VehicleOwner.Driver.Default.CollisionHeight @
						VehicleOwner.Driver.pointReachable(NP.Location) @ VehicleOwner.Driver.Location);
				}
				continue;
			}
			if (bDebug) Log(i @ "Visible" @ T @ NP);
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
		if (bDebug) log(VehicleOwner.Driver @ 1 @ dbg);
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
			
		BestDist = Abs(V dot Normal(Pos[best] - VehicleOwner.Driver.Location));
		
//		dbg = "";
		for (i = best + 1; i < ArrayCount(Visible); i++)
		{
			if (Visible[i] == None)
			{
				dbg = dbg @ ".";
				continue;
			}
			Dist = Abs(V dot Normal(Pos[i] - VehicleOwner.Driver.Location));
			if (VehicleOwner.bCanFly)
				Dist = i + 10; // Dist before always be in range [0; 1]
//			dbg = dbg @ "+";
			if (dist >= BestDist - AimError)
			{
				if (dist > BestDist)
					BestDist = dist;
				best = i;
//				dbg = dbg @ "!";
			}				
		}
		if (bDebug) log(VehicleOwner.Driver @ 2 @ dbg);
		
		if (i >= 14) // too old?
			VehicleOwner.Driver.MoveTimer = -1f; // time to refresh path
		else if (VehicleOwner.bCanFly && Closest >= 400f)
			VehicleOwner.Driver.MoveTimer = 1f; // prevent refresh path in air
//		Log("Use driver RouteCache" @ best @ Visible[best] @ Visible[best].getHumanName() @ VSize(Pos[best] - VehicleOwner.Location) @ VSize(Visible[best].Location - VehicleOwner.Location) @ VehicleOwner.CollisionRadius);
		if (best + 1 < ArrayCount(Visible) && Visible[best + 1] != None)
		{
			T = Pos[best] - Pos[best + 1];
			if ((T dot (Pos[best] - VehicleOwner.Driver.Location))*
				(T dot (Pos[best + 1] - VehicleOwner.Driver.Location)) < 0)
				best++; // prevent stuck between points
		}
		V = Pos[best];
		if (best == 0 && VehicleOwner.Driver.RouteCache[1] != None &&
			VSize(V - VehicleOwner.Location) < VehicleOwner.CollisionRadius)
			V = Pos[1]; // prevent stuck at pos 0
		if (VSize(V - VehicleOwner.Location) < 100 && Vsize(V - Visible[best].Location) > 100)
			V = Visible[best].Location;
		bFlagBase = FlagBase(Visible[best]) != None;
		if (!bFlagBase)
			bJumpPad = best + 1 < ArrayCount(VehicleOwner.Driver.RouteCache) && 
				UTJumpPad(Visible[best]) != None &&
				UTJumpPad(VehicleOwner.Driver.RouteCache[best + 1]) != None && 
				string(VehicleOwner.Driver.RouteCache[best + 1].Tag) ~= UTJumpPad(Visible[best]).URL;
		if (bFlagBase || bJumpPad)
		{
			S = (Normal(VehicleOwner.ExitOffset)*(VehicleOwner.CollisionRadius + 10 + Visible[best].CollisionRadius/2)) >> VehicleOwner.Rotation;
			V -= S;
			if (bFlagBase)
				Bot(VehicleOwner.Driver).AlternatePath = None; // hack for prevent bot run to it
		}
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
