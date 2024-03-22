//=============================================================================
// RefsCleaner.
//=============================================================================
class RefsCleaner expands UWindowWindow;

var float LastWinTime;
var LevelInfo Level;

static simulated function bool Init(PlayerPawn PP)
{
	local WindowConsole C;
	local RefsCleaner W;
	local bool ret;
	ret = Abs(default.LastWinTime - PP.Level.TimeSeconds) < 3;
	if (!ret && PP != None && PP.Player != None)
	{
		C = WindowConsole(PP.Player.Console);
		if (C != None && C.Root != None)
		{
			W = RefsCleaner(C.Root.CreateWindow(default.Class, default.WinLeft, default.WinTop, default.WinWidth, default.WinHeight));
			if (W != None)
			{			
				W.SendToBack();
				W.Level = PP.Level;
				ret = true;
			}
		}
	}
	return ret;
}

function Tick(float Delta)
{
	if (Level != None)
		default.LastWinTime = Level.TimeSeconds;
}

function NotifyBeforeLevelChange()
{
	CleanRefs();

	Super.NotifyBeforeLevelChange();
	
	Level = None;
	default.LastWinTime = -100;
	Close(false);
}

function CleanRefs()
{
	Class'Vehicle'.default.StubPawn = None;
	Class'CameraMaster'.default.Master = None;
	Class'XVehiclesHUD'.default.UsedHUD = None;
}

defaultproperties
{
	LastWinTime=-100.000000
	bAlwaysBehind=True
	bTransient=True
}
