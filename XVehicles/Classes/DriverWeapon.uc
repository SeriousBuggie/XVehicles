class DriverWeapon expands TournamentWeapon Config(XVehicles);

var Vehicle VehicleOwner;
var DriverWNotifier MyNotifier;
var bool bPassengerGun;
var byte SeatNumber;
var bool bDemoplay;

var Actor OldOwner;

var() config bool UseStandardCrosshair;

replication
{
	// Variables the server should send to the client.
	reliable if (Role == ROLE_Authority)
		VehicleOwner, SeatNumber, bPassengerGun;
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	InventoryGroup = Charge; // hack for net
	
//	SetName();
}

function PreBeginPlay()
{
	Super.PreBeginPlay();
	VehicleOwner = Vehicle(Owner);
	if (VehicleOwner == None)
		Destroy();
	else
		VehicleOwner.InitInventory(self);
}

function ChangeOwner(Actor NewOwner)
{
	local Pawn OldOwner;
	OldOwner = Pawn(Owner);
	SetOwner(NewOwner);
	if (OldOwner != None)
	{
		OldOwner.DeleteInventory(self);
		if (MyNotifier!=None)
			OldOwner.DeleteInventory(MyNotifier);
	}
	Inventory = MyNotifier;
}

event float BotDesireability(Pawn Bot)
{
	if (VehicleOwner != None)
		return VehicleOwner.BotDesireability2(Bot);
	return -1;
}

function float SuggestAttackStyle()
{
	if (VehicleOwner.Health < 0.5*VehicleOwner.default.Health)
		return -10.0; // cautious
	return 20.0; // aggressive	
}

function float SuggestDefenseStyle()
{
	return -10.0; // run away, vehicle override usage of this
}

function float RateSelf(out int bUseAltMode)
{
	bUseAltMode = int(FRand() < 0.4);
	return (AIRating + FRand() * 0.05);
}

simulated event RenderOverlays(canvas Canvas);

simulated function PostBeginPlay()
{
	bOwnsCrosshair = !class'DriverWeapon'.default.UseStandardCrosshair;
	if (Role == ROLE_Authority)
	{
		MyNotifier = Spawn(Class'DriverWNotifier');
		//VehicleOwner.InitInventory(MyNotifier);
		MyNotifier.WeaponOwner = Self;
		Inventory = MyNotifier;
	}
	
	if (Role == ROLE_Authority /*|| class'VActor'.static.IsDemoPlayback(Level)*/)
		setTimer(1, true);
		
	bDemoplay = class'VActor'.static.IsDemoPlayback(Level);
	if (!bDemoplay)
		Disable('Tick');
}
event TravelPostAccept()
{
	Destroy();
}

function ChangeCamera()
{
	if( bPassengerGun )
		VehicleOwner.PassengerChangeBackView(SeatNumber);
	else
		VehicleOwner.ChangeBackView();
}

auto state ClientActive
{
	ignores BringUp, Finish;

	function bool PutDown()
	{
		bChangeWeapon = true;
		return true;
	}
	
	simulated function AnimEnd() {}
	simulated function BeginState()
	{
		Mesh = PlayerViewMesh;
	}
}

state Idle
{
ignores BringUp,Finish;

	function bool PutDown()
	{
		bChangeWeapon = true;
		return true;
	}
	
	simulated function AnimEnd() {}
Begin:
}

function float SwitchPriority()
{
	return 340282346638528870000000000000000000000.0; // max float
}

simulated function SetName()
{
	if (ItemName == "Weapon")
	{
		if (VehicleOwner != None)
			ItemName = VehicleOwner.GetWeaponName(SeatNumber);
		else
			SetTimer(1, false);
	}
}

// Tick enabled only in demo playback. See PostBeginPlay
simulated function Tick(float Delta)
{
	local DriverCameraActor Camera;
	local DriverWeapon OtherWeapon;
	local Actor ViewTarget;
	
	if (!bDemoplay)
		Disable('Tick');
	else if (OldOwner != Owner)
	{
		if (VehicleOwner != None && (Pawn(OldOwner) != None || Pawn(Owner) != None))
		{
			Camera = VehicleOwner.GetCam(self);
			if (Camera != None)
			{
				if (Pawn(OldOwner) != None)
				{
					OtherWeapon = DriverWeapon(Pawn(OldOwner).Weapon);
					if (OtherWeapon != None && OtherWeapon.VehicleOwner != None)
						ViewTarget = OtherWeapon.VehicleOwner.GetCam(OtherWeapon);
					if (ViewTarget == None || ViewTarget == Camera)
						ViewTarget = OldOwner;
					Camera.ChangeCam(Camera, ViewTarget);
				}
				if (Pawn(Owner) != None)
					Camera.ChangeCam(Owner, Camera);
			}
		}
		OldOwner = Owner;
	}
}

simulated function Timer()
{
	local name DesiredState;
/*	if (Role < ROLE_Authority) 
	{
		SetName();
		return;
	}*/
	
	if (Level != None && Level.NetMode == NM_DedicatedServer)
		DesiredState = 'Idle';
	else
		DesiredState = 'ClientActive';

	if (!IsInState(DesiredState))
		GotoState(DesiredState);
	if (Pawn(Owner) != None && Pawn(Owner).Weapon != self)
	{
		Pawn(Owner).PendingWeapon = self;
		if (Pawn(Owner).Weapon != None)
			Pawn(Owner).Weapon.GoToState('');
		Pawn(Owner).Weapon = self;
	}	
}

/* Functions used by Unreal Tournament */
function ForceFire()
{
	Fire(0);
}
function ForceAltFire()
{
	AltFire(0);
}
simulated function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
}

function Fire(float F)
{
	if( bPassengerGun )
		VehicleOwner.PassengerFireWeapon(False,SeatNumber);
	else
		VehicleOwner.FireWeapon(False);
}
function AltFire(float F) 
{
	if( bPassengerGun )
		VehicleOwner.PassengerFireWeapon(True,SeatNumber);
	else
		VehicleOwner.FireWeapon(True);
}
function NotifyNewDriver( Pawn NewDriver );
function NotifyDriverLeft( Pawn OldDriver );
function DropFrom(vector StartLocation)
{
	local Bot Bot;
	if (bPassengerGun)
		VehicleOwner.PassengerLeave(SeatNumber);
	else VehicleOwner.DriverLeft(False);
	
	if (VehicleOwner.Driver == None && !VehicleOwner.HasPassengers())
		foreach VehicleOwner.RadiusActors(class'Bot', Bot, 800)
			if (Bot.PlayerReplicationInfo.Team != VehicleOwner.CurrentTeam)
				Bot.EnemyDropped = VehicleOwner.DWeapon; // enemy bots wanna steal vehicle
}

function Destroyed()
{
	if( MyNotifier!=None )
	{
		if (Pawn(Owner) != None)
			Pawn(Owner).DeleteInventory(MyNotifier);
		MyNotifier.Destroy();
		MyNotifier = None;
	}
	Super.Destroyed();
}
function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn);
function TraceFire( float Accuracy );

function SetupWeapon(WeaponAttachment WA)
{
	if (WA == None)
		return;
	bInstantHit = WA.WeapSettings[0].bInstantHit;
	bSplashDamage = !bInstantHit;
	bRecommendSplashDamage = bSplashDamage;
	bAltWarnTarget = WA.bAltFireZooms;
}

simulated function TweenToStill() {}

simulated function AnimEnd() {}

State ClientDown
{		
	simulated function AnimEnd() {}
	simulated function BeginState() {}
	simulated function Tick(float Delta)
	{
		Global.Tick(Delta);
	}
}

State DownWeapon
{
ignores Fire, AltFire;

Begin:
	TweenDown();
	FinishAnim();
	if (Pawn(Owner) != None)
		Pawn(Owner).ChangedWeapon();
}

defaultproperties
{
	bWarnTarget=True
	bWeaponUp=True
	AIRating=1.000000
	bRotatingPickup=False
	PickupMessage="You got a vehicle"
	ItemName="Vehicle"
	PlayerViewMesh=LodMesh'Botpack.AutoML'
	PlayerViewScale=0.000100
	PickupViewMesh=LodMesh'Botpack.MagPick'
	PickupViewScale=0.000100
	ThirdPersonMesh=LodMesh'Botpack.AutoHand'
	ThirdPersonScale=0.000100
	Charge=1
	MaxDesireability=10.000000
	bHidden=True
	Physics=PHYS_Trailer
	DrawType=DT_Sprite
	Mesh=LodMesh'Botpack.MagPick'
	DrawScale=0.000100
	bGameRelevant=True
	bCarriedItem=True
	CollisionHeight=24.000000
	bFixedRotationDir=False
	RotationRate=(Pitch=0,Yaw=0)
	NetPriority=2.000000
	NetUpdateFrequency=100.000000
}
