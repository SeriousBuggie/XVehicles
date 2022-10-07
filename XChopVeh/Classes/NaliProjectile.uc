//////////////////////////////////////////////////////////////
//	Nali Weapons III Projectile base class
//				Feralidragon (27-04-2010)
//
// NW3 CORE BUILD 1.00
//////////////////////////////////////////////////////////////

class NaliProjectile expands Projectile 
abstract;

//Trails
var(Trails) class<Actor> TrailClass1, TrailClass2;
var(Trails) vector TrailOffset1, TrailOffset2;
var(Trails) bool bSpawnServerTrail;
var Actor Trail1, Trail2;

//Smoke generation
var(SmokeGen) bool enableSmokeGen, bSmokeGenUnderWater;
var(SmokeGen) class<effects> SmokeClass;
var(SmokeGen) float SmokeGenRateMax, SmokeGenRateMin;
var(SmokeGen) float SmokeXOffset;
var(SmokeGen) class<effects> UnderWaterSmokeClass;
var(SmokeGen) float UnderWaterSmokeGenRateMax, UnderWaterSmokeGenRateMin;
var(SmokeGen) float UnderWaterSmokeXOffset;
var(SmokeGen) bool bClientOnlySmokeGen;
var bool isSmkGenRand;

//Water hit
var(WaterFX) bool bWaterHitFX;
var(WaterFX) float WaterFXScale, WaterSpeedScale;
var(WaterFX) byte WaterSplashType;
var(WaterFX) float WaterWaveSize;
var bool bHitWater;

//Other settings
var() float ProjAccel;
var() bool CanHitInstigator;
var() float HitInstigatorTimeOut;	//Only when CanHitInstigator=True and LifeSpan>0
var() bool bDirectHit;
var() float ExplosionNoise;
var() bool bDirDecal;
var vector initialDir;
var() float DmgRadius;
var() bool bNeverHurtInstigator;
var() bool bNoHurtTeam;
var() bool bDirectionalBlow;

//Timers Setting
var(TimeOut) float TimeOut1, TimeOut2, TimeOut3;
var(TimeOut) bool bRepeating1, bRepeating2, bRepeating3;
var bool bSet1, bSet2, bSet3;
var float TmCount1, TmCount2, TmCount3;

//Trailing
var(Trailing) class<Effects> TrailingClass;
var(Trailing) float TrailingSize;
var(Trailing) vector TrailingSpawnOffset;
var(Trailing) bool bReverseTrailingPoint;
var vector OldTrailingLoc;

//Modifiers
var int Kickback;
var float Splasher, MoreDamage;
var bool HealthGiver;

//Player owner saving (fix online games)
var byte savedTeam;
var string ownerName;


function BeginPlay()
{
local vector Dir;

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	Acceleration = Dir * ProjAccel;
	bCanTeleport = false;
	
	if (SpawnSound != None)
		PlaySound(SpawnSound);
		
	if (Instigator != None && Instigator.PlayerReplicationInfo != None)
	{
		ownerName = Instigator.PlayerReplicationInfo.PlayerName;
		savedTeam = Instigator.PlayerReplicationInfo.Team;
	}
}

function GiveSpecials(Actor A)
{
}

simulated function Tick(float Delta)
{
local vector CurLoc, offsetLoc;
local float distTrailingCount;

	Super.Tick(Delta);
	
	if (TimeOut1 > 0 && (bRepeating1 || !bSet1))
	{
		TmCount1 += Delta;
		if (TmCount1 >= TimeOut1)
		{
			bSet1 = True;
			TmCount1 = 0;
			TimedOut1();
		}
	}
	
	if (TimeOut2 > 0 && (bRepeating2 || !bSet2))
	{
		TmCount2 += Delta;
		if (TmCount2 >= TimeOut2)
		{
			bSet2 = True;
			TmCount2 = 0;
			TimedOut2();
		}
	}
	
	if (TimeOut3 > 0 && (bRepeating3 || !bSet3))
	{
		TmCount3 += Delta;
		if (TmCount3 >= TimeOut3)
		{
			bSet3 = True;
			TmCount3 = 0;
			TimedOut3();
		}
	}
	
	if (Level.NetMode != NM_DedicatedServer && TrailingClass != None && VSize(OldTrailingLoc) != 0)
	{
		offsetLoc = Location + (TrailingSpawnOffset >> Rotation) + Velocity*Delta;
		distTrailingCount = VSize(offsetLoc - OldTrailingLoc);
		while (distTrailingCount >= TrailingSize)
		{
			distTrailingCount -= TrailingSize;
			CurLoc = OldTrailingLoc + Normal(offsetLoc - OldTrailingLoc)*TrailingSize;
			if (bReverseTrailingPoint)
				Spawn(TrailingClass,,, OldTrailingLoc, rotator(CurLoc - OldTrailingLoc));
			else
				Spawn(TrailingClass,,, CurLoc, rotator(OldTrailingLoc - CurLoc));
			
			OldTrailingLoc = CurLoc;
		}
	}
}

//Timings
simulated function TimedOut1();
simulated function TimedOut2();
simulated function TimedOut3();

simulated function SetTimeOut1(float Tout, optional bool bRepeat)
{
	TimeOut1 = Tout;
	bRepeating1 = bRepeat; 
	bSet1 = False;
}

simulated function SetTimeOut2(float Tout, optional bool bRepeat)
{
	TimeOut2 = Tout;
	bRepeating2 = bRepeat; 
	bSet2 = False;
}

simulated function SetTimeOut3(float Tout, optional bool bRepeat)
{
	TimeOut3 = Tout;
	bRepeating3 = bRepeat; 
	bSet3 = False;
}

simulated function PostBeginPlay()
{
local bool bSpawnServer;

	bSpawnServer = (bSpawnServerTrail && !bNetTemporary);
	if ((bSpawnServer && Role == ROLE_Authority) || (!bSpawnServer && Level.NetMode != NM_DedicatedServer))
		SpawnTrail();	
	initialDir = vector(Rotation);
	
	if (enableSmokeGen && (!bClientOnlySmokeGen || Level.NetMode != NM_DedicatedServer))
	{
		if (SmokeGenRateMax == SmokeGenRateMin && SmokeGenRateMax > 0)
			SetTimer(1/SmokeGenRateMax, False);
		else if (SmokeGenRateMax > SmokeGenRateMin && SmokeGenRateMin > 0)
		{
			SetTimer(1/(SmokeGenRateMin + FRand()*(SmokeGenRateMax - SmokeGenRateMin)), False);
			isSmkGenRand = True;
		}
		else if (SmokeGenRateMin > SmokeGenRateMax && SmokeGenRateMax > 0)
		{
			SmokeGenRateMax = SmokeGenRateMin;
			SetTimer(1/SmokeGenRateMin, False);
		}
	}
	
	if (TrailingClass != None)
		OldTrailingLoc = Location + (TrailingSpawnOffset >> Rotation);
}

simulated function SpawnTrail()
{
	if (TrailClass1 != None)
	{
		Trail1 = Spawn(TrailClass1, Self,, Location + (TrailOffset1 >> Rotation));
		if (NaliTrail(Trail1) != None)
		{
			if (Role != ROLE_Authority)
				Trail1.RemoteRole = ROLE_None;
			NaliTrail(Trail1).SetPrePivot(TrailOffset1);
		}
	}
	if (TrailClass2 != None)
	{
		Trail2 = Spawn(TrailClass2, Self,, Location + (TrailOffset2 >> Rotation));
		if (NaliTrail(Trail2) != None)
		{
			if (Role != ROLE_Authority)
				Trail2.RemoteRole = ROLE_None;
			NaliTrail(Trail2).SetPrePivot(TrailOffset2);
		}
	}
}

simulated function Timer()
{
	if (!bClientOnlySmokeGen || Level.NetMode != NM_DedicatedServer)
	{
		if (SmokeClass != None && (!Region.Zone.bWaterZone || bSmokeGenUnderWater))
		{
			Spawn(SmokeClass,,, Location + ((SmokeXOffset*vect(1,0,0)) >> Rotation));
			if (isSmkGenRand)
			{
				if (!Region.Zone.bWaterZone)
					SetTimer(1/(SmokeGenRateMin + FRand()*(SmokeGenRateMax - SmokeGenRateMin))*(Speed/FMax(1,VSize(Velocity))), False);
				else if (bSmokeGenUnderWater)
					SetTimer(1/(SmokeGenRateMin + FRand()*(SmokeGenRateMax - SmokeGenRateMin)*WaterSpeedScale)*(Speed*WaterSpeedScale/FMax(1,VSize(Velocity))), False);
			}
			else
			{
				if (!Region.Zone.bWaterZone)
					SetTimer(1/SmokeGenRateMax*(Speed/FMax(1,VSize(Velocity))), False);
				else if (bSmokeGenUnderWater)
					SetTimer(1/(SmokeGenRateMax * WaterSpeedScale)*(Speed*WaterSpeedScale/FMax(1,VSize(Velocity))), False);
			}
		}
		else if (UnderWaterSmokeClass != None && Region.Zone.bWaterZone)
		{
			Spawn(UnderWaterSmokeClass,,, Location + ((UnderWaterSmokeXOffset*vect(1,0,0)) >> Rotation));
			if (isSmkGenRand)
				SetTimer(1/(UnderWaterSmokeGenRateMin + FRand()*(UnderWaterSmokeGenRateMax - UnderWaterSmokeGenRateMin))*(Speed*WaterSpeedScale/FMax(1,VSize(Velocity))), False);
			else
				SetTimer(1/UnderWaterSmokeGenRateMax*(Speed*WaterSpeedScale/FMax(1,VSize(Velocity))), False);
		}
		else
			SetTimer(0.5, False);
	}
}

simulated function Destroyed()
{
	if (Trail1 != None)
		Trail1.Destroy();
	if (Trail2 != None)
		Trail2.Destroy();
		
	Trail1 = None;
	Trail2 = None;
		
	Super.Destroyed();
}

simulated singular function ZoneChange(Zoneinfo NewZone)
{
local waterring w;
local vector Dir;
	
	Dir = Normal(Velocity);
	if (NewZone.bWaterZone && default.LifeSpan == LifeSpan && !bHitWater)
	{
		bHitWater = True;
		Velocity = WaterSpeedScale * speed * Dir;
		Acceleration = Dir * ProjAccel;
		return;
	}
	if (NewZone.bWaterZone == bHitWater || default.LifeSpan == LifeSpan) 
		return;
	
	bHitWater = NewZone.bWaterZone;
	if (Level.NetMode != NM_DedicatedServer && bWaterHitFX)
	{
/*		if (Class'NWInfo'.default.bEnhancedWaterSplashes)
			SpawnWaterSplash(NewZone.bWaterZone, NewZone);
		else
		{*/
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
			w.DrawScale = WaterFXScale;
//		}
	}
	
	if (NewZone.bWaterZone)
		Velocity = WaterSpeedScale * speed * Dir;
	else if (Physics != PHYS_Falling)
		Velocity = speed * Dir;
	Acceleration = Dir * ProjAccel;
}

/*
simulated function SpawnWaterSplash(bool inWater, ZoneInfo WZone)
{
	Class'NWUtils'.static.SpawnWaterSplash(Self, WaterSplashType, inWater, WZone, WaterWaveSize);
}
*/

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ((!CanHitInstigator || (CanHitInstigator && (Default.LifeSpan - LifeSpan) < HitInstigatorTimeOut)) && Other == Instigator)
		return;
	
	if (Other.IsA('Projectile') && !Other.bProjTarget)
		return;
	
	if (bDirectHit)
		DirectHurtProcess( Other, HitLocation);

	ExplodeX( HitLocation, Normal(HitLocation-Other.Location), Other);
}

simulated function SetWallDecal( vector HitNormal, actor Wall)
{
local Decal d;
local bool bFog;

	if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer))
	{
//		bFog = Region.Zone.bFogZone;
//		if (bFog)
//			Region.Zone.bFogZone = false;
			
        d = Spawn(ExplosionDecal,self,,Location, rotator(HitNormal));
		
		if (bDirDecal && DirectionalBlast(d) != None)
			DirectionalBlast(d).DirectionalAttach( initialDir, HitNormal);
		
		if (!bNetTemporary && Level.NetMode != NM_StandAlone)
			ExplosionDecal = None;
		
//		Region.Zone.bFogZone = bFog;
	}
}

simulated function HitWall ( vector HitNormal, actor Wall)
{
    if ( Role == ROLE_Authority )
    {
        if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
            Wall.TakeDamage( Damage * FMax(1.0,MoreDamage), instigator, Location, MomentumTransfer * Normal(Velocity) * (KickBack + 1), '');
    }
	
    Explode(Location + ExploWallOut * HitNormal, HitNormal);
    SetWallDecal( HitNormal, Wall);
	ExplodeOnWall(HitNormal, Wall);
}

function ExplodeOnWall(vector HitNormal, actor Wall);

simulated function ExplodeX(vector HitLocation, vector HitNormal, optional actor A)
{
	BlowUp(HitLocation);
	Destroy();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	ExplodeX( HitLocation, HitNormal);
}

function BlowUp(vector HitLocation)
{
	MakeNoise(ExplosionNoise);
	if (DmgRadius > 0)
		HurtRadiusX(Damage * FMax(1.0,MoreDamage), DmgRadius * FMax(1.0, Splasher), MyDamageType, MomentumTransfer * (KickBack + 1), HitLocation);
}

function DirectHurtProcess(actor A, vector HitLocation)
{
local Pawn P;
local vector dir;
local int tempKick;

	P = Pawn(A);
	if (HealthGiver && giveFiredHealth(P, Damage))
		return;
	if (A != self && !ProcessHurtRadiusVictim(A) && !noHurtThisPawn(P))
	{
		tempKick = KickBack;
		if (!isAllowedToKick(Instigator, P))
			tempKick = 0;
		if (!bDirectionalBlow)
			dir = Normal(A.Location - HitLocation);
		else
			dir = Normal(Velocity);
		A.TakeDamage(Damage * FMax(1.0,MoreDamage), Instigator, HitLocation, (MomentumTransfer * (tempKick + 1) * dir), MyDamageType);
	}
}

function bool noHurtThisPawn(Pawn P)
{
return false;
//	return Class'NWUtils'.static.isFriend(P, Level, Instigator, savedTeam, bNoHurtTeam, bNeverHurtInstigator, ownerName, Self);
}

function bool isAllowedToKick(Pawn Inst, Pawn P)
{
return true;
//	return Class'NWUtils'.static.isAllowedToKick(Inst, P, Level, Kickback, savedTeam, ownerName, Self);
}

function HurtRadiusX(float DamageAmount, float DamageRadius, name DamageName, float Momentum, vector HitLocation)
{
local actor Victims;
local float damageScale, dist;
local vector dir, mdir;
local Pawn P;
local float tempKick;
    
    if (bHurtEntry)
        return;

    bHurtEntry = true;
    foreach VisibleCollidingActors(class 'Actor', Victims, DamageRadius, HitLocation)
    {
		P = Pawn(Victims);
		damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
		if (HealthGiver && giveFiredHealth(P, damageScale * DamageAmount))
			continue;
		
		if (Victims != self && !ProcessHurtRadiusVictim(Victims) && !noHurtThisPawn(P))
		{
			dir = Normal(Victims.Location - HitLocation);
			dist = FMax(1, VSize(Victims.Location - HitLocation));
			mdir = dir;
			tempKick = 1;
			
			if (!isAllowedToKick(Instigator, P))
				tempKick += KickBack;
			if (bDirectionalBlow)
				mdir = Normal(Velocity);
			
			Victims.TakeDamage(damageScale * DamageAmount, Instigator, 
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * (Momentum/tempKick) * mdir), DamageName);
		}
		
		PostProcessVictim(Victims);
    }

    bHurtEntry = false;
}

function bool ProcessHurtRadiusVictim(Actor Victim)
{
	return False;
}

function PostProcessVictim(Actor Victim);

simulated function ShakePlayers(float shaketime, float RollMag, float vertmag, float MaxRange)
{
local Pawn P;
local float magCoef;

	for (P=Level.PawnList; P!=None; P=P.NextPawn)
	{
		if (P.IsA('PlayerPawn') && (VSize(P.Location - Location) < MaxRange))
		{
			magCoef = FMax(0.1, MaxRange - VSize(Location - P.Location));
			PlayerPawn(P).ShakeView(shaketime, magCoef * RollMag / MaxRange, magCoef * vertmag / MaxRange);
		}
	}
}

function bool giveFiredHealth(Actor Other, float dmg)
{
/*	if (Pawn(Other) == None || Instigator == None || Pawn(Other).PlayerReplicationInfo == None || Instigator.PlayerReplicationInfo == None)
		return False;
	if (HealthGiver && (Pawn(Other) == Instigator || Class'NWUtils'.static.isFriend(Pawn(Other), Level, Instigator, savedTeam, True,, ownerName, Self)))
		return Class'NWUtils'.static.processFiredHealth(Int(dmg * FMax(1.0, MoreDamage)), Pawn(Other), Instigator);
*/
	return False;
}

defaultproperties
{
	WaterFXScale=0.200000
	WaterSpeedScale=0.600000
	WaterSplashType=1
	ProjAccel=50.000000
	HitInstigatorTimeOut=0.500000
	ExplosionNoise=0.500000
	RemoteRole=ROLE_SimulatedProxy
}
