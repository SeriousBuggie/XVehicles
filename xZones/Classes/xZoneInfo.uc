class xZoneInfo expands ZoneInfo Config(xZones);

var(Config) globalconfig bool enableWaterZoneFX;
var(Config) globalconfig byte WaterZoneFXDetail;	// 7 - Full Detail
var(Config) globalconfig bool hasDistortion;
var(Config) globalconfig bool enableFirstPersonPlayerSplash;

var() bool isWaterFX;
var() byte DistortionAmount;
var() int DistortRollPerSec;
var() float WaterMinSplashSpeed;

var(ZoneSound) sound ZoneAmbSound;
var(ZoneSound) byte ZoneAmbPitch;
var(ZoneSound) byte ZoneAmbVolume;

var(FX) class<WaterVertSplashA02> SplashClass[8];
var(FX) class<BalWaterSplash00> BallisticSplashClass[4];
var(FX) class<WaterSplashRing> WaterRingClass;
var(FX) int SplashDamage;

var bool hasGivenZoneObj;

var() int MinDesiredFrameRate;
var bool bLowFps;

simulated function PostBeginPlay()
{
	local xZoneInfo xZObj;
	local PlayerPawn PP;

	/* // XZonesMut disabled. for more info look at XZonesMut class
	// hackish way instantiate mutator only once.
	ForEach AllActors(Class'xZoneInfo', xZObj)
	{
		if (xZObj == Self)
			Level.Game.BaseMutator.AddMutator(Spawn(Class'XZonesMut'));
		break;
	}
	*/

	if (Level.NetMode != NM_DedicatedServer)
		SetTimer(0.5, False);
	
	foreach AllActors(class'PlayerPawn', PP)
		if (PP.Player != None)
			MinDesiredFrameRate = Max(MinDesiredFrameRate, 
				int(PP.ConsoleCommand("get ini:Engine.Engine.ViewportManager MinDesiredFrameRate")));
}

simulated function Tick(float Delta)
{
	bLowFps = Delta*MinDesiredFrameRate > 1;
	Super.Tick(Delta);
}

simulated function Timer()
{
local xZoneInfo xZ;
local PlayerPawn P;

	ForEach AllActors(Class'xZoneInfo', xZ)
	{
		if (xZ == Self)
			foreach AllActors(class'PlayerPawn', P)
				if (P.Player != None && P.CollisionRadius > 0 && P.CollisionHeight > 0 && !P.bHidden && P.Health > 0)
				{
					Spawn(Class'xZonePlayerObj', P);
					hasGivenZoneObj = True;
				}
		break;
	}

	if (!hasGivenZoneObj)
		SetTimer(0.5,False);
}

singular simulated function ActorEntered( actor Other )
{
local xOldLocDummy OldLD;
local Projectile xPD;
local byte i;
local Pawn InstP;
local vector StartLoc;
local byte willFloat;
local actor A;
local vector AddVelocity;

	if (bWaterZone && isWaterFX && enableWaterZoneFX && !Other.bStatic && !bLowFps)
	{
		InstP = Other.Instigator;

		if (Other.Buoyancy != 0 && Other.Mass != 0)
			willFloat = Byte(Other.Buoyancy/Other.Mass * 2);

		if (Other.IsA('Projectile') || (Other.IsA('Effects') && !Other.IsA('TornOffCarPartActor') && (Other.Physics == PHYS_Falling || Other.Physics == PHYS_Projectile)) )
			Other.Mass = CheckProperUTMass(Other);

		if (Other.IsA('xZoneInstantHitPoint') && InstP != None && !InstP.HeadRegion.Zone.bWaterZone)
			SpawnBullet( 1, InstP, Other);
		else if ((Other.IsA('ut_RingExplosion5') || (Other.IsA('RingExplosion') && !Other.IsA('RingExplosion2') && !Other.IsA('WaterRing')) || Other.IsA('ut_ComboRing')) && InstP != None && !InstP.HeadRegion.Zone.bWaterZone)
			SpawnBullet( 7, InstP, Other);
		else if (Other.IsA('ut_SuperRing2') && InstP != None && !InstP.HeadRegion.Zone.bWaterZone)
			SpawnBullet( 8, InstP, Other);
		else if (Other.IsA('Vehicle') || Other.IsA('TornOffCarPartActor'))
		{
			StartLoc = (Other.OldLocation + Other.Location) / 2;
			OldLD = Spawn(Class'xOldLocDummy',,, StartLoc);
			if (OldLD != None && OldLD.Region.Zone.bWaterZone)
				OldLD.SetLocation(Other.OldLocation);
			if (OldLD != None && !OldLD.Region.Zone.bWaterZone)
				SpawnWaterFX(Other, GetCollisionCategory(Other), VSize(Other.Velocity) < WaterMinSplashSpeed * 1.65);

		}
		else if (Other.IsA('xSplashProjDummy'))
		{
			if (Other.Mass < 5)
				SpawnWaterFX(Other, Byte(Other.Mass) + 7);
			else
				SpawnWaterFX(Other, Byte(Other.Mass) - 5);
		}
		else if (Other.IsA('Projectile') && Other.Mass >= 1 && Other.Mass <= 10)
		{
			StartLoc = (Other.OldLocation + Other.Location) / 2;
			xPD = Spawn(Class'xSplashProjDummy',,, StartLoc);

			if (xPD != None && xPD.Region.Zone.bWaterZone)
				xPD.SetLocation(Other.OldLocation);

			if (xPD != None)
			{
				xPD.Speed = 2000;
				xPD.MaxSpeed = 2000;
				xPD.Mass = Other.Mass;
				xPD.Velocity = Normal(Other.Location - Other.OldLocation)*xPD.Speed;
			}
		}
		else if (Other.bCollideWorld)
		{
			if (!Other.IsA('Pawn') && !Other.IsA('Decoration') && !Other.IsA('TornOffCarPartActor') && (Other.Physics == PHYS_Falling || Other.Physics == PHYS_Projectile) && Other.Mass > 10 && willFloat < 2)
			{
				if (willFloat == 0 || (willFloat == 1 && !Other.bLensFlare))
				{
					StartLoc = (Other.OldLocation + Other.Location) / 2;
					OldLD = Spawn(Class'xOldLocDummy',,, StartLoc);
					if (OldLD != None && OldLD.Region.Zone.bWaterZone)
						OldLD.SetLocation(Other.OldLocation);
					if (OldLD != None && !OldLD.Region.Zone.bWaterZone)
						SpawnWaterFX(Other, GetMassCategory(Other));
				}
	
				if (willFloat == 1 && !Other.bLensFlare)
					Other.bLensFlare = True;
			}
			else if (!Other.bHidden && (Other.IsA('Pawn') || Other.IsA('TornOffCarPartActor') || (Other.IsA('Decoration') && (Other.Physics == PHYS_Falling || Other.Physics == PHYS_Projectile) && willFloat < 2)))
			{
				if (willFloat == 0 || Other.IsA('Pawn') || (willFloat == 1 && !Other.bLensFlare))
				{
					StartLoc = (Other.OldLocation + Other.Location) / 2;
					OldLD = Spawn(Class'xOldLocDummy',,, StartLoc);
					if (OldLD != None && OldLD.Region.Zone.bWaterZone)
						OldLD.SetLocation(Other.OldLocation);
					if (OldLD != None && !OldLD.Region.Zone.bWaterZone)
					{
						if (!Other.IsA('PlayerPawn'))
							SpawnWaterFX(Other, GetCollisionCategory(Other), VSize(Other.Velocity) < WaterMinSplashSpeed);
						else
							SpawnWaterFX(Other, GetCollisionCategory(Other), PlayerPawn(Other) != None && (PlayerPawn(Other).ViewTarget == None || !PlayerPawn(Other).bBehindView || !enableFirstPersonPlayerSplash) && VSize(Other.Velocity) < WaterMinSplashSpeed);
	
					}
				}
	
				if (!Other.IsA('Pawn') && willFloat == 1 && !Other.bLensFlare)
					Other.bLensFlare = True;
			}
			else if ((Other.Physics == PHYS_Falling || Other.Physics == PHYS_Projectile) && !Other.IsA('Pawn') && Other.Mass > 10 && willFloat >= 2 && !Other.bLensFlare)
			{
				StartLoc = (Other.OldLocation + Other.Location) / 2;
				OldLD = Spawn(Class'xOldLocDummy',,, StartLoc);
				if (OldLD != None && OldLD.Region.Zone.bWaterZone)
					OldLD.SetLocation(Other.OldLocation);
				if (OldLD != None && !OldLD.Region.Zone.bWaterZone)
					SpawnWaterFX(Other, GetMassCategory(Other), True);
	
				Other.bLensFlare = True;
			}
		}
	}
	
	if (!Other.IsA('VehWaterAttach'))
		Super.ActorEntered(Other);
}

singular simulated function ActorLeaving( actor Other )
{
local xOldLocDummy OldLD;
local Projectile xPD;
local byte i;
local Pawn InstP;
local vector StartLoc;
local byte willFloat;

	if (bWaterZone && isWaterFX && enableWaterZoneFX && !Other.bStatic && !bLowFps)
	{
		InstP = Other.Instigator;

		if (Other.Buoyancy != 0 && Other.Mass != 0)
			willFloat = Byte(Other.Buoyancy/Other.Mass * 2);

		if (Other.IsA('Projectile') || (Other.IsA('Effects') && !Other.IsA('TornOffCarPartActor') && (Other.Physics == PHYS_Falling || Other.Physics == PHYS_Projectile)) )
			Other.Mass = CheckProperUTMass(Other);

		if (Other.IsA('Vehicle') || Other.IsA('TornOffCarPartActor'))
		{
			StartLoc = (Other.OldLocation + Other.Location) / 2;
			OldLD = Spawn(Class'xOldLocDummy',,, StartLoc);
			if (OldLD != None && !OldLD.Region.Zone.bWaterZone)
				OldLD.SetLocation(Other.OldLocation);
			if (OldLD != None && OldLD.Region.Zone.bWaterZone)
				SpawnWaterFX(Other, GetCollisionCategory(Other), VSize(Other.Velocity) < WaterMinSplashSpeed * 3.5, True);

		}
		else if (Other.bCollideWorld && Other.Mass > 15)
		{
			if (!Other.IsA('Pawn') && !Other.IsA('Decoration') && !Other.IsA('TornOffCarPartActor') && (Other.Physics == PHYS_Falling || Other.Physics == PHYS_Projectile) && Other.Mass > 10 && willFloat < 2)
			{
				if (willFloat == 0 || (willFloat == 1 && !Other.bLensFlare))
				{
					StartLoc = (Other.OldLocation + Other.Location) / 2;
					OldLD = Spawn(Class'xOldLocDummy',,, StartLoc);
					if (OldLD != None && !OldLD.Region.Zone.bWaterZone)
						OldLD.SetLocation(Other.OldLocation);
					if (OldLD != None && OldLD.Region.Zone.bWaterZone)
						SpawnWaterFX(Other, GetMassCategory(Other),,True);
				}
	
				if (willFloat == 1 && !Other.bLensFlare)
					Other.bLensFlare = True;
			}
			else if (!Other.bHidden && (Other.IsA('Pawn') || Other.IsA('TornOffCarPartActor') || (Other.IsA('Decoration') && (Other.Physics == PHYS_Falling || Other.Physics == PHYS_Projectile) && willFloat < 2)))
			{
				if (willFloat == 0 || Other.IsA('Pawn') || (willFloat == 1 && !Other.bLensFlare))
				{
					StartLoc = (Other.OldLocation + Other.Location) / 2;
					OldLD = Spawn(Class'xOldLocDummy',,, StartLoc);
					if (OldLD != None && !OldLD.Region.Zone.bWaterZone)
						OldLD.SetLocation(Other.OldLocation);
					if (OldLD != None && OldLD.Region.Zone.bWaterZone)
					{
						if (!Other.IsA('PlayerPawn'))
							SpawnWaterFX(Other, GetCollisionCategory(Other), VSize(Other.Velocity) < WaterMinSplashSpeed, True);
						else
							SpawnWaterFX(Other, GetCollisionCategory(Other), PlayerPawn(Other) != None && (PlayerPawn(Other).ViewTarget == None || !PlayerPawn(Other).bBehindView || !enableFirstPersonPlayerSplash) && VSize(Other.Velocity) < WaterMinSplashSpeed, True);
	
					}
				}
	
				if (!Other.IsA('Pawn') && willFloat == 1 && !Other.bLensFlare)
					Other.bLensFlare = True;
			}
			else if ((Other.Physics == PHYS_Falling || Other.Physics == PHYS_Projectile) && !Other.IsA('Pawn') && willFloat >= 2 && !Other.bLensFlare)
			{
				StartLoc = (Other.OldLocation + Other.Location) / 2;
				OldLD = Spawn(Class'xOldLocDummy',,, StartLoc);
				if (OldLD != None && !OldLD.Region.Zone.bWaterZone)
					OldLD.SetLocation(Other.OldLocation);
				if (OldLD != None && OldLD.Region.Zone.bWaterZone)
					SpawnWaterFX(Other, GetMassCategory(Other), True, True);
	
				Other.bLensFlare = True;
			}	
		}
	}

	Super.ActorLeaving(Other);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

simulated function SpawnBullet(byte BType, pawn OtherInst, actor xTarget)
{
local Projectile xPD;
local vector StartLoc;

	StartLoc.Z = OtherInst.Eyeheight;
	StartLoc = OtherInst.Location + (StartLoc >> OtherInst.ViewRotation);
	xPD = Spawn(Class'xProjDummy',,, StartLoc);
	xPD.Mass = FClamp(BType, 1, 10);
	xPD.Speed = 50000;
	xPD.MaxSpeed = 50000;
	xPD.Velocity = Normal(xTarget.Location - StartLoc)*xPD.Speed;
}

simulated function SpawnWaterFX(Actor Other, byte SplashLevel, optional bool NoSplash, optional bool bOutFX)
{
local WaterSplashRing wsr;
local WaterVertSplashA02 wvs;
local BalWaterSplash00 bws;
local vector RealLoc;

	if (bOutFX)
		RealLoc = Other.Location;
	else
		RealLoc = Other.OldLocation;

	if (SplashLevel < 8)
	{
		if (!NoSplash)
		{
			wvs = Spawn(SplashClass[SplashLevel],,, RealLoc + (2**SplashLevel)*vect(0,0,10), Rand(16384)*4*rot(0,1,0));
			wvs.PlaySound(wvs.SplashSnd[Rand(4)],, 50 + 50 * SplashLevel,, 500 + 750 * (SplashLevel**2));
			if (VSize(ZoneVelocity) > 0)
				wvs.Velocity += ZoneVelocity;

			if (SplashDamage > 0)
				HurtRadius(SplashDamage, (SplashLevel+1) * 26.67, DamageType, 1, RealLoc + (2**SplashLevel)*vect(0,0,10) + vect(0,0,24));
		}

		if (WaterZoneFXDetail > 3)
		{
			wsr = Spawn(WaterRingClass,,, RealLoc, rotator(vect(0,0,1)));
			wsr.RotationRate.Roll = 10000;
			wsr.InitDrawScale = (2**SplashLevel) * 0.75;
			if (VSize(ZoneVelocity) > 0)
			{
				wsr.SetPhysics(PHYS_Projectile);
				wsr.Velocity += ZoneVelocity;
			}
			wsr = Spawn(WaterRingClass,,, RealLoc, rotator(vect(0,0,1)));
			wsr.RotationRate.Roll = -10000;
			wsr.InitDrawScale = (2**SplashLevel) * 0.75;
			if (VSize(ZoneVelocity) > 0)
			{
				wsr.SetPhysics(PHYS_Projectile);
				wsr.Velocity += ZoneVelocity;
			}
		}
	}
	else if (SplashLevel <= 12)
	{
		SplashLevel -= 8;

		if (!NoSplash)
		{
			bws = Spawn(BallisticSplashClass[SplashLevel],,, RealLoc + (2**SplashLevel)*vect(0,0,10), Rand(16384)*4*rot(0,1,0));
			bws.PlaySound(bws.SplashSnd[Rand(4)],, 50 + 50 * SplashLevel,, 500 + 750 * (SplashLevel**2));
			if (VSize(ZoneVelocity) > 0)
				bws.Velocity += ZoneVelocity;

			if (SplashDamage > 0)
				HurtRadius(SplashDamage, (SplashLevel+1) * 5.0, DamageType, 1, RealLoc + (2**SplashLevel)*vect(0,0,10) + vect(0,0,24));
		}

		if (WaterZoneFXDetail > 3)
		{
			wsr = Spawn(WaterRingClass,,, RealLoc, rotator(vect(0,0,1)));
			wsr.RotationRate.Roll = 10000;
			wsr.InitDrawScale = (SplashLevel + 1) * 0.625;
			if (VSize(ZoneVelocity) > 0)
			{
				wsr.SetPhysics(PHYS_Projectile);
				wsr.Velocity += ZoneVelocity;
			}
			wsr = Spawn(WaterRingClass,,, RealLoc, rotator(vect(0,0,1)));
			wsr.RotationRate.Roll = -10000;
			wsr.InitDrawScale = (SplashLevel + 1) * 0.625;
			if (VSize(ZoneVelocity) > 0)
			{
				wsr.SetPhysics(PHYS_Projectile);
				wsr.Velocity += ZoneVelocity;
			}
		}
	}
}

simulated function byte GetCollisionCategory(Actor Other)
{
local float colmult;

	colmult = 1.0;

	if (Other.IsA('VehicleAttachment'))
		colmult = 0.65;
	else if (Other.IsA('Vehicle'))
		colmult = 0.45;
		
	if (FMax(Other.CollisionHeight, Other.CollisionRadius) >= 1024*colmult)
		return 7;
	else if (FMax(Other.CollisionHeight, Other.CollisionRadius) >= 512*colmult)
		return 6;
	if (FMax(Other.CollisionHeight, Other.CollisionRadius) >= 256*colmult)
		return 5;
	else if (FMax(Other.CollisionHeight, Other.CollisionRadius) >= 128*colmult)
		return 4;
	else if (FMax(Other.CollisionHeight, Other.CollisionRadius) >= 64*colmult)
		return 3;
	else if (FMax(Other.CollisionHeight, Other.CollisionRadius) >= 32*colmult)
		return 2;
	else if (FMax(Other.CollisionHeight, Other.CollisionRadius) >= 16*colmult)
		return 1;
	else
		return 0;
}

simulated function byte GetMassCategory(Actor Other)
{
	if (Other.Mass > 5000)
		return 7;
	else if (Other.Mass > 2000)
		return 6;
	else if (Other.Mass > 800)
		return 5;
	else if (Other.Mass > 200)
		return 4;
	else if (Other.Mass > 100)
		return 3;
	else if (Other.Mass > 50)
		return 2;
	else if (Other.Mass > 25)
		return 1;
	else if (Other.Mass > 4)
		return 0;
	else
		return 255;
}

simulated function float CheckProperUTMass(Actor Other)
{
	if (Other.IsA('Projectile'))
	{
		if (Other.IsA('MTracer') || Other.IsA('PBolt') || Other.IsA('Tracer'))
			return 0;
		else if (Other.IsA('Arrow') || Other.IsA('ShellCase') || Other.IsA('UT_ShellCase'))
			return 20;
		else if (Other.IsA('Chunk') || Other.IsA('UTChunk'))
			return 40;
		else if (Other.IsA('WarShell'))
			return 150;
		else if (Other.IsA('BigRock'))
		{
			if (Other.DrawScale > 144.0)
				return 7500;
			else if (Other.DrawScale >= 72.0)
				return 3500;
			else if (Other.DrawScale >= 36.0)
				return 1000;
			else if (Other.DrawScale >= 18.0)
				return 400;
			else if (Other.DrawScale >= 7.0)
				return 150;
			else if (Other.DrawScale >= 4.5)
				return 100;
			else if (Other.DrawScale >= 2.0)
				return 40;
			else
				return 20;
		}
		else if (Other.IsA('Fragment'))
		{
			if (Other.DrawScale > 64.0)
				return 7500;
			else if (Other.DrawScale >= 32.0)
				return 3500;
			else if (Other.DrawScale >= 16.0)
				return 1000;
			else if (Other.DrawScale >= 8.0)
				return 400;
			else if (Other.DrawScale >= 4.0)
				return 150;
			else if (Other.DrawScale >= 2.0)
				return 100;
			else if (Other.DrawScale >= 1.0)
				return 40;
			else
				return 20;
		}

		return Other.Mass;
	}
	else
	{
		if (Other.IsA('Bubble') || Other.IsA('Bubble1'))
			return Other.Mass;
		else if (Other.IsA('GreenBlob') || Other.IsA('UT_GreenBlob'))
			return 40;

		return 0;
	}
}

defaultproperties
{
	enableWaterZoneFX=True
	WaterZoneFXDetail=5
	hasDistortion=True
	enableFirstPersonPlayerSplash=True
	DistortRollPerSec=75
	WaterMinSplashSpeed=345.000000
	ZoneAmbPitch=64
	ZoneAmbVolume=128
	SplashClass(0)=Class'xZones.WaterVertSplashA00'
	SplashClass(1)=Class'xZones.WaterVertSplashA01'
	SplashClass(2)=Class'xZones.WaterVertSplashA02'
	SplashClass(3)=Class'xZones.WaterVertSplashA03'
	SplashClass(4)=Class'xZones.WaterVertSplashA04'
	SplashClass(5)=Class'xZones.WaterVertSplashA05'
	SplashClass(6)=Class'xZones.WaterVertSplashA06'
	SplashClass(7)=Class'xZones.WaterVertSplashA07'
	BallisticSplashClass(0)=Class'xZones.BalWaterSplash00'
	BallisticSplashClass(1)=Class'xZones.BalWaterSplash01'
	BallisticSplashClass(2)=Class'xZones.BalWaterSplash02'
	BallisticSplashClass(3)=Class'xZones.BalWaterSplash03'
	WaterRingClass=Class'xZones.WaterSplashRing'
	MinDesiredFrameRate=60
	bStatic=False
	RemoteRole=ROLE_SimulatedProxy
	SoundRadius=0
	SoundVolume=0
}
