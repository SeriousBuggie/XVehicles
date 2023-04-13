//=============================================================================
// XVGWRI.
//=============================================================================
class XVGWRI expands ReplicationInfo;

var XVGTabWindow TabWindow;
var UWindowWindow TheWindow;

var() Class<UWindowWindow> WindowClass;

var() int  WinLeft;
var() int  WinTop;
var() int  WinWidth;
var() int  WinHeight;
var() bool DestroyOnClose;

var bool   bOpenWindowDispatched;
var bool   bSetupWindowDelayDone;
var bool   bDestroyRequested;

var bool bInitialized;
var string sVersion;
var int	TicksPassed;

replication
{
	reliable if (Role == ROLE_Authority)
		OpenWindow, CloseWindow;

	reliable if (Role < ROLE_Authority)
		DestroyWRI;
}

event PostBeginPlay()
{
	Super.PostBeginPlay();

	if (!bInitialized)
	{
		OpenIfNecessary();
		bInitialized = true;
	}
}

simulated event PostNetBeginPlay()
{
	PostBeginPlay();
	OpenIfNecessary();
}

simulated function OpenIfNecessary()
{
	local PlayerPawn P;

	if (Owner != None)
	{
		P = PlayerPawn(Owner);
		if (P != None && P.Player != None && P.Player.Console != None)
			OpenWindow();
	}
}

simulated function bool OpenWindow()
{
	local PlayerPawn P;
	local WindowConsole C;

	P = PlayerPawn(Owner);
	if (P == None)
	{
		Log("#### -- Attempted to open a window on something other than a PlayerPawn");
		DestroyWRI();
		return False;
	}

	C = WindowConsole(P.Player.Console);

	if (C == None)
	{
		Log("#### -- No Console");
		DestroyWRI();
		return False;
	}
	
	if (C.bTyping)
	{
		SetTimer(0.50, False);
		return False;
	}

	bOpenWindowDispatched = True;

	if (!C.bCreatedRoot || C.Root == None)
		C.CreateRootWindow(None);

	C.bQuickKeyEnable = True;
	C.LaunchUWindow();
	TicksPassed = 1;
	return True;
}

simulated function Tick(float DeltaTime)
{
	if (TicksPassed != 0 && TicksPassed++  == 5)
	{
		SetupWindow();
		TicksPassed = 0;
	}
	// 1st port of call
	if (DestroyOnClose && TheWindow != None && !TheWindow.bWindowVisible && !bDestroyRequested)
	{
		bDestroyRequested = True;
		DestroyWRI();
	}
}

simulated function bool SetupWindow()
{
	if (!bSetupWindowDelayDone)
	{
		SetTimer(1.00, False);
		return False;
	}

	if (SetWindow())
	{
		TabWindow = XVGTabWindow(XVGWindowFrame(TheWindow).ClientArea);
		SetTimer(1.00, False);
	}
}

simulated function bool SetWindow()
{
	local WindowConsole C;

	C = WindowConsole(PlayerPawn(Owner).Player.Console);
	TheWindow = C.Root.CreateWindow(WindowClass, WinLeft, WinTop, WinWidth, WinHeight);

	if (TheWindow == None)
	{
		DestroyWRI();
		return False;
	}

	if (C.bShowConsole)
		C.HideConsole();

	TheWindow.bLeaveOnscreen = True;
	TheWindow.ShowWindow();
	return True;
}

simulated function Timer()
{
	if (!bOpenWindowDispatched)
	{
		OpenWindow();
		return;
	}

	if (!bSetupWindowDelayDone)
	{
		bSetupWindowDelayDone = True;
		SetupWindow();
	}
}

simulated function CloseWindow()
{
	local WindowConsole C;

	if (PlayerPawn(Owner) != None)
	{
	   C = WindowConsole(PlayerPawn(Owner).Player.Console);
	   C.bQuickKeyEnable = False;
	}

	if (TheWindow != None)
	{
		TheWindow.Close();
		TabWindow.Close();
	}
}

function DestroyWRI()
{
	Destroy();
}

defaultproperties
{
	WindowClass=Class'XVGWindowFrame'
	WinWidth=600
	WinHeight=450
	DestroyOnClose=True
	bAlwaysRelevant=False
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=2.000000
	NetUpdateFrequency=2.000000
}
