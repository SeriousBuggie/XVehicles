//Vehicle light coronas sprites
Class VehicleLightsCor extends Effects;

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
	local Vehicle Veh;
	Veh = Vehicle(Owner);
	if (Veh!=None)
	{
		if (Veh.bSlopedPhys && Veh.GVT!=None)
			PrePivot = Veh.GVT.PrePivot + (POffSet >> Veh.Rotation);
		else
			PrePivot = (POffSet >> Veh.Rotation);
	}
}

defaultproperties
{
      bReady=False
      POffSet=(X=0.000000,Y=0.000000,Z=0.000000)
      bHidden=True
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
