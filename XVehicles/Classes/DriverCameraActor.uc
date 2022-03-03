Class DriverCameraActor extends Info;

var Vehicle VehicleOwner;
var byte SeatNum;
var WeaponAttachment GunAttachM;

var float DesiredViewMult, CurrentViewMult, OldDesiredViewMult, KeepWait;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority && bNetOwner && Class!=Class'DriverCameraActor' )
		VehicleOwner,SeatNum,GunAttachM;
}

function KeepView()
{
local bool b;

	KeepWait = 0.15;
	b = CurrentViewMult < (DesiredViewMult + OldDesiredViewMult) / 2;
	if ((b && CurrentViewMult < DesiredViewMult) || (!b && CurrentViewMult > DesiredViewMult))
	{
		DesiredViewMult = OldDesiredViewMult;
		CurrentViewMult = OldDesiredViewMult;
	}
	else
	{
		OldDesiredViewMult = DesiredViewMult;
		CurrentViewMult = DesiredViewMult;
	}
}

function ChangeView()
{
	if (KeepWait <= 0)
	{
		if (DesiredViewMult == 1.0)
			DesiredViewMult = 2.0;
		else if (DesiredViewMult == 2.0)
			DesiredViewMult = 3.0;
		else if (DesiredViewMult == 3.0)
			DesiredViewMult = 4.0;
		else
			DesiredViewMult = 1.0;
	}
}

simulated function Tick( float Delta )
{
	local vector V;
	local rotator R;
	local float RRoll;
	
	if (KeepWait <= 0)
	{
		if (CurrentViewMult < DesiredViewMult)
			CurrentViewMult += (FMax(0.1,Abs(CurrentViewMult - DesiredViewMult)) * Delta);
		else if (CurrentViewMult > DesiredViewMult)
			CurrentViewMult -= (FMax(0.1,Abs(CurrentViewMult - DesiredViewMult)) * Delta);
	
		if (CurrentViewMult != DesiredViewMult && Abs(CurrentViewMult - DesiredViewMult) < 0.025)
		{
			CurrentViewMult = DesiredViewMult;
			OldDesiredViewMult = DesiredViewMult;
		}
	}
	else
		KeepWait -= Delta;

	RRoll = Rotation.Roll;

	if( Owner==None )
		Return;
	if( VehicleOwner==None )
	{
		VehicleOwner = Vehicle(Owner);
		if( VehicleOwner==None )
			Return;
	}
	if( Owner==None || PlayerPawn(Owner.Owner)==None )
		Return;
	if(!VehicleOwner.bVehicleBlewUp )
	{
		if( PlayerPawn(Owner.Owner).ViewTarget==None && VehicleOwner.bDriving ) // In case player typed 'ViewSelf'
			PlayerPawn(Owner.Owner).ViewTarget = Self;
		else if( PlayerPawn(Owner.Owner).ViewTarget==Self && !VehicleOwner.bDriving )
			PlayerPawn(Owner.Owner).ViewTarget = None;
	}
	VehicleOwner.CalcCameraPos(V,R,CurrentViewMult);
	Move(V-Location);

	//Vertical shake support
	MoveSmooth(PlayerPawn(Owner.Owner).ShakeVert * 0.01 * vect(0,0,1));

	R.Roll = RRoll;
	SetRotation(R);
}
simulated function RenderOverlays( canvas Canvas )
{
	VehicleOwner.RenderCanvasOverlays(Canvas,Self,SeatNum);
}

simulated function Destroyed()
{
	if (PlayerPawn(Owner.Owner) != None)
		PlayerPawn(Owner.Owner).ViewTarget = None;

	Super.Destroyed();
}

defaultproperties
{
      VehicleOwner=None
      SeatNum=0
      GunAttachM=None
      DesiredViewMult=1.000000
      CurrentViewMult=1.000000
      OldDesiredViewMult=1.000000
      KeepWait=0.000000
      RemoteRole=ROLE_SimulatedProxy
}
