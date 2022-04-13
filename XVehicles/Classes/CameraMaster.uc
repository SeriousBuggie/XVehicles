class CameraMaster expands Info;

var CameraMaster Master;

var string Pending;

static function Init(Actor Instigator)
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
	local DriverWeapon Weapon;
	local Actor Camera;
	local string Check;
	local int i, used;

	for (P=Level.PawnList; P!=None; P=P.nextPawn)
	{
		Player = PlayerPawn(P);
		if (Player == None || Pawn(Player.ViewTarget) == None)
			continue;
		Weapon = DriverWeapon(Pawn(Player.ViewTarget).Weapon);
		if (Weapon == None || Weapon.VehicleOwner == None)
			continue;
		Camera = Weapon.VehicleOwner.GetCam(Weapon);

		if (Camera == None || Camera == Player)
			continue;
			
		Check = Player @ Player.ViewTarget;
		
		i = InStr(Pending, Check);
		if (i < 0)
		{
			Pending = Pending $ ";" $ Check;
			used++;
			continue;
		}
		
		Pending = Left(Pending, i - 1) $ Mid(Pending, i + Len(Check));

		Player.ViewTarget = Camera;
		Player.bHiddenEd = Player.bBehindView;
		Player.bBehindView = false;
	}
	
	if (used == 0)
		Pending = "";
}

defaultproperties
{
      Master=None
      Pending="("
}
