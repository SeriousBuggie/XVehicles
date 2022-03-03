Class TankOver extends xTreadVehEffects;

var actor SlopedPart;

function Tick(float Delta)
{
	if (SlopedPart != None)
		PrePivot = SlopedPart.PrePivot;
		
	if (LifeSpan > 3.0)
		ScaleGlow = (4 - LifeSpan) * Default.ScaleGlow;
	else
		ScaleGlow = LifeSpan * Default.ScaleGlow / 3;
}

defaultproperties
{
      SlopedPart=None
      bAnimByOwner=True
      bTrailerSameRotation=True
      Physics=PHYS_Trailer
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=4.000000
      DrawType=DT_Mesh
      Style=STY_Translucent
      ScaleGlow=2.000000
      bUnlit=True
}
