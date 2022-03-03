// A hover craft. (Created by .:..: 13.1.2008)
Class HoverCraftPhys extends Vehicle;

var() float MaxHoverSpeed,VehicleTurnSpeed,HoveringHeight,JumpingHeight;
var() bool bHoverWhenNotDriving;
var float CurTurnSpeed,NextJumpTime;

// Return normal for acceleration direction.
simulated function vector GetAccelDir( int InTurn, int InRise, int InAccel )
{
	local rotator R;
	local vector X,Y,Z;

	if( PlayerPawn(Driver)==None )
	{
		X = (MoveDest-Location);
		X.Z = 0;
		X = Normal(X);
		if( bOnGround )
			Return SetUpNewMVelocity(X,ActualFloorNormal,0);
		else Return X;
	}
	R.Yaw = VehicleYaw;
	GetAxes(R,X,Y,Z);
	Z = X*InAccel+Y*InTurn*-1;
	if( VSize(Z)<0.02 )
		Z = vect(0,0,0);
	else Z = Normal(Z);
	if( bOnGround )
		Return SetUpNewMVelocity(Z,ActualFloorNormal,0);
	else Return Z;
}
simulated function UpdateDriverInput( float Delta )
{
	local vector Ac,End,Start,HL,HN;
	local float DeAcc,DeAccRat;
	local rotator R;
	local bool bInHoverDist;
	local int OlY;

	if( !bOnGround )
		ActualFloorNormal = vect(0,0,1);
	R = TransformForGroundRot(VehicleYaw,FloorNormal);
	if( Rotation!=R )
		SetRotation(R);
	if( bDriving || bHoverWhenNotDriving )
	{
		Start = Location;
		Start.Z-=(CollisionHeight-1);
		End = Start;
		End.Z-=(HoveringHeight+11);
		if( Trace(HL,HN,End,Start,False)!=None && HN.Z>0.5 )
		{
			bInHoverDist = True;
			DeAcc = HL.Z-Location.Z+HoveringHeight+CollisionHeight;
			if( Velocity.Z>(DeAcc*2.f) )
				Velocity.Z-=DeAcc*Delta;
			else Velocity.Z+=DeAcc*5.f*Delta;
			if( Abs(DeAcc)<5 )
				Velocity.Z*=(1.f-Delta*2.f);
		}
		else bInHoverDist = False;
	}
	else bInHoverDist = False;
	if( !bOnGround && !bInHoverDist )
		Velocity+=Region.Zone.ZoneGravity*Delta*VehicleGravityScale;

	if( Level.NetMode==NM_Client && !IsNetOwner(Owner) )
		Return;

	// Update vehicle yaw.
	if( bDriving && Driver!=None )
	{
		OlY = VehicleYaw;
		if( PlayerPawn(Driver)==None )
		{
			if( Driver.Target!=None )
				HL = Driver.Target.Location;
			else HL = Location+Velocity*100;
			VehicleYaw = CalcTurnSpeed(CurTurnSpeed*Delta,VehicleYaw,rotator(HL-Location).Yaw);
		}
		else VehicleYaw = CalcTurnSpeed(CurTurnSpeed*Delta,VehicleYaw,Driver.ViewRotation.Yaw);
		if( OlY==VehicleYaw )
			CurTurnSpeed = Default.CurTurnSpeed;
		else if( CurTurnSpeed<VehicleTurnSpeed )
		{
			CurTurnSpeed+=Delta*VehicleTurnSpeed*2;
			if( CurTurnSpeed>VehicleTurnSpeed )
				CurTurnSpeed = VehicleTurnSpeed;
		}
	}
	// Update vehicle speed
	if( Rising<0 && Velocity.Z>-250 )
	{
		if( bInHoverDist )
			Velocity.Z-=HoveringHeight*Delta*0.5;
		else if( Velocity.Z>0 )
			Velocity.Z-=1500.f*Delta;
		else Velocity.Z-=500.f*Delta;
	}
	else if( Rising>0 && bInHoverDist && NextJumpTime<Level.TimeSeconds )
	{
		NextJumpTime = Level.TimeSeconds+5;
		Velocity.Z+=JumpingHeight;
	}
	if( Accel==0 && Turning==0 )
	{
		Ac = Velocity;
		Ac.Z = 0;
		DeAcc = VSize(Ac);
		if( bInHoverDist )
			DeAccRat = Delta*WDeAccelRate;
		else DeAccRat = Delta*WDeAccelRate/3;
		if( DeAccRat>DeAcc )
			DeAccRat = DeAcc;
		Ac-=Normal(Ac)*DeAccRat;
		Velocity.X = Ac.X;
		Velocity.Y = Ac.Y;
		Return;
	}

	if (Accel != 0)
		Ac = GetAccelDir(Turning,Rising,Accel)*WAccelRate;
	else
		Ac = GetAccelDir(Turning,Rising,Accel)*WDeAccelRate;
	if( VSize(Velocity)>MaxHoverSpeed && VSize(Normal(Velocity)-Normal(Ac))<0.15 )
		Velocity+=Ac*Delta/10;
	else Velocity+=Ac*Delta;
}
// Returns the bot turning value for target
function int ShouldTurnFor( vector AcTarget, optional float YawAdjust, optional float DeadZone )
{
	Return 0;
}
// Read whatever input driver is pressing now
simulated function ReadDriverInput( PlayerPawn Other, float DeltaTime )
{
	Super.ReadDriverInput(Other,DeltaTime);
	Other.bPressedJump = False;
}

defaultproperties
{
      MaxHoverSpeed=800.000000
      VehicleTurnSpeed=55000.000000
      HoveringHeight=100.000000
      JumpingHeight=500.000000
      bHoverWhenNotDriving=False
      CurTurnSpeed=100.000000
      NextJumpTime=0.000000
      WAccelRate=700.000000
      Health=200
      VehicleName="Hover Craft"
      TranslatorDescription="This is a Hover Craft, press [Fire] or [AltFire] to fire the different firemodes. Use your Strafe keys and Move Forward/Backward keys to strafe/accelerate/deaccelerate. To leave this vehicle, press your [ThrowWeapon] key."
      VehicleKeyInfoStr="Hover craft keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%,%StrafeRight% to strafe|%Jump% to jump with the vehicle|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%ThrowWeapon% to exit the vehicle"
      Mesh=LodMesh'UnrealShare.WoodenBoxM'
}
