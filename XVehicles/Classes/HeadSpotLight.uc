//Vehicle head light spot light
Class HeadSpotLight extends Light;

var bool bReady;
var vector POffSet;
var byte LightConeRepl;

replication
{
	// Variables the server should send to the client.
	reliable if (Role == ROLE_Authority)
		POffSet, LightConeRepl;
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
	if (!bHidden && Mesh != None && Vehicle(Owner) != None && Level.NetMode != NM_DedicatedServer)
	{
		if (Vehicle(Owner).bSlopedPhys && Vehicle(Owner).GVT != None)
			PrePivot = Vehicle(Owner).GVT.PrePivot + (POffSet >> Vehicle(Owner).Rotation);
		else
			PrePivot = (POffSet >> Vehicle(Owner).Rotation);
	}
	if (Role == ROLE_Authority)
		LightConeRepl = LightCone;
	else
		LightCone = LightConeRepl;
}

defaultproperties
{
	LightConeRepl=128
	bStatic=False
	bNoDelete=False
	bAlwaysRelevant=True
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
