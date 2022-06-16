// A tread craft. (Created by .:..: 10.1.2008)
Class TreadCraftPhys extends Vehicle;

var() float MaxGroundSpeed,VehicleTurnSpeed;
var float CurTurnSpeed,NextAUpdTime;
var byte TurningRep,NumMoveAnimFrames,CurrentAnimFrame;
var bool bHasAnimTread;

var bool bWasStuckOnW,bReversing;
var float StuckTimer,ReverseTimer;

var() texture TreadPan[16], AltTreadPan[16];	//Treads moving texture

//Treads
struct TTreading
{
	var() float MovPerTreadCycle;	//Basically, it's distance made in uu when the tread pan makes a full cycle
	var() mesh TreadMesh;
	var() byte TreadSkinN;		//Multiskin where the pan is apllied
	var() vector TreadOffset;
	var() float TreadScale;
	var() bool bUseAltTread;
	var TreadsTrailer TTread;
	var int CurrentTPan;
	var float TPanCount;
	var() bool bHaveAnimTWheels;
	var() int WheelFramesN;
	var() name WheelAnimSet;
	var() float WheelSize;
	var() bool bWheenAnimInverted;
	var float CurrentWheelFrame;
	var() float TrackWidth;		//For water FX
	var() vector TrackFrontOffset, TrackBackOffset;	//For water FX
};

var() TTreading Treads[8];

var(TreadedEng) bool bEngDynSndPitch;
var(TreadedEng) byte MinEngPitch, MaxEngPitch;
var() float TreadsTraction;
var vector VelFriction;

var float OldVehicleYaw;
var bool OldTTurnDir;
var bool IceFix;

var(Wrecked) float WreckTrackColHeight, WreckTrackColRadius;

var VehWaterAttach VWaterT[8];

replication
{
	// Variables the server should send to the client.
	unreliable if( Role==ROLE_Authority && !bNetOwner )
		TurningRep;
}

simulated function PostBeginPlay()
{
	local byte i;

	if( Level.NetMode!=NM_DedicatedServer )
	{
		For (i=0; i<ArrayCount(Treads); i++)
		{
			if (Treads[i].TreadMesh != None)
			{
				Treads[i].TTread = Spawn(Class'TreadsTrailer',Self);
				Treads[i].TTread.PrePivotRel = Treads[i].TreadOffset;
				Treads[i].TTread.Mesh = Treads[i].TreadMesh;
				if (!Treads[i].bUseAltTread)
					Treads[i].TTread.MultiSkins[Treads[i].TreadSkinN] = TreadPan[0];
				else
					Treads[i].TTread.MultiSkins[Treads[i].TreadSkinN] = AltTreadPan[0];
				Treads[i].TTread.DrawScale = Treads[i].TreadScale;
				Treads[i].TTread.AnimSequence = Treads[i].WheelAnimSet;
		
				//Water Trail FX points creation
				if (bHaveGroundWaterFX && bSlopedPhys)
				{
					VWaterT[i] = Spawn(Class'VehWaterAttach',Self);
					VWaterT[i].WaveSize = Treads[i].TTread.DrawScale * Treads[i].TrackWidth * 2;
					VWaterT[i].SoundRadius = Max(32,Min(Max(CollisionRadius,CollisionHeight)/2.5,255));
				}	
			}
		}
	}

	Super.PostBeginPlay();
}

simulated function SpawnFurtherParts()
{
local byte i;
local TornOffCarPartActor WT;

	For (i=0; i<ArrayCount(Treads); i++)
	{
		if (Treads[i].TTread != None)
		{
			WT = Spawn(Class'TornOffCarPartActor',Self,,Location + Treads[i].TTread.PrePivot,Rotation);
			if (WT != None)
			{
				WT.CopyDisplayFrom(Treads[i].TTread,Self);
				WT.SetInitialSpeed(2);
				WT.SetCollisionSize(WreckTrackColRadius,WreckTrackColHeight);
			}
			Treads[i].TTread.Destroy();
		}
	}
}

simulated function ClientUpdateState( float Delta )
{
	Super.ClientUpdateState(Delta);
	if( TurningRep>0 )
	{
		Turning = int(TurningRep)-2;
		TurningRep = 0;
	}
}
function ServerPackState( float Delta)
{
	Super.ServerPackState(Delta);
	TurningRep = Turning+2;
}
// Return normal for acceleration direction.
simulated function vector GetAccelDir( int InTurn, int InRise, int InAccel )
{
	local rotator R;

	R.Yaw = VehicleYaw;
	Return SetUpNewMVelocity(vector(R)*InAccel,ActualFloorNormal,0);
}

simulated function float GetTreadLinSpeed(float LinSpeed, byte Tn, float TYawDif, float Delta, bool bTurnR, int TAcDir)
{
local float RotRadius, rrad, w;
local float TRadius, TreadLinSpeed;

	//Calculate current vehicle turn radius
	rrad = TYawDif*pi/32768;
	w = rrad/Delta;

	if (w > 0)
		RotRadius = LinSpeed / w;
	else
		return TAcDir*LinSpeed;

	//Calculate linear speed of the current tread
	if ((!bTurnR && Treads[Tn].TreadOffset.Y >= 0) || (bTurnR && Treads[Tn].TreadOffset.Y < 0))
	{
		TRadius = Abs(RotRadius - Abs(Treads[Tn].TreadOffset.Y));

		if (LinSpeed != 0)
			TreadLinSpeed = w * TRadius * TAcDir;
		else
			TreadLinSpeed = w * TRadius;

		if (TRadius > Abs(Treads[Tn].TreadOffset.Y))
			return TreadLinSpeed;
		else
			return (-1*TreadLinSpeed);
	}
	else /*if ((bTurnR && Treads[Tn].TreadOffset.Y < 0) || (!bTurnR && Treads[Tn].TreadOffset.Y >= 0))*/
	{
		TRadius = RotRadius + Abs(Treads[Tn].TreadOffset.Y);
		if (LinSpeed != 0)
			TreadLinSpeed = w * TRadius * TAcDir;
		else
			TreadLinSpeed = w * TRadius;

		return TreadLinSpeed;
	}
}

simulated function FellToGround()
{
	if (FallingLenghtZ > 0)
	{
		if ((FallingLenghtZ * VehicleGravityScale) > 1500)
			TakeImpactDamage(FallingLenghtZ*VehicleGravityScale/15,None, "FellToGround_1");
		else if ((FallingLenghtZ * VehicleGravityScale) > 120)
			TakeImpactDamage(0,None, "FellToGround_2");
		FallingLenghtZ = 0;
	}
}

simulated function UpdateTreads(float Delta)
{
local byte i;
local float YDelta, TLinSpeed, TWheelAng, MaxFrT, CycleStep;
local int PanSkip, dir;

	//Treads control
	if (FMax(Region.Zone.ZoneGroundFriction,TreadsTraction) > 4.0)
		YDelta = Abs(Abs(OldVehicleYaw) - Abs(VehicleYaw));
	else
		YDelta = Abs(Abs(OldVehicleYaw) - Abs(VehicleYaw))*(FMax(Region.Zone.ZoneGroundFriction,TreadsTraction)/0.1)*4.25;

	For (i=0; i<ArrayCount(Treads); i++)
	{
		if (Treads[i].TTread != None)
		{
			if (FMax(Region.Zone.ZoneGroundFriction,TreadsTraction) > 4.0 && bOnGround)
			{
				dir = OldAccelD;
				if( Level.NetMode==NM_Client && !IsNetOwner(Driver) )
					dir = GetMovementDir();
				TLinSpeed = GetTreadLinSpeed(VSize(Velocity),i,YDelta,Delta,OldTTurnDir,dir);
			}
			else
			{
				dir = VirtOldAccel;
				if( Level.NetMode==NM_Client && !IsNetOwner(Driver) )
					dir = GetIcedMovementDir();
				TLinSpeed = GetTreadLinSpeed(VSize(GetVirtualSpeedOnIce(Delta)),i,YDelta,Delta,OldTTurnDir,dir);
			}

			if (TLinSpeed > 10 || TLinSpeed < -10)	//Bug fix on stopped tracks moving on big slopes
				Treads[i].TPanCount += (TLinSpeed*Delta);
			CycleStep = Treads[i].MovPerTreadCycle/16;
	
			if (Treads[i].TPanCount > CycleStep)
			{
				PanSkip = Int(Treads[i].TPanCount/CycleStep);
				Treads[i].TPanCount -= (CycleStep * PanSkip);
	
				PanSkip = Max(0, Min(PanSkip,7));
				Treads[i].CurrentTPan += PanSkip;
				if (Treads[i].CurrentTPan > 15)
					Treads[i].CurrentTPan -= 15;
				
	
				if (!Treads[i].bUseAltTread)
					Treads[i].TTread.MultiSkins[Treads[i].TreadSkinN] = TreadPan[Treads[i].CurrentTPan];
				else
					Treads[i].TTread.MultiSkins[Treads[i].TreadSkinN] = AltTreadPan[Treads[i].CurrentTPan];
			}
			else if (Treads[i].TPanCount < 0)
			{
				PanSkip = Abs(Int(Treads[i].TPanCount/CycleStep));
				Treads[i].TPanCount += (CycleStep * PanSkip);
	
				PanSkip = Max(0, Min(PanSkip,7));
				Treads[i].CurrentTPan -= PanSkip;
				if (Treads[i].CurrentTPan < 0)
					Treads[i].CurrentTPan += 15;
	
				if (!Treads[i].bUseAltTread)
					Treads[i].TTread.MultiSkins[Treads[i].TreadSkinN] = TreadPan[Treads[i].CurrentTPan];
				else
					Treads[i].TTread.MultiSkins[Treads[i].TreadSkinN] = AltTreadPan[Treads[i].CurrentTPan];
			}
	
			if (Treads[i].bHaveAnimTWheels)
			{
				if (TLinSpeed > 10 || TLinSpeed < -10)	//Bug fix on stopped tracks moving on big slopes
					TWheelAng = GetAngularSpeed(TLinSpeed,Delta,Treads[i].WheelSize);
				MaxFrT = (Treads[i].WheelFramesN-1)/Treads[i].WheelFramesN;
	
				if (!Treads[i].bWheenAnimInverted)
					Treads[i].CurrentWheelFrame += (TWheelAng * MaxFrT / 65536);
				else
					Treads[i].CurrentWheelFrame -= (TWheelAng * MaxFrT / 65536);
	
				if (Treads[i].CurrentWheelFrame > MaxFrT)
					Treads[i].CurrentWheelFrame = 0;
				else if (Treads[i].CurrentWheelFrame < 0)
					Treads[i].CurrentWheelFrame = MaxFrT;
	
				Treads[i].TTread.AnimFrame = Treads[i].CurrentWheelFrame;
			}
		}
	}
}

function ZoneChange( ZoneInfo NewZone )
{
	if (NewZone.bWaterZone)
		Velocity *= 0.65;
}

simulated function UpdateDriverInput( float Delta )
{
	local vector Ac, NVeloc;
	local float DeAcc,DeAccRat;
	local rotator R;
	local bool bTurnR;
	local byte i;
	
	OldVehicleYaw = VehicleYaw;	

	if (bSlopedPhys && GVT!=None)
		R = TransformForGroundRot(VehicleYaw,GVTNormal);
	else
		R = TransformForGroundRot(VehicleYaw,FloorNormal);
	if( Rotation!=R )
		SetRotation(R);

	if (FMax(Region.Zone.ZoneGroundFriction,TreadsTraction) > 4.0)
	{
		VelFriction = Velocity;
		VirtOldAccel = OldAccelD;
	}

	if( !bOnGround )
	{
		if (!(Level.NetMode==NM_Client && !IsNetOwner(Driver)))
		{
			if (!Region.Zone.bWaterZone)				Velocity+=Region.Zone.ZoneGravity*Delta*VehicleGravityScale;			else				Velocity+=Region.Zone.ZoneGravity*Delta*VehicleGravityScale*0.35;			FallingLenghtZ += Abs(OldLocation.Z - Location.Z);
		}
		UpdateTreads(Delta);
		Return;
	}

	if( Turning!=0 )
	{
		bTurnR = ((Turning==1 && Accel!=-1) || (Turning==-1 && Accel==-1));
		if( !bTurnR && CurTurnSpeed<VehicleTurnSpeed )
		{
			if (FMax(Region.Zone.ZoneGroundFriction,TreadsTraction) > 4.0)
				CurTurnSpeed+=VehicleTurnSpeed*Delta*3;
			else
				CurTurnSpeed+=VehicleTurnSpeed*Delta*(3*Region.Zone.ZoneGroundFriction/4);
			if( CurTurnSpeed>VehicleTurnSpeed )
				CurTurnSpeed = VehicleTurnSpeed;
		}
		else if( bTurnR && CurTurnSpeed>(VehicleTurnSpeed*-1) )
		{
			if (FMax(Region.Zone.ZoneGroundFriction,TreadsTraction) > 4.0)
				CurTurnSpeed-=VehicleTurnSpeed*Delta*3;
			else
				CurTurnSpeed-=VehicleTurnSpeed*Delta*(3*Region.Zone.ZoneGroundFriction/4);
			if( CurTurnSpeed<(VehicleTurnSpeed*-1) )
				CurTurnSpeed = (VehicleTurnSpeed*-1);
		}

		OldTTurnDir = bTurnR;
	}
	else if( CurTurnSpeed>0 )
	{
		if (FMax(Region.Zone.ZoneGroundFriction,TreadsTraction) > 4.0)
			CurTurnSpeed-=Delta*VehicleTurnSpeed*3;
		else
			CurTurnSpeed-=Delta*VehicleTurnSpeed*(3*Region.Zone.ZoneGroundFriction/4);
		if( CurTurnSpeed<0 )
			CurTurnSpeed = 0;
	}
	else if( CurTurnSpeed<0 )
	{
		if (FMax(Region.Zone.ZoneGroundFriction,TreadsTraction) > 4.0)
			CurTurnSpeed+=Delta*VehicleTurnSpeed*3;
		else
			CurTurnSpeed+=Delta*VehicleTurnSpeed*(3*Region.Zone.ZoneGroundFriction/4);
		if( CurTurnSpeed>0 )
			CurTurnSpeed = 0;
	}
	VehicleYaw+=CurTurnSpeed*Delta;
	
	if( Level.NetMode==NM_Client && !IsNetOwner(Driver) )
	{
		UpdateTreads(Delta);
		Return;
	}
	
	if( !bCameraOnBehindView && Driver!=None )
		Driver.ViewRotation.Yaw+=CurTurnSpeed*Delta;

	Velocity+=CalcGravityStrength(Region.Zone.ZoneGravity*(VehicleGravityScale/GroundPower),FloorNormal)*Delta/(Region.Zone.ZoneGroundFriction/8.f+1.f);

	//Treads control
	UpdateTreads(Delta);
	
	// Update vehicle speed
	if (Accel != 0)
	{
		//Quick ice speed Fix
		if (VSize(Velocity) <= 16 && FMax(Region.Zone.ZoneGroundFriction,TreadsTraction) <= 4.0 && !IceFix)
		{
			OldAccelD = Accel;
			Velocity = VSize(Velocity)*vector(Rotation)*Accel;
			IceFix = True;
		}
		else if (VSize(Velocity) > 16 && FMax(Region.Zone.ZoneGroundFriction,TreadsTraction) <= 4.0 && IceFix)
			IceFix = False;

		//Braking, so reduce speed 3x superior to normal deacceleration
		if (OldAccelD == -Accel && VSize(Velocity) > 16)
		{
			DeAcc = VSize(Velocity);
			DeAccRat = Delta*WDeAccelRate*3*FMax(Region.Zone.ZoneGroundFriction,TreadsTraction);
			if( DeAccRat>DeAcc )
				DeAccRat = DeAcc;
			Ac = GetAccelDir(Turning,Rising,OldAccelD);
			if (FMax(Region.Zone.ZoneGroundFriction,TreadsTraction) <= 4.0)
			{	
				if( DeAcc>0 )
				{
					DeAcc-=WDeAccelRate*Delta;
					if( DeAcc<0 )
						DeAcc = 0;
				}
				else DeAcc-=WDeAccelRate*3*Delta/100;
	
				NVeloc = Normal(Velocity);
				if( DeAcc>50 && (Ac Dot NVeloc)<0.4 )
				{
					Velocity-=Ac*FMax(Region.Zone.ZoneGroundFriction,TreadsTraction)*WDeAccelRate*3*Delta*2.f;
					Return;
				}
				Ac = Ac*MaxGroundSpeed*FMax(Region.Zone.ZoneGroundFriction,TreadsTraction)/10;
				Velocity = Normal(Velocity+Ac)*DeAcc;
			}
			else
			{
				if (DeAccRat >= VSize(Velocity))
					Velocity = vect(0,0,0);
				else
				{
					Velocity-=Normal(Velocity)*DeAccRat;
					if (Velocity dot Ac > 0)						Velocity = VSize(Velocity)*Normal(Ac);					else						OldAccelD = -OldAccelD;
				}

				SetSignalLights(SL_Stop);
			}

			Return;
		}
		else
		{
			if (FMax(Region.Zone.ZoneGroundFriction,TreadsTraction) > 4.0)
			{
				if (Accel == -1)
					SetSignalLights(SL_Backwards);
				else
					SetSignalLights(SL_None);
			}

			OldAccelD = Accel;
		}
	}

	//If no braking, and no accel, deaccel smoothly
	if( Accel==0 )
	{
		DeAcc = VSize(Velocity);
		DeAccRat = Delta*WDeAccelRate*FMax(Region.Zone.ZoneGroundFriction,TreadsTraction);
		if( DeAccRat>DeAcc )
			DeAccRat = DeAcc;
		Ac = GetAccelDir(Turning,Rising,OldAccelD);
		if (FMax(Region.Zone.ZoneGroundFriction,TreadsTraction) <= 4.0)
		{
			if( DeAcc>0 )
			{
				DeAcc-=WDeAccelRate*Delta;
				if( DeAcc<0 )
					DeAcc = 0;
			}
			else DeAcc-=WDeAccelRate*Delta/100;

			NVeloc = Normal(Velocity);
			if( DeAcc>50 && (Ac Dot NVeloc)<0.4 )
			{
				Velocity-=Ac*FMax(Region.Zone.ZoneGroundFriction,TreadsTraction)*WDeAccelRate*Delta*2.f;
				Return;
			}
			Ac = Ac*MaxGroundSpeed*FMax(Region.Zone.ZoneGroundFriction,TreadsTraction)/10;
			Velocity = Normal(Velocity+Ac)*DeAcc;
		}
		else
		{
			if (DeAccRat >= VSize(Velocity))
				Velocity = vect(0,0,0);
			else
			{
				Velocity-=Normal(Velocity)*DeAccRat;
				if (Velocity dot Ac > 0)
					Velocity = VSize(Velocity)*Normal(Ac);
				else if (VSize(Velocity) > 0)
					OldAccelD = -OldAccelD;
			}
			
			SetSignalLights(SL_None);
		}
		Return;
	}
	DeAcc = VSize(Velocity);
	if( DeAcc<MaxGroundSpeed )
	{
		DeAcc+=WAccelRate*Delta;
		if( DeAcc>MaxGroundSpeed )
			DeAcc = MaxGroundSpeed;
	}
	else DeAcc+=WAccelRate*Delta/100;

	Ac = GetAccelDir(Turning,Rising,OldAccelD)*MaxGroundSpeed*FMax(Region.Zone.ZoneGroundFriction,TreadsTraction)/10;
	Velocity = Normal(Velocity+Ac)*DeAcc;
	if (Driver != None)
		ShouldTurnFor(vector(Driver.ViewRotation)*20000+Location);
}
function int ShouldAccel( vector AcTarget )
{
	local float dir;
	local vector A, B, V;
	
	A = AcTarget-Location;
	A.Z = 0;
	V = Velocity;
	V.Z = 0;
//	if (VSize(V) > Vsize(A)) Return 0;
	B = vector(Rotation);
	B.Z = 0;
	dir = Normal(A) dot Normal(B);
	if( dir>0.82 )
		Return 1;
	else if (dir < -0.82) 
		Return -1;
	else
		Return 0;
}
function int ShouldAccelFor( vector AcTarget )
{
	local int ret;
	ret = ShouldAccelFor2(AcTarget);
	if (ret == -1)
		Turning *= -1;
	return ret;
}
function int ShouldAccelFor2( vector AcTarget )
{
	local bool bStuck;
	local vector X,Y,Z;
	local float Res;
	local int ret;
	
	if (AboutToCrash(ret))
		return ret;
		
	ret = ShouldAccel(AcTarget);

	if( bReversing )
	{
		if( ReverseTimer<Level.TimeSeconds )
		{
			bReversing = False;
			StuckTimer = Level.TimeSeconds+3;
			Return ret;
		}
		Return -ret;
	}
	bStuck = ret != 0 && VSize(Velocity)<MaxGroundSpeed/5;
	if( bWasStuckOnW!=bStuck )
	{
		bWasStuckOnW = bStuck;
		if( bStuck )
			StuckTimer = Level.TimeSeconds+2;
	}
	if( bStuck && StuckTimer<Level.TimeSeconds )
	{
		bReversing = True;
		ReverseTimer = Level.TimeSeconds+2;
		Return -ret;
	}
	Return ret;
}
function int ShouldTurnFor( vector AcTarget, optional float YawAdjust, optional float DeadZone )
{
	local int ret;
	
	YawAdjust = CurTurnSpeed;
	
	if( bReversing )
		if (int(Level.TimeSeconds/10) % 2 == 0)
			YawAdjust += 12000;
		else
			YawAdjust -= 12000;

	return Super.ShouldTurnFor(AcTarget, YawAdjust, DeadZone);
}
simulated function int GetIcedMovementDir()
{
	if( (Normal(VelFriction) dot vector(Rotation))>0 )
		Return 1;
	else Return -1;
}
function vector GetVirtualSpeedOnIce( float Delta )
{
	local vector Ac;
	local float DeAcc,DeAccRat;
	local rotator R;
	local bool bTurnR;
	local byte i;


	if( !bOnGround )
	{
		VelFriction+=Region.Zone.ZoneGravity*Delta*VehicleGravityScale;
		Return VelFriction;
	}

	if( bOnGround )
		VelFriction+=CalcGravityStrength(Region.Zone.ZoneGravity,FloorNormal)*Delta/(8.0/8.f+1.f);
	
	// Update vehicle speed
	if (Accel != 0)
	{
		//Braking, so reduce speed 3x superior to normal deacceleration
		if (VirtOldAccel == -Accel && VSize(VelFriction) > 16)
		{
			DeAcc = VSize(VelFriction);
			DeAccRat = Delta*WDeAccelRate*24.0;
			if( DeAccRat>DeAcc )
				DeAccRat = DeAcc;

			VelFriction-=Normal(VelFriction)*DeAccRat;

			SetSignalLights(SL_Stop);
	
			return VelFriction;
		}
		else
		{
			if (Accel == -1)
				SetSignalLights(SL_Backwards);
			else
				SetSignalLights(SL_None);

			VirtOldAccel = Accel;
		}
	}
	else
	{
		DeAcc = VSize(VelFriction);
		DeAccRat = Delta*WDeAccelRate*8.0;
		if( DeAccRat>DeAcc )
			DeAccRat = DeAcc;
		VelFriction-=Normal(VelFriction)*DeAccRat;

		SetSignalLights(SL_None);

		Return VelFriction;
	}
	DeAcc = VSize(VelFriction);

	if( DeAcc<MaxGroundSpeed )
	{
		DeAcc+=WAccelRate*Delta;
		if( DeAcc>MaxGroundSpeed )
			DeAcc = MaxGroundSpeed;
	}
	else DeAcc+=WAccelRate*Delta/100;

	Ac = vector(rotation)*Accel*MaxGroundSpeed*8/10;
	VelFriction = Normal(VelFriction+Ac)*DeAcc;
	return VelFriction;
}

simulated function AttachmentsTick( float Delta )
{
	local byte PitchDif, i;
	local float EngP;

	//Water zone variables
	local byte rec;
	local byte FootSndVol, FootSndPitch;
	local sound FootAmbSnd;
	local float FootZoneSpeed;

	Super.AttachmentsTick(Delta);
	
	if (bEngDynSndPitch)
	{
		PitchDif = MaxEngPitch - MinEngPitch;
		if (FMax(Region.Zone.ZoneGroundFriction,TreadsTraction) > 4.0)
			EngP = MinEngPitch + Min(PitchDif,(VSize(Velocity)*PitchDif/MaxGroundSpeed));
		else
			EngP = MinEngPitch + Min(PitchDif,(VSize(VelFriction)*PitchDif/MaxGroundSpeed));
		SoundPitch = Byte(EngP);
	}

	
	//********************************************************************************
	//Water Trail FX points update
	//********************************************************************************
	if (bHaveGroundWaterFX && bSlopedPhys)
	{
		For (i=0; i<ArrayCount(Treads); i++)
		{
			if (Treads[i].TTread != None && (Location != OldLocation || (FootVehZone[i] != None && VSize(FootVehZone[i].ZoneVelocity)>150 )))
			{
				if ((vector(Rotation) dot Normal(Location - OldLocation)) > 0 || (Location == OldLocation && OldAccelD > 0))
					VWaterT[i].SetLocation(Location + Treads[i].TTread.PrePivot + (Treads[i].TrackFrontOffset >> Rotation));
				else
					VWaterT[i].SetLocation(Location + Treads[i].TTread.PrePivot + (Treads[i].TrackBackOffset >> Rotation));
	
				VWaterT[i].Move(WreckTrackColHeight*vect(0,0,-1));
	
				if (VWaterT[i].Region.Zone.bWaterZone && !Region.Zone.bWaterZone)
				{
					FootVehZone[i] = VWaterT[i].Region.Zone;
					rec = 0;
	
					if (VSize(FootVehZone[i].ZoneVelocity) > 150)
						FootZoneSpeed = VSize(FootVehZone[i].ZoneVelocity);
					else
						FootZoneSpeed = 0;
						
					FootSndVol = Min(Max(8,VWaterT[i].WaveSize*3),255) * ((VSize(Location - OldLocation)/Delta + FootZoneSpeed)/ RefMaxWaterSpeed);
					FootSndPitch = 32 + ((VSize(Location - OldLocation)/Delta + FootZoneSpeed)/ RefMaxWaterSpeed) * 96;
					FootAmbSnd = VWaterT[i].Region.Zone.AmbientSound;
	
					if (VWaterT[i].SoundPitch != FootSndPitch)
						VWaterT[i].SoundPitch = FootSndPitch;
					if (VWaterT[i].AmbientSound != FootAmbSnd)
						VWaterT[i].AmbientSound = FootAmbSnd;
					if (VWaterT[i].SoundVolume != FootSndVol)
						VWaterT[i].SoundVolume = FootSndVol;
	
					while (VWaterT[i].Region.Zone.bWaterZone && !Region.Zone.bWaterZone && rec < 20)
					{
						VWaterT[i].OldWaterZone = VWaterT[i].Region.Zone;
						VWaterT[i].Move(vect(0,0,8));
						rec++;
					}
//log (self @ Level.TimeSeconds @ VWaterT[i].WaveLenght @ (Velocity dot vector(Rotation)) @ VSize(Location - OldLocation));
					if ((Velocity dot vector(Rotation)) > 0)
						VWaterT[i].WaveLenght += VSize(Location - OldLocation);
					else
						VWaterT[i].WaveLenght -= VSize(Location - OldLocation);
				}
				else
				{
					if (VWaterT[i].OldWaterZone != None)
						VWaterT[i].OldWaterZone = None;
					if (VWaterT[i].AmbientSound != None)
						VWaterT[i].AmbientSound = None;
	
					FootVehZone[i] = None;
				}
	
			}
			else if (FootVehZone[i] != None && Location == OldLocation && VWaterT[i] != None && VWaterT[i].AmbientSound != None)
				VWaterT[i].AmbientSound = None;
		}
	}
	//********************************************************************************

	//********************************************************************************
	//Foot zone handling
	//********************************************************************************
	if (bHaveGroundWaterFX)
	{
		SecCount += Delta;
		if (SecCount >= 0.35)
		{
			i = 0;
			while (i < 8)
			{
				if (FootVehZone[i] != None)
				{
					AnalyzeZone(FootVehZone[i]);
					i = 10;
				}
				
				i++;
			}

			SecCount = 0;
		}
	}
	//********************************************************************************
}

/*function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	if ((normal(momentum) Dot vector(Rotation)) > 0.5)
		Accel = 1;
	else if ((normal(momentum) Dot -vector(Rotation)) > 0.5)
		Accel = -1;

	Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}*/

defaultproperties
{
      MaxGroundSpeed=600.000000
      VehicleTurnSpeed=15000.000000
      CurTurnSpeed=0.000000
      NextAUpdTime=0.000000
      TurningRep=0
      NumMoveAnimFrames=0
      CurrentAnimFrame=0
      bHasAnimTread=False
      bWasStuckOnW=False
      bReversing=False
      StuckTimer=0.000000
      ReverseTimer=0.000000
      TreadPan(0)=None
      TreadPan(1)=None
      TreadPan(2)=None
      TreadPan(3)=None
      TreadPan(4)=None
      TreadPan(5)=None
      TreadPan(6)=None
      TreadPan(7)=None
      TreadPan(8)=None
      TreadPan(9)=None
      TreadPan(10)=None
      TreadPan(11)=None
      TreadPan(12)=None
      TreadPan(13)=None
      TreadPan(14)=None
      TreadPan(15)=None
      AltTreadPan(0)=None
      AltTreadPan(1)=None
      AltTreadPan(2)=None
      AltTreadPan(3)=None
      AltTreadPan(4)=None
      AltTreadPan(5)=None
      AltTreadPan(6)=None
      AltTreadPan(7)=None
      AltTreadPan(8)=None
      AltTreadPan(9)=None
      AltTreadPan(10)=None
      AltTreadPan(11)=None
      AltTreadPan(12)=None
      AltTreadPan(13)=None
      AltTreadPan(14)=None
      AltTreadPan(15)=None
      Treads(0)=(MovPerTreadCycle=0.000000,TreadMesh=None,TreadSkinN=0,TreadOffset=(X=0.000000,Y=0.000000,Z=0.000000),TreadScale=1.000000,bUseAltTread=False,TTread=None,CurrentTPan=0,TPanCount=0.000000,bHaveAnimTWheels=False,WheelFramesN=0,WheelAnimSet="None",WheelSize=0.000000,bWheenAnimInverted=False,CurrentWheelFrame=0.000000,TrackWidth=64.000000,TrackFrontOffset=(X=0.000000,Y=0.000000,Z=0.000000),TrackBackOffset=(X=0.000000,Y=0.000000,Z=0.000000))
      Treads(1)=(MovPerTreadCycle=0.000000,TreadMesh=None,TreadSkinN=0,TreadOffset=(X=0.000000,Y=0.000000,Z=0.000000),TreadScale=1.000000,bUseAltTread=False,TTread=None,CurrentTPan=0,TPanCount=0.000000,bHaveAnimTWheels=False,WheelFramesN=0,WheelAnimSet="None",WheelSize=0.000000,bWheenAnimInverted=False,CurrentWheelFrame=0.000000,TrackWidth=64.000000,TrackFrontOffset=(X=0.000000,Y=0.000000,Z=0.000000),TrackBackOffset=(X=0.000000,Y=0.000000,Z=0.000000))
      Treads(2)=(MovPerTreadCycle=0.000000,TreadMesh=None,TreadSkinN=0,TreadOffset=(X=0.000000,Y=0.000000,Z=0.000000),TreadScale=1.000000,bUseAltTread=False,TTread=None,CurrentTPan=0,TPanCount=0.000000,bHaveAnimTWheels=False,WheelFramesN=0,WheelAnimSet="None",WheelSize=0.000000,bWheenAnimInverted=False,CurrentWheelFrame=0.000000,TrackWidth=64.000000,TrackFrontOffset=(X=0.000000,Y=0.000000,Z=0.000000),TrackBackOffset=(X=0.000000,Y=0.000000,Z=0.000000))
      Treads(3)=(MovPerTreadCycle=0.000000,TreadMesh=None,TreadSkinN=0,TreadOffset=(X=0.000000,Y=0.000000,Z=0.000000),TreadScale=1.000000,bUseAltTread=False,TTread=None,CurrentTPan=0,TPanCount=0.000000,bHaveAnimTWheels=False,WheelFramesN=0,WheelAnimSet="None",WheelSize=0.000000,bWheenAnimInverted=False,CurrentWheelFrame=0.000000,TrackWidth=64.000000,TrackFrontOffset=(X=0.000000,Y=0.000000,Z=0.000000),TrackBackOffset=(X=0.000000,Y=0.000000,Z=0.000000))
      Treads(4)=(MovPerTreadCycle=0.000000,TreadMesh=None,TreadSkinN=0,TreadOffset=(X=0.000000,Y=0.000000,Z=0.000000),TreadScale=1.000000,bUseAltTread=False,TTread=None,CurrentTPan=0,TPanCount=0.000000,bHaveAnimTWheels=False,WheelFramesN=0,WheelAnimSet="None",WheelSize=0.000000,bWheenAnimInverted=False,CurrentWheelFrame=0.000000,TrackWidth=64.000000,TrackFrontOffset=(X=0.000000,Y=0.000000,Z=0.000000),TrackBackOffset=(X=0.000000,Y=0.000000,Z=0.000000))
      Treads(5)=(MovPerTreadCycle=0.000000,TreadMesh=None,TreadSkinN=0,TreadOffset=(X=0.000000,Y=0.000000,Z=0.000000),TreadScale=1.000000,bUseAltTread=False,TTread=None,CurrentTPan=0,TPanCount=0.000000,bHaveAnimTWheels=False,WheelFramesN=0,WheelAnimSet="None",WheelSize=0.000000,bWheenAnimInverted=False,CurrentWheelFrame=0.000000,TrackWidth=64.000000,TrackFrontOffset=(X=0.000000,Y=0.000000,Z=0.000000),TrackBackOffset=(X=0.000000,Y=0.000000,Z=0.000000))
      Treads(6)=(MovPerTreadCycle=0.000000,TreadMesh=None,TreadSkinN=0,TreadOffset=(X=0.000000,Y=0.000000,Z=0.000000),TreadScale=1.000000,bUseAltTread=False,TTread=None,CurrentTPan=0,TPanCount=0.000000,bHaveAnimTWheels=False,WheelFramesN=0,WheelAnimSet="None",WheelSize=0.000000,bWheenAnimInverted=False,CurrentWheelFrame=0.000000,TrackWidth=64.000000,TrackFrontOffset=(X=0.000000,Y=0.000000,Z=0.000000),TrackBackOffset=(X=0.000000,Y=0.000000,Z=0.000000))
      Treads(7)=(MovPerTreadCycle=0.000000,TreadMesh=None,TreadSkinN=0,TreadOffset=(X=0.000000,Y=0.000000,Z=0.000000),TreadScale=1.000000,bUseAltTread=False,TTread=None,CurrentTPan=0,TPanCount=0.000000,bHaveAnimTWheels=False,WheelFramesN=0,WheelAnimSet="None",WheelSize=0.000000,bWheenAnimInverted=False,CurrentWheelFrame=0.000000,TrackWidth=64.000000,TrackFrontOffset=(X=0.000000,Y=0.000000,Z=0.000000),TrackBackOffset=(X=0.000000,Y=0.000000,Z=0.000000))
      bEngDynSndPitch=False
      MinEngPitch=0
      MaxEngPitch=0
      TreadsTraction=0.100000
      VelFriction=(X=0.000000,Y=0.000000,Z=0.000000)
      OldVehicleYaw=0.000000
      OldTTurnDir=False
      IceFix=False
      WreckTrackColHeight=15.000000
      WreckTrackColRadius=15.000000
      VWaterT(0)=None
      VWaterT(1)=None
      VWaterT(2)=None
      VWaterT(3)=None
      VWaterT(4)=None
      VWaterT(5)=None
      VWaterT(6)=None
      VWaterT(7)=None
      AIRating=2.000000
      WAccelRate=800.000000
      Health=1000
      bFPViewUseRelRot=True
      bFPRepYawUpdatesView=True
      VehicleName="Tread Craft"
      TranslatorDescription="This is a Tread Craft, press [Fire] or [AltFire] to fire the different firemodes. Use your Strafe keys to turn this vehicle and Move Forward/Backward keys to accelerate/deaccelerate. To leave this vehicle, press your [ThrowWeapon] key."
      VehicleKeyInfoStr="Tread craft keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%PrevWeapon%, %NextWeapon%, %SwitchToBestWeapon% to change camera|%ThrowWeapon% to exit the vehicle"
      bDestroyUpsideDown=True
      WDeAccelRate=35.000000
      Mesh=LodMesh'UnrealShare.WoodenBoxM'
}
