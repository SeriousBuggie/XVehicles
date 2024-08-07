// Some attachment for a vehicle (wheels, turrets etc...)
Class VehicleAttachment extends VActor
	Abstract;

var Vehicle OwnerVehicle;
var VehicleAttachment NextAttachment;
var() bool bAutoDestroyWithVehicle;
var bool bMasterPart;
var() byte PartMass;	// 0-Light, 1-Medium weight, 3-Heavy
var vector LocationRep;

replication
{
	// Variables the server should send to the client.
	unreliable if (Role == ROLE_Authority)
		OwnerVehicle;
	unreliable if (Role == ROLE_Authority && AmbientSound != None && !bNetOwner)
		LocationRep;
}

function PreBeginPlay()
{
	OwnerVehicle = Vehicle(Owner);
	if (OwnerVehicle == None && VehicleAttachment(Owner) != None)
		OwnerVehicle = VehicleAttachment(Owner).OwnerVehicle;
}

simulated function Detach(Actor Other)
{
	Super.Detach(Other);
	if (Pawn(Other) != None && OwnerVehicle != None)
		Other.Velocity += OwnerVehicle.Velocity; // inertial detach
}

// Called if bAutoDestroyWithVehicle is false.
simulated function NotifyVehicleDestroyed();

simulated function AnimEnd()
{
	if (WeaponAttachment(Owner) != None)
	{
		if (WeaponAttachment(Owner).PitchPart == Self)
			WeaponAttachment(Owner).AnimEnd();
	}
}

simulated function Tick(float Delta)
{
	if (OwnerVehicle == None)
	{
		if (Level.NetMode == NM_Client && LocationRep != default.LocationRep)
		{
			SetLocation(LocationRep);
			LocationRep = default.LocationRep;
		}
		return;
	}
	if (Level.NetMode != NM_Client && AmbientSound != None)
		LocationRep = Location;
	//if (OwnerVehicle.AttachmentList == Self)
	if (bMasterPart)
		OwnerVehicle.AttachmentsTick(Delta);
	ProcessOverlayMat();
}

simulated function AddCanvasOverlay( Canvas C )
{
	if( NextAttachment!=None )
		NextAttachment.AddCanvasOverlay(C);
}

simulated function ProcessOverlayMat()
{
	if (Level.NetMode != NM_DedicatedServer && !class'VehiclesConfig'.default.bDisableTeamSpawn)
	{
		if (OwnerVehicle.OverlayMat != None)
		{
			if (OverlayMActor == None)
				OverlayMActor = Spawn(Class'MatOverlayFX',Self);
			OverlayMActor.Texture = OwnerVehicle.OverlayMat;
			if (OwnerVehicle.OverlayTime >= 1)
				OverlayMActor.ScaleGlow = 1;
			else
				OverlayMActor.ScaleGlow = OwnerVehicle.OverlayTime/1;
			OverlayMActor.AmbientGlow = OverlayMActor.ScaleGlow * 255;
		}
		else if (OverlayMActor != None)
		{
			OverlayMActor.Destroy();
			OverlayMActor = None;
		}
	}
}

defaultproperties
{
	bAutoDestroyWithVehicle=True
	RemoteRole=ROLE_None
	bGameRelevant=True
}
