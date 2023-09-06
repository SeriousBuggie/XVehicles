//=============================================================================
// XVehiclesCTF.
//=============================================================================
class XVehiclesCTF expands Mutator;

enum EPulseForHeal
{
	PFH_Auto,				// Detect by presence FixGun on map, or by use FixGunMutator
	PFH_Yes,				// Pulse Heal vehicles
	PFH_No,					// Pulse not heal vehicles
};
var() EPulseForHeal PulseForHeal;
var() bool bShowFlagBase;

var Bot Bots[1024];
var int BotsCount;

var int Tmr;

var DefensePointCache DPC;

event PreBeginPlay()
{
	local Actor A;
	local bool bPulseAltHeal;
	Local PulseGun Pulse;
	local Mutator M;
	local FlagBase FB;
	Local XFlagBase xFB;
	Local vector HL, HN, dir;
	local BotSpawnNotify BSN;
	
	Super.PreBeginPlay();
	
	foreach AllActors(Class, A)
		break;
	if (A != self)
		return;

	if (!class'VehiclesConfig'.default.bDisableFastWarShell)
		Spawn(class'FastWSNotify'); // Fast WarShell
		
	if (!class'VehiclesConfig'.default.bAllowTranslocator && DeathMatchPlus(Level.Game) != None)
		DeathMatchPlus(Level.Game).bUseTranslocator = false;
	
	if (CTFGame(Level.Game) != None)
		Spawn(class'FlagAnnouncer');
		
	class'XVehiclesHUD'.static.SpawnHUD(self);
	
	if (PulseForHeal == PFH_Yes)
		bPulseAltHeal = true;
	else if (PulseForHeal == PFH_Auto)
	{
		foreach AllActors(class'PulseGun', Pulse)
			if (Pulse.isA('FixGun'))
				break;
		if (Pulse == None) // on map no any Fixgun?
		{
			foreach AllActors(class'Mutator', M)
				if (M.isA('FixGunMutator'))
					break;
			if (M == None) // FixGunMutator not loaded? (able give FixGun on enter to vehicle)
				bPulseAltHeal = true;
		}
	}
	
	class'VehiclesConfig'.default.bPulseAltHeal = bPulseAltHeal;
	class'VehiclesConfig'.static.Update(self);
	
	if (bShowFlagBase)
		foreach AllActors(class'FlagBase', FB)
		{
			HL = FB.Location;
			dir = vect(0,0,134.5)*FB.DrawScale/FB.default.DrawScale >> FB.Rotation;
			HL -= dir;
			if (FB.Trace(HL, HN, HL) != None && (Normal(dir) dot HN) > 0.998)
			{
				xFB = FB.Spawn(class'XFlagBase', FB, , HL + (vect(0,0,18) >> FB.Rotation), FB.Rotation);
				if (xFB != None && FB.Team != 0)
					xFB.MultiSkins[0] = Texture'FlagBaseSkinB';				
			}
		}
		
	foreach AllActors(class'BotSpawnNotify', BSN)
		break;
	if (BSN == None)
		BSN = Spawn(class'BotSpawnNotify');
	if (BSN != None)
		SetTimer(0.1, true);
	class'BotSpawnNotify'.default.XVehiclesCTF = self;
		
	DPC = Spawn(class'DefensePointCache', self);
}

event KillCredit(Actor Other) {
	local Bot Bot;
	Bot = Bot(Other);
	if (Bot != None)
		AddBot(Bot);
	else if (PLITracker(Other) != None) {
		Bot = Bot(Other.Owner);
		if (Bot.AmbushSpot == None)
			DPC.Update(Bot);
		FixBot(Bot, Tmr);
	}
}

function AddBot(Bot Bot) {
	local int i;
	if (Bot == None)
		return;
	for (i = 0; i < ArrayCount(Bots); i++)
		if (Bots[i] == None || Bots[i].bDeleteMe) {
			Bots[i] = Bot;
			if (BotsCount <= i)
				BotsCount = i + 1;
			break;
		}
}

function Timer() {
	local int i;
	if (Level.Game.bGameEnded)
		return;
	for (i = BotsCount - 1; i >= 0; i--)
		if (Bots[i] != None && !Bots[i].bDeleteMe)
			FixBot(Bots[i], Tmr);
		else if (i == BotsCount - 1)
			BotsCount--;
	Tmr++;
}

static function FixBot(Bot Bot, optional int Tmr) {
	local CTFFlag MyFlag, FriendlyFlag;
	local Vehicle Veh, Best;
	local float Dist, BestDist;
	if (class'VehiclesConfig'.default.bPulseAltHeal && PulseGun(Bot.Weapon) != None)
		TryHeal(Bot);
	if (DriverWeapon(Bot.Weapon) != None || Bot.PlayerReplicationInfo == None)
		return;
	if (Vehicle(Bot.MoveTarget) != None)
	{
		if (Vehicle(Bot.MoveTarget).BotDesireability2(Bot) > 0)
			return;
		Bot.MoveTarget = None;
		Bot.MoveTimer = -1;
	}
	MyFlag = CTFFlag(Bot.PlayerReplicationInfo.HasFlag);
	if (MyFlag == None)
	{
		if (Tmr % 10 == 0 && (Bot.IsInState('wandering') || 
			(Bot.IsInState('Roaming') && Bot.Ambushspot != None && 
			VSize(Bot.Ambushspot.Location - Bot.Location) <= 512 &&
			Bot.FastTrace(Bot.Ambushspot.Location))))
		{
			Best = class'WeaponAttachment'.static.AttackVehicle(None, Bot, 3000);
			if (Best != None)
				class'WeaponAttachment'.static.RangedAttack(Bot, Best, 1.0);
			return;
		}
		if (Bot.Enemy != None)
			return;
	}
	else
	{
		if (Bot.PlayerReplicationInfo.Team >= ArrayCount(CTFReplicationInfo(Bot.Level.Game.GameReplicationInfo).FlagList))
			return;
		FriendlyFlag = CTFReplicationInfo(Bot.Level.Game.GameReplicationInfo).FlagList[Bot.PlayerReplicationInfo.Team];
		if (FriendlyFlag == None || VSize(FriendlyFlag.HomeBase.Location - Bot.Location) < 800)
			return;
	}
	foreach Bot.RadiusActors(class'Vehicle', Veh, 700)
	{
		if (MyFlag != None && Tmr == -1 && Veh.LastDriver == Bot)
			Veh.LastDriver = None;
		Dist = Veh.BotDesireability2(Bot);
		if (Dist > 0)
		{
			Dist *= VSize(Veh.Location - Bot.Location);
			if ((Best == None || BestDist > Dist) && Bot.pointReachable(Veh.Location))
			{
				Best = Veh;
				BestDist = Dist;
			}
		}
	}
	if (Best != None)
	{
		Bot.MoveTarget = Best;
		Bot.MoveTimer = 1.1*VSize(Best.Location - Bot.Location)/Bot.GroundSpeed;
	}
}

static function TryHeal(Bot Bot)
{
	Local Pawn P;
	Local Inventory Inv;
	local name BotState;
	local Vehicle Actor;
	local Weapon BotWeapon;
	
	if (FixGun(Bot.Weapon) != None) // use own heal code
		return;
	if (Bot.PlayerReplicationInfo == None ||
		(Bot.Enemy != None && Bot.Enemy != Bot) ||
		CTFFlag(Bot.Target) != None || Bot.PlayerReplicationInfo.HasFlag != None)
		return;
	BotState = Bot.GetStateName();
	if (BotState == 'RangedAttack' || BotState == 'FallingState' || BotState == 'TakeHit' || BotState == 'ImpactJumping')
		return;	

	for (P = Bot.Level.PawnList; P != None; P = P.nextPawn)
		if (P.Weapon != None && P.Weapon.isA('DriverWeapon') && 
			P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.Team == Bot.PlayerReplicationInfo.Team)
		{
			Actor = DriverWeapon(P.Weapon).VehicleOwner;
			if (Actor == None || Actor.Health >= Actor.FirstHealth ||
				VSize(Actor.Location - Bot.Location) - Actor.CollisionRadius > 710 || !Bot.LineOfSightTo(Actor))
				continue;
			BotWeapon = Bot.Weapon;
			Bot.Enemy = Bot; // weird hack
			if (!Bot.SwitchToBestWeapon() || Bot.Weapon != BotWeapon || Bot.Weapon != Bot.PendingWeapon)
			{
				P = None;
				break;
			}
			Bot.Target = Actor;
			Bot.bComboPaused = true;
			Bot.SpecialPause = 1.0; // calculate exact time for heal
//			log(Bot.Level.TimeSeconds @ Bot @ "set to heal" @ Actor @ P @ BotState @ Bot.NextState @ Bot.NextLabel);
			Bot.NextState = BotState;
			Bot.NextLabel = 'Begin';
			Bot.GotoState('RangedAttack');
			break;
		}
	if (P == None && Bot.Enemy == Bot)
		Bot.Enemy = None; // reset hack
}

/*
function Tick(float delta)
{
	local Pawn P;
	local Inventory Inv, Lost;
	local string chain;
	local bool bBad;
	
	Super.Tick(delta);
	
	for (P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if (!P.bIsPlayer || P.health <= 0 || P.isInState('Dying') || P.IsInState('PlayerWaiting') || Spectator(P) != None)
			continue;
		if (P.Inventory == None)
		{
			Log(P @ P.GetHumanName() @ "lost inventory!");
			foreach AllActors(class'Inventory', Lost)
				if (Lost.owner == P)
					Log("Found lost item:" @ Lost @ "which point to" @ Lost.Inventory);
		}
		else
		{
			bBad = false;
			chain = "";
			for (Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
			{
				chain @= ">" @ Inv;
				if (Inv.Owner != P)
					chain @= "(" $ Inv.Owner @ Inv.Owner.GetHumanName() $ ")";
				if (DriverWeapon(Inv) != None || DriverWNotifier(Inv) != None || Inv.Owner != P)
					bBad = true;
			}
			if (bBad)
				Log("Bad chain:" @ P @ P.GetHumanName() @ chain);
		}
	}
}
*/

defaultproperties
{
	bShowFlagBase=True
}
