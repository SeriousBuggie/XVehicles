//=============================================================================
// LinkCraftGun.
//=============================================================================
class LinkCraftGun expands RaptorGun;

function SpawnFireEffects(byte Mode)
{
	Super.SpawnFireEffects(Mode);
	
	if (OwnerVehicle == None)
		return;
	if (Mode == 1 && OwnerVehicle.HasAnim('Name'))
		OwnerVehicle.PlayAnim('Name');
}

defaultproperties
{
	WeapSettings(0)=(FireStartOffset=(X=96.500000,Y=19.000000,Z=8.000000),FireSound=Sound'BPulseRifleFire')
	WeapSettings(1)=(FireStartOffset=(X=158.000000,Y=0.000000,Z=-38.000000),DualMode=0)
}
