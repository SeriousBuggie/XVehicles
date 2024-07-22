//=============================================================================
// IonTankMGRot.
//=============================================================================
class IonTankMGRot expands GoliathMGRot;

defaultproperties
{
	BarrelYOffset=4.700000
	ShellOffset=(X=5.000000,Y=-8.000000,Z=1.000000)
	PitchRange=(Max=15000,Min=-5000)
	TurretPitchActor=Class'IonTankMGun'
	PitchActorOffset=(X=-18.000000,Y=0.000000,Z=13.500000)
	WeapSettings(0)=(FireStartOffset=(X=53.400002,Z=0.500000))
	Mesh=SkeletalMesh'IonTankMGRot'
}
