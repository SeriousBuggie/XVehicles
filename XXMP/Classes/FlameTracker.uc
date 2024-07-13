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

	if (Owner == None || Owner.bDeleteMe || 
		(Region.Zone.bWaterZone && !Region.Zone.IsA('LavaZone') && Region.Zone.DamageType != 'Burned'))
	{
		Destroy();
		return;
	}
	
	if (Level.NetMode != NM_Client)
		PlaySound(FlameSound, SLOT_Misc);
	
	if (Level.NetMode == NM_DedicatedServer)
		return;
	
	Scale = 1;
	if (LifeSpan < 1)
		Scale = Max(0.001, LifeSpan);
	
	e = Spawn(SmokeClass);
	e.DrawScale *= Scale*Owner.CollisionRadius/ScaleSmoke;
	
	e = Spawn(FlameClass);
	e.DrawScale *= Scale*Owner.CollisionRadius/ScaleFire;
	
	Mass /= 1.1;
	if (Mass > 0 && LifeSpan > 0.25)
		Owner.TakeDamage(Mass, instigator, Owner.Location, vect(0, 0, 0), 'burned');
}

function Destroyed()
{
	if (Owner != None)
		Owner.bShadowCast = False;
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
