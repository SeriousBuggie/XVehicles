//=============================================================================
// IonTankTurret.
//=============================================================================
class IonTankTurret expands TankGKOneTurret;

simulated function FireEffect()
{
	Super.FireEffect();
	if (PitchPart != None && PitchPart.HasAnim('Name'))
		PitchPart.PlayAnim('Name');
}

defaultproperties
{
	PitchRange=(Max=4500,Min=-1900)
	TurretPitchActor=Class'IonTankCannon'
	PitchActorOffset=(X=11.000000,Y=0.000000,Z=-8.000000)
	WeapSettings(0)=(FireStartOffset=(X=264.000000),FireSound=Sound'XTreadVeh.IonTank.BExplosion5')
	Mesh=SkeletalMesh'IonTankCanon'
	CollisionHeight=60.000000
}
