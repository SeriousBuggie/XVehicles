Class TankOver extends xTreadVehEffects;

var actor SlopedPart;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		SlopedPart;
}

simulated function Tick(float Delta)
{
	if (SlopedPart != None)
		if (Vehicle(SlopedPart) != None)
			PrePivot = Vehicle(SlopedPart).GVT.PrePivot;
		else
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
