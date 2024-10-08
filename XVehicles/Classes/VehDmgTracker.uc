//=============================================================================
// VehDmgTracker.
//=============================================================================
class VehDmgTracker expands Info;

var Pawn MyPawn;
var Vehicle MyVehicle;
var bool DesiredResult;

event FellOutOfWorld();

function VehDmgTracker Init(Pawn InPawn, Vehicle InVehicle, bool InDesiredResult)
{
	MyPawn = InPawn;
	MyVehicle = InVehicle;
	DesiredResult = InDesiredResult;
	return self;
}

function Check()
{
	if (MyPawn == None || MyVehicle == None || 
		MyPawn.Target != MyVehicle)
	{
		Destroy();
		return;
	}
	if (HealthTooLow(MyVehicle, DesiredResult) != DesiredResult)
	{
		MyPawn.Target = None;
		if (MyPawn.FaceTarget == MyVehicle)
			MyPawn.FaceTarget = None;
		if (Bot(MyPawn) != None)
			Class'WeaponAttachment'.static.StopFiring(MyPawn);
		Destroy();
	}	
}

function Destroyed()
{
	Super.Destroyed();
	GotoState('');
}

static function bool HealthTooLow(Vehicle Veh, bool bDesiredResult)
{
	local int OldHealth;
	local bool ret;
	local Projectile Proj;
	
	// fast check
	ret = Veh.HealthTooLowFor(None);
	if (ret != bDesiredResult)
		return ret;
	OldHealth = Veh.Health;
	foreach Veh.AllActors(class'Projectile', Proj, Veh.Name)
		Veh.Health -= Veh.Level.Game.ReduceDamage(Proj.Damage, Proj.MyDamageType, Class'Vehicle'.static.SpawnStubPawn(Veh), Proj.Instigator);
	if (bDesiredResult && Veh.Health <= 0)
		ret = false;
	else if (Veh.Health != OldHealth)
		ret = Veh.HealthTooLowFor(None);
	Veh.Health = OldHealth;
	return ret;
}

auto state Idle
{
Begin:
	Sleep(0.25); // like timer, but can't be stopped outside
	Check();
	Goto('Begin');
}

defaultproperties
{
	RemoteRole=ROLE_None
}
