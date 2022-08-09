//=============================================================================
// FixAmmo.
//=============================================================================
class FixAmmo expands TournamentAmmo;

defaultproperties
{
	AmmoAmount=25
	MaxAmmo=200
	UsedInWeaponSlot(5)=1
	PickupMessage="You picked up a FixGun Cell."
	ItemName="FixGun Cell"
	PickupViewMesh=LodMesh'Botpack.PAmmo'
	Mesh=LodMesh'Botpack.PAmmo'
	bGameRelevant=True
	MultiSkins(1)=Texture'FixGun.Skins.JPammo_01'
	CollisionRadius=20.000000
	CollisionHeight=12.000000
}
