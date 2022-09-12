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

const HoverGap = 50.0f;
const HoverDuck = 30.0f;

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
		bIsOnGround = PossibleBase != None && HN.Z >= 0.7;
		if (!bIsOnGround)
			HN = vect(0,0,1);
		ActualFloorNormal = HN;
		ActualHoverHeight = 0;
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
			PossibleBase = Trace(HL, HN, Dest, Rep, false);
			if (PossibleBase == None)
				HL = Dest;
			else if (HN.Z < 0.7) // preven climb on walls by repulsors
				continue;
			else
			{
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
			else if (Mover(PossibleBase) != None)
			{
				if (bDuck || bDuckFire)
				{
					if (PossibleBase.IsInState('StandOpenTimed'))
						Mover(PossibleBase).Attach(Driver);
					else
						Mover(PossibleBase).Bump(Driver);
				}
				if (PossibleBase.Velocity.Z > 0 && PossibleBase.Velocity.Z > Velocity.Z)
					Velocity.Z = PossibleBase.Velocity.Z;
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
	local bool bNeedDuck;
	local Actor HitDuck;

	if (Driver != None && PlayerPawn(Driver) == None)
	{ // bot drive code
		if (Driver.IsInState('GameEnded') || Driver.IsInState('Dying'))
			return vect(0,0,0);
		X = MoveDest - Location;
		Rising = 0;
		if (X.Z > 100)
			Rising = 1;
		// dont slow down if run over
		bNeedDuck = false;
		if (Driver.Enemy != None)
		{
			if (DriverWeapon(Driver.Enemy.Weapon) == None && VSize(Driver.Enemy.Location - MoveDest) <= CollisionRadius)
				bNeedDuck = true;
			else if (!bOnGround && Driver.Enemy.Location.Z < Location.Z)
			{
				Y = Driver.Enemy.Location - Location;
				Y.Z = 0;				
				if (VSize(Y) < CollisionRadius + Driver.Enemy.CollisionRadius)
					bNeedDuck = true;
				else if (Normal(Driver.Enemy.Location - Location).Z < -0.9)
					bNeedDuck = true;
			}
		}
		if (!bNeedDuck)
			X -= Velocity*0.85;
		if (LiftCenter(Driver.MoveTarget) != None && LiftCenter(Driver.MoveTarget).MyLift != None)
			bNeedDuck = true;
		if (!bNeedDuck)
		{
			Z.X = CollisionRadius;
			Z.Y = Z.X;
			Z.Z = CollisionHeight;						
			HitDuck = Trace(Y, Y, MoveDest - vect(0,0,1)*HoverDuck, Location - vect(0,0,1)*HoverDuck, true, Z);
			if (Pawn(HitDuck) != None && Pawn(HitDuck).PlayerReplicationInfo != None && 
				Pawn(HitDuck).PlayerReplicationInfo.Team != CurrentTeam)
				bNeedDuck = true; // run over enemy
			else if (HitDuck == None && Trace(Y, Y, MoveDest, Location, true, Z) != None)
				bNeedDuck = true; // need crouch for pass this place
		}
		if (bNeedDuck && !bDuckFire)
			PlayOwnedSound(DuckSound);
		bDuckFire = bNeedDuck;
		X.Z = 0;
		if (bOnGround)
			X = SetUpNewMVelocity(X, ActualFloorNormal, 0);
		// X dot X == VSize(X)*VSize(X)
		if ((X dot X) > 25 /* 5*5 */)
			return Normal(X);
		return vect(0,0,0);
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
	local vector Ac,End,Start,HL,HN;
	local float EngP, DeAcc, DeAccRat, GoDown, DesiredHoverHeight, Scale, BigScale;
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
		DesiredHoverHeight = HoveringHeight - HoverGap;
		GoDown = 0.75;
		Scale = 1000;
		BigScale = 0.2;
		
		if (PlayerPawn(Driver) != None && (Level.NetMode != NM_Client || IsNetOwner(Owner)) && 
			!Driver.IsInState('GameEnded'))
		{
			if (((Rising < 0 && !bDuck) ||
				(Driver.bAltFire != 0 && !bDuckFire)) &&
				DuckSound != None)
				PlayOwnedSound(DuckSound);
			bDuck = Rising < 0;
			bDuckFire = Driver.bAltFire != 0;
		}
		
		if (bDuck || bDuckFire)
		{				
			DesiredHoverHeight -= HoverDuck;
			GoDown = 8;
			Scale *= 3;
			BigScale *= 3;
		}
		if (bOnGround && LastJumpTime < Level.TimeSeconds - 0.4)
		{
			DesiredHoverHeight -= ActualHoverHeight;
			if (Abs(DesiredHoverHeight) < 2)
				Velocity.Z = 0;
			else
				Velocity.Z = DesiredHoverHeight*FMax(DesiredHoverHeight*DesiredHoverHeight*BigScale, Scale)*0.01/
					(1 + (Delta - 0.01)*25);
			BigScale = 5;
			if (Level.TimeSeconds - DriveFrom < 0.4)
				BigScale = 2.5; // *2.5 = /0.4
			Velocity.Z = FMin(Velocity.Z, HoveringHeight*BigScale);
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

	Ac = GetAccelDir(Turning, Rising, Accel);
	if (Ac dot Velocity > 0)
		Ac *= WAccelRate;
	else
		Ac *= WDeAccelRate;
	Velocity += Ac*Delta;	
	if (VSize(Velocity) > MaxHoverSpeed)
		Velocity = Normal(Velocity)*MaxHoverSpeed;
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
{
	if (DamageType == 'BumpWall' || DamageType == 'Crushed')
		Damage *= 0.04;
	Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

// Returns the bot turning value for target
function int ShouldTurnFor( vector AcTarget, optional float YawAdjust, optional float DeadZone )
{ // handled inside GetAccelDir
	Return 0;
}

simulated function PostBeginPlay()
{
	local int i;
	local float Avg;
	Super.PostBeginPlay();
	if (VehicleAI != None)
	{
		for (i = 0; i < ArrayCount(Repulsor); i++)
			Avg += Repulsor[i].Z;
		VehicleAI.AirFlyScale = (HoveringHeight - HoverGap - 
			Avg/ArrayCount(Repulsor) - class'NavigationPoint'.default.CollisionHeight)/CollisionHeight;
	}
}

simulated function RenderCanvasOverlays( Canvas C, DriverCameraActor Cam, byte Seat )
{
	local float Y, XS, X;
	Super.RenderCanvasOverlays(C, Cam, Seat);
	if (Seat == 0)
	{
		Y = C.ClipY/6*5;
		XS = C.ClipX/4;
		X = C.ClipX/2;
		DrawJumpBar(C, X, Y + 24, XS, 6);
	}
}

simulated function DrawJumpBar(Canvas C, int X, int Y, float Width, float Height)
{
	local float Pct;
	
	Pct = Fmin(1.0, (Level.TimeSeconds - LastJumpTime)/JumpDelay);

	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 64;
	
	C.SetPos(X + (0.5 - Pct)*Width, Y);
	C.DrawTile(Texture'Misc', Width*Pct, Height, 60, 60, 64, 64);
}

defaultproperties
{
	MaxHoverSpeed=800.000000
	VehicleTurnSpeed=55000.000000
	HoveringHeight=100.000000
	JumpingHeight=500.000000
	JumpDelay=3.000000
	WAccelRate=700.000000
	Health=200
	bCanFly=True
	VehicleName="Hover Craft"
	TranslatorDescription="This is a Hover Craft, press [Fire] or [AltFire] to fire the different firemodes. Use your Strafe keys and Move Forward/Backward keys to strafe/accelerate/deaccelerate. To leave this vehicle, press your [ThrowWeapon] key."
	VehicleKeyInfoStr="Hover craft keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%,%StrafeRight% to strafe|%Jump% to jump with the vehicle|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%ThrowWeapon% to exit the vehicle"
	Mesh=LodMesh'UnrealShare.WoodenBoxM'
}
