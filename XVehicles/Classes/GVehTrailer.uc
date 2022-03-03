// This is what solves the land vehicles air floating bug.
// Basically this is spawned by the ground vehicle, and while the real hidden vehicles stays in the same place
// without any physics bugs, this "body" will make the vehilces visually stand correctly on slopes
// After all, the ground vehicles had no physics bugs, just a visual one
// This apllies to the ground vehicle types: wheeledphys and treadedphys, the rest don't need their slope correction apllied
Class GVehTrailer extends Effects;

function PostBeginPlay()
{
	SetTimer(0.2,True);
}

function Timer()
{

	If (Owner == None)
		Destroy();
}

defaultproperties
{
      bNetTemporary=False
      bTrailerSameRotation=True
      bTrailerPrePivot=True
      Physics=PHYS_Trailer
      RemoteRole=ROLE_None
      DrawType=DT_Mesh
}
