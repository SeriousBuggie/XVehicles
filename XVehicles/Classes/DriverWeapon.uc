Class DriverWeapon extends Weapon;

var Vehicle VehicleOwner;
var DriverWNotifier MyNotifier;
var bool bPassengerGun;
var byte SeatNumber;

var() config bool UseStandardCrosshair;

simulated event RenderOverlays( canvas Canvas );

function PostBeginPlay()
{
	bOwnsCrosshair = !class'DriverWeapon'.default.UseStandardCrosshair;
	MyNotifier = Spawn(Class'DriverWNotifier');
	MyNotifier.WeaponOwner = Self;
	Inventory = MyNotifier;
}
event TravelPostAccept()
{
	Destroy();
}

Auto State DoNothing
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

/* Functions used by Unreal Tournament */
function ForceFire()
{
	Fire(0);
}
function ForceAltFire()
{
	AltFire(0);
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
		MyNotifier.Destroy();
		MyNotifier = None;
	}
	Super.Destroyed();
}
function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn);
function TraceFire( float Accuracy );

defaultproperties
{
      VehicleOwner=None
      MyNotifier=None
      bPassengerGun=False
      SeatNumber=0
      UseStandardCrosshair=False
      DeathMessage=""
      bHidden=True
      bGameRelevant=True
      bCarriedItem=True
}
