Class DriverCameraActor extends Info;

var Vehicle VehicleOwner;
var byte SeatNum;
var WeaponAttachment GunAttachM;

var float DesiredViewMult, CurrentViewMult, OldDesiredViewMult, KeepWait;

// Chase view smoothing (see SmoothView)
var vector HeldOffset;	// where the view is held, from the focus, in the view's frame
var float LastWantSq;	// squared distance the view wanted last frame
var float ViewHold;		// time left before the view may back off
var float LastDelta;
var bool bViewHeld;

const ViewHoldTime = 0.3;
const ViewEaseRate = 20.0;	// exp(-20*0.15) = 0.05, so about 0.15s for the whole move

replication
{
	// Variables the server should send to the client.
	reliable if (Role == ROLE_Authority)
		VehicleOwner, SeatNum, GunAttachM, DesiredViewMult;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if (Level.PawnList != None || class'VActor'.static.IsDemoPlayback(Level))
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
	LastDelta = Delta;
	VehicleOwner.CalcCameraPos(V,R,CurrentViewMult,SeatNum,self);
	Move(V-Location);

	//Vertical shake support
	if (PP != None)
		MoveSmooth(PP.ShakeVert * 0.01 * vect(0,0,1));

	R.Roll = RRoll;
	SetRotation(R);
}

// Pos is where the chase view wants to be (walls already taken in), Focus is what it looks from.
// A pull closer is taken at once. When Pos backs off, the view stays where it was while that
// spot is still clear from the focus, for ViewHoldTime, then eases to Pos; a new pull-in in the
// meantime restarts the wait. So beams overhead do not make it jump back and forth.
// The held spot lives in the view's frame, so turning the view stays instant.
// While held the view is off Pos, and the aim still starts from Pos.
simulated function vector SmoothView(vector Pos, vector Focus, rotator Rot)
{
	local vector Want, Shown, HL, HN;
	local float WantSq;

	if (Level.NetMode == NM_DedicatedServer)
		return Pos;
	Want = (Pos - Focus) << Rot;
	WantSq = Want dot Want;
	if (!bViewHeld || WantSq <= (HeldOffset dot HeldOffset))
	{
		HeldOffset = Want;
		ViewHold = ViewHoldTime;
		LastWantSq = WantSq;
		bViewHeld = true;
		return Pos;
	}
	// pulled in again, even if not as far as the held spot (the next beam): wait anew.
	// 0.9 of the square is about 5% of the distance, so ride jitter does not count
	if (WantSq < LastWantSq*0.9)
		ViewHold = ViewHoldTime;
	LastWantSq = WantSq;
	if (ViewHold > 0.f)
		ViewHold -= LastDelta;
	else
	{
		HeldOffset += (Want - HeldOffset)*(1.0 - Exp(-ViewEaseRate*LastDelta));
		// within 1 uu: there
		Shown = Want - HeldOffset;
		if ((Shown dot Shown) < 1.f)
		{
			HeldOffset = Want;
			return Pos;
		}
	}
	Shown = Focus + (HeldOffset >> Rot);
	// the held spot is no longer clear: go where the walls put the view
	if (Trace(HL, HN, Shown, Focus, false) != None)
	{
		HeldOffset = Want;
		return Pos;
	}
	return Shown;
}

simulated function Pawn GetCamOwner()
{
	if (Class != Class'DriverCameraActor')
		return Pawn(Owner);
	If (Owner == None)
		return None;
	return Pawn(Owner.Owner);
}

simulated function SetCamOwner(Actor NewOwner)
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

simulated function ChangeCam(Actor IfView, Actor ThenView)
{
	Local Pawn P;
	local PlayerPawn Player;
	
	if (class'VActor'.static.IsDemoPlayback(Level))
		foreach AllActors(class'PlayerPawn', Player)
			ChangePlayerCam(Player, IfView, ThenView);
	else
		for (P = Level.PawnList; P != None; P = P.nextPawn)
			if (PlayerPawn(P) != None)
				ChangePlayerCam(PlayerPawn(P), IfView, ThenView);
}

simulated function ChangePlayerCam(PlayerPawn Player, Actor IfView, Actor ThenView)
{
	if (Player != None && Player != ThenView && Player.ViewTarget == IfView)
	{
		Player.SetPropertyText("bLockOn", "False"); // udemo playback hack
		Player.ViewTarget = ThenView;
		if (DriverCameraActor(ThenView) != None)
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
	NetPriority=1.500000
	NetUpdateFrequency=100.000000
}
