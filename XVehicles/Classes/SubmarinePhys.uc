// A submarine. (Created by .:..: 15.1.2008)
Class SubmarinePhys extends Vehicle;

var() float MaxWaterSpeed,VehicleTurnSpeed;
var() bool bCanStrafe;
var int VehiclePitch;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		VehiclePitch;
}

// Return normal for acceleration direction.
simulated function vector GetAccelDir( int InTurn, int InRise, int InAccel )
{
	local rotator R;
	local vector X,Y,Z,Sp;

	if( PlayerPawn(Driver)==None )
	{
		if( Driver.Target!=None )
			X = Driver.Target.Location;
		else X = MoveDest;
		Return Normal(X-Location);
	}
	R.Yaw = VehicleYaw;
	R.Pitch = VehiclePitch;
	GetAxes(R,X,Y,Z);
	if( !bCanStrafe )
		Return X*InAccel;
	Sp = X*InAccel+Y*InTurn*(-1)+Z*InRise;
	if( VSize(Sp)<0.02 )
		Sp = vect(0,0,0);
	else Sp = Normal(Sp);
	Return Sp;
}
simulated function UpdateDriverInput( float Delta )
{
	local vector Ac,HL;
	local float DeAcc,DeAccRat;
	local rotator R;

	if( Region.Zone.bWaterZone )
		ActualFloorNormal = vect(0,0,1);
	R = TransformForGroundRot(VehicleYaw,FloorNormal,VehiclePitch);
	if( Rotation!=R )
		SetRotation(R);

	if( Level.NetMode==NM_Client && !IsNetOwner(Owner) )
		Return;

	// Update vehicle yaw.
	if( bDriving && Driver!=None )
	{
		Driver.PainTime = 1;
		if( PlayerPawn(Driver)==None )
		{
			if( !bHasMoveTarget )
			{
				if( Driver.Target!=None )
					HL = Driver.Target.Location;
				else HL = Location+vector(Rotation)*100;
			}
			else HL = MoveDest;
			R = rotator(HL-Location);
		}
		else R = Driver.ViewRotation;
		VehicleYaw = CalcTurnSpeed(VehicleTurnSpeed,VehicleYaw,R.Yaw);
		if( Region.Zone.bWaterZone )
			VehiclePitch = CalcTurnSpeed(VehicleTurnSpeed,VehiclePitch,R.Pitch);
		else if( bOnGround )
			VehiclePitch = 0;
	}
	if( !Region.Zone.bWaterZone )
	{
		if( !bOnGround )
			Velocity+=Region.Zone.ZoneGravity*Delta*VehicleGravityScale;
		else
		{
			Ac = Velocity;
			Ac.Z = 0;
			DeAcc = VSize(Ac);
			DeAccRat = Delta*Region.Zone.ZoneGroundFriction*300;
			if( DeAccRat>DeAcc )
				DeAccRat = DeAcc;
			Ac-=Normal(Ac)*DeAccRat;
			Velocity.X = Ac.X;
			Velocity.Y = Ac.Y;
		}
		Return;
	}
	// Update vehicle speed
	if( (bCanStrafe && Accel==0 && Turning==0 && Rising==0) || (!bCanStrafe && Accel==0) )
	{
		Ac = Velocity;
		DeAcc = VSize(Ac);
		DeAccRat = Delta*WAccelRate;
		if( DeAccRat>DeAcc )
			DeAccRat = DeAcc;
		Ac-=Normal(Ac)*DeAccRat;
		Velocity.X = Ac.X;
		Velocity.Y = Ac.Y;
		Velocity.Z = Ac.Z;
		Return;
	}
	Ac = GetAccelDir(Turning,Rising,Accel)*WAccelRate;
	if( VSize(Velocity)>MaxWaterSpeed && VSize(Normal(Velocity)-Normal(Ac))<0.15 )
		Velocity+=Ac*Delta/10;
	else Velocity+=Ac*Delta;
	Velocity*=(1.f-Delta);
}
// Returns the bot turning value for target
function int ShouldTurnFor( vector AcTarget, optional float YawAdjust, optional float DeadZone )
{
	Return 0;
}

defaultproperties
{
      MaxWaterSpeed=600.000000
      VehicleTurnSpeed=8000.000000
      bCanStrafe=False
      VehiclePitch=0
      WAccelRate=2000.000000
      Health=2000
      bIsWaterResistant=True
      VehicleName="Submarine"
      TranslatorDescription="This is a Submarine, press [Fire] or [AltFire] to fire the different firemodes. Use your Strafe keys and Move Forward/Backward keys to strafe/accelerate/deaccelerate. To leave this vehicle, press your [ThrowWeapon] key."
      VehicleKeyInfoStr="Submarine keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to strafe|%Jump%, %Duck% to move up/down|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%ThrowWeapon% to exit the vehicle"
      Mesh=LodMesh'UnrealShare.WoodenBoxM'
      Mass=6000.000000
      Buoyancy=6000.000000
}
