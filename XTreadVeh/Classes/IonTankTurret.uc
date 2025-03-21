//=============================================================================
// IonTankTurret.
//=============================================================================
class IonTankTurret expands TankGKOneTurret;

simulated function FireEffect()
{
	Super.FireEffect();
	if (PitchPart != None && PitchPart.HasAnim('Fire'))
		PitchPart.PlayAnim('Fire');
}

defaultproperties
{
	PitchRange=(Min=-1900)
	TurretPitchActor=Class'IonTankCannon'
	PitchActorOffset=(X=11.000000,Z=-8.000000)
	WeapSettings(0)=(FireStartOffset=(X=264.000000),FireSound=Sound'XTreadVeh.IonTank.BExplosion5')
	Mesh=SkeletalMesh'IonTankCanon'
	CollisionHeight=60.000000
}
