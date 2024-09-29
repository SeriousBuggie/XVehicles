//=============================================================================
// GhostFactory.
//=============================================================================
class GhostFactory expands VehicleFactory;

defaultproperties
{
	VehicleClass=Class'Ghost'
	Texture=Texture'XHoverVeh.pics.fan1'
	Mesh=SkeletalMesh'Ghost'
	AmbientGlow=127
	MultiSkins(1)=Texture'XHoverVeh.pics.fan1'
	MultiSkins(2)=Texture'XHoverVeh.pics.fan1'
	SoundRadius=255
	SoundVolume=255
	CollisionRadius=92.000000
	CollisionHeight=46.000000
}
