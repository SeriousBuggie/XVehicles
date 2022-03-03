Class VehicleFactory extends Actor;

var() class<Vehicle> VehicleClass;
var() byte TeamNum;
var() bool bStartTeamLocked,bInitialActive;
var() float VehicleRespawnTime,VehicleResetTime;
var Vehicle MyVehicle;
var float NextRespawnTimer;
var bool bInitAct;
var byte InitialTeamNum;
var bool bDisableTeamSpawn; // replaced by class'VehiclesConfig'.default.bDisableTeamSpawn
var() bool bUseMultipleSpawn;

function PostBeginPlay()
{
	bInitAct = bInitialActive;
	InitialTeamNum = TeamNum;
	if( bInitialActive )
		SetTimer(1,False);
}
function Timer()
{
	if( !bInitialActive )
		Return;
	if( VehicleClass==None )
	{
		Error("Missing vehicle class!");
		Return;
	}
	if (MyVehicle != None && MyVehicle.bDeleteMe)
		MyVehicle = None;
	if (MyVehicle != None && VSize(MyVehicle.Location - Location) > 2*MyVehicle.CollisionRadius)
	{
		if (MyVehicle.ResetTimer <= 0)
			MyVehicle.CheckForEmpty();
		if (bUseMultipleSpawn)
		{
			PrepareNew();
			return;
		}
	}
	if( MyVehicle==None && NextRespawnTimer > Level.TimeSeconds )
	{
		SetTimer((NextRespawnTimer-Level.TimeSeconds),False);
		return;
	}
	if( MyVehicle==None )
	{
		MyVehicle = Spawn(VehicleClass);
		if( MyVehicle==None )
		{
			SetTimer(1,False);
			Return;
		}
		MyVehicle.MyFactory = Self;
		MyVehicle.CurrentTeam = TeamNum;
		MyVehicle.bTeamLocked = bStartTeamLocked;

		if (!class'VehiclesConfig'.default.bDisableTeamSpawn)
			MyVehicle.SetOverlayMat(MyVehicle.TeamOverlays[TeamNum],0.5);

		//MyVehicle.bDisableTeamSpawn = (MyVehicle.bDisableTeamSpawn || bDisableTeamSpawn);
		MyVehicle.ShowState();
	}
	SetTimer(1,False);
}
function PrepareNew()
{
	MyVehicle = None;
	NextRespawnTimer = Level.TimeSeconds+VehicleRespawnTime;
	if( !bInitialActive )
		Return;
	SetTimer(VehicleRespawnTime,False);
}
function NotifyVehicleDestroyed(Vehicle InVehicle)
{
	if (bUseMultipleSpawn && MyVehicle != InVehicle)
		return;
	PrepareNew();
}
function Reset()
{
	bInitialActive = bInitAct;
	TeamNum = InitialTeamNum;
	if( MyVehicle!=None )
	{
		MyVehicle.MyFactory = None;
		MyVehicle.Destroy();
	}
	NextRespawnTimer = 0;
	SetTimer(1,False);
}
event Trigger( Actor Other, Pawn EventInstigator )
{
	if( !bInitialActive )
	{
		bInitialActive = True;
		if( MyVehicle==None || MyVehicle.bDeleteMe )
		{
			if( NextRespawnTimer<=Level.TimeSeconds )
				SetTimer(0.5,False);
			else SetTimer((NextRespawnTimer-Level.TimeSeconds),False);
		}
	}
}
event UnTrigger( Actor Other, Pawn EventInstigator )
{
	if( bInitialActive )
	{
		bInitialActive = False;
		if( MyVehicle!=None && !MyVehicle.bDeleteMe && !MyVehicle.bHadADriver )
		{
			MyVehicle.MyFactory = None;
			MyVehicle.Destroy();
			MyVehicle = None;
		}
		SetTimer(0,False);
	}
}
function Destroyed()
{
	if( MyVehicle!=None && !MyVehicle.bDeleteMe )
	{
		if( !MyVehicle.bHadADriver )
		{
			MyVehicle.MyFactory = None;
			MyVehicle.Destroy();
			MyVehicle = None;
		}
		else MyVehicle.MyFactory = None;
	}
}

defaultproperties
{
      VehicleClass=None
      TeamNum=0
      bStartTeamLocked=True
      bInitialActive=True
      VehicleRespawnTime=5.000000
      VehicleResetTime=60.000000
      MyVehicle=None
      NextRespawnTimer=0.000000
      bInitAct=False
      InitialTeamNum=0
      bDisableTeamSpawn=True
      bUseMultipleSpawn=False
      bHidden=True
      RemoteRole=ROLE_None
      bDirectional=True
      DrawType=DT_Mesh
      Mesh=LodMesh'UnrealShare.WoodenBoxM'
      bCollideWhenPlacing=True
      bCollideWorld=True
}
