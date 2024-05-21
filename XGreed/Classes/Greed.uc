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

function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	spawn(class'CTFFlagSpawnNotify'); // Disable flags
	spawn(class'GreedHUD');
}

event InitGame( string Options, out string Error )
{
	Super.InitGame(Options, Error);
	
	GoalTeamScore = GetIntOption(Options, "GoalTeamScore", GoalTeamScore);
}

function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	Damage = Super.ReduceDamage(Damage, DamageType, injured, instigatedBy);
	if (Damage > 0 && injured != None && injured.weapon != None && 
		injured.weapon.isA('DriverWeapon'))
	{
		LastDamageDriver = injured;
		LastDamageTime = Level.TimeSeconds;
		LastDamageInfo = instigatedBy @ injured @ DamageType;
		SetPropertyText("LastDamageVehicle", injured.weapon.GetPropertyText("VehicleOwner"));
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
		Skull = Skull(Other.FindInventoryType(Class'Skull'));
		if (Skull == None && Bonus > 0)
			Skull = Other.Spawn(Class'Skull');
		if (Skull != None)
		{
			if (Skull.Charge >= 5 && Other.PlayerReplicationInfo != None && 
				VSize(CTFReplicationInfo(GameReplicationInfo).FlagList[1 - Other.PlayerReplicationInfo.Team].HomeBase.Location - 
				Other.Location) < 1000)
				AllClientsPlaySound(Sound'Denied');
				
			Skull.Charge += Bonus;
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
			Scorer.PlayerReplicationInfo.Score += Skull.Charge;
			Teams[Scorer.PlayerReplicationInfo.Team].Score += Skull.Charge;

			Scorer.PlaySound(Sound'DeliverSkulls');
			AllClientsPlaySound(CaptureSound[Scorer.PlayerReplicationInfo.Team]);

			EndStatsClass.Default.TotalFlags += Skull.Charge;
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
	local Pawn P;

	BestStart = FindPlayerStart(Traveler, 255);

	if (BestStart != None)
	{
		PrevPosition = Traveler.Location;
		Traveler.SetLocation(BestStart.Location);
		PlayTeleportEffect(Traveler, true, true);
		SpawnEffect(Traveler, PrevPosition, BestStart.Location);
		Traveler.Velocity = vect(0, 0, 0);
		NewRotation = BestStart.Rotation;
		NewRotation.Roll = 0;
		Traveler.ClientSetRotation(NewRotation);
		
		B = Bot(Traveler);
		if ( B != None )
		{
			B.MoveTarget = BestStart;
			B.MoveTimer = -1;
			B.bJumpOffPawn = true;
			if (!B.Region.Zone.bWaterZone)
				B.SetFall();
		}
		else
		{
			// bots must re-acquire this player
			for (P = Level.PawnList; P != None; P = P.NextPawn)
				if (P.Enemy == Traveler && Bot(P) != None)
					Bot(P).LastAcquireTime = Level.TimeSeconds;
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
		GRI.Skulls = Skull.Charge;
	else
		GRI.Skulls = 0;
}

function bool HarvestSkullsNear(Bot aBot, float MaxDist)
{
	local Skull Skull;
	local float Dist, BestDist, Scale;
	local Actor Best, MoveTarget;

	BestDist = 12345678; // just big number;
	Scale = 50.0;
	if (MaxDist > 800)
		Scale = 100.0;
	foreach VisibleCollidingActors(Class'Skull', Skull, MaxDist)
	{
		Dist = VSize(Skull.Location - aBot.Location) - Skull.Charge*Scale;
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
		if (aBot.Enemy != None && !aBot.IsInState('FallBack'))
		{
			aBot.bNoClearSpecial = true;
			aBot.TweenToRunning(0.1);
			aBot.GotoState('Fallback', 'SpecialNavig');
		}
		return true;
	}
	return false;
}

// fail safe polling fix - disabled
function Timer_off()
{
	local Pawn P;
	local Skull Skull;
	local GreedReplicationInfo GRI;

	Super.Timer();
	
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

function bool FindSpecialAttractionFor(Bot aBot)
{
	local CTFFlag FriendlyFlag, EnemyFlag;
	local bool bOrdered;
	local Skull Skull;
	local GreedReplicationInfo GRI;

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

	if (Skull != None && Skull.Charge > 0)
	{
		if (aBot.Enemy != None && aBot.Health < 60 && Skull.Charge > 5)
			aBot.SendTeamMessage(None, 'OTHER', 13, 25);
		if (aBot.ActorReachable(EnemyFlag))
		{
			// if nobody near - harvest items near
			if ((ThereNoEnemy(aBot) || (aBot.Enemy != None && aBot.Enemy.Weapon != None && aBot.Weapon != None && 
				aBot.Weapon.AIRating > aBot.Enemy.Weapon.AIRating + 0.2) || FRand() < 0.5/Skull.Charge) &&
				HarvestSkullsNear(aBot, 800.0))
				return true;
			aBot.MoveTarget = EnemyFlag;
			SetAttractionStateFor(aBot);
			return true;
		}
		else if ( (aBot.Orders == 'Attack')
				 || ((aBot.Orders == 'Follow') && aBot.OrderObject.IsA('Bot')
					&& ((Pawn(aBot.OrderObject).Health <= 0) 
						 || ((EnemyFlag.Region.Zone == aBot.Region.Zone) && (VSize(EnemyFlag.Location - aBot.Location) < 2000)))) )
		{
			if ( !aBot.bKamikaze
				&& ( (aBot.Weapon == None) || (aBot.Weapon.AIRating < 0.4)) )
			{
				aBot.bKamikaze = ( FRand() < 0.1 );
				return false;
			}

			if ( (aBot.Enemy != None) 
				&& (aBot.Enemy.IsA('PlayerPawn') || (aBot.Enemy.IsA('Bot') && (Bot(aBot.Enemy).Orders == 'Attack')))
				&& (((aBot.Enemy.Region.Zone == FriendlyFlag.HomeBase.Region.Zone) && (EnemyFlag.HomeBase.Region.Zone != FriendlyFlag.HomeBase.Region.Zone)) 
					|| (VSize(aBot.Enemy.Location - FriendlyFlag.HomeBase.Location) < 0.6 * VSize(aBot.Location - EnemyFlag.HomeBase.Location))) )
				{
					aBot.SendTeamMessage(None, 'OTHER', 14, 15); //"Incoming!"
					aBot.Orders = 'Freelance';
					return false;
				}		
			// if nobody near - harvest items near
			if (FRand() < 2/Skull.Charge && HarvestSkullsNear(aBot, 800.0))
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
	
	bOrdered = aBot.bSniping || (aBot.Orders == 'Follow') || (aBot.Orders == 'Hold');

	if ( (bOrdered && !aBot.OrderObject.IsA('Bot')) || (aBot.Weapon == None) || (aBot.Weapon.AIRating < 0.4) )
		return false;

	if (aBot.Orders != 'Defend')
	{
		if (aBot.Enemy == None)
		{
			if (HarvestSkullsNear(aBot, 800.0) || HarvestSkullsNear(aBot, 2000.0))
				return true;
			
			// go to enemy base for kill defenders
			if (!aBot.ActorReachable(EnemyFlag))
			{
				FindPathToBase(aBot, EnemyFlag.HomeBase);
				if (aBot.MoveTarget == EnemyFlag && (Skull == None || Skull.Charge <= 0))
					aBot.MoveTarget = None;
				if (aBot.MoveTarget != None)
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
		else if (HarvestSkullsNear(aBot, 800.0))
			return true;
	}
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
		return 10 + Skulls/10.0;
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
	local CTFFlag Flag;

	Flag = CTFReplicationInfo(GameReplicationInfo).FlagList[1 - aBot.PlayerReplicationInfo.Team]; 

	if (getSkulls(aBot) > 0)
	{
		if ( (VSize(aBot.Location - Flag.HomeBase.Location) < 2000)
			&& aBot.LineOfSightTo(Flag.HomeBase) )
			return 255;
		return 2;
	}

	if (aBot.Enemy != None && getSkulls(aBot.Enemy) > 0)
		return 1;

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
	GoalTeamScore=100.000000
	TimeLimit=20
	bUseTranslocator=False
	StartUpMessage="Return the enemy's skulls to their base."
	gamegoal="captured skulls wins the match!"
	GameName="Greed"
	bGameRelevant=True
}
