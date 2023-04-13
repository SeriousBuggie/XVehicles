//=============================================================================
// XVGTabPage.
//=============================================================================
class XVGTabPage expands UWindowPageWindow;

function KeyDown(int Key, float X, float Y)
{
	ParentWindow.KeyDown(Key,X,Y);
}

function NotifyBeforeLevelChange()
{
	ParentWindow.ParentWindow.Close();
}

defaultproperties
{
	bIgnoreLDoubleClick=True
	bIgnoreMDoubleClick=True
	bIgnoreRDoubleClick=True
}
