class DriverWeapon expands TournamentWeapon;

var Vehicle VehicleOwner;
var DriverWNotifier MyNotifier;
var bool bPassengerGun;
var byte SeatNumber;

var() config bool UseStandardCrosshair;

/*replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		VehicleOwner,SeatNumber;
}*/

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

event float BotDesireability( pawn Bot )
{
	return VehicleOwner.BotAttract.BotDesireability(Bot);
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

function float RateSelf( out int bUseAltMode )
{
	bUseAltMode = int(FRand() < 0.4);
	return (AIRating + FRand() * 0.05);
}

simulated event RenderOverlays( canvas Canvas );

function PostBeginPlay()
{
	bOwnsCrosshair = !class'DriverWeapon'.default.UseStandardCrosshair;
	MyNotifier = Spawn(Class'DriverWNotifier');
	//VehicleOwner.InitInventory(MyNotifier);
	MyNotifier.WeaponOwner = Self;
	Inventory = MyNotifier;
	
	setTimer(1, true);
}
event TravelPostAccept()
{
	Destroy();
}

Auto State ClientActive
{
Ignores BringUp,Finish;

	function bool PutDown()
	{
		bChangeWeapon = true;
		if( bPassengerGun )
			VehicleOwner.PassengerChangeBackView(SeatNumber);
		else
			VehicleOwner.ChangeBackView();
		return true;
	}
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

simulated function Timer()
{
/*	if (Role < ROLE_Authority) 
	{
		SetName();
		return;
	}*/

	if (!IsInState('ClientActive'))
		GotoState('ClientActive');
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
	if( bPassengerGun )
		VehicleOwner.PassengerLeave(SeatNumber);
	else VehicleOwner.DriverLeft(False);
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

simulated function TweenToStill();

defaultproperties
{
      VehicleOwner=None
      MyNotifier=None
      bPassengerGun=False
      SeatNumber=0
      UseStandardCrosshair=False
      bWarnTarget=True
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
}
