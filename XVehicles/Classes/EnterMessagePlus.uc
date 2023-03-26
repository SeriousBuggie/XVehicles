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
	local string key;
	if (OptionalObject != None)
	{
		if (Switch >= 2)
			return Vehicle(OptionalObject).GetWeaponName(Switch - 1);
		else if (Switch == 1)
			return Vehicle(OptionalObject).VehicleName;
		else
		{
			key = Class'KeyBindObject'.Static.FindKeyBinding("Duck", Actor(OptionalObject));
			if (key != "")
				key = "(" $ key $ ") ";
			return "Hold 'Crouch' key " $ key $ "to enter this" @ Vehicle(OptionalObject).VehicleName;
		}
	}
}

defaultproperties
{
}
