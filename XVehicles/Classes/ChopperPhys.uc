// A helicopter vehicle (Created by .:..: 9.1.2008)
Class ChopperPhys extends Vehicle;

var() float MaxAirSpeed,YawTurnSpeed;
var float CurrentYawSpeed,NextCutTime;
var const float MaxYawRates[2];
var ChopperRotor MyRotor;
var() class<ChopperRotor> ChopperRotorClass;
var() vector RotorOffset,RotorSize;
var int RotorYaw;
var bool bHasRotorDmg;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if( Level.NetMode!=NM_DedicatedServer && ChopperRotorClass!=None )
		MyRotor = ChopperRotor(AddAttachment(ChopperRotorClass));
	if( Level.NetMode!=NM_Client && ChopperRotorClass!=None && RotorSize!=vect(0,0,0) )
		bHasRotorDmg = True;
}
simulated singular function HitWall( vector HitNormal, Actor Wall )
{
	local vector V;

	MoveSmooth(HitNormal);
	if( bDriving )
	{
		Velocity = SetUpNewMVelocity(Velocity,HitNormal,0.05);
		Return;
	}
	V = SetUpNewMVelocity(Velocity,HitNormal,1);
	if( !bOnGround && HitNormal.Z>0.8 )
	{
		if( VSize(Normal(V)-Normal(Velocity))>0.85 && VSize(Velocity)>450 )
		{
			Velocity = SetUpNewMVelocity(Velocity,HitNormal,0.15);
			Return;
		}
		bOnGround = True;
		ActualFloorNormal = HitNormal;
		Velocity = SetUpNewMVelocity(Velocity,HitNormal,0);
		Return;
	}
	if( VSize(Normal(V)-Normal(Velocity))>0.85 || (bOnGround && !CanYawUpTo(Rotation,TransformForGroundRot(VehicleYaw,HitNormal),1500)) )
	{
		if( bOnGround && CanGetOver(35,0.85) )
			Return;
		bOnGround = False;
		Velocity = SetUpNewMVelocity(Velocity,HitNormal,0.5);
	}
	else
	{
		Velocity = SetUpNewMVelocity(Velocity,HitNormal,0);
		ActualFloorNormal = HitNormal;
		bOnGround = True;
	}
}
simulated function vector GetMovementSpeeds()
{
	local vector V;

	V = (Velocity << Rotation);
	V.Z = 0;
	Return Normal(V);
}

defaultproperties
{
      MaxAirSpeed=1400.000000
      YawTurnSpeed=18000.000000
      CurrentYawSpeed=5.000000
      NextCutTime=0.000000
      MaxYawRates(0)=6000.000000
      MaxYawRates(1)=-6000.000000
      MyRotor=None
      ChopperRotorClass=None
      RotorOffset=(X=0.000000,Y=0.000000,Z=0.000000)
      RotorSize=(X=0.000000,Y=0.000000,Z=0.000000)
      RotorYaw=0
      bHasRotorDmg=False
      WAccelRate=900.000000
      Health=300
      VehicleName="Helicopter"
      TranslatorDescription="This is a chopper vehicle, you can fire different firemodes using [Fire] and [AltFire] buttons. To move higher or lover use [Jump] and [Crouch] buttons and to move around use movement keys. To leave this vehicle press [ThrowWeapon] key."
      VehicleKeyInfoStr="Chopper craft keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to strafe|%Jump%, %Duck% to move up/down|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%ThrowWeapon% to exit the vehicle"
      Mesh=LodMesh'UnrealShare.WoodenBoxM'
}
