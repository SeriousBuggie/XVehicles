Class TreadsTrailer extends Effects;

var vector PrePivotRel;

function PostBeginPlay()
{
	SetTimer(0.2,True);
}

function Tick(float Delta)
{
	if (Vehicle(Owner) != None)
	{
		if (Vehicle(Owner).GVT != None)
			PrePivot = (PrePivotRel >> Owner.Rotation) + Vehicle(Owner).GVT.PrePivot;
		else
			PrePivot = (PrePivotRel >> Owner.Rotation);
	}
}

function Timer()
{

	If (Owner == None)
		Destroy();
}

defaultproperties
{
      PrePivotRel=(X=0.000000,Y=0.000000,Z=0.000000)
      bNetTemporary=False
      bTrailerSameRotation=True
      bTrailerPrePivot=True
      Physics=PHYS_Trailer
      RemoteRole=ROLE_None
      DrawType=DT_Mesh
}
