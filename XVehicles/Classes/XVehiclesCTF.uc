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

event PreBeginPlay()
{
	local Actor A;
	local bool bPulseAltHeal;
	Local PulseGun Pulse;
	local Mutator M;
	local FlagBase FB;
	Local XFlagBase xFB;
	Local vector HL, HN, dir;
	
	Super.PreBeginPlay();
	
	foreach AllActors(Class, A)
		break;
	if (A != self)
		return;

	if (!class'VehiclesConfig'.default.bDisableFastWarShell)
		Spawn(class'FastWSNotify'); // Fast WarShell
		
	if (!class'VehiclesConfig'.default.bAllowTranslocator && DeathMatchPlus(Level.Game) != None)
		DeathMatchPlus(Level.Game).bUseTranslocator = false;
		
	if (!class'VehiclesConfig'.default.bDisableFlagAnnouncer && CTFGame(Level.Game).MaxTeams == 2)
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
		
	if (Spawn(class'BotSpawnNotify', self) != None)
		SetTimer(0.1, true);
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
			FixBot(Bots[i]);
		else if (i == BotsCount - 1)
			BotsCount--;
}

function FixBot(Bot Bot) {
	local CTFFlag MyFlag, FriendlyFlag;
	local Vehicle Veh, Best;
	local float Dist, BestDist;
	
	if (DriverWeapon(Bot.Weapon) != None || Bot.PlayerReplicationInfo == None || Vehicle(Bot.MoveTarget) != None)
		return;		
	MyFlag = CTFFlag(Bot.PlayerReplicationInfo.HasFlag);
	if (MyFlag == None)
		return;
		
	FriendlyFlag = CTFReplicationInfo(Level.Game.GameReplicationInfo).FlagList[Bot.PlayerReplicationInfo.Team];
	if (VSize(FriendlyFlag.HomeBase.Location - Bot.Location) < 800)
		return;
	
	foreach Bot.RadiusActors(class'Vehicle', Veh, 600)
	{
		Dist = Veh.BotDesireability2(Bot);
		if (Dist > 0)
		{
			Dist *= VSize(Veh.Location - Bot.Location);
			if (Best == None || BestDist > Dist)
			{
				Best = Veh;
				BestDist = Dist;
			}
		}
	}
	if (Best != None)
		Bot.MoveTarget = Best;
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
