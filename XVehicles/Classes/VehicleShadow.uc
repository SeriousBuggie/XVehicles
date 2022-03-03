//=============================================================================
// VehicleShadow.
//=============================================================================
class VehicleShadow expands PlayerShadow;

var Vehicle OwnerVehicle;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	OwnerVehicle = Vehicle(Owner);
	if (OwnerVehicle == None && Owner != None && Owner.Owner != None)
		OwnerVehicle = Vehicle(Owner.Owner);
	if (OwnerVehicle != None)
		DrawScale *= OwnerVehicle.CollisionRadius/class'PlayerPawn'.default.CollisionRadius;
}

simulated event Tick(Float Delta)
{
	Update(None);
}

simulated event Update(Actor L)
{
	local Actor HitActor;
	local Vector HitNormal,HitLocation, ShadowStart, ShadowDir;
	
	if (Owner == None)
	{
		Destroy();
		return;
	}

	if ( !Level.bHighDetailMode )
		return;

	SetTimer(0.08, false);
	if ( OldOwnerLocation == Owner.Location )
		return;

	OldOwnerLocation = Owner.Location;

	DetachDecal();

	if ( Owner.Style == STY_Translucent )
		return;

	ShadowStart = Owner.Location;
	if (OwnerVehicle != None)
		ShadowDir = -OwnerVehicle.FloorNormal;
	else
		ShadowDir = vect(0,0,-1);
	HitActor = Trace(HitLocation, HitNormal, ShadowStart + 300*ShadowDir, ShadowStart, false);

	if ( HitActor == None )
		return;

	SetLocation(HitLocation);
	SetRotation(rotator(HitNormal));
	AttachDecal(20*DrawScale, ShadowDir);
}

defaultproperties
{
      OwnerVehicle=None
      Physics=PHYS_Trailer
}
