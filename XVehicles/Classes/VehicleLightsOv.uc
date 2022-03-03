//Vehicle lights overlayer
Class VehicleLightsOv extends Effects;

var bool bReady;

function PostBeginPlay()
{
	SetTimer(0.2,True);
}

function Timer()
{

	If (Owner == None)
		Destroy();
}

function Tick(float Delta)
{
	if (Vehicle(Owner)!=None)
	{
		if (Vehicle(Owner).bSlopedPhys && Vehicle(Owner).GVT!=None)
			PrePivot = Vehicle(Owner).GVT.PrePivot;
	}
}

defaultproperties
{
      bReady=False
      bNetTemporary=False
      bTrailerSameRotation=True
      bTrailerPrePivot=True
      Physics=PHYS_Trailer
      RemoteRole=ROLE_SimulatedProxy
      DrawType=DT_Mesh
      Style=STY_Translucent
      ScaleGlow=2.500000
      bUnlit=True
}
