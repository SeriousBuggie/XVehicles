Class DriverCameraActor extends Info;

var Vehicle VehicleOwner;
var byte SeatNum;
var WeaponAttachment GunAttachM;

var float DesiredViewMult, CurrentViewMult, OldDesiredViewMult, KeepWait;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		VehicleOwner,SeatNum,GunAttachM,DesiredViewMult;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	class'CameraMaster'.static.Init(self);	
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
	if (Bot(GetCamOwner()) != None)
		return;

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
	local Pawn P;
	local PlayerPawn PP;
	local bool bPasengerCam;
	
	if (KeepWait <= 0)
	{
		if (CurrentViewMult != DesiredViewMult)
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
	}
	else
		KeepWait -= Delta;

	RRoll = Rotation.Roll;
	
	bPasengerCam = Class != Class'DriverCameraActor';

	if (bPasengerCam)
	{
		P = Pawn(Owner);
		if (P == None)
			return;
		if (GunAttachM != None)
		{
			R.Pitch = GunAttachM.TurretPitch;
			R.Yaw = GunAttachM.TurretYaw;
		}
		else if (VehicleOwner != None)
			R = VehicleOwner.Rotation;
	}
	else
	{
		if( Owner==None)
			Return;
		if( VehicleOwner==None )
			VehicleOwner = Vehicle(Owner);
		P = Pawn(Owner.Owner);
	}
	if( P == None || VehicleOwner==None )
		Return;
	PP = PlayerPawn(P);
	if( PP != None && Level.NetMode!=NM_Client && !VehicleOwner.bVehicleBlewUp )
	{
		if( PP.ViewTarget==None && (bPasengerCam || VehicleOwner.bDriving) ) // In case player typed 'ViewSelf'
			PP.ViewTarget = Self;
		else if( !bPasengerCam && PP.ViewTarget==Self && !VehicleOwner.bDriving )
			PP.ViewTarget = None;
		else if( bPasengerCam && PP.bBehindView && PP.ViewTarget==Self )
			PP.bBehindView = False;
	}
	VehicleOwner.CalcCameraPos(V,R,CurrentViewMult,SeatNum,self);
	Move(V-Location);

	//Vertical shake support
	if (PP != None)
		MoveSmooth(PP.ShakeVert * 0.01 * vect(0,0,1));

	R.Roll = RRoll;
	SetRotation(R);
}

simulated function Pawn GetCamOwner()
{
	if (Class != Class'DriverCameraActor')
		return Pawn(Owner);
	If (Owner == None)
		return None;
	return Pawn(Owner.Owner);
}

function SetCamOwner(Actor NewOwner)
{
	local Pawn CamOwner;
	
	CamOwner = GetCamOwner();
	
	if (NewOwner == None && CamOwner == None)
		return;
	if (NewOwner != None && CamOwner != None)
	{
		if (PlayerPawn(CamOwner) != None)
		{
			PlayerPawn(CamOwner).ViewTarget = None;
			PlayerPawn(CamOwner).bBehindView = false;
		}
		ChangeCam(self, CamOwner);
	}
	if (Class != Class'DriverCameraActor')
		SetOwner(NewOwner);
	if (PlayerPawn(NewOwner) != None)
	{
		PlayerPawn(NewOwner).ViewTarget = self;
		PlayerPawn(NewOwner).bHiddenEd = PlayerPawn(NewOwner).bBehindView;
		PlayerPawn(NewOwner).bBehindView = false;
	}
	else if (Bot(NewOwner) != None)
		DesiredViewMult = default.DesiredViewMult;
	if (NewOwner == None)
		ChangeCam(self, CamOwner);
	else
		ChangeCam(NewOwner, self);
}

function ChangeCam(Actor IfView, Actor ThenView)
{
	Local Pawn P;
	local PlayerPawn Player;

	for (P=Level.PawnList; P!=None; P=P.nextPawn)
	{
		Player = PlayerPawn(P);
		if (Player != None && Player != ThenView && Player.ViewTarget == IfView)
		{
			Player.ViewTarget = ThenView;
			if (ThenView == self)
			{
				Player.bHiddenEd = Player.bBehindView;
				Player.bBehindView = false;					
			}
			else if (ThenView == None)
				Player.bBehindView = false;
			else
				Player.bBehindView = Player.bHiddenEd;
		}
	}
}

simulated function RenderOverlays( canvas Canvas )
{
	if (VehicleOwner != None)
		VehicleOwner.RenderCanvasOverlays(Canvas,Self,SeatNum);
}

simulated function Destroyed()
{
/*
	if (PlayerPawn(Owner) != None) // passenger
		PlayerPawn(Owner).ViewTarget = None;
	else if (Owner != None && PlayerPawn(Owner.Owner) != None) // driver
		PlayerPawn(Owner.Owner).ViewTarget = None;
*/
	SetCamOwner(None);

	Super.Destroyed();
}

defaultproperties
{
	DesiredViewMult=1.000000
	CurrentViewMult=1.000000
	OldDesiredViewMult=1.000000
	bHidden=False
	RemoteRole=ROLE_SimulatedProxy
	Texture=None
	CollisionRadius=0.000000
	CollisionHeight=0.000000
}
