// A stationary Turret. (Created by .:..: 11.1.2008)
Class StationaryPhys extends Vehicle;

var() float TurnSpeed,MaxZoomInRate;
var() IntRange PitchLimit;
var() Class<StationaryPitchAttach> PitchViewActor;
var() vector PitchMeshOffset;
var vector ViewPos;
var int VehiclePitch;
var StationaryPitchAttach PitchMeshActor;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority && !bNetOwner )
		ViewPos;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if( Level.NetMode!=NM_DedicatedServer && PitchViewActor!=None )
	{
		PitchMeshActor = StationaryPitchAttach(AddAttachment(PitchViewActor));
		PitchMeshActor.Move(Location+(PitchMeshOffset >> Rotation)-PitchMeshActor.Location);
	}
}
simulated singular function HitWall( vector HitNormal, Actor Wall );
simulated function vector GetAccelDir( int InTurn, int InRise, int InAccel )
{
	return vect(0,0,0);
}
simulated function ReadDriverInput( PlayerPawn Other, float DeltaTime )
{
	if( Other.bWasForward )
	{
		if( Other.FovAngle>MaxZoomInRate )
		{
			Other.FovAngle-=DeltaTime*60;
			if( Other.FovAngle<MaxZoomInRate )
				Other.FovAngle = MaxZoomInRate;
		}
	}
	else if( Other.bWasBack )
	{
		if( Other.FovAngle<Other.DefaultFOV )
		{
			Other.FovAngle+=DeltaTime*60;
			if( Other.FovAngle>Other.DefaultFOV )
				Other.FovAngle = Other.DefaultFOV;
		}
	}
	Other.DesiredFOV = Other.FovAngle;
	if( MyCameraAct!=None )
	{
		if( Other.bBehindView && Other.ViewTarget==MyCameraAct )
		{
			Other.bBehindView = False;
			bUseBehindView = !bUseBehindView;
			ServerSetBehindView(bUseBehindView);
			SaveConfig();
		}
	}
}
simulated function UpdateDriverInput( float Delta )
{
	local rotator R;

	if( Level.NetMode!=NM_DedicatedServer )
	{
		R.Yaw = VehicleYaw;
		if( PitchMeshActor==None )
			R.Pitch = VehiclePitch;
		if( Rotation!=R )
			SetRotation(R);
		if( PitchMeshActor!=None )
		{
			R.Pitch = VehiclePitch;
			if( PitchMeshActor.Rotation!=R )
				PitchMeshActor.SetRotation(R);
		}
	}
	if( Driver!=None && (Level.NetMode!=NM_Client || IsNetOwner(Driver)) )
	{
		if( PlayerPawn(Driver)==None )
		{
			if( Driver.Target!=None )
				ViewPos = Driver.Target.Location;
			else if( Driver.FaceTarget!=None )
				ViewPos = Driver.FaceTarget.Location;
			else ViewPos = Driver.Focus;
		}
		else ViewPos = CalcPlayerAimPos();
	}
	if( !bDriving )
		Return;
	R = rotator(ViewPos-Location);
	VehicleYaw = CalcTurnSpeed(TurnSpeed,VehicleYaw,R.Yaw);
	VehiclePitch = CalcTurnSpeed(TurnSpeed,VehiclePitch,R.Pitch);
}
simulated function ServerPerformMove( int InRise, int InTurn, int InAccel );

// Nothing here to constantly replicate.
simulated function ClientUpdateState( float Delta );
function ServerPackState( float Delta);

simulated function bool CheckOnGround()
{
	Return True;
}

// No inputs for bots!
function ReadBotInput( float Delta );
simulated function Bump( Actor Other );

simulated function AttachmentsTick( float Delta )
{
	if( PitchMeshActor!=None )
		PitchMeshActor.Move(Location+(PitchMeshOffset >> Rotation)-PitchMeshActor.Location);
}

defaultproperties
{
      TurnSpeed=18000.000000
      MaxZoomInRate=30.000000
      PitchLimit=(Max=15000,Min=-10000)
      PitchViewActor=None
      PitchMeshOffset=(X=0.000000,Y=0.000000,Z=0.000000)
      ViewPos=(X=0.000000,Y=0.000000,Z=0.000000)
      VehiclePitch=0
      PitchMeshActor=None
      Health=300
      bShouldRepVehYaw=False
      bStationaryTurret=True
      VehicleName="Stationary Turret"
      TranslatorDescription="This is a stationary turret. You can fire using [Fire] and [AltFire] and zoom in and out using movement keys. To leave this vehicle press [ThrowWeapon] key."
      VehicleKeyInfoStr="Turret keys:|%Fire% to fire, %AltFire% to alt fire|%ThrowWeapon% to exit the vehicle"
      Physics=PHYS_None
      Mesh=LodMesh'UnrealShare.WoodenBoxM'
}
