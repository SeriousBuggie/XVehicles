// A hover craft. (Created by .:..: 13.1.2008)
Class HoverCraftPhys extends Vehicle;

var() float MaxHoverSpeed, 
			VehicleTurnSpeed, 
			HoveringHeight, 
			JumpingHeight,
			MaxPushUpDiff,
			JumpDelay;
var() bool bHoverWhenNotDriving;
var() bool bCanDuck;
var() vector Repulsor[8]; // used only 3, since Manta really one vehicle for it
var() int RepulsorCount;
var() float RideHeight;	// repulsors over the ground when hovering, from HoveringHeight if not set
var() Sound JumpSound, DuckSound;

var   float LastJumpTime,
			ActualHoverHeight,
			DriveFrom,
			RepDist[ArrayCount(Repulsor)];
var bool bDuck, bDuckFire;

var RepulsorTracker RepulsorTracker;

var vector BotAccelDir;
var float RepulsorZ;		// average height of the repulsors on the craft
var vector GroundLook;		// real ground plane under the repulsors
var vector HoverTilt, HoverTiltRate;	// body tilt, a spring onto part of that plane

const HoverGap = 50.0f;
const HoverDuck = 40.0f;
const LookAhead = 0.14f;	// seconds
const Clearance = 12.0f;	// kept under the collision cylinder
const ClimbShare = 0.1f;	// part of the ground the spring follows, the craft rides low on a climb
const HillDrag = 1.8f;		// speed lost per second on a climb, times tan(grade)
const NoseUp = 0.85f;		// part of a slope the nose takes going up
const NoseMost = 0.27f;		// ~15 degrees
const NoseDown = 0.25f;		// same going down
const RollShare = 0.60f;	// same for a side slope
const RollMost = 0.2f;		// ~11 degrees
const RestNose = 0.028f;	// ~1.6 degrees nose up when parked, gone at speed
const SideThrust = 0.74f;	// strafing is weaker than main thrust
const WallDrag = 0.85f;		// speed lost along a wall for each uu/s into it
const BankDrag = 0.5f;		// same along a bank
const WallZ = 0.35f;		// steeper than this is a wall, not a bank

replication
{
	// Variables the server should send to the client.
	unreliable if (Role == ROLE_Authority && !bNetOwner)
		bDuck, bDuckFire;
}

// detect if hover above ground or no
simulated function bool CheckOnGround()
{
	local vector RepPos[ArrayCount(Repulsor)], Under[ArrayCount(Repulsor)], Rep, Dest, HL, HN;
	local int i, PushUpMax, Count;
	local rotator R;
	local float Dist, Delta, Prev, Sum, PushUp[ArrayCount(Repulsor)];
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
		
		for (i = 0; i < RepulsorCount; i++)
		{
			RepDist[i] = -1;
			R.Yaw = Rotation.Yaw;
			R.Pitch = 0;
			R.Roll = 0;
			
			// outside the collision cylinder and level, leaning doesn't change the ground under it
			Rep = Repulsor[i] >> R;
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
			RepulsorTracker.SetLocation(HL);
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
				if (bCanDuck && (bDuck || bDuckFire))
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
			Under[i] = Rep;
			Under[i].Z -= Dist;
			Sum += Dist;
			Count++;
			PushUp[i] = HoveringHeight - Dist;
			if (PushUpMax != i && PushUp[PushUpMax] < PushUp[i])
				PushUpMax = i;
		}
		if (!bIsOnGround)
		{
			ActualFloorNormal = vect(0,0,1);
			GroundLook = vect(0,0,1);
		}
		else
		{
			// Manta specific: not pitch down, only up
			if (RepulsorCount == 3)
			{
				PushUp[0] = FMax(PushUp[0], (PushUp[1] + PushUp[2])/2);
				if (bCanDuck && (bDuck || bDuckFire))
				{
					PushUp[1] -= 1;
					PushUp[2] -= 1;
				}
			}
			for (i = 0; i < RepulsorCount; i++)
			{
				if (RepDist[i] == -1)
					PushUp[i] = PushUp[PushUpMax];
				else if (PushUpMax != i && PushUp[PushUpMax] - PushUp[i] > MaxPushUpDiff)
					PushUp[i] = PushUp[PushUpMax] - MaxPushUpDiff;
				RepPos[i].Z += PushUp[i];
			}
			// thrust stays near level with these limits, the body uses the real ground
			ActualFloorNormal = Normal((RepPos[1] - RepPos[0]) cross (RepPos[2] - RepPos[0]));
			if (ActualFloorNormal.Z < 0)
				ActualFloorNormal = -ActualFloorNormal;
			ActualHoverHeight = Sum/Count;
			for (i = 0; i < 3; i++)
				if (RepDist[i] == -1)
				{
					Under[i] = Location + (Repulsor[i] >> R);
					Under[i].Z -= ActualHoverHeight;
				}
			GroundLook = Normal((Under[1] - Under[0]) cross (Under[2] - Under[0]));
			if (GroundLook.Z < 0)
				GroundLook = -GroundLook;
		}
	}
	
	LastCheckOnGroundLocation = Location;
	LastCheckOnGroundTime = Level.TimeSeconds;
	bLastCheckOnGroundResult = bIsOnGround;
	
	return bIsOnGround;
}

function bool NeedStop(Pawn pDriver)
{
	local bool ret;
	local vector Diff;
	ret = Super.NeedStop(pDriver);
	if (!ret && bOnGround)
	{
		Diff = (MoveDest - Location);
		if (Normal(Diff).Z < -0.85 && Diff.Z < -CollisionHeight &&
			Diff.Z > -(CollisionHeight + 1.2*HoveringHeight)) // 1.2 ~= 1/0.85
			ret = true;
	}
	return ret;
}

// Return normal for acceleration direction.
simulated function vector GetAccelDir( int InTurn, int InRise, int InAccel )
{
	local rotator R;
	local vector X,Y,Z;

	if (Driver != None && PlayerPawn(Driver) == None)
		return BotAccelDir;
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
// Rise speed needed for the front edge of the cylinder to clear the ground ahead
simulated function float ClearAhead(vector Flat, float Run, float Time)
{
	local vector Ahead, HL, HN;

	Ahead = Location + Flat*(Time + CollisionRadius/Run);
	Ahead.Z += CollisionHeight;
	if (Trace(HL, HN, Ahead - vect(0,0,1)*(CollisionHeight + HoveringHeight + 64), Ahead, false) == None)
		return 0;
	return (HL.Z + CollisionHeight + Clearance - Location.Z)/Time;
}

// Body takes only part of a slope, through a spring
simulated function UpdateTilt(float Delta)
{
	local vector X, Y, Z, Want;
	local float Along, Across, Freq;
	const HoverFreq = 9.0;
	const AirFreq = 3.5;
	const HoverDamp = 0.7;

	if (HoverTilt == vect(0,0,0))
		HoverTilt = Normal(FloorNormal);
	if (!bDriving && !bHoverWhenNotDriving)
		Want = ActualFloorNormal;
	else
	{
		GetAxes(rot(0, 1, 0)*VehicleYaw, X, Y, Z);
		Along = -(GroundLook dot X)/FMax(0.4, GroundLook.Z);
		Across = -(GroundLook dot Y)/FMax(0.4, GroundLook.Z);
		if (Along > 0)
			Along = FMin(Along*NoseUp, NoseMost);
		else
			Along *= NoseDown;
		if (bDriving)
			Along += RestNose*(1.0 - FMin(1.0, VSize(Velocity)/1000.0));
		Want = vect(0,0,1) - X*Along - Y*FClamp(Across*RollShare, -RollMost, RollMost);
	}
	Freq = HoverFreq;
	if (!bOnGround)
		Freq = AirFreq;
	HoverTiltRate += (Freq*Freq*(Want - HoverTilt) - 2*HoverDamp*Freq*HoverTiltRate)*Delta;
	HoverTilt += HoverTiltRate*Delta;
}

simulated function UpdateDriverInput( float Delta )
{
	local byte PitchDif;
	local vector Ac, X, Y, Z, Flat, Push;
	local float EngP, GoDown, DesiredHoverHeight, Climb, Spring, Most, Least, Damp, Run, Slope;
	local rotator R;

	if (bEngDynSndPitch && Level.NetMode != NM_DedicatedServer)
	{
		PitchDif = MaxEngPitch - MinEngPitch;
		EngP = MinEngPitch + Min(PitchDif, (VSize(Velocity)*PitchDif/MaxHoverSpeed));
		SoundPitch = Byte(EngP);
	}
	
	if (!bDriving)
		DriveFrom = Level.TimeSeconds;

	if (Level.NetMode != NM_DedicatedServer)
	{
		TrackAccel(Delta, 11.0);
		// barely any pitch from thrust, turning and strafing do most of the lean
		GetAxes(rot(0, 1, 0)*VehicleYaw, X, Y, Z);
		Push = X*FClamp((BodyAccel dot X)*0.000015, -0.12, 0.12) + Y*FClamp((BodyAccel dot Y)*0.00015, -0.18, 0.18);
		if (!bDriving)
			Push = vect(0,0,0);
		UpdateLean(Push, Delta);
	}
	UpdateTilt(Delta);
	R = TransformForGroundRot(VehicleYaw, Normal(HoverTilt + BodyLean));
	if (Rotation != R)
		SetRotation(R);

	GoDown = 1;
	if (bDriving || bHoverWhenNotDriving)
	{
		DesiredHoverHeight = RideHeight;
		GoDown = 0.83;
		Spring = 11;
		Damp = 0.8;
		Most = 1500;
		
		if (PlayerPawn(Driver) != None && (Level.NetMode != NM_Client || IsNetOwner(Owner)) && 
			!Driver.IsInState('GameEnded') && !(Level.Game != None && Level.Game.bGameEnded))
		{
			if (((Rising < 0 && !bDuck) ||
				(Driver.bAltFire != 0 && !bDuckFire)) &&
				DuckSound != None && bCanDuck)
				PlayOwnedSound(DuckSound);
			bDuck = bCanDuck && Rising < 0;
			bDuckFire = bCanDuck && Driver.bAltFire != 0;
		}
		
		if (bCanDuck && (bDuck || bDuckFire))
		{				
			DesiredHoverHeight -= HoverDuck;
			GoDown = 8;
			Spring = 20;
			Most = 9000;
		}
		if (bOnGround && LastJumpTime < Level.TimeSeconds - 0.4 && (Level.NetMode != NM_Client || IsNetOwner(Owner)))
		{
			// spring that only pushes and follows part of the ground, gravity brings the craft down
			Flat = Velocity;
			Flat.Z = 0;
			Slope = -(Flat dot GroundLook)/FMax(0.4, GroundLook.Z);
			Climb = Slope*ClimbShare;
			// cylinder is wider than the repulsors, its front edge has to clear what's coming
			Run = VSize(Flat);
			if (Run > 1)
			{
				Climb = FMax(Climb, ClearAhead(Flat, Run, LookAhead/2));
				Climb = FMax(Climb, ClearAhead(Flat, Run, LookAhead));
			}
			if (Velocity.Z < -200)
				Most = FMax(Most, 5200); // falling lands hard on the repulsors
			if (Level.TimeSeconds - DriveFrom < 0.5)
				Most = FMin(Most, 1500);
			Least = -Abs(Region.Zone.ZoneGravity.Z)*VehicleGravityScale*GoDown;
			Velocity.Z += FClamp(Spring*Spring*(DesiredHoverHeight - ActualHoverHeight) +
				2*Damp*Spring*(Climb - Velocity.Z), Least, Most)*Delta;
			if (Slope > 0 && Run > 1)
				Velocity -= Flat*FMin(0.5, HillDrag*Slope/Run*Delta);
		}
	}
	else if (bOnGround)
		Velocity -= ActualFloorNormal*(ActualFloorNormal dot Velocity);

	if (Level.NetMode == NM_Client && !IsNetOwner(Owner))
		Return;

	if (!bOnGround || LastJumpTime >= Level.TimeSeconds - 0.4)
		Velocity += Region.Zone.ZoneGravity*Delta*VehicleGravityScale*GoDown;

	// Update vehicle yaw.
	if (bDriving && Driver != None && !Driver.IsInState('GameEnded') && 
		(Level.Game == None || !Level.Game.bGameEnded))
	{
		/*
		if (PlayerPawn(Driver) == None)
		{
			if (Driver.Target != None && FastTrace(Driver.Target.Location))
				X = Driver.Target.Location - Location;
			else
				X = Velocity;
			if (VSize(X) > 10)
				R = rotator(X);
			else
				R = Driver.ViewRotation;
			VehicleYaw = CalcTurnSpeed(VehicleTurnSpeed*Delta, VehicleYaw, R.Yaw);
		}
		else
		*/
			FollowYaw(Driver.ViewRotation.Yaw, VehicleTurnSpeed, Delta);
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
		GetAxes(rot(0, 1, 0)*VehicleYaw, X, Y, Z);
		Ac = Velocity;
		Ac.Z = 0;
		Ac -= FMin(1, Delta)*(X dot Ac)*X + 5*FMin(0.2, Delta)*(Y dot Ac)*Y;
		Velocity.X = Ac.X;
		Velocity.Y = Ac.Y;
		Return;
	}
	
	if (Accel == 0)
	{
		GetAxes(rot(0, 1, 0)*VehicleYaw, X, Y, Z);
		Velocity -= FMin(1, Delta)*(X dot Velocity)*X;
	}
	else if (Turning == 0)
	{
		GetAxes(rot(0, 1, 0)*VehicleYaw, X, Y, Z);
		Velocity -= 5.5*FMin(0.18, Delta)*(Y dot Velocity)*Y;
	}

	Ac = GetAccelDir(Turning, Rising, Accel);
	GetAxes(rot(0, 1, 0)*VehicleYaw, X, Y, Z);
	Ac -= Y*(Y dot Ac)*(1.0 - SideThrust);
	if (Ac dot Velocity > 0)
		Ac *= WAccelRate;
	else
		Ac *= WDeAccelRate;
	Velocity += Ac*Delta;
	if (VSize(Velocity) > MaxHoverSpeed)
		Velocity = Normal(Velocity)*MaxHoverSpeed;
}

// Ground: glance off and keep flying. Wall: no bounce, drag along it and swing the nose in
simulated singular function HitWall( vector HitNormal, Actor Wall )
{
	local vector X, Y, Z, Along;
	local float Into, Speed, Square, Swing;

	Into = Velocity dot HitNormal;
	if (Into >= 0)
		return;
	Speed = VSize(Velocity);
	if (HitNormal.Z >= WalkableZ)
	{
		Velocity -= HitNormal*Into;
		if (Speed > 0 && bDriving)
			Velocity = Normal(Velocity)*FMax(VSize(Velocity), Speed*0.97);
		return;
	}
	if (Pawn(Wall) != None)
	{
		Velocity -= HitNormal*Into*1.3;
		return;
	}
	Velocity -= HitNormal*Into;
	Along = Velocity;
	Square = BankDrag;
	if (HitNormal.Z < WallZ)
	{
		Along.Z = FMax(0, Along.Z); // pressing on a wall doesn't hold the craft up
		Square = WallDrag;
	}
	if (VSize(Along) > 0)
		Velocity -= Along*FMin(1.0, -Square*Into/VSize(Along));
	if (HitNormal.Z < WallZ && bDriving && Into < -150)
	{
		GetAxes(rot(0, 1, 0)*VehicleYaw, X, Y, Z);
		Swing = X.X*HitNormal.Y - X.Y*HitNormal.X;
		if ((X dot HitNormal) < 0)
			TurnRate += FClamp(Swing*Into/30.0, -60, 60)*3900.0;
	}
	if (Wall != Level && Wall.Brush == None)
		return;
	Square = -Into/FMax(1.0, Speed);
	if (Speed > 500 && Square > 0.97)
		TakeImpactDamage((Speed - 500)/2, None, "HoverHit_1");
	else if (Speed > 600 && Square > 0.877)
		TakeImpactDamage((Speed - 600)/4, None, "HoverHit_2");
	else if (NextScrapeTime < Level.TimeSeconds)
	{
		NextScrapeTime = Level.TimeSeconds + 0.4;
		TakeImpactDamage(0, None, "HoverHit_3");
	}
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
{
	if (DamageType == 'BumpWall' || DamageType == 'Crushed')
		Damage *= 0.04;
	Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
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
	local vector Dir, X, Y, Z, Vxy;
	local bool bNeedDuck;
	local Actor HitDuck;
	local float V;
	
	if (Driver.IsInState('GameEnded') || Driver.IsInState('Dying') || 
		(Level.Game != None && Level.Game.bGameEnded))
		return vect(0,0,0);
	if (Reverse != 0 && ReverseTime > Level.TimeSeconds)
		return Normal((Location - MoveDest)*vect(1,1,0));
	Dir = MoveDest - Location;
	bNeedDuck = false;
	Accel = 1; // always accelerate
	Rising = 0;
	V = Dir.Z;
	Dir.Z = 0;
	if (bOnGround && V > 100 && VSize(Dir) < 800)
		Rising = 1;
	if (!bOnGround && V < -200 && VSize(Dir) < CollisionRadius)
		bNeedDuck = true;
	Turning = 0;
	if (Abs(Normal(Dir) dot vector(rot(0, 1, 0)*VehicleYaw)) < 0.999)
		Turning = 1; // for prevent slow down for move on side
	// dont slow down if run over
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
//	if (!bNeedDuck)
//		X -= Velocity*0.85;
	if (!bNeedDuck)
	{		
		GetAxes(rotator(Dir), X, Y, Z);
		Vxy = Velocity;
		Vxy.Z = 0;
		Dir -= 0.55*Square(X dot Vxy)/WDeAccelRate*X;
		Dir -= 0.85*(Y dot Vxy)*Y;
	}
	if (bCanDuck)
	{
		if (LiftCenter(Driver.MoveTarget) != None && LiftCenter(Driver.MoveTarget).MyLift != None)
			bNeedDuck = true;
		if (LiftExit(Driver.MoveTarget) != None && 
			LiftExit(Driver.MoveTarget).Location.Z - Location.Z > JumpingHeight && 
			LiftExit(Driver.MoveTarget).MyLift != None && 
			LiftExit(Driver.MoveTarget).MyLift.myMarker != None &&
			VSize(Location - LiftExit(Driver.MoveTarget).MyLift.myMarker.Location) < 
			CollisionRadius + LiftExit(Driver.MoveTarget).MyLift.myMarker.CollisionRadius)
			bNeedDuck = true;
		if (ControlPoint(Driver.MoveTarget) != None)
			bNeedDuck = true;
		if (!bNeedDuck)
		{
			Z.X = CollisionRadius;
			Z.Y = Z.X;
			Z.Z = CollisionHeight;						
			HitDuck = Trace(Y, Y, MoveDest - vect(0,0,1)*HoverDuck, Location - vect(0,0,1)*HoverDuck, true, Z);
			if (!Level.Game.bTeamGame || 
				(Pawn(HitDuck) != None && Pawn(HitDuck).PlayerReplicationInfo != None && 
				Pawn(HitDuck).PlayerReplicationInfo.Team != CurrentTeam))
				bNeedDuck = true; // run over enemy
			else if (HitDuck == None && Trace(Y, Y, MoveDest, Location, true, Z) != None)
				bNeedDuck = true; // need crouch for pass this place
			else if (Level.Game.bTeamGame && Vehicle(HitDuck) != None && 
				Vehicle(HitDuck).CurrentTeam == CurrentTeam)
				Rising = 1; // need jump for pass through this friendly vehicle
		}
		if (bNeedDuck && !bDuckFire)
			PlayOwnedSound(DuckSound);
	}
	bDuckFire = bCanDuck && bNeedDuck;
	Dir.Z = 0;
	if (bOnGround)
		Dir = SetUpNewMVelocity(Dir, ActualFloorNormal, 0);
	// X dot X == VSize(X)*VSize(X)
	if ((Dir dot Dir) > 25 /* 5*5 */)
		return Normal(Dir);
	return vect(0,0,0);
}

simulated function PostBeginPlay()
{
	local int i;
	local float Avg;
	bScriptMove = True;
	if (RideHeight <= 0)
		RideHeight = (HoveringHeight - HoverGap)/0.75;
	Super.PostBeginPlay();
	for (i = 0; i < RepulsorCount; i++)
		Avg += Repulsor[i].Z;
	if (RepulsorCount > 0)
		RepulsorZ = Avg/RepulsorCount;
	if (VehicleAI != None)
	{
		VehicleAI.AirFlyScale = (HoveringHeight - HoverGap -
			Avg/RepulsorCount - class'NavigationPoint'.default.CollisionHeight)/CollisionHeight;
	}
}

simulated function RenderCanvasOverlays( Canvas C, DriverCameraActor Cam, byte Seat )
{
	local float Y, XS, X;
	Super.RenderCanvasOverlays(C, Cam, Seat);
	if (Seat == 0)
	{
		Y = C.CurY; // come from Super call
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
	DropFlag=DF_All
	Mesh=LodMesh'UnrealShare.WoodenBoxM'
}
