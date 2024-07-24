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

simulated function Tick(float Delta)
{
	local Vehicle Veh;
	Veh = Vehicle(Owner);
	if (Veh != None)
	{
		if (Veh.bSlopedPhys && Veh.GVT != None)
			PrePivot = Veh.GVT.PrePivot + (POffSet >> Veh.Rotation);
		else
			PrePivot = (POffSet >> Veh.Rotation);
	}
	else if (Role == ROLE_Authority)
		Destroy();
}

defaultproperties
{
	bHidden=True
	bNetTemporary=False
	bTrailerSameRotation=True
	bTrailerPrePivot=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_None
	DrawType=DT_Sprite
	Style=STY_Translucent
	ScaleGlow=1.500000
	bUnlit=True
}
