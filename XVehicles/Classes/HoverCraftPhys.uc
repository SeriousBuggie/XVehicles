// A hover craft. (Created by .:..: 13.1.2008)
Class HoverCraftPhys extends Vehicle;

var() float MaxHoverSpeed, 
			VehicleTurnSpeed, 
			HoveringHeight, 
			JumpingHeight,
			MaxPushUpDiff,
			JumpDelay;
var() bool bHoverWhenNotDriving;
var() vector Repulsor[3]; // used only 3, since Manta really one vehicle for it
var() Sound JumpSound, DuckSound;
var() bool bEngDynSndPitch;
var() byte MinEngPitch, MaxEngPitch;

var   float LastJumpTime,
			ActualHoverHeight,
			DriveFrom,
			RepDist[ArrayCount(Repulsor)];
var bool bDuck, bDuckFire;

var RepulsorTracker RepulsorTracker;

replication
{
	// Variables the server should send to the client.
	unreliable if (Role == ROLE_Authority && !bNetOwner)
		bDuck, bDuckFire;
}

// detect if hover above ground or no
simulated function bool CheckOnGround()
{
	local vector RepPos[ArrayCount(Repulsor)], Rep, Dest, HL, HN;
	local int i, PushUpMax;
	local rotator R;
	local float Dist, Delta, Prev, PushUp[ArrayCount(Repulsor)];
	local bool bIsOnGround;
	local Actor PossibleBase;
	
	if (Location == LastCheckOnGroundLocation && 
		Level.TimeSeconds < LastCheckOnGroundTime + 0.2)
		return bLastCheckOnGroundResult;
	
	if (!bDriving && !bHoverWhenNotDriving)
	{
		HL = Location;
		HL.Z -= CollisionHeight + 4;
		HN.X = CollisionRadius;
		HN.Y = HN.X;
		PossibleBase = Trace(HL, HN, HL, Location, True, HN);
		bIsOnGround = PossibleBase != None;
		if (!bIsOnGround)
			HN = vect(0,0,1);
		ActualFloorNormal = HN;
		CheckBase(PossibleBase);
	}
	else
	{	
		
		if (RepulsorTracker == None)
			RepulsorTracker = Spawn(class'RepulsorTracker', self);
		
		for (i = 0; i < ArrayCount(Repulsor); i++)
		{
			RepDist[i] = -1;
			R.Yaw = Rotation.Yaw;
			R.Pitch = 0;
			R.Roll = 0;
			
			// this need for save repulsor location outside collision cylinder
			Rep = Repulsor[i] >> R;
			Rep.Z = (Repulsor[i] >> Rotation).Z;
			Rep += Location;
			
			RepPos[i] = Rep;
			// repulsor inside world geometry, so not take it in account
			if (!FastTrace(Rep))
				continue;
			RepulsorTracker.SetLocation(Rep);
			// Repulsor not work under water
			if (RepulsorTracker.Region.Zone.bWaterZone)
				continue;
			
			Dest = Rep;
			Dest.Z -= HoveringHeight;
			if (Trace(HL, HN, Dest, Rep, false) == None)
				HL = Dest;
			else {
				bIsOnGround = true;
				HL.Z += 0.1; // avoid be on edge
			}
			Dist = Rep.Z - HL.Z;
			RepulsorTracker.SetLocation(Dest);		
			if (RepulsorTracker.Region.Zone.bWaterZone) {
				bIsOnGround = true;
				// end in water, now need find water surface
				// use binary search for that
				Dest.Z = Rep.Z;
				for (Delta = Dist/2; Delta > 0.1; Delta /= 2)
				{
					Prev = Dest.Z;
					Dest.Z -= Delta;
					RepulsorTracker.SetLocation(Dest);
					if (RepulsorTracker.Region.Zone.bWaterZone)
						Dest.Z = Prev;
				}
				Dist = Rep.Z - Dest.Z;
			}
			RepDist[i] = Dist;
			PushUp[i] = HoveringHeight - Dist;
			if (PushUpMax != i && PushUp[PushUpMax] < PushUp[i])
				PushUpMax = i;
		}
		if (!bIsOnGround)
			ActualFloorNormal = vect(0,0,1);
		else
		{
			// Manta specific: not pitch down, only up
			PushUp[0] = FMax(PushUp[0], (PushUp[1] + PushUp[2])/2);
			if (bDuck || bDuckFire)
			{
				PushUp[1] -= 1;
				PushUp[2] -= 1;
			}
			for (i = 0; i < ArrayCount(Repulsor); i++)
			{
				if (RepDist[i] == -1)
					PushUp[i] = PushUp[PushUpMax];
				else if (PushUpMax != i && PushUp[PushUpMax] - PushUp[i] > MaxPushUpDiff)
					PushUp[i] = PushUp[PushUpMax] - MaxPushUpDiff;
				RepPos[i].Z += PushUp[i];
				ActualHoverHeight += PushUp[i];
			}
			ActualFloorNormal = Normal((RepPos[1] - RepPos[0]) cross (RepPos[2] - RepPos[0]));
			if (ActualFloorNormal.Z < 0)
				ActualFloorNormal = -ActualFloorNormal;
			ActualHoverHeight = HoveringHeight - ActualHoverHeight/ArrayCount(Repulsor);
		}
	}
	
	LastCheckOnGroundLocation = Location;
	LastCheckOnGroundTime = Level.TimeSeconds;
	bLastCheckOnGroundResult = bIsOnGround;
	
	return bIsOnGround;
}

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
	local byte PitchDif;
	local float EngP;
	local vector Ac,End,Start,HL,HN;
	local float DeAcc, DeAccRat, GoDown, DesiredHoverHeight, Scale, BigScale;
	local rotator R;

	if (bEngDynSndPitch)
	{
		PitchDif = MaxEngPitch - MinEngPitch;
		EngP = MinEngPitch + Min(PitchDif, (VSize(Velocity)*PitchDif/MaxHoverSpeed));
		SoundPitch = Byte(EngP);
	}
	
	if (!bDriving)
		DriveFrom = Level.TimeSeconds;

	R = TransformForGroundRot(VehicleYaw, FloorNormal);
	if (Rotation != R)
		SetRotation(R);
		
	GoDown = 1;
	if (bDriving || bHoverWhenNotDriving)
	{
		DesiredHoverHeight = HoveringHeight - 50;
		GoDown = 0.75;
		Scale = 1000;
		BigScale = 0.2;
		
		if ((Level.NetMode != NM_Client || IsNetOwner(Owner)))		{			if (((Rising < 0 && !bDuck) ||				(Driver.bAltFire != 0 && !bDuckFire)) &&				DuckSound != None)				PlayOwnedSound(DuckSound);			bDuck = Rising < 0;			bDuckFire = Driver.bAltFire != 0;		}				if (bDuck || bDuckFire)		{							DesiredHoverHeight -= 30;			GoDown = 8;			Scale *= 3;			BigScale *= 3;		}		if (bOnGround && LastJumpTime < Level.TimeSeconds - 0.4)		{			DesiredHoverHeight -= ActualHoverHeight;			if (Abs(DesiredHoverHeight) < 2)				Velocity.Z = 0;			else				Velocity.Z = DesiredHoverHeight*FMax(DesiredHoverHeight*DesiredHoverHeight*BigScale, Scale)*Delta;
			if (Level.TimeSeconds - DriveFrom > 0.4)
				Velocity.Z = FMin(Velocity.Z, HoveringHeight/0.4);
						}
	}
	else if (bOnGround)
		Velocity -= ActualFloorNormal*(ActualFloorNormal dot Velocity);
	
	if (!bOnGround)
		Velocity += Region.Zone.ZoneGravity*Delta*VehicleGravityScale*GoDown;

	if (Level.NetMode == NM_Client && !IsNetOwner(Owner))
		Return;

	// Update vehicle yaw.
	if (bDriving && Driver != None)
	{
		if (PlayerPawn(Driver) == None)
		{
			if (Driver.Target != None)
				HL = Driver.Target.Location;
			else 
				HL = Location+Velocity*100;
			VehicleYaw = CalcTurnSpeed(VehicleTurnSpeed*Delta, VehicleYaw, rotator(HL - Location).Yaw);
		}
		else
			VehicleYaw = CalcTurnSpeed(VehicleTurnSpeed*Delta, VehicleYaw, Driver.ViewRotation.Yaw);
	}
	// Update vehicle speed
	if (Rising > 0 && bOnGround && LastJumpTime < Level.TimeSeconds - JumpDelay)
	{
		LastJumpTime = Level.TimeSeconds;
		Velocity.Z += JumpingHeight;
		if (JumpSound != None)
			PlayOwnedSound(JumpSound);
	}
	if (Accel == 0 && Turning == 0)
	{
		Ac = Velocity;
		Ac.Z = 0;
		DeAcc = VSize(Ac);
		DeAccRat = Delta*WAccelRate;
		if (DeAccRat > DeAcc)
			DeAccRat = DeAcc;
		Ac -= Normal(Ac)*DeAccRat;
		Velocity.X = Ac.X;
		Velocity.Y = Ac.Y;
		Return;
	}

	Ac = GetAccelDir(Turning,Rising,Accel);
	if (Ac dot Velocity > 0)
		Ac *= WAccelRate;
	else
		Ac *= WDeAccelRate;
	if (VSize(Velocity) > MaxHoverSpeed && VSize(Normal(Velocity) - Normal(Ac)) < 0.15)
		Velocity += Ac*Delta/10;
	else
		Velocity += Ac*Delta;
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
{
	if (DamageType == 'BumpWall')
		Damage *= 0.04;
	Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

// Returns the bot turning value for target
function int ShouldTurnFor( vector AcTarget, optional float YawAdjust, optional float DeadZone )
{
	Return 0;
}

defaultproperties
{
      MaxHoverSpeed=800.000000
      VehicleTurnSpeed=55000.000000
      HoveringHeight=100.000000
      JumpingHeight=500.000000
      MaxPushUpDiff=0.000000
      JumpDelay=3.000000
      bHoverWhenNotDriving=False
      Repulsor(0)=(X=0.000000,Y=0.000000,Z=0.000000)
      Repulsor(1)=(X=0.000000,Y=0.000000,Z=0.000000)
      Repulsor(2)=(X=0.000000,Y=0.000000,Z=0.000000)
      JumpSound=None
      DuckSound=None
      bEngDynSndPitch=False
      MinEngPitch=0
      MaxEngPitch=0
      LastJumpTime=0.000000
      ActualHoverHeight=0.000000
      DriveFrom=0.000000
      RepDist(0)=0.000000
      RepDist(1)=0.000000
      RepDist(2)=0.000000
      bDuck=False
      bDuckFire=False
      RepulsorTracker=None
      WAccelRate=700.000000
      Health=200
      bCanFly=True
      VehicleName="Hover Craft"
      TranslatorDescription="This is a Hover Craft, press [Fire] or [AltFire] to fire the different firemodes. Use your Strafe keys and Move Forward/Backward keys to strafe/accelerate/deaccelerate. To leave this vehicle, press your [ThrowWeapon] key."
      VehicleKeyInfoStr="Hover craft keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%,%StrafeRight% to strafe|%Jump% to jump with the vehicle|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%ThrowWeapon% to exit the vehicle"
      Mesh=LodMesh'UnrealShare.WoodenBoxM'
}
