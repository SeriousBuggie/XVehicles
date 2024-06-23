//=============================================================================
// GoliathTurret.
//=============================================================================
class GoliathTurret expands TankGKOneTurret;

defaultproperties
{
	TurretPitchActor=Class'GoliathCannon'
	PitchActorOffset=(X=45.000000,Y=0.000000)
	WeapSettings(0)=(FireStartOffset=(X=217.000000))
	Mesh=SkeletalMesh'GoliathCanon'
}
