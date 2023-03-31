class CameraMaster expands Info;

var CameraMaster Master;

var string Pending;
var int used;

static simulated function Init(Actor Instigator)
{
	if (default.Master != None && !default.Master.bDeleteMe)
		return;
		
	default.Master = Instigator.Spawn(class'CameraMaster');
	default.Master.SetTimer(3, true);
}

function Timer()
{
	Local Pawn P;
	local PlayerPawn Player;
	
	used = 0;

	if (class'VActor'.static.IsDemoPlayback(Level))
		foreach AllActors(class'PlayerPawn', Player)
			ProcessPlayerPawn(Player);
	else
		for (P = Level.PawnList; P != None; P = P.nextPawn)
			if (PlayerPawn(P) != None)
				ProcessPlayerPawn(PlayerPawn(P));
	
	if (used == 0)
		Pending = "";
}

function ProcessPlayerPawn(PlayerPawn Player)
{
	local DriverWeapon Weapon;
	local Actor Camera;
	local string Check;
	local int i;

	if (Player == None || Pawn(Player.ViewTarget) == None)
		return;
	Weapon = DriverWeapon(Pawn(Player.ViewTarget).Weapon);
	if (Weapon == None || Weapon.VehicleOwner == None)
		return;
	Camera = Weapon.VehicleOwner.GetCam(Weapon);
	if (Camera == None || Camera == Player)
		return;
		
	Check = Player @ Player.ViewTarget;
	
	i = InStr(Pending, Check);
	if (i < 0)
	{
		Pending = Pending $ ";" $ Check;
		used++;
		return;
	}
	
	Pending = Left(Pending, i - 1) $ Mid(Pending, i + Len(Check));

	Player.SetPropertyText("bLockOn", "False"); // udemo playback hack
	//log(Level.TimeSeconds @ "ViewTarget" @ Player @ Player.ViewTarget @ Camera, self.name);
	Player.ViewTarget = Camera;
	Player.bHiddenEd = Player.bBehindView;
	Player.bBehindView = false;
}

defaultproperties
{
	Pending="("
}
