class ShrIonHitMark expands Scorch;

simulated function AttachToSurface()
{
	bAttached = AttachDecal(100, vect(0,0,1)) != None;
}

defaultproperties
{
      Texture=Texture'Botpack.bigshockmark'
      DrawScale=0.750000
}
