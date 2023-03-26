//=============================================================================
// EnterMessagePlus.
//=============================================================================
class EnterMessagePlus expands PickupMessagePlus;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (OptionalObject != None)
	{
		if (Switch >= 2)
			return Vehicle(OptionalObject).GetWeaponName(Switch - 1);
		else if (Switch == 1)
			return Vehicle(OptionalObject).VehicleName;
		else
			return "Hold 'Crouch' key to enter this" @ Vehicle(OptionalObject).VehicleName;
	}
}

defaultproperties
{
}
