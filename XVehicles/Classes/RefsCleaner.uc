//=============================================================================
// RefsCleaner.
//=============================================================================
class RefsCleaner expands UWindowWindow;

var RefsCleaner Win;

static simulated function bool Init(PlayerPawn PP)
{
	local WindowConsole C;
	local RefsCleaner W;
	if (default.Win == None && PP != None && PP.Player != None)
	{
		C = WindowConsole(PP.Player.Console);
		if (C != None && C.Root != None)
		{
			W = RefsCleaner(C.Root.CreateWindow(default.Class, default.WinLeft, default.WinTop, default.WinWidth, default.WinHeight));
			if (W != None)
			{			
				W.SendToBack();
				default.Win = W;
			}
		}
	}
	return default.Win != None;
}

function NotifyBeforeLevelChange()
{
	CleanRefs();

	Super.NotifyBeforeLevelChange();
	
	default.Win = None;
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
	bAlwaysBehind=True
	bTransient=True
}
