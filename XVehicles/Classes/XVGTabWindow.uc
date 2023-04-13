//=============================================================================
// XVGTabWindow.
//=============================================================================
class XVGTabWindow expands UWindowDialogClientWindow;

var XVGWRI XVGWRI;

var UWindowWindow TheWindow;

var UMenuPageControl Pages;

var XVGTabSettings TabSettings;
var XVGTabHelp TabHelp;

function Created()
{
	Super.Created();

	if (XVGWRI == None)
		foreach Root.GetPlayerOwner().AllActors(class'XVGWRI', XVGWRI)
			break;

	WinLeft = (Root.WinWidth - WinWidth)/2;
	WinTop = (Root.WinHeight - WinHeight)/2;

	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight - 15));
	Pages.SetMultiLine(false);

	TabSettings = XVGTabSettings(Pages.AddPage("Settings", class'XVGTabSettings').Page);

	TabHelp = XVGTabHelp(Pages.AddPage("Help", class'XVGTabHelp').Page);
}

defaultproperties
{
}
