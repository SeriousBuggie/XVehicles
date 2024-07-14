//=============================================================================
// UT3Rewards.
//=============================================================================
class UT3Rewards expands Mutator;

var() Sound Sounds[18];
var() localized string Strings[ArrayCount(Sounds)];
var() int Threshold[ArrayCount(Sounds)];
var int Counter[ArrayCount(Sounds)];

var Pawn LastKilled, LastKiller;
var int LastMessage, Offset, LastNew;

simulated function string GetString(
	optional int Sw,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	) {
	local bool bNewMessage;
	if (Sw == 0)
		return "";
	bNewMessage = Sw > LastNew;
	if (bNewMessage)
		LastNew = Sw;
	Sw = Sw % 100;
	if (--Sw >= 0 && Sw < ArrayCount(Sounds)) {
		if (bNewMessage)
			Counter[Sw]++;
		if (Threshold[Sw] == 1 || Counter[Sw] == Threshold[Sw]) {
			if (Sw == 11) {
				if (Counter[Sw] == 10)
					Sw = 17;
				else
					Sw = 10 + (Counter[Sw] % 4);
			}
			if (bNewMessage)
				PlayReward(Sounds[Sw]);
			return Strings[Sw];
		}
	}
	return "";	
}

simulated function PlayReward(Sound PlaySound) {
	local PlayerPawn P;
	local bool b3DSound;
	foreach AllActors(class'PlayerPawn', P)
		if (P.bIsPlayer)
		{
			if (TournamentPlayer(P) != None)
			{
				b3DSound = TournamentPlayer(P).b3DSound;
				TournamentPlayer(P).b3DSound = true; // hack for v436, for prevent play too loud
			}
			P.ClientPlaySound(PlaySound, , true);
			if (TournamentPlayer(P) != None)
				TournamentPlayer(P).b3DSound = b3DSound;
		}
}

function PostBeginPlay() {
	Super.PostBeginPlay();
	
	Level.Game.BaseMutator.AddMutator(self);
}

function bool PreventDeath(Pawn Killed, Pawn Killer, name damageType, vector HitLocation)
{
	local bool ret;
	local Vehicle KillerVeh, KilledVeh;
	local vector Diff, StartTrace;
	local float DiffZ;
	local Projectile Proj, OtherProj;
	local ShockProj Combo;
	ret = Super.PreventDeath(Killed, Killer, damageType, HitLocation);
	if (!ret && Killed != None && Killer != None) {
		LastKilled = Killed;
		LastKiller = Killer;
		if (damageType == 'RocketDeath' && UT_Eightball(Killer.Weapon) != None)
			LastMessage = 0;
		else if ((damageType == 'FlakDeath' || damageType == 'shredded') && UT_FlakCannon(Killer.Weapon) != None)
			LastMessage = 1;
		else if (damageType == 'Decapitated' && SniperRifle(Killer.Weapon) != None)
			LastMessage = 2;
		else if (damageType == 'jolted' && ShockRifle(Killer.Weapon) != None) // need detect combo
		{
			foreach Killed.RadiusActors(Class'Vehicle', KilledVeh, 10)
				if (KilledVeh.Location == HitLocation && KilledVeh.Health <= 0)
					break;
			if (KilledVeh != None) {
				DiffZ = KilledVeh.CollisionRadius;
				Diff = HitLocation;
			} else {
				DiffZ = Killed.CollisionRadius;
				Diff = Killed.Location;
			}
			foreach Killed.RadiusActors(Class'ShockProj', Combo, 250 + DiffZ, Diff)
				if (Combo.Instigator == Killer && Combo.bHurtEntry)
					break;
			StartTrace = Killer.Location + Killer.Weapon.CalcDrawOffset();
			if (Combo != None && Killer.TraceShot(Diff, Diff, StartTrace + 
				vector(Killer.ViewRotation)*(VSize(Combo.Location - Killer.Location) + 100), StartTrace) == Combo)
				LastMessage = 3;
		}
		else if (damageType == 'ShockCombo' && ShockRifle(Killer.Weapon) != None) // newnet combo
			LastMessage = 3;
		else if (damageType == 'Corroded' && ut_biorifle(Killer.Weapon) != None)
			LastMessage = 4;
		else if (damageType == 'impact' && ImpactHammer(Killer.Weapon) != None)
			LastMessage = 5;
		else if (damageType == 'zapped' && PulseGun(Killer.Weapon) != None)
			LastMessage = 6;
		else if (damageType == 'shot' && Enforcer(Killer.Weapon) != None)
			LastMessage = 7;
		else if (false) // avril - not yet implemented
			LastMessage = 8;
		else if (damageType == 'shot' && minigun2(Killer.Weapon) != None)
			LastMessage = 9;
		else {
			if (DriverWeapon(Killer.Weapon) != None)
				KillerVeh = DriverWeapon(Killer.Weapon).VehicleOwner;
			foreach Killed.RadiusActors(Class'Vehicle', KilledVeh, 10, HitLocation)
				if (KilledVeh.Location == HitLocation && KilledVeh.Health <= 0)
					break;
			if (damageType == 'Crushed' && KillerVeh != None && KilledVeh == None && KillerVeh.bHitAPawn) {
				LastMessage = 11;
				Diff = Killed.Location - KillerVeh.Location;
				if (Diff.Z < -KillerVeh.CollisionHeight) {
					DiffZ = -Diff.Z;
					Diff.Z = 0;
					if (VSize(Diff)/DiffZ < (KillerVeh.CollisionRadius + Killed.CollisionRadius)/
						(KillerVeh.CollisionHeight + Killed.CollisionHeight))
						LastMessage = 14;
				}
			} else if (FlightCraftPhys(KilledVeh) != None || ChopperPhys(KilledVeh) != None) {
				if (FlightCraftPhys(KillerVeh) != None || ChopperPhys(KillerVeh) != None)
					LastMessage = 16;
				else if (DamageType != 'shot' && KillerVeh != None && KillerVeh.bSlopedPhys &&
					VSize(KillerVeh.Location - KilledVeh.Location) > 2000) {
					foreach KilledVeh.RadiusActors(Class'Projectile', Proj, KilledVeh.CollisionRadius + 100)
						if (Proj.Instigator == Killer && Proj.bHurtEntry && 
							VSize(Proj.Location - KilledVeh.Location) < 
							KilledVeh.CollisionRadius + Proj.CollisionRadius + 10)
							break;
					if (Proj != None) {
						foreach AllActors(Class'Projectile', OtherProj)
							if (OtherProj.Instigator == Killer && OtherProj != Proj && OtherProj.Class == Proj.Class)
								break;
						if (OtherProj == None) // ensure it be single shot, not spam of projectiles
							LastMessage = 15;
					}
				}
			}
		}
	}
	return ret;
}

function XLog(Pawn Killer, coerce string S, optional name Tag) {
	if (Bot(Killer) != None)
		return;
	Log(S, Tag);
}

function ScoreKill(Pawn Killer, Pawn Killed)
{
	Super.ScoreKill(Killer, Killed);
			
	if (LastMessage != -1 && Killed != None && Killer != None && Killer == LastKiller && Killed == LastKilled) {
		Killer.ReceiveLocalizedMessage(Class'UT3RewardMessage', LastMessage + 1 + ++Offset*100, 
			Killer.PlayerReplicationInfo, Killed.PlayerReplicationInfo);
	}
	LastKilled = None;
	LastKiller = None;
	LastMessage = -1;
}

defaultproperties
{
	Sounds(0)=Sound'A_RewardAnnouncer_RocketScientist'
	Sounds(1)=Sound'A_RewardAnnouncer_FlakMaster'
	Sounds(2)=Sound'A_RewardAnnouncer_HeadHunter'
	Sounds(3)=Sound'A_RewardAnnouncer_ComboKing'
	Sounds(4)=Sound'A_RewardAnnouncer_BioHazard'
	Sounds(5)=Sound'A_RewardAnnouncer_JackHammer'
	Sounds(6)=Sound'A_RewardAnnouncer_ShaftMaster'
	Sounds(7)=Sound'A_RewardAnnouncer_GunSlinger'
	Sounds(8)=Sound'A_RewardAnnouncer_BigGameHunter'
	Sounds(9)=Sound'A_RewardAnnouncer_BlueStreak'
	Sounds(10)=Sound'A_RewardAnnouncer_RoadKill'
	Sounds(11)=Sound'A_RewardAnnouncer_Hitandrun'
	Sounds(12)=Sound'A_RewardAnnouncer_RoadRage'
	Sounds(13)=Sound'A_RewardAnnouncer_Vehicularmanslaughter'
	Sounds(14)=Sound'A_RewardAnnouncer_Pancake'
	Sounds(15)=Sound'A_RewardAnnouncer_EagleEye'
	Sounds(16)=Sound'A_RewardAnnouncer_topgun'
	Sounds(17)=Sound'A_RewardAnnouncer_RoadRampage'
	Strings(0)="Rocket Scientist!"
	Strings(1)="Flak Master!"
	Strings(2)="Head Hunter!"
	Strings(3)="Combo King!"
	Strings(4)="Bio Hazard!"
	Strings(5)="JackHammer!"
	Strings(6)="Shaft Master!"
	Strings(7)="Gun Slinger!"
	Strings(8)="Big Game Hunter!"
	Strings(9)="Blue Streak!"
	Strings(10)="Road Kill!"
	Strings(11)="Hit and Run!"
	Strings(12)="Road Rage!"
	Strings(13)="Vehicular Manslaughter!"
	Strings(14)="Pancake!"
	Strings(15)="Eagle Eye!"
	Strings(16)="Top Gun!"
	Strings(17)="Road Rampage!"
	Threshold(0)=15
	Threshold(1)=15
	Threshold(2)=15
	Threshold(3)=15
	Threshold(4)=15
	Threshold(5)=15
	Threshold(6)=15
	Threshold(7)=15
	Threshold(8)=15
	Threshold(9)=15
	Threshold(10)=1
	Threshold(11)=1
	Threshold(12)=1
	Threshold(13)=1
	Threshold(14)=1
	Threshold(15)=1
	Threshold(16)=1
	Threshold(17)=1
	LastMessage=-1
	bAddToPackageMap=True
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
}
