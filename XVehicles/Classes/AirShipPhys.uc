// A air ship (a blimp). (Created by .:..: 14.1.2008)
Class AirShipPhys extends Vehicle;

var() float MaxAirSpeed,VehicleTurnSpeed;
var() bool bStayStillWhenNotDriving;

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
	GetAxes(R,X,Y,Z);
	Sp = X*InAccel+Y*InTurn*-1+Z*InRise;
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

	if( !bOnGround )
		ActualFloorNormal = vect(0,0,1);
	R = TransformForGroundRot(VehicleYaw,FloorNormal);
	if( Rotation!=R )
		SetRotation(R);

	if( Level.NetMode==NM_Client && !IsNetOwner(Owner) )
		Return;

	// Update vehicle yaw.
	if( bDriving && Driver!=None )
	{
		if( PlayerPawn(Driver)==None )
		{
			if( !bHasMoveTarget )
			{
				if( Driver.Target!=None )
					HL = Driver.Target.Location;
				else HL = Location+vector(Rotation)*100;
			}
			else HL = MoveDest;
			VehicleYaw = CalcTurnSpeed(VehicleTurnSpeed,VehicleYaw,rotator(HL-Location).Yaw);
		}
		else VehicleYaw = CalcTurnSpeed(VehicleTurnSpeed,VehicleYaw,Driver.ViewRotation.Yaw);
	}
	// Update vehicle speed
	if( Accel==0 && Turning==0 && Rising==0 )
	{
		Ac = Velocity;
		DeAcc = VSize(Ac);
		DeAccRat = Delta*WDeAccelRate;
		if( DeAccRat>DeAcc )
			DeAccRat = DeAcc;
		Ac-=Normal(Ac)*DeAccRat;
		Velocity.X = Ac.X;
		Velocity.Y = Ac.Y;
		if( !bDriving && !bStayStillWhenNotDriving && !bOnGround && Velocity.Z>(-60) )
			Velocity.Z-=200*Delta;
		else Velocity.Z = Ac.Z;
		Return;
	}
	else if( Rising==0 && PlayerPawn(Driver)!=None )
		Velocity.Z*=(1.f-Delta*2.f);

	if (Accel!=0)
		Ac = GetAccelDir(Turning,Rising,Accel)*WAccelRate;
	else
		Ac = GetAccelDir(Turning,Rising,Accel)*WDeAccelRate;
	if( VSize(Velocity)>MaxAirSpeed && VSize(Normal(Velocity)-Normal(Ac))<0.15 )
		Velocity+=Ac*Delta/10;
	else Velocity+=Ac*Delta;
}
// Returns the bot turning value for target
function int ShouldTurnFor( vector AcTarget, optional float YawAdjust, optional float DeadZone )
{
	Return 0;
}

defaultproperties
{
      MaxAirSpeed=400.000000
      VehicleTurnSpeed=8000.000000
      bStayStillWhenNotDriving=False
      WAccelRate=200.000000
      Health=2000
      VehicleName="Air Ship"
      TranslatorDescription="This is a Air Ship, press [Fire] or [AltFire] to fire the different firemodes. Use your Strafe keys and Move Forward/Backward keys to strafe/accelerate/deaccelerate. To leave this vehicle, press your [ThrowWeapon] key."
      VehicleKeyInfoStr="Airship keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to strafe|%Jump%, %Duck% to move up/down|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%ThrowWeapon% to exit the vehicle"
      Mesh=LodMesh'UnrealShare.WoodenBoxM'
      Mass=6000.000000
}
