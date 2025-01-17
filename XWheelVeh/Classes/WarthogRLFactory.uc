//=============================================================================
// WarthogRLFactory.
//=============================================================================
class WarthogRLFactory expands VehicleFactory;

defaultproperties
{
	VehicleClass=Class'WarthogRL'
	Texture=Texture'XVehicles.Skins.CybotMetal'
	Mesh=SkeletalMesh'Warthog'
	MultiSkins(0)=Texture'XWheelVeh.Warthog.WarthogRLBlue'
	CollisionRadius=60.000000
	CollisionHeight=60.000000
}
