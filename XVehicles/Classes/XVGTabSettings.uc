//=============================================================================
// XVGTabSettings.
//=============================================================================
class XVGTabSettings expands XVGTabPage;

const BindCount = 9;

var() string AliasNames[BindCount];
var() localized string LabelList[BindCount];
var() localized string HelpText[BindCount];

var UMenuLabelControl KeyNames[BindCount];
var UMenuRaisedButton KeyButtons[BindCount];

var UMenuRaisedButton SelectedButton;
var int Selection;
var bool bPolling;

function Created()
{
	local int LabelWidth, LabelLeft, ButtonWidth, ButtonLeft, ButtonTop, i;
	local UMenuLabelControl Heading;
	local PlayerPawn PP;

	Super.Created();

	SetAcceptsFocus();
	
	LabelWidth = 100;
	LabelLeft = 20;

	ButtonWidth = 140;
	ButtonLeft = LabelLeft + LabelWidth + 20;
	
	ButtonTop = 25;
	
	Heading = UMenuLabelControl(CreateControl(class'UMenuLabelControl', LabelLeft - 10, ButtonTop + 3, LabelWidth, 1));
	Heading.SetText("Keybinds:");
	Heading.SetFont(F_Bold);
	
	ButtonTop += 30;
	
	PP = GetPlayerOwner();
	class'KeyBindObject'.static.Refresh(PP);
	
	for (i = 0; i < BindCount; i++)
	{
		KeyNames[i] = UMenuLabelControl(CreateControl(class'UMenuLabelControl', LabelLeft, ButtonTop + 3, LabelWidth, 1));
		KeyNames[i].SetText(LabelList[i]);
		KeyNames[i].SetHelpText(HelpText[i]);
		KeyNames[i].SetFont(F_Normal);
		KeyButtons[i] = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', ButtonLeft, ButtonTop, ButtonWidth, 1));
		KeyButtons[i].SetHelpText(HelpText[i]);
		KeyButtons[i].bAcceptsFocus = False;
		KeyButtons[i].bIgnoreLDoubleClick = True;
		KeyButtons[i].bIgnoreMDoubleClick = True;
		KeyButtons[i].bIgnoreRDoubleClick = True;
		
		KeyButtons[i].SetText(class'KeyBindObject'.static.FindKeyBinding(AliasNames[i], PP));
		
		ButtonTop += 30;
	}
}

/* // v469 stuff, break v436
function bool MouseWheelDown(float ScrollDelta)
{
	Super.MouseWheelDown(ScrollDelta);
	if (bPolling)
		return true;
	return false;
}

function bool MouseWheelUp(float ScrollDelta)
{
	local int Key;
	
	Super.MouseWheelUp(ScrollDelta);
	if (bPolling)
	{
		if (ScrollDelta > 0)
			Key = 0xED;
		else
			Key = 0xEC;
		ProcessMenuKey(Key, class'KeyBindObject'.static.GetKeyName(Key));
		bPolling = False;
		SelectedButton.bDisabled = False;
		return true;
	}
	return false;
}
*/

function KeyDown( int Key, float X, float Y )
{
	if (bPolling)
	{
		ProcessMenuKey(Key, class'KeyBindObject'.static.GetKeyName(Key));
		bPolling = False;
		SelectedButton.bDisabled = False;
	}
}

function ProcessMenuKey(int KeyNo, string KeyName)
{
	local string CurrBind;
	local PlayerPawn PP;
	local int i, pos;
	
	if (KeyName == "" || KeyName ~= "Escape"
		|| (KeyNo >= 0x70 && KeyNo <= 0x79) // function keys
		|| (KeyNo >= 0x30 && KeyNo <= 0x39)) // number keys
		return;
	
	PP = GetPlayerOwner();
	
	if (SelectedButton.Text == KeyName && PP.ConsoleCommand("KEYBINDING" @ KeyName) ~= AliasNames[Selection])
		return;
		
	if (SelectedButton.Text != "")
		PP.ConsoleCommand("SET INPUT" @ SelectedButton.Text @ 
			RemoveBind(PP.ConsoleCommand("KEYBINDING" @ SelectedButton.Text), AliasNames[Selection]));
		
	CurrBind = PP.ConsoleCommand("KEYBINDING" @ KeyName);
	if (CurrBind != "")
		CurrBind = CurrBind $ "|";
	CurrBind = CurrBind $ AliasNames[Selection];
	PP.ConsoleCommand("SET INPUT" @ KeyName @ CurrBind);

	class'KeyBindObject'.static.Refresh(PP);
	for (i = 0; i < BindCount; i++)
		KeyButtons[i].SetText(class'KeyBindObject'.static.FindKeyBinding(AliasNames[i], PP));
}

function string RemoveBind(string PrevBind, string Alias)
{
	local string PrevBindCaps, ALiasCaps;
	local int a, b;
	
	if (PrevBind ~= Alias)
		return "";
		
	PrevBindCaps = Caps(PrevBind);
	ALiasCaps = Caps(Alias);
	
	a = InStr(PrevBindCaps, ALiasCaps);
	if (a < 0)
		return PrevBind;
	b = a + Len(ALiasCaps);
	while (a > 0 && Mid(PrevBindCaps, a - 1, 1) == " ")
		a--;
	while (Mid(PrevBindCaps, b, 1) == " ")
		b++;
	if (Mid(PrevBindCaps, b, 1) == "|")
		b++;
	if (Len(PrevBindCaps) <= b && a > 0 && Mid(PrevBindCaps, a - 1, 1) == "|")
		a--;
	
	return Left(PrevBind, a) $ Mid(PrevBind, b);
}

function Notify(UWindowDialogControl C, byte E)
{
	local int I;

	Super.Notify(C, E);

	switch(E)
	{
		case DE_Click:
			if (bPolling)
			{
				bPolling = False;
				SelectedButton.bDisabled = False;
	
				if (C == SelectedButton)
				{
					ProcessMenuKey(1, class'KeyBindObject'.static.GetKeyName(1));
					return;
				}
			}
	
			if (UMenuRaisedButton(C) != None)
			{
				SelectedButton = UMenuRaisedButton(C);
				for (I = 0; I < BindCount; I++)
				{
					if (KeyButtons[I] == C)
						Selection = I;
				}
				bPolling = True;
				SelectedButton.bDisabled = True;
			}
			break;
		case DE_RClick:
			if (bPolling)
				{
					bPolling = False;
					SelectedButton.bDisabled = False;
	
					if (C == SelectedButton)
					{
						ProcessMenuKey(2, class'KeyBindObject'.static.GetKeyName(2));
						return;
					}
				}
			break;
		case DE_MClick:
			if (bPolling)
				{
					bPolling = False;
					SelectedButton.bDisabled = False;
	
					if (C == SelectedButton)
					{
						ProcessMenuKey(4, class'KeyBindObject'.static.GetKeyName(4));
						return;
					}			
				}
			break;
	}
}

defaultproperties
{
	AliasNames(0)="Duck"
	AliasNames(1)="ThrowWeapon"
	AliasNames(2)="mutate VehicleEnter"
	AliasNames(3)="mutate VehicleExit"
	AliasNames(4)="mutate VehicleEnterExit"
	AliasNames(5)="mutate VehicleHonk"
	AliasNames(6)="mutate VehicleCamera"
	AliasNames(7)="TeamSay Taxi!"
	AliasNames(8)="TeamSay Get in the vehicle!"
	LabelList(0)="Crouch"
	LabelList(1)="Throw Weapon"
	LabelList(2)="Enter Vehicle"
	LabelList(3)="Exit Vehicle"
	LabelList(4)="Enter/Exit Vehicle"
	LabelList(5)="Honk"
	LabelList(6)="Camera"
	LabelList(7)="Say Taxi!"
	LabelList(8)="Say Get In Vehicle!"
	HelpText(0)="Allow enter to the vehicle"
	HelpText(1)="Exit from the vehicle"
	HelpText(2)="Enter to the vehicle without crouch, can't be hold"
	HelpText(3)="Exit from the vehicle"
	HelpText(4)="Enter or Exit from the vehicle"
	HelpText(5)="Honk if you inside the vehicle, except stationary turrets"
	HelpText(6)="Change the camera position for the vehicle"
	HelpText(7)="Chat + voice command for your temmates"
	HelpText(8)="Chat + voice command for your temmates"
}
