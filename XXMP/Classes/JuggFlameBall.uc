//=============================================================================
// JuggFlameBall.
//=============================================================================
class JuggFlameBall expands GasBagBelch;

var(Projectile) float    DamageRadius;

function SetUp()
{
	Velocity = Vector(Rotation) * speed + VRand()*(Speed/8);
	if (Owner != None)
		Velocity += Owner.Velocity;
	SetTimer(0.5, True);
}

simulated function PostBeginPlay()
{
	SetUp();
	if (Level.NetMode != NM_DedicatedServer)
		Texture = SpriteAnim[Rand(6)];
}

function bool IsSameTeam(int CurrentTeam, Pawn Pawn)
{
	return Level.Game.bTeamGame && Pawn != none && Pawn.PlayerReplicationInfo != None && 
		Pawn.PlayerReplicationInfo.Team == CurrentTeam;
}

auto state Flying
{
	simulated function ProcessTouch(Actor Other, Vector HitLocation)
	{
		if (Role == ROLE_Authority && Other != instigator && Other != Owner)
			Other.TakeDamage(Damage*FRand(), instigator, HitLocation, vect(0, 0, 0), 'burned');
	}
	simulated function Explode(vector HitLocation, vector HitNormal);

Begin:
	Stop;
}

function Timer()
{
	local actor Victims;
	local vector HL, HN;
	local float DamageAmount;
    local int CurrentTeam;
    
    if( bHurtEntry )
        return;

    bHurtEntry = true;
    if (Instigator != none && Instigator.PlayerReplicationInfo != None)
	    CurrentTeam = Instigator.PlayerReplicationInfo.Team;
	else
		CurrentTeam = -1;
	foreach VisibleCollidingActors(class'Actor', Victims, DamageRadius, Location)
	{
		if (Victims != self && Victims != Owner && Victims != Instigator)
        {
	        DamageAmount = Damage;
	        if (IsSameTeam(CurrentTeam, Pawn(Victims)))
            	DamageAmount = 0;
			if (FastTrace(Victims.Location, Location) &&
				Trace(HL, HN, Victims.Location, Location, False) == None)
			{
				DamageAmount *= FRand();
				Victims.TakeDamage(DamageAmount, instigator, Victims.Location, vect(0, 0, 0), 'burned');
				if (LifeSpan > 0.25 && DamageAmount > 0)
					Ignite(Victims, DamageAmount);
			}
		}
	}
	bHurtEntry = false;
}

simulated function Tick(float Delta)
{
	local float TS;

	Velocity.Z += Delta*250.f;
	if (Level.NetMode == NM_DedicatedServer)
		return;
	TS = 1.f - (LifeSpan/Default.LifeSpan);
	if (TS < 0.5)
		DrawScale = Default.DrawScale*(TS*2.f);
	else
	{
		DrawScale = Default.DrawScale*(TS + 0.5);
		ScaleGlow = 1.f - (TS - 0.5f)*2.f;
		AmbientGlow = ScaleGlow*255;
	}
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	Velocity -= (Velocity dot HitNormal)*HitNormal;
}

simulated function ZoneChange(Zoneinfo NewZone)
{
	if (NewZone.bWaterZone && !NewZone.IsA('LavaZone') && NewZone.DamageType != 'Burned')
	{
		SpawnSmoke();
		Destroy();
	}
}

simulated function SpawnSmoke()
{
	local Effects s;

	if (Level.NetMode != NM_DedicatedServer)
	{
		s = Spawn(Class'SmokePuff');
		s.DrawScale = DrawScale * 2.15;
		s.ScaleGlow = ScaleGlow;
	}
}

function Ignite(Actor Victim, float DamageAmount)
{
	local FlameTracker ftc;
	local ZoneInfo VictZone;

	VictZone = Victim.Region.Zone;
	if (VictZone.bWaterZone && !VictZone.IsA('LavaZone') && VictZone.DamageType != 'Burned')
		return;

	if (Victim.IsA('CreatureChunks') || Victim.IsA('UTCreatureChunks'))
	{
		if (!Victim.bShadowCast)
		{
			Spawn(Class'FlameTracker', Victim,, Victim.Location);
			Victim.bShadowCast = True;
		}
	}
	else if (Victim.Mesh != None && (!Victim.bHidden || Victim.IsA('Vehicle')) && CheckInflamableActor(Victim))
	{	
		if (!Victim.bShadowCast)
		{
			ftc = Spawn(Class'FlameTracker', Victim,, Victim.Location);
			ftc.Mass = DamageAmount/2;
			ftc.Instigator = Instigator;
			Victim.bShadowCast = True;
		}
	}
}

function bool CheckInflamableActor(Actor A)
{	
	if (A.IsA('Pawn') || A.IsA('Vehicle'))
		return True;
	
	if (A.IsA('Decoration'))
		return (!(A.IsA('Boulder') || A.IsA('CTFFlag') || A.IsA('MonkStatue') || A.IsA('Vase')));
	
	return False;
}

defaultproperties
{
	DamageRadius=220.000000
	speed=800.000000
	Damage=20.000000
	LifeSpan=1.250000
	DrawScale=12.000000
	CollisionRadius=25.000000
	CollisionHeight=25.000000
	bBounce=True
}
