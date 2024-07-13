//=============================================================================
// JuggernautTurret.
//=============================================================================
class JuggernautTurret expands TankGKOneTurret;

defaultproperties
{
	TurretPitchActor=Class'JuggernautGun'
	PitchActorOffset=(X=44.000000,Y=0.000000)
	WeapSettings(0)=(FireStartOffset=(X=163.000000,Y=32.000000,Z=0.100000),FireSound=Sound'JuggernautFire')
	Mesh=SkeletalMesh'JuggernautTurret'
}
