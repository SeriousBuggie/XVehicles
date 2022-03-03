// A hovering/flying vehicle. (Created by .:..: 14.1.2008)
Class FlightCraftPhys extends HoverCraftPhys;

var() float MaxFlightSpeed,FlyingTurnSpeed,MinFlyingSpeed;
var int VehiclePitch;
var bool bReleasedAccel;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority && !bNetOwner )
		bReleasedAccel;
}

simulated singular function HitWall( vector HitNormal, Actor Wall )
{
	local vector OldV,V;

	if( VSize(Velocity)>MinFlyingSpeed )
	{
		MoveSmooth(HitNormal);
		OldV = Velocity;
		Velocity = SetUpNewMVelocity(Velocity,HitNormal,0.8);
		if( Level.NetMode!=NM_Client && VSize(Normal(OldV)-Normal(Velocity))>0.65 )
			TakeDamage(VSize(OldV)*2.f,None,Location,Velocity,'Crashed');
		Return;
	}
	MoveSmooth(HitNormal);
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
// Return normal for acceleration direction.
simulated function vector GetAccelDir( int InTurn, int InRise, int InAccel )
{
	local rotator R;
	local vector X,Y,Z;

	if( PlayerPawn(Driver)==None )
	{
		if( VSize(Velocity)>MinFlyingSpeed )
		{
			R.Yaw = VehicleYaw;
			R.Pitch = VehiclePitch;
			Return vector(R);
		}
		X = (MoveDest-Location);
		X.Z = 0;
		X = Normal(X);
		if( bOnGround )
			Return SetUpNewMVelocity(X,ActualFloorNormal,0);
		else Return X;
	}
	R.Yaw = VehicleYaw;
	GetAxes(R,X,Y,Z);
	R.Pitch = VehiclePitch;
	Z = X*InAccel+Y*InTurn*-1;
	if( VSize(Z)<0.02 )
		Z = vect(0,0,0);
	else Z = Normal(Z);
	if( VSize(Velocity)>MinFlyingSpeed )
		Return vector(R);
	else if( bOnGround )
		Return SetUpNewMVelocity(Z,ActualFloorNormal,0);
	else Return Z;
}
simulated function UpdateDriverInput( float Delta )
{
	local vector Ac,End,Start,HL,HN;
	local float DeAcc,DeAccRat,Spe;
	local rotator R;
	local bool bInHoverDist,bOKFlightSpeed;
	local int OlY;

	if( !bOnGround )
		ActualFloorNormal = vect(0,0,1);
	Spe = VSize(Velocity);
	bOKFlightSpeed = (Spe>MinFlyingSpeed);
	if( bOKFlightSpeed )
	{
		R.Yaw = VehicleYaw;
		R.Pitch = VehiclePitch;
		R.Roll = Rotation.Roll/2;
	}
	else R = TransformForGroundRot(VehicleYaw,FloorNormal,VehiclePitch);
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
	if( !bOnGround && !bInHoverDist && (!bOKFlightSpeed || !bDriving || bReleasedAccel) )
	{
		Velocity+=Region.Zone.ZoneGravity*Delta*VehicleGravityScale;
		if( Abs(Velocity.X)>50 && Abs(Velocity.Y)>50 )
			VehiclePitch = rotator(Velocity).Pitch;
	}

	if( Level.NetMode==NM_Client && !IsNetOwner(Owner) )
	{
		if( !bOnGround && !bInHoverDist )
		{
			R = rotator(Velocity);
			VehicleYaw = R.Yaw;
			VehiclePitch = R.Pitch;
		}
		Return;
	}

	// Update vehicle yaw.
	if( bDriving && Driver!=None )
	{
		if( bOKFlightSpeed )
		{
			if( PlayerPawn(Driver)==None )
			{
				R = rotator(MoveDest-Location);
				VehicleYaw = CalcTurnSpeed(FlyingTurnSpeed*Delta,VehicleYaw,R.Yaw);
				VehiclePitch = CalcTurnSpeed(FlyingTurnSpeed*Delta,VehiclePitch,R.Pitch);
			}
			else
			{
				VehicleYaw = CalcTurnSpeed(FlyingTurnSpeed*Delta,VehicleYaw,Driver.ViewRotation.Yaw);
				VehiclePitch = CalcTurnSpeed(FlyingTurnSpeed*Delta,VehiclePitch,Driver.ViewRotation.Pitch);
			}
		}
		else if( bInHoverDist )
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
			VehiclePitch = 0;
		}
	}
	// Update vehicle speed
	if( bOKFlightSpeed )
	{
		if( Accel==0 )
		{
			R.Yaw = 0;
			R.Pitch = VehiclePitch;
			Ac = vector(R);
			DeAccRat = VSize(Velocity)+(Ac.Z*Region.Zone.ZoneGravity.Z*Delta*VehicleGravityScale*2.f)-WAccelRate*Delta;
			Velocity = vector(Rotation)*DeAccRat;
			if( !(VSize(Velocity)>MinFlyingSpeed) )
				bReleasedAccel = True;
			if( VSize(Velocity)>MaxFlightSpeed )
				Velocity = Normal(Velocity)*MaxFlightSpeed;
			Return;
		}
		R.Yaw = 0;
		R.Pitch = VehiclePitch;
		Ac = vector(R);
		DeAccRat = VSize(Velocity)+(Ac.Z*Region.Zone.ZoneGravity.Z*Delta*VehicleGravityScale*2.f);
		if( DeAccRat<MaxFlightSpeed )
			DeAccRat+=WAccelRate*Delta;
		else DeAccRat+=WAccelRate*Delta/10;
		Velocity = GetAccelDir(Turning,Rising,Accel)*DeAccRat;
		bReleasedAccel = False;
		if( VSize(Velocity)>MaxFlightSpeed )
			Velocity = Normal(Velocity)*MaxFlightSpeed;
	}
	if( Accel==0 && Turning==0 )
	{
		Ac = Velocity;
		Ac.Z = 0;
		DeAcc = VSize(Ac);
		if( bInHoverDist )
			DeAccRat = Delta*WAccelRate;
		else DeAccRat = Delta*WAccelRate/3;
		if( DeAccRat>DeAcc )
			DeAccRat = DeAcc;
		Ac-=Normal(Ac)*DeAccRat;
		Velocity.X = Ac.X;
		Velocity.Y = Ac.Y;
		Return;
	}
	Ac = GetAccelDir(Turning,Rising,Accel)*WAccelRate;
	if( VSize(Velocity)>MaxHoverSpeed && VSize(Normal(Velocity)-Normal(Ac))<0.15 )
		Velocity+=Ac*Delta/10;
	else Velocity+=Ac*Delta;
}

defaultproperties
{
      MaxFlightSpeed=4000.000000
      FlyingTurnSpeed=10000.000000
      MinFlyingSpeed=800.000000
      VehiclePitch=0
      bReleasedAccel=False
      CurTurnSpeed=600.000000
      WAccelRate=500.000000
      Health=300
      VehicleName="Flight Craft"
      TranslatorDescription="This is a Flight Craft, press [Fire] or [AltFire] to fire the different firemodes. Use your Strafe keys and Move Forward/Backward keys to strafe/accelerate/deaccelerate while on ground, if you accelerated fast enough you can take off and steer this plane through air. To leave this vehicle, press your [ThrowWeapon] key."
      VehicleKeyInfoStr="Flight craft keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to strafe (when not in air)|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%ThrowWeapon% to exit the vehicle"
}
