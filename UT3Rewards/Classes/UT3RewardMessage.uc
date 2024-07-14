//=============================================================================
// UT3RewardMessage.
//=============================================================================
class UT3RewardMessage expands CriticalEventPlus;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	) {
	local UT3Rewards Mut;
	if (RelatedPRI_1 == None)
		return "";
	foreach RelatedPRI_1.AllActors(Class'UT3Rewards', Mut)
		break;
	if (Mut == None)
		return "";
		
	return Mut.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
	bBeep=False
	DrawColor=(R=255,G=128,B=255,A=0)
	YPos=160.000000
}
