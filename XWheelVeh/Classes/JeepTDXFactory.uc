//=============================================================================
// JeepTDXFactory.
//=============================================================================
class JeepTDXFactory expands VehicleFactory;

defaultproperties
{
      VehicleClass=Class'XWheelVeh.JeepTDX'
      Mesh=LodMesh'XWheelVeh.JeepSDX'
      MultiSkins(1)=Texture'XWheelVeh.Skins.JeepTDXHBodySk01'
      MultiSkins(2)=Texture'XWheelVeh.Skins.JeepTDXHBodySk02'
      MultiSkins(3)=Texture'XWheelVeh.Skins.JeepTDXHBodySk03'
      CollisionRadius=80.000000
      CollisionHeight=60.000000
}
