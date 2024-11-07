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
	CollisionRadius=75.000000
	CollisionHeight=75.000000
}
