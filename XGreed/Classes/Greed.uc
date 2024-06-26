//=============================================================================
// Greed.
//
// Use PlayerReplicationInfo.Target as cache for current GreedReplicationInfo
// Possible this hackish approach make it incompatible with other mods?
//=============================================================================
class Greed expands CTFGame;

var Pawn LastDamageDriver;
var float LastDamageTime;
var string LastDamageInfo;
var Actor LastDamageVehicle;

var Actor TempVehicle;
var class<Inventory> BotAttractInvClass;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	spawn(class'CTFFlagSpawnNotify'); // Disable flags
	spawn(class'GreedHUD');
	
	SetPropertyText("BotAttractInvClass", "Class'XVehicles.BotAttractInv'");
}

event InitGame( string Options, out string Error )
{
	Super.InitGame(Options, Error);
	
	GoalTeamScore = GetIntOption(Options, "GoalTeamScore", GoalTeamScore);
}

function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	Damage = Super.ReduceDamage(Damage, DamageType, injured, instigatedBy);
	if (Damage > 0 && injured != None && injured.Weapon != None && 
		injured.Weapon.isA('DriverWeapon'))
	{
		LastDamageDriver = injured;
		LastDamageTime = Level.TimeSeconds;
		LastDamageInfo = instigatedBy @ injured @ DamageType;
		SetPropertyText("LastDamageVehicle", injured.Weapon.GetPropertyText("VehicleOwner"));
	}
	return Damage;
}

function Killed( pawn Killer, pawn Other, name damageType )
{
	local Skull Skull;
	local int FirstHealth, Bonus;

	if (Other.bIsPlayer)
	{
		if (Killer != None && Killer != Other)
		{
			if (LastDamageTime == Level.TimeSeconds &&
				LastDamageDriver == Other &&
				LastDamageInfo == (Killer @ Other @ DamageType))
			{
				Bonus = 2;
				if (LastDamageVehicle != None)
				{
					if (LastDamageVehicle.isA('StationaryPhys') || 
						int(LastDamageVehicle.GetPropertyText("Health")) > 0)
						Bonus = 0;
					else
					{
						FirstHealth = int(LastDamageVehicle.GetPropertyText("FirstHealth"));
						if (FirstHealth >= 1800)
							Bonus = 10;
						else if (FirstHealth >= 1300)
							Bonus = 6;
					}
				}
			}
			Bonus++;
		}
		// Positive pawn health make them drop/collect skulls in the loop
		// So force Other to be really dead.
		Other.Health = Min(0, Other.Health);
		
		Skull = Skull(Other.FindInventoryType(Class'Skull'));
		if (Skull == None && Bonus > 0)
			Skull = Other.Spawn(Class'Skull');
		if (Skull != None)
		{
			if (Skull.Amount >= 5 && Other.PlayerReplicationInfo != None && 
				VSize(CTFReplicationInfo(GameReplicationInfo).FlagList[1 - Other.PlayerReplicationInfo.Team].HomeBase.Location - 
				Other.Location) < 1000)
				AllClientsPlaySound(Sound'XGreed.Denied');
				
			Skull.Amount += Bonus;
			Skull.Drop(Other, 0.5*Other.Velocity);
		}
	}
	SetSkulls(Other, None);

	Super.Killed(Killer, Other, damageType);
}

function DiscardInventory(Pawn Other)
{
	Super.DiscardInventory(Other);
	SetSkulls(Other, None);
}

function ScoreFlag(Pawn Scorer, CTFFlag theFlag)
{
	local Skull Skull;
	
	if (Scorer.bIsPlayer)
	{
		Skull = Skull(Scorer.FindInventoryType(Class'Skull'));
		if (Skull != None)
		{
			Scorer.PlayerReplicationInfo.Score += Skull.Amount;
			Teams[Scorer.PlayerReplicationInfo.Team].Score += Skull.Amount;

			Scorer.PlaySound(Sound'DeliverSkulls');
			AllClientsPlaySound(CaptureSound[Scorer.PlayerReplicationInfo.Team]);

			EndStatsClass.Default.TotalFlags += Skull.Amount;
			BroadcastLocalizedMessage( class'CTFMessage', 0, Scorer.PlayerReplicationInfo, None, TheFlag );

			if ( (bOverTime || (GoalTeamScore != 0)) && (Teams[Scorer.PlayerReplicationInfo.Team].Score >= GoalTeamScore) )
				EndGame("teamscorelimit");
			else if ( bOverTime )
				EndGame("timelimit");
				
			Scorer.DeleteInventory(Skull);
			SetSkulls(Scorer, None);
			Skull.Destroy();
			TeleportToBase(Scorer);
		}
	}
}

function TeleportToBase(Pawn Traveler)
{
	local NavigationPoint BestStart;
	local vector PrevPosition;
	local rotator NewRotation;
	local Bot B;

	BestStart = FindPlayerStart(Traveler, 255);

	if (BestStart != None)
	{
		if (Traveler.IsA('bbPlayer'))
		{ // NewNet ugly stuff
			if (float(Traveler.GetPropertyText("zzForceUpdateUntil")) < Level.TimeSeconds + 0.15)
				Traveler.SetPropertyText("zzForceUpdateUntil", string(Level.TimeSeconds + 0.15));
		}
		PrevPosition = Traveler.Location;
		Traveler.SetLocation(BestStart.Location);
		PlayTeleportEffect(Traveler, true, true);
		SpawnEffect(Traveler, PrevPosition, BestStart.Location);
		Traveler.Velocity = vect(0, 0, 0);
		NewRotation = BestStart.Rotation;
		NewRotation.Roll = 0;
		Traveler.ClientSetRotation(NewRotation);
		
		B = Bot(Traveler);
		if (B != None)
		{
			B.MoveTarget = BestStart;
			B.Destination = BestStart.Location;
			B.MoveTimer = -1;
			B.bJumpOffPawn = true;
			if (!B.Region.Zone.bWaterZone)
				B.SetFall();
			B.SetOrders(BotReplicationInfo(B.PlayerReplicationInfo).RealOrders, 
				BotReplicationInfo(B.PlayerReplicationInfo).RealOrderGiver, true);
			B.GotoState('Roaming');
		}
	}
}

function SpawnEffect(Pawn Traveler, vector Start, vector Dest)
{
	local actor e;

	e = Spawn(class'TranslocOutEffect',,,start, Traveler.Rotation);
	e.Mesh = Traveler.Mesh;
	e.Animframe = Traveler.Animframe;
	e.Animsequence = Traveler.Animsequence;
	e.Velocity = 900 * Normal(Dest - Start);
}

function AllClientsPlaySound(Sound Sound)
{
	local pawn P;
	for (P = Level.PawnList; P != None; P = P.NextPawn)
		if (P.IsA('PlayerPawn'))
			PlayerPawn(P).ClientPlaySound(Sound);
}

function SetSkulls(Pawn Player, Skull Skull)
{
	local GreedReplicationInfo GRI;
	if (Player.PlayerReplicationInfo == None)
		return;
	GRI = GreedReplicationInfo(Player.PlayerReplicationInfo.Target);
	if (GRI == None)
		GRI = Player.Spawn(Class'GreedReplicationInfo', Player);
	GRI.Skull = Skull;
	if (Skull != None)
		GRI.Skulls = Skull.Amount;
	else
		GRI.Skulls = 0;
}

function bool InVehicle(Pawn Pawn)
{
	return Pawn.Weapon != None && Pawn.Weapon.isA('DriverWeapon');
}

function bool HarvestSkullsNear(Bot aBot, float MaxDist)
{
	local Skull Skull;
	local int Skulls;
	local float Dist, BestDist, Scale;
	local Actor Best, MoveTarget;
	
	if (InVehicle(aBot) && !ThereNoEnemy(aBot))
	{
		TempVehicle = None;
		SetPropertyText("TempVehicle", aBot.Weapon.GetPropertyText("VehicleOwner"));
		if (TempVehicle == None)
			return false;
		MaxDist = TempVehicle.CollisionRadius + aBot.default.CollisionRadius;
	}
	
	Skulls = getSkulls(aBot);

	Scale = 50.0;
	if (MaxDist > 800)
		Scale = 100.0;
	BestDist = MaxDist - Skulls*Scale;
	foreach aBot.VisibleCollidingActors(Class'Skull', Skull, MaxDist)
	{
		if (Skull.bHidden)
			continue;
		Dist = VSize(Skull.Location - aBot.Location);
		if (Skull.LifeSpan > 0 && Skull.LifeSpan < 0.5 + Dist/aBot.GroundSpeed)
			continue;
		Dist -= Skull.Amount*Scale;
		if (Dist < BestDist)
		{
			if (MaxDist > 800.0)
				MoveTarget = aBot.FindPathToward(Skull);
			else if (aBot.ActorReachable(Skull))
				MoveTarget = Skull;
			else
				MoveTarget = None;
			if (MoveTarget != None)
			{
				BestDist = Dist;
				Best = MoveTarget;
			}
		}
	}
	if (Best != None)
	{
		aBot.MoveTarget = Best;
		SetAttractionStateFor(aBot);
		return true;
	}
	return false;
}

function Timer()
{
	Super.Timer();

	FixDefenders();

	// fail safe polling fix - disabled	
	if (false)
		PollingFix();
}

function SetAttractionStateFor(Bot aBot)
{
	aBot.bNoClearSpecial = true;
	aBot.TweenToRunning(0.1);
	if (aBot.Enemy != None)
		aBot.GotoState('FallBack', 'SpecialNavig');
	else
		aBot.GotoState('Roaming', 'SpecialNavig');
}

function FixDefenders()
{
	local Pawn P;
	local Bot Bot;
	local float Dist, InvDist, BestInvDist;
	local FlagBase BotBase;
	local Actor A;
	local Inventory Inv, BestInv;
	
	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		Bot = Bot(P);
		if (Bot != None && Bot.PlayerReplicationInfo != None && 
			Bot.Orders == 'Defend' && Bot.MoveTarget == None && (Bot.IsInState('wandering') || Bot.IsInState('Roaming')))
		{
			BotBase = FlagBase(Bot.OrderObject);
			if (BotBase == None)
				continue;
			Dist = VSize(BotBase.Location - Bot.Location);
			if (InVehicle(Bot))
			{
				if (Dist > 1000)
					Bot.GotoState('Roaming');
			}
			else
			{
				BestInv = None;
				if (BotAttractInvClass != None)
					foreach Bot.RadiusActors(BotAttractInvClass, A, 2000)
					{
						Inv = Inventory(A);
						if (Inv.BotDesireability(Bot) <= 0.001)
							continue;
						InvDist = VSize(Inv.Location - Bot.Location);
						if (BestInv == None || BestInvDist > InvDist)
						{
							BestInv = Inv;
							BestInvDist = InvDist;
						}
					}
				if (BestInv != None)
				{
					if (Bot.actorReachable(BestInv))
						Bot.MoveTarget = BestInv;
					else
						Bot.MoveTarget = Bot.FindPathToward(BestInv);
					if (Bot.MoveTarget != None)
						SetAttractionStateFor(Bot);
				}
				if (Bot.MoveTarget == None && Dist > 1000)
				{
					Bot.MoveTarget = Bot.FindPathToward(BotBase);
					if (Bot.MoveTarget != None)
						SetAttractionStateFor(Bot);
				}
			}
		}
	}
}

function PollingFix()
{
	local Pawn P;
	local Skull Skull;
	local GreedReplicationInfo GRI;
	
	for (P = Level.PawnList; P != None; P = P.NextPawn)
		if (P.bIsPlayer && P.PlayerReplicationInfo != None)
		{
			GRI = GreedReplicationInfo(P.PlayerReplicationInfo.Target);
			if (GRI == None)
			{
				Skull = Skull(P.FindInventoryType(Class'Skull'));
				SetSkulls(P, Skull);
				continue;
			}
			Skull = GRI.Skull;
			if (Skull == None || Skull.Owner != P)
				Skull = Skull(P.FindInventoryType(Class'Skull'));
			SetSkulls(P, Skull);
		}
}

function ModifyBehaviour(Bot NewBot)
{
	Super.ModifyBehaviour(NewBot);
	
	SetSkulls(NewBot, None);
}

event PostLogin(playerpawn NewPlayer)
{
	Super.PostLogin(NewPlayer);
	
	SetSkulls(NewPlayer, None);
}

function bool MustKeepEnemy(Pawn E)
{
	if (E == None || E.PlayerReplicationInfo == None || E.Health <= 0)
		return false;
	return getSkulls(E) > 10;
}

function Dbg(Bot aBot, coerce string Info)
{
	Log(Level.TimeSeconds @ aBot.GetHumanName() @ 
		aBot.GetStateName() @ "(" @ aBot.NextState @ aBot.NextLabel @ ")" @
		"Skulls" @ getSkulls(aBot) @ "Enemy" @ aBot.Enemy @ "MoveTarget" @ aBot.MoveTarget @
		Info);
}

function bool FindSpecialAttractionFor(Bot aBot)
{
	local CTFFlag FriendlyFlag, EnemyFlag;
	local bool bOrdered;
	local Skull Skull;
	local int Skulls;
	local GreedReplicationInfo GRI;
	local Actor MoveTarget;

	if (aBot.LastAttractCheck == Level.TimeSeconds)
		return false;
	aBot.LastAttractCheck = Level.TimeSeconds;

	FriendlyFlag = CTFReplicationInfo(GameReplicationInfo).FlagList[aBot.PlayerReplicationInfo.Team];
	
	if (aBot.PlayerReplicationInfo.Team == 0)
		EnemyFlag = CTFReplicationInfo(GameReplicationInfo).FlagList[1];
	else
		EnemyFlag = CTFReplicationInfo(GameReplicationInfo).FlagList[0];
	
	GRI = GreedReplicationInfo(aBot.PlayerReplicationInfo.Target);
	if (GRI != None)
		Skull = GRI.Skull;
	else
	{
		Skull = Skull(aBot.FindInventoryType(Class'Skull'));
		SetSkulls(aBot, Skull);
	}
	if (Skull != None)
		Skulls = Skull.Amount;
		
	if (aBot.Enemy != None && aBot.Health < 60 && Skulls > 7)
		aBot.SendTeamMessage(None, 'OTHER', 13, 25);

	if (Skulls > 0 && aBot.ActorReachable(EnemyFlag))
	{
		// if nobody near - harvest items near
		if ((ThereNoEnemy(aBot) || FRand() < 0.5/Skulls) && HarvestSkullsNear(aBot, 800.0))
			return true;
		aBot.MoveTarget = EnemyFlag;
		SetAttractionStateFor(aBot);
		return true;
	}
	
	bOrdered = aBot.bSniping || (aBot.Orders == 'Follow') || (aBot.Orders == 'Hold');

	if ( (bOrdered && !aBot.OrderObject.IsA('Bot')) || (aBot.Weapon == None) || (aBot.Weapon.AIRating < 0.4) )
		return false;
	
	if (aBot.Orders == 'Defend' && Skulls <= 7)
	{
		if (VSize(FriendlyFlag.Location - aBot.Location) > 1000 && 
			(InVehicle(aBot) || aBot.IsInState('wandering')))
		{
			aBot.MoveTarget = aBot.FindPathToward(FriendlyFlag.HomeBase);
			if (aBot.MoveTarget != None)
			{
				SetAttractionStateFor(aBot);
				return true;
			}
		}
		if (HarvestSkullsNear(aBot, 800.0))
			return true;
		return false;
	}

	if (Skulls >= Clamp(Clamp(GoalTeamScore - Teams[aBot.PlayerReplicationInfo.Team].Score, 1, 3), 1, 
		aBot.PlayerReplicationInfo.Score + 2))
	{
		if (aBot.Orders == 'Attack' || aBot.Orders == 'Freelance' ||
				(aBot.Orders == 'Defend' && Skulls > 7) ||
				(aBot.Orders == 'Follow' && aBot.OrderObject.IsA('Bot') && 
				(Pawn(aBot.OrderObject).Health <= 0 || 
				(EnemyFlag.Region.Zone == aBot.Region.Zone && VSize(EnemyFlag.Location - aBot.Location) < 2000))) )
		{
			aBot.Orders = 'Freelance'; // for able enter to others vehicles
			if ( (aBot.Enemy != None) 
				&& (aBot.Enemy.IsA('PlayerPawn') || (aBot.Enemy.IsA('Bot') && (Bot(aBot.Enemy).Orders == 'Attack')))
				&& (((aBot.Enemy.Region.Zone == FriendlyFlag.HomeBase.Region.Zone) && (EnemyFlag.HomeBase.Region.Zone != FriendlyFlag.HomeBase.Region.Zone)) 
					|| (VSize(aBot.Enemy.Location - FriendlyFlag.HomeBase.Location) < 0.6 * VSize(aBot.Location - EnemyFlag.HomeBase.Location))) )
			{
				aBot.SendTeamMessage(None, 'OTHER', 14, 15); //"Incoming!"
				//aBot.Orders = 'Freelance';
				//return false;
			}
			if (HarvestSkullsNear(aBot, 800.0))
				return true;

			FindPathToBase(aBot, EnemyFlag.HomeBase);
			if (aBot.MoveTarget != None)
			{
				SetAttractionStateFor(aBot);
				return true;
			}
			else
			{
				if (aBot.bVerbose)
					log(aBot @ "no path to flag");
				return false;
			}
		}
		return false;
	}

	if (aBot.Orders != 'Defend' && aBot.Enemy == None)
	{
		if (HarvestSkullsNear(aBot, 800.0) || HarvestSkullsNear(aBot, 4000.0))
			return true;
		
		// go to enemy base for kill defenders
		if (VSize(EnemyFlag.Location - aBot.Location) > 1000)
		{
			MoveTarget = aBot.MoveTarget;
			FindPathToBase(aBot, EnemyFlag.HomeBase);
			if (aBot.MoveTarget == EnemyFlag.HomeBase && Skulls < 1)
				aBot.MoveTarget = MoveTarget;
			else if (aBot.MoveTarget != None)
			{
				SetAttractionStateFor(aBot);
				return true;
			}
		}
		
		if ( FRand() < 0.35 )
			aBot.GotoState('Wandering');
		else
		{
			aBot.CampTime = 1.0;
			aBot.bCampOnlyOnce = true;
			aBot.GotoState('Roaming', 'Camp');
		}
		return true;
	}
	if (HarvestSkullsNear(aBot, 800.0))
		return true;
	return false;
}

function bool ThereNoEnemy(Bot aBot)
{
	return aBot.Enemy == None || (VSize(aBot.Enemy.Location - aBot.Location) > 1000.0 &&
		!aBot.FastTrace(aBot.Enemy.Location));
}

simulated static function int getSkulls(Pawn Other)
{
	local GreedReplicationInfo GRI;
	if (Other.PlayerReplicationInfo != None)
	{
		GRI = GreedReplicationInfo(Other.PlayerReplicationInfo.Target);
		if (GRI != None)
			return GRI.Skulls;
	}
	return 0;
}

function float GameThreatAdd(Bot aBot, Pawn Other)
{
	local float Skulls;

	Skulls = getSkulls(Other);

	if (Skulls > 0)
		return Skulls/5.0;
	else
		return 0;
}

function byte AssessBotAttitude(Bot aBot, Pawn Other)
{
	if ( Other.PlayerReplicationInfo != None && aBot.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team )
		return 3; //teammate
		
	if ( (Other.bIsPlayer && getSkulls(Other) > 0) || getSkulls(aBot) > 0 )
		return 1;
	return Super.AssessBotAttitude(aBot, Other);
}

function byte PriorityObjective(Bot aBot)
{
	local CTFFlag EnemyFlag;
	local int Skulls;
	
	if (aBot.PlayerReplicationInfo != None)
	{
		EnemyFlag = CTFReplicationInfo(GameReplicationInfo).FlagList[1 - aBot.PlayerReplicationInfo.Team]; 
		Skulls = getSkulls(aBot);
		
		if (Skulls > 0 && VSize(aBot.Location - EnemyFlag.HomeBase.Location) < 1000 && aBot.LineOfSightTo(EnemyFlag.HomeBase))
			return 255;
		
		if ((Skulls > Min(5, GoalTeamScore - Teams[aBot.PlayerReplicationInfo.Team].Score)) ||
			(Skulls >= 3 && (VSize(aBot.Location - EnemyFlag.HomeBase.Location) < 2000) && aBot.LineOfSightTo(EnemyFlag.HomeBase)))
			return 2;
	}
	return 0;
}

function bool SetEndCams(string Reason)
{
	local bool Ret;
	local GreedFlag Flag;
	
	Ret = Super.SetEndCams(Reason);
	foreach AllActors(Class'GreedFlag', Flag)
	{
		Flag.bHidden = false;
		Flag.HomeBase.bHidden = true;
	}
	return Ret;
}

defaultproperties
{
	StartUpMessage="Return the enemy's skulls to their base."
	gamegoal="captured skulls wins the match!"
	GameName="Greed"
	bGameRelevant=True
}
