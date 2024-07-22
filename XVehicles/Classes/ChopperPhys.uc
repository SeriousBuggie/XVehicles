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

var vector BotAccelDir;

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
	local float fVelocity, Bounce;

	MoveSmooth(HitNormal);
	fVelocity = VSize(Velocity);
	if (fVelocity > 1000)
		Bounce = 0.15;
	else if (fVelocity > 450)
		Bounce = 0.05;
	if (bDriving)
	{
		Velocity = SetUpNewMVelocity(Velocity, HitNormal, Bounce);
		Return;
	}
	V = SetUpNewMVelocity(Velocity, HitNormal, 1);
	if (!bOnGround && HitNormal.Z > 0.8)
	{
		if (VSize(Normal(V) - Normal(Velocity)) > 0.85 && fVelocity > 450)
		{
			Velocity = SetUpNewMVelocity(Velocity, HitNormal, Bounce);
			Return;
		}
		bOnGround = True;
		ActualFloorNormal = HitNormal;
		Velocity = SetUpNewMVelocity(Velocity, HitNormal, Bounce);
		Return;
	}
	if (VSize(Normal(V) - Normal(Velocity)) > 0.85 || 
		(bOnGround && !CanYawUpTo(Rotation, TransformForGroundRot(VehicleYaw, HitNormal), 1500)))
	{
		Velocity = SetUpNewMVelocity(Velocity, HitNormal, Bounce);
		if (bOnGround && VSize(SetUpNewMVelocity(Velocity, HitNormal, 0)) > 100 && CanGetOver(35, 0.85))
			Return;
		bOnGround = False;
	}
	else
	{
		Velocity = SetUpNewMVelocity(Velocity, HitNormal, Bounce);
		ActualFloorNormal = HitNormal;
		bOnGround = True;
	}
}

// Return normal for acceleration direction.
simulated function vector GetAccelDir( int InTurn, int InRise, int InAccel )
{
	local rotator R;
	local vector X,Y,Z;
	
//	log("Turn" @ InTurn @ "Accel" @ InAccel @ "Rise" @ InRise @ "VehicleYaw" @ VehicleYaw);

	if (Driver != None && PlayerPawn(Driver) == None)
		return BotAccelDir;
	if( InTurn==0 && InRise==0 && InAccel==0 )
		return vect(0,0,0);
	R.Yaw = VehicleYaw;
	GetAxes(R,X,Y,Z);
	Return Normal(X*InAccel+Y*-InTurn+Z*InRise);
}

simulated function UpdateDriverInput( float Delta )
{
	local byte PitchDif;
	local vector Ac,X,Y,Z,HL,HN,En;
	local rotator R,Rr;
	local float EngP, Changed,DeAcc,DeAccRat;
	local Actor A;
	local int i;
	
	if (bEngDynSndPitch && Level.NetMode != NM_DedicatedServer)
	{
		PitchDif = MaxEngPitch - MinEngPitch;
		EngP = MinEngPitch + Min(PitchDif, (VSize(Velocity)*PitchDif/MaxAirSpeed));
		SoundPitch = Byte(EngP);
	}

	if( bHasRotorDmg && !bOnGround && NextCutTime<Level.TimeSeconds )
	{
		NextCutTime = Level.TimeSeconds+0.05;
		GetAxes(Rotation,X,Y,Z);
		Ac = Location+(RotorOffset >> Rotation);
		For( i=0; i<8; i++ )
		{
			DeAcc = (float(i)+FRand());
			En = Ac+X*RotorSize.X*Sin(DeAcc)+Y*RotorSize.Y*Cos(DeAcc);
			A = Trace(HL,HN,En,Ac,True);
			if( A!=None )
			{
				if( A.bIsPawn || Carcass(A)!=None )
					A.TakeDamage(50+Rand(60),Driver,HL,vect(0,0,0),'cutted');
				else if( Vehicle(A)!=None )
				{
					A.TakeDamage(50+Rand(60),Driver,HL,HN,'crushed');
					A.Velocity-=HN*500;
					TakeDamage(30+Rand(20),None,HL,HN,'crushed');
					Velocity+=HN*500;
				}
				else
				{
					TakeDamage(50+Rand(60),Driver,HL,HN,'crushed');
					Velocity+=HN*500;
				}
			}
		}
	}
	if( bOnGround )
		R = TransformForGroundRot(VehicleYaw,FloorNormal);
	else
	{
		R = Normalize(Rotation);
		R.Yaw = VehicleYaw;
		R.Roll/=2;
		R.Pitch/=2;
	}
	if (!bDriving && !bOnGround)
	{
		Velocity += Region.Zone.ZoneGravity*Delta*VehicleGravityScale;
		return;
	}
	if( Level.NetMode!=NM_DedicatedServer && !bOnGround && bDriving )
	{
		Rr.Yaw = VehicleYaw;
		Ac = (Velocity << Rr)*MaxYawRates[0]/MaxAirSpeed;
		if( Ac.Y>MaxYawRates[0] )
			Ac.Y = MaxYawRates[0];
		else if( Ac.Y<MaxYawRates[1] )
			Ac.Y = MaxYawRates[1];
		if( Ac.X>MaxYawRates[0] )
			Ac.X = MaxYawRates[0];
		else if( Ac.X<MaxYawRates[1] )
			Ac.X = MaxYawRates[1];
		if( Abs(R.Roll)<Abs(Ac.Y) )
			R.Roll = Ac.Y;
		if( Abs(R.Pitch)<Abs(Ac.X) )
			R.Pitch = -Ac.X;
		GetAxes(R,X,Y,Z);
		ActualFloorNormal = Z;
		FloorNormal = Z;
	}
	if (Rotation != R)
		SetRotation(R);
	if (!bDriving)
	{
		DeAcc = VSize(Velocity);
		DeAccRat = Delta*WDeAccelRate*Region.Zone.ZoneGroundFriction;
		if (DeAccRat > DeAcc)
			DeAccRat = DeAcc;
		Velocity -= Normal(Velocity)*DeAccRat;
		Return;
	}
	if (Level.NetMode == NM_Client && !IsNetOwner(Owner))
		Return;
	if (Driver != None && !Driver.IsInState('GameEnded') && (Level.Game == None || !Level.Game.bGameEnded))
	{
		Changed = CalcTurnSpeed(FMax(1, CurrentYawSpeed*Delta),VehicleYaw,Driver.ViewRotation.Yaw);
		Changed -= VehicleYaw;
		if (Changed == 0)
			CurrentYawSpeed = 5;
		else if (CurrentYawSpeed < YawTurnSpeed)
		{
			CurrentYawSpeed += Delta*0.5*YawTurnSpeed;
			if (CurrentYawSpeed > YawTurnSpeed)
				CurrentYawSpeed = YawTurnSpeed;
		}
		VehicleYaw += Changed;
	}	
	Ac = WAccelRate*Delta*GetAccelDir(Turning, Rising, Accel);
/*	
	if( VSize(Velocity)>MaxAirSpeed && VSize(Normal(Velocity)-Normal(Ac))<0.85 )
		Velocity+=(Ac*0.1);
	else Velocity+=Ac;
*/
	Velocity += Ac;
	// X dot X == VSize(X)*VSize(X)
	if ((Velocity dot Velocity) > MaxAirSpeed*MaxAirSpeed)
		Velocity = MaxAirSpeed*Normal(Velocity);
	
	if (PlayerPawn(Driver) != None)
	{
		if( Rising==0)
			Velocity.Z*=FMax(0f, 1.f-Delta);
		if( Turning==0 && Accel==0 )
		{
			Velocity.X*=FMax(0f, 1.f-Delta);
			Velocity.Y*=FMax(0f, 1.f-Delta);
		}
	}
}

function int ShouldTurnFor( vector AcTarget, optional float YawAdjust, optional float DeadZone )
{
	Return Turning;
}

function int ShouldRiseFor( vector AcTarget )
{
	return Rising;
}

function int ShouldAccelFor( vector AcTarget )
{
	local int ret;
		
	BotAccelDir = BotDrive();
	
	if (AboutToCrash(ret))
		return ret;
	return Accel;
}

function vector BotDrive()
{
	local vector Dir, X, Y, Z;
	local float V;
	
	if (Driver.IsInState('GameEnded') || Driver.IsInState('Dying') || 
		(Level.Game != None && Level.Game.bGameEnded))
		return vect(0,0,0);
	Dir = MoveDest - Location;
	// dont slow down if run over
	if (Driver.Enemy == None || VSize(Driver.Enemy.Location - MoveDest) > 40)
	{
		GetAxes(rotator(Dir), X, Y, Z);
		V = X dot Velocity;
		Y = V*X;
		Dir -= 0.55*V/WAccelRate*Y;
		Dir -= 0.9*(Velocity - Y);
	}
	// X dot X == VSize(X)*VSize(X)
	if ((Dir dot Dir) > 25 /* 5*5 */)
		return Normal(Dir);
	return vect(0,0,0);
}

simulated function vector GetMovementSpeeds()
{
	local vector V;

	V = (Velocity << Rotation);
	V.Z = 0;
	Return Normal(V);
}
simulated function AttachmentsTick( float Delta )
{
	Super.AttachmentsTick(Delta);
	if( MyRotor!=None )
	{
		if( bOnGround )
			RotorYaw+=80000*Delta;
		else RotorYaw+=80000*(VSize(Velocity)/500+2.f)*Delta;
		While( RotorYaw>65536 )
			RotorYaw-=65536;
		MyRotor.Move(Location+(RotorOffset >> Rotation)-MyRotor.Location);
		MyRotor.SetRotation(MyRotor.TransformForGroundRot(RotorYaw,FloorNormal));
	}
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
{
	if (DamageType == 'BumpWall' || DamageType == 'Crushed')
		Damage *= 0.4;
	Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

defaultproperties
{
	MaxAirSpeed=1400.000000
	YawTurnSpeed=18000.000000
	CurrentYawSpeed=5.000000
	MaxYawRates(0)=6000.000000
	MaxYawRates(1)=-6000.000000
	WAccelRate=900.000000
	Health=300
	bCanFly=True
	VehicleName="Helicopter"
	TranslatorDescription="This is a chopper vehicle, you can fire different firemodes using [Fire] and [AltFire] buttons. To move higher or lover use [Jump] and [Crouch] buttons and to move around use movement keys. To leave this vehicle press [ThrowWeapon] key."
	VehicleKeyInfoStr="Chopper craft keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to strafe|%Jump%, %Duck% to move up/down|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%ThrowWeapon% to exit the vehicle"
	MaxObstclHeight=0.000000
	DropFlag=DF_All
	Mesh=LodMesh'UnrealShare.WoodenBoxM'
}
