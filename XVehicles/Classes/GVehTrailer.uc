// This is what solves the land vehicles air floating bug.
// Basically this is spawned by the ground vehicle, and while the real hidden vehicles stays in the same place
// without any physics bugs, this "body" will make the vehilces visually stand correctly on slopes
// After all, the ground vehicles had no physics bugs, just a visual one
// This apllies to the ground vehicle types: wheeledphys and treadedphys, the rest don't need their slope correction apllied
Class GVehTrailer extends Effects;

var Decal Shadow;

function PostBeginPlay()
{
	SetTimer(0.2,True);
	
	if ( Level.NetMode != NM_DedicatedServer )
		Shadow = Spawn(class'VehicleShadow', self);
}

function Timer()
{
	If (Owner == None)
		Destroy();
}

simulated function Destroyed()
{
	if (Shadow != None)
		Shadow.Destroy();
	Super.Destroyed();
}

defaultproperties
{
      Shadow=None
      bNetTemporary=False
      bTrailerSameRotation=True
      bTrailerPrePivot=True
      Physics=PHYS_Trailer
      RemoteRole=ROLE_None
      DrawType=DT_Mesh
}
