//=============================================================================
// IonTankCannon.
//=============================================================================
class IonTankCannon expands xTreadVehAttach;

simulated event AnimEnd()
{
	Super.AnimEnd();
	if (HasAnim('Idle'))
		TweenAnim('Idle', 0.5);
}

defaultproperties
{
	Mesh=SkeletalMesh'IonTankCanonPitch'
}
