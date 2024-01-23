//=============================================================================
// XVGTabHelp.
//=============================================================================
class XVGTabHelp expands XVGTabPage;

var UWindowDynamicTextArea TextArea;
var() color TextColor;
var() string Buttons[6], URL[ArrayCount(Buttons)];

function Created()
{
	local string EOL;
	local ChallengeHUD HUD;
	local UWindowSmallButton Button;
	local int i, ButtonTop, ButtonHeight, ButtonLeft, ButtonWidth;
	
	Super.Created();
	
	ButtonHeight = 15;
	ButtonTop = WinHeight - 6 - 5 - ButtonHeight;	
	ButtonLeft = 10;
	ButtonWidth = (WinWidth - ButtonLeft)/ArrayCount(Buttons) - ButtonLeft;
	
	for (i = 0; i < ArrayCount(Buttons); i++)
	{
		Button = UWindowSmallButton(CreateControl(class'UWindowSmallButton', ButtonLeft, ButtonTop, ButtonWidth, ButtonHeight));
		Button.SetText(Buttons[i]);
		ButtonLeft += Button.WinWidth + 10;
	}
	
	EOL = "\\n";

/*
	TextArea = UWindowDynamicTextArea(CreateControl(class'UWindowHTMLTextArea', 0, 0, WinWidth, WinHeight, Self));
	UWindowHTMLTextArea(TextArea).SetHTML("");
*/

	TextArea = UWindowDynamicTextArea(CreateControl(class'UWindowDynamicTextArea', 0, 0, WinWidth - 3, ButtonTop - 5, Self));
	TextArea.AddText(
		"Tips:" $ EOL $
		"1. Only ground vehicles can carry the flag. Manta or Heli cannot." $ EOL $
		"2. In a stationary turret, you can use the forward/back keys to partially zoom in." $ EOL $
		"3. You can steal an empty enemy vehicle if it is not locked for the team (the sign above it is not 'X')." $ EOL $
		"4. If there is no Fix Gun on the map, then the alt fire from the Pulse Gun will heal vehicles from your team." $ EOL $
		"5. The main useful keys are written at the bottom of the screen when you are inside the vehicle." $ EOL $
		"6. You can zoom out the HUD while in the vehicle to read the full information about the available keys in the upper right corner." $ EOL $
		"7. You can swap seats with a bot, but not with a human." $ EOL $
		"8. If you fall into a vehicle while crouching, you will automatically enter the vehicle if possible." $ EOL $
		"9. Manta can jump and crouch. The crouch is useful for running over and can also be activated with alt fire." $ EOL $
		"10. The Heli missile automatically aims at the nearest flying vehicle, such as Manta or Heli." $ EOL $
		"11. Some vehicles allow multiple players to ride (jeeps, some tanks)." $ EOL $
		"12. In a Jeep, the driver can only use the horn if someone is in the second seat. So if you're in the second seat in the Jeep, shoot. The driver can't do that while you're in there." $ EOL $
		"13. Jeeps can use headlights (<0> key). SDX Jeep can use winter tires for slippery surfaces (<9> key), but it will damage the Jeep when used on normal surfaces." $ EOL $
		"14. Manta can perform an elevator jump. Use crouch to activate the elevator." $ EOL $
		"15. The manta jumps higher from a crouch position, but it needs the right time to hit the jump." $ EOL $
		"16. You can use PrevWeapon/NextWeapon to change the position of the camera when you are in a vehicle." $ EOL $
		"17. You can choose the weapon that will be when you exit the vehicle if you press the weapon button while inside the vehicle." $ EOL $
		"18. Manta can damage itself if you shoot too close objects." $ EOL $
		"19. The red dot shows the actual aiming point." $ EOL $
		"20. Twin fire from jeeps is a little faster than a single alternate one." $ EOL $
		"21. If you want the bot to ride with you, order it to follow you." $ EOL $
		"22. In order for the bot with the flag to get out of the vehicle to capture the flag - change seats to the second place or get out of the vehicle." $ EOL $
		"23. Mantas hover over water surfaces. This also works most often with lava, acid, and other liquids." $ EOL $
		"23. In water, the vehicle is damaged, but not quickly, so it can sometimes be used to overcome small water obstacles." $ EOL $
		"24. If you bind 'Crouch' and 'Enter Vehicle' to the same key, you will be able to enter the vehicle almost instantly with the ability to use hold to do this." $ EOL $
		"" $ EOL $
		"Keybinds:" $ EOL $
		"Duck - Crouch" $ EOL $
		"ThrowWeapon - Throw Weapon" $ EOL $
		"mutate VehicleEnter - Enter Vehicle" $ EOL $
		"mutate VehicleExit - Exit Vehicle" $ EOL $
		"mutate VehicleEnterExit - Enter/Exit Vehicle" $ EOL $
		"mutate VehicleHonk - Honk" $ EOL $
		"mutate VehicleCamera - Change the camera position" $ EOL $
		"mutate XVOpenGUI - Show this dialog box" $ EOL $
		"TeamSay Taxi! - Say Taxi!" $ EOL $
		"TeamSay Get in the vehicle! - Say Get in the vehicle!" $ EOL $
		"" $ EOL $
		"Chat commands:" $ EOL $
		"!XV - Show this dialog box" $ EOL $
		""
	);
	
	TextArea.bTopCentric = True;
	TextArea.TextColor = TextColor;
	TextArea.SetFont(1); // Fallback
	foreach GetPlayerOwner().AllActors(class'ChallengeHUD', HUD)
		if (HUD.MyFonts != None)
			break;
	if (HUD != None)
		TextArea.SetAbsoluteFont(HUD.MyFonts.GetMediumFont(WinWidth));
}

function Notify(UWindowDialogControl C, byte E)
{
	local string Text;
	local int i;
	
	if (E == DE_Click && UWindowSmallButton(C) != None)
	{
		Text = UWindowSmallButton(C).Text;
		for (i = 0; i < ArrayCount(Buttons); i++)
			if (Buttons[i] == Text)
				GetPlayerOwner().ConsoleCommand("START " $ URL[i]);
	}
	Super.Notify(C,E);
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	Super.Paint(C, MouseX, MouseY);

	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;

	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'AmmoCountJunk');
}

defaultproperties
{
	TextColor=(R=128,G=255,B=255)
	Buttons(0)="Discord"
	Buttons(1)="Forum"
	Buttons(2)="ModDB"
	Buttons(3)="GitHub"
	Buttons(4)="YouTube"
	Buttons(5)="Tutorial video"
	URL(0)="https://discord.gg/NVaNRXUvUU"
	URL(1)="https://ut99.org/viewtopic.php?f=34&t=14936"
	URL(2)="https://www.moddb.com/mods/xvehicles"
	URL(3)="https://github.com/SeriousBuggie/XVehicles"
	URL(4)="https://www.youtube.com/@xvehicles"
	URL(5)="https://www.youtube.com/watch?v=_yygKab2fbQ"
}
