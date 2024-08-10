//=============================================================================
// FlameTracker.
//=============================================================================
class FlameTracker expands Effects;

var Class<Effects> SmokeClass;
var float ScaleSmoke;
var Class<Effects> FlameClass;
var float ScaleFire;
var Sound FlameSound;
var float ScaleSound;
var bool InDying;

simulated function PostBeginPlay()
{
	if (Role == ROLE_Authority && Owner != None)
	{
		SoundRadius *= Owner.CollisionRadius/ScaleSound;
		SoundVolume *= Owner.CollisionRadius/ScaleSound;
	}
	SetTimer(0.25, true);
}

simulated function Timer()
{
	local Effects e;
	local float Scale;
	local Carcass Carc;
	local PlayerReplicationInfo PRI;

	if (Owner == None || Owner.bDeleteMe || 
		(Region.Zone.bWaterZone && !Region.Zone.IsA('LavaZone') && Region.Zone.DamageType != 'Burned'))
	{
		Destroy();
		return;
	}
	
	Mass /= 1.1;
	if (Mass > 0 && LifeSpan > 0.25 && Carcass(Owner) == None)
	{
		if (!InDying)
			Owner.TakeDamage(Mass, instigator, Owner.Location, vect(0, 0, 0), 'burned');
		if (Owner.bDeleteMe || (InDying && !Owner.IsInState('Dying')))
		{
			Destroy();
			return;
		}
		if (Owner.IsInState('Dying'))
		{
			InDying = true;
			if (PlayerPawn(Owner) != None && Carcass(PlayerPawn(Owner).ViewTarget) != None)
				SetOwner(PlayerPawn(Owner).ViewTarget);
			else if (Pawn(Owner) != None && Pawn(Owner).PlayerReplicationInfo != None)
			{
				PRI = Pawn(Owner).PlayerReplicationInfo;
				foreach AllActors(Class'Carcass', Carc)
					if (Carc.PlayerOwner == PRI)
					{
						SetOwner(Carc);
						break;
					}
			}	
		}
	}
	
	if (Level.NetMode == NM_DedicatedServer)
		return;
	
	Scale = 1;
	if (LifeSpan < 1)
		Scale = Max(0.001, LifeSpan);
	
	e = Spawn(SmokeClass);
	e.DrawScale *= Scale*Owner.CollisionRadius/ScaleSmoke;
	
	e = Spawn(FlameClass);
	e.DrawScale *= Scale*Owner.CollisionRadius/ScaleFire;
	
	PlaySound(FlameSound, SLOT_Misc);
}

simulated function Destroyed()
{
	if (Role == ROLE_Authority && Owner != None)
		Owner.bShadowCast = False;
	if (Level.NetMode != NM_DedicatedServer)
		PlaySound(Sound'Silence', SLOT_Misc); // clear sound
}

defaultproperties
{
	SmokeClass=Class'XVehicles.VehEngBlackSmoke'
	ScaleSmoke=50.000000
	FlameClass=Class'XVehicles.VehDmgFire'
	ScaleFire=30.000000
	FlameSound=Sound'FT_FireLoop'
	ScaleSound=20.000000
	Physics=PHYS_Trailer
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=6.000000
	DrawType=DT_Mesh
	bGameRelevant=False
	Mass=0.000000
}
