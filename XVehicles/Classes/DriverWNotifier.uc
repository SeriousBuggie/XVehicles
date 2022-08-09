Class DriverWNotifier extends Inventory;

var DriverWeapon WeaponOwner;

simulated event RenderOverlays( canvas Canvas );

event TravelPostAccept()
{
	Destroy();
}
Auto State DoNothing
{
Ignores DropFrom,Tick,Touch,BecomePickup,BecomeItem;
}
function Weapon WeaponChange( byte F )
{
	if( F==0 )
		F = 10;
	else F--;

	if (F == 9 && !WeaponOwner.bPassengerGun)
		WeaponOwner.VehicleOwner.SwitchVehicleLights();
	else if (F > 0 && !WeaponOwner.bPassengerGun)
	{
		F--;
		if (WeaponOwner.VehicleOwner.Specials[F].bSpecialAct)
			WeaponOwner.VehicleOwner.ActivateSpecial(F);
		else
		{
			F++;
			WeaponOwner.VehicleOwner.ChangeSeat(F,WeaponOwner.bPassengerGun,WeaponOwner.SeatNumber);
		}
	}
	else
		WeaponOwner.VehicleOwner.ChangeSeat(F,WeaponOwner.bPassengerGun,WeaponOwner.SeatNumber);
		
	WeaponOwner.VehicleOwner.KeepCams();
	Return None;
}

defaultproperties
{
	bRotatingPickup=False
	bHidden=True
	RemoteRole=ROLE_None
	bGameRelevant=True
}
