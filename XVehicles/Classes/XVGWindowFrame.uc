//=============================================================================
// XVGWindowFrame.
//=============================================================================
class XVGWindowFrame expands UWindowFramedWindow;

function Created()
{
	Super.Created();

	bLeaveOnScreen = true;
	bMoving = true;
	bStatusBar = true;
	bSizable = False;

	SetSizePos();
	WindowTitle = "XVehicles v56";
}

function ResolutionChanged(float W, float H)
{
	SetSizePos();
	Super.ResolutionChanged(W, H);
}

function SetSizePos()
{
	SetSize(WinWidth, WinHeight);
	WinLeft = Max(0, (Root.WinWidth  - WinWidth)/2);
	WinTop  = Max(0, (Root.WinHeight - WinHeight)/2);
}

function Resized()
{
	if (ClientArea == None)
		return;

	Super.Resized();
}

function Close(optional bool bByParent)
{
	Root.Console.CloseUWindow();
	Super.Close(bByParent);
}

defaultproperties
{
	ClientClass=Class'XVehicles.XVGTabWindow'
}
