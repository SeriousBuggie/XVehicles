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

static function bool IsCritical(int Switch)
{
	return Switch == 0 && class'XVehiclesHUD'.default.EnterCount < 3 && 
		class'XVehiclesHUD'.default.UsedHUD != None &&
		!class'VActor'.static.IsDemoPlayback(class'XVehiclesHUD'.default.UsedHUD.Level);
}

static function float GetOffset(int Switch, float YL, float ClipY )
{
	if (IsCritical(Switch))
	{
		return Class'CriticalEventPlus'.static.GetOffset(Switch, YL, ClipY);
	}
	return Super.GetOffset(Switch, YL, ClipY);
}

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	if (IsCritical(Switch))
	{
		return Class'CriticalEventPlus'.static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);
	}
	return Super.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);
}

defaultproperties
{
}
