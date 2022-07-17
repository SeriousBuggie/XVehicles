//=============================================================================
// MantaFactory.
//=============================================================================
class MantaFactory expands VehicleFactory;

defaultproperties
{
      VehicleClass=Class'XHoverVeh.XManta'
      Texture=Texture'XHoverVeh.pics.fan1'
      Mesh=LodMesh'XHoverVeh.Manta'
      DrawScale=25.000000
      AmbientGlow=127
      MultiSkins(1)=Texture'XHoverVeh.pics.fan1'
      MultiSkins(2)=Texture'XHoverVeh.pics.fan1'
      SoundRadius=255
      SoundVolume=255
      CollisionRadius=92.000000
      CollisionHeight=46.000000
}
