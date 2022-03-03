//Vehicle light coronas sprites
Class VehicleLightsCor extends Effects;

var bool bReady;
var vector POffSet;

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
			PrePivot = Vehicle(Owner).GVT.PrePivot + (POffSet >> Vehicle(Owner).Rotation);
		else
			PrePivot = (POffSet >> Vehicle(Owner).Rotation);
	}
}

defaultproperties
{
      bReady=False
      POffSet=(X=0.000000,Y=0.000000,Z=0.000000)
      bNetTemporary=False
      bTrailerSameRotation=True
      bTrailerPrePivot=True
      Physics=PHYS_Trailer
      RemoteRole=ROLE_SimulatedProxy
      DrawType=DT_Sprite
      Style=STY_Translucent
      ScaleGlow=1.500000
      bUnlit=True
}
