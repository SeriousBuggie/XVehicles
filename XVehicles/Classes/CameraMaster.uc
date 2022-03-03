class CameraMaster expands Info;

var CameraMaster Master;

static function Init(Actor Instigator)
{
	if (default.Master != None && !default.Master.bDeleteMe)
		return;
		
	default.Master = Instigator.Spawn(class'CameraMaster');
	default.Master.SetTimer(5, true);
}

function Timer()
{
	Local Pawn P;
	local PlayerPawn Player;
	local DriverWeapon Weapon;
	local Actor Camera;

	for (P=Level.PawnList; P!=None; P=P.nextPawn)
	{
		Player = PlayerPawn(P);
		if (Player == None || Pawn(Player.ViewTarget) == None)
			continue;
		Weapon = DriverWeapon(Pawn(Player.ViewTarget).Weapon);
		if (Weapon == None || Weapon.VehicleOwner == None)
			continue;
		Camera = Weapon.VehicleOwner.GetCam(Weapon);

		if (Camera == None)
			continue;
			
		Player.ViewTarget = Camera;
		Player.bHiddenEd = Player.bBehindView;
		Player.bBehindView = false;
	}
}

defaultproperties
{
      Master=None
}
