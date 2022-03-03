//Vehicle head light spot light
Class HeadSpotLight extends Light;

var bool bReady;
var vector POffSet;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		POffSet;
}

function PostBeginPlay()
{
	SetTimer(0.2,True);
}

function Timer()
{
	If (Owner == None)
		Destroy();
}

simulated function Tick(float Delta)
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
      bStatic=False
      bNoDelete=False
      bTrailerSameRotation=True
      bTrailerPrePivot=True
      Physics=PHYS_Trailer
      RemoteRole=ROLE_SimulatedProxy
      bDirectional=True
      DrawType=DT_Mesh
      Style=STY_Translucent
      ScaleGlow=2.500000
      bUnlit=True
      bMovable=True
      LightEffect=LE_Spotlight
}
