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
		return "Hold 'Crouch' key to enter this"@Vehicle(OptionalObject).VehicleName;
}

defaultproperties
{
}
