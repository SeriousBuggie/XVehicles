//=============================================================================
// ViperFactory.
//=============================================================================
class ViperFactory expands VehicleFactory;

defaultproperties
{
	VehicleClass=Class'Viper'
	AnimSequence="SlowIdle"
	Texture=Texture'XHoverVeh.pics.fan1'
	Mesh=SkeletalMesh'Viper'
	AmbientGlow=127
	MultiSkins(1)=Texture'XHoverVeh.pics.fan1'
	MultiSkins(2)=Texture'XHoverVeh.pics.fan1'
	SoundRadius=255
	SoundVolume=255
	CollisionRadius=92.000000
	CollisionHeight=46.000000
}
