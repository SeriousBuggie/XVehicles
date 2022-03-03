// Weapon Attachments for vehicles.
Class WeaponAttachment extends VehicleAttachment
	Abstract;

var bool bDriverWeapon,bInvisGun,bFireRestrict,bFireInit,bRotatingBarrel,bPressingAltZoom;
var Pawn WeaponController;
var int TurretYaw,TurretPitch;
var vector TurretOffset,RepAimPos;
var byte FireFXCounter;
var() float RotatingSpeed;
var(Sounds) Sound BarrelTurnSound;
var() IntRange PitchRange;
var() bool bAltFireZooms;
var float OlVehYaw;
var byte PassengerNum;
var VehicleAttachment PitchPart;
var() class<VehicleAttachment> TurretPitchActor;
var() vector PitchActorOffset;
var bool bHasPitchPart, bTurretYawInit;
var vector PassWPosOffset[8]; 
var bool bUpdatedPassOffsets;
var rotator OldAimRotation;

struct VehWWeapon
{
	var() class<Projectile> ProjectileClass;
	var() vector FireStartOffset;
	var() float RefireRate;
	var() name FireAnim1;
	var() name FireAnim2;
	var() sound FireSound;
	var() byte FireSndRange, FireSndVolume;
	var() byte DualMode;
	var() bool bInstantHit;
	var() int HitDamage;
	var() name HitType;
	var() float HitError;
	var() float HitMomentum;
	var() byte HitHeavyness;
	var() float FireDelay;
	var() sound FireDelaySnd;
	var() byte FireDelaySndRange, FireDelaySndVolume;
	var() name FireDelayAnim;
	var() float FireDelayAnimRate;
};

var() VehWWeapon WeapSettings[2];
var() bool bFireRateByAnim;
var bool bTurnFire;
var() bool bLimitPitchByCarTop;
var() float CarTopRange;
var() IntRange CarTopAllowedPitch;
var float ZAimOffset;	//Basically is Fireoffset.Z+PitchActorOffset.Z
var() bool bPhysicalGunAimOnly;		//Realistic aim relative to gun position, althought it's autodisabled when Roll>50

var() bool bRotWithOtherWeap;	//Rotate with another weapon attachment when empty
var() byte RotWithOtherWeapPassN;	//When bRotWithOtherWeap=True, choose passenger weapon (0 = Driver weapon)
var float UpdateAttachInfoC;
var WeaponAttachment WAtt;

var float firec;
var byte bInFiringProcess;


//Gathering energy effect
var(EnergyParticles) bool bUseEnergyFX;
struct xEnPartc
{
	var() bool bHaveThisEnPartc;
	var() class<EnLnPartics> EnLnClass;
	var() vector EnLnLocOffSet;
	var() float FirstDelay, RepeatDelay;
	var() int RepeatTimes;
	var() bool bProgressive;
	var() bool bWaitForPreviousFX;	//Ignore FirstDelay and only start after the i-1 effect finished (won't work in the first effect for obvious reasons)
	var EnLnPartics EnLnP;
	var float delayc;
	var int repeatc;
};

var float energyc;

var(EnergyParticles) bool bUseBothSystems;	//Use EnergyPartsA and EnergyPartsB as elements for the same fire, otherwise use A for primary and B for Alt
var(EnergyParticles) xEnPartc EnergyPartsA[16], EnergyPartsB[16];

//ShakeEvents
struct xShakeWeap
{
	var() bool bShakeEnabled, bShakeByStep;
	var() enum EShakeType
	{
		SHK_OnFire,
		SHK_OnAltFire,
		SHK_DuringFire,
		SHK_DuringAltFire,
	} ShakeStart;
	var() float ShakeRadius, ShakeTime, ShakeVertMag, ShakeRollMag, StepInterval;
	var int StepAmount;
	var float StepShkCount;
};

var(Shake) xShakeWeap FiringShaking[4];

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		bInvisGun,TurretOffset,FireFXCounter,
		PitchPart,TurretYaw,TurretPitch,WAtt;
	reliable if( Role==ROLE_Authority && bNetOwner )
		PassengerNum;
	reliable if( Role==ROLE_Authority && !bDriverWeapon && (!bInvisGun || bNetOwner) )
		WeaponController;
	reliable if( Role==ROLE_Authority && !bInvisGun )
		bDriverWeapon;
	reliable if( Role==ROLE_Authority && !bNetOwner )
		RepAimPos;
}

simulated function ClientShakes(byte i)
{
local Pawn P;
local float d;

	For ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		if (PlayerPawn(P) != None && VSize(P.Location - Location) <= FiringShaking[i].ShakeRadius)
		{
			d = FiringShaking[i].ShakeRadius - VSize(P.Location - Location);
	
			if (!FiringShaking[i].bShakeByStep)
				PlayerPawn(P).ShakeView( FiringShaking[i].ShakeTime, d*FiringShaking[i].ShakeRollMag/FiringShaking[i].ShakeRadius , d*FiringShaking[i].ShakeVertMag/FiringShaking[i].ShakeRadius);
			else
				PlayerPawn(P).ShakeView( FiringShaking[i].StepInterval, d*FiringShaking[i].ShakeRollMag/FiringShaking[i].ShakeRadius , d*FiringShaking[i].ShakeVertMag/FiringShaking[i].ShakeRadius);
		}
	}
}

simulated function PostBeginPlay()
{
local byte i;

	if (bUseEnergyFX)
	{
		For (i=0; i<16; i++)
		{
			EnergyPartsA[i].delayc = EnergyPartsA[i].FirstDelay;
			EnergyPartsA[i].repeatc = EnergyPartsA[i].RepeatTimes + 1;
			EnergyPartsB[i].delayc = EnergyPartsB[i].FirstDelay;
			EnergyPartsB[i].repeatc = EnergyPartsB[i].RepeatTimes + 1;
	
			if (EnergyPartsA[i].bWaitForPreviousFX && i!=0)
				EnergyPartsA[i].delayc = 99999.0;
			if (EnergyPartsB[i].bWaitForPreviousFX && i!=0)
				EnergyPartsB[i].delayc = 99999.0;
	
			if (EnergyPartsA[i].EnLnClass == None)
				EnergyPartsA[i].EnLnClass = Class'EnLnPartics';
			if (EnergyPartsB[i].EnLnClass == None)
				EnergyPartsB[i].EnLnClass = Class'EnLnPartics';
		}
	}

	bHasPitchPart = (TurretPitchActor!=None);
	if( bHasPitchPart)
	{
		if (Level.NetMode!=NM_Client)
			PitchPart = Spawn(TurretPitchActor,Self);

		if (!bAltFireZooms)
			ZAimOffset = (WeapSettings[0].FireStartOffset.Z + WeapSettings[1].FireStartOffset.Z)/2 + PitchActorOffset.Z;
		else
			ZAimOffset = WeapSettings[0].FireStartOffset.Z + PitchActorOffset.Z;
	}
	else
	{
		if (!bAltFireZooms)
			ZAimOffset = (WeapSettings[0].FireStartOffset.Z + WeapSettings[1].FireStartOffset.Z)/2;
		else
			ZAimOffset = WeapSettings[0].FireStartOffset.Z;
	}
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	
	if (Level.NetMode==NM_Client)
		OlVehYaw = TurretYaw;
}

simulated function Destroyed()
{
local byte i;

	if( PitchPart!=None )
	{
		PitchPart.Destroy();
		PitchPart = None;
	}

	For (i=0; i<16; i++)
	{
		if (EnergyPartsA[i].EnLnP != None)
			EnergyPartsA[i].EnLnP.Destroy();
		if (EnergyPartsB[i].EnLnP != None)
			EnergyPartsB[i].EnLnP.Destroy();
	}
	Super.Destroyed();
}

function EnLnPartics MakeEnergy(byte i, bool UsingBSys)
{
local EnLnPartics e;
local rotator eR;
local int prog;

	if (PitchPart != None)
		eR = PitchPart.Rotation;
	else
		eR = Rotation;
	eR.Roll = Rand(32768);

	if (!UsingBSys)
	{
		if (PitchPart != None)
			e = Spawn(EnergyPartsA[i].EnLnClass, PitchPart,, PitchPart.Location + (EnergyPartsA[i].EnLnLocOffSet >> PitchPart.Rotation), eR);
		else
			e = Spawn(EnergyPartsA[i].EnLnClass, Self,, Location + (EnergyPartsA[i].EnLnLocOffSet >> Rotation), eR);

		if (e != None)
			e.eOffSet = EnergyPartsA[i].EnLnLocOffSet;

		if (EnergyPartsA[i].bProgressive && EnergyPartsA[i].RepeatTimes >= 6 && e != None)
		{
	
			prog = Abs(EnergyPartsA[i].RepeatTimes - EnergyPartsA[i].repeatc);
	
			if (EnergyPartsA[i].RepeatTimes / 6 > 0)
			{
				if (prog < (5*EnergyPartsA[i].RepeatTimes/6))
					e.MultiSkins[2] = Texture'TransInvis';
				if (prog < (4*EnergyPartsA[i].RepeatTimes/6))
					e.MultiSkins[5] = Texture'TransInvis';
				if (prog < (3*EnergyPartsA[i].RepeatTimes/6))
					e.MultiSkins[4] = Texture'TransInvis';
				if (prog < (2*EnergyPartsA[i].RepeatTimes/6))
					e.MultiSkins[3] = Texture'TransInvis';
				if (prog < (EnergyPartsA[i].RepeatTimes/6))
					e.MultiSkins[6] = Texture'TransInvis';
			}
	
			e.ExtInit( Float(EnergyPartsA[i].repeatc)/Float(EnergyPartsA[i].RepeatTimes));

		}
	}
	else
	{
		if (PitchPart != None)
			e = Spawn(EnergyPartsB[i].EnLnClass, PitchPart,, PitchPart.Location + (EnergyPartsB[i].EnLnLocOffSet >> PitchPart.Rotation), eR);
		else
			e = Spawn(EnergyPartsB[i].EnLnClass, Self,, Location + (EnergyPartsB[i].EnLnLocOffSet >> Rotation), eR);

		if (e != None)
			e.eOffSet = EnergyPartsB[i].EnLnLocOffSet;

		if (EnergyPartsB[i].bProgressive && EnergyPartsB[i].RepeatTimes >= 6 && e != None)
		{

			prog = Abs(EnergyPartsB[i].RepeatTimes - EnergyPartsB[i].repeatc);
	
			if (EnergyPartsB[i].RepeatTimes / 6 > 0)
			{
				if (prog < (5*EnergyPartsB[i].RepeatTimes/6))
					e.MultiSkins[2] = Texture'TransInvis';
				if (prog < (4*EnergyPartsB[i].RepeatTimes/6))
					e.MultiSkins[5] = Texture'TransInvis';
				if (prog < (3*EnergyPartsB[i].RepeatTimes/6))
					e.MultiSkins[4] = Texture'TransInvis';
				if (prog < (2*EnergyPartsB[i].RepeatTimes/6))
					e.MultiSkins[3] = Texture'TransInvis';
				if (prog < (EnergyPartsB[i].RepeatTimes/6))
					e.MultiSkins[6] = Texture'TransInvis';
			}
	
			e.ExtInit( Float(EnergyPartsB[i].repeatc)/Float(EnergyPartsB[i].RepeatTimes));

		}
	}

	return e;	
}

function EnergyGather(float Delta, byte Mode)
{
local byte i;

	energyc += Delta;

	For (i=0; i<16; i++)
	{
		if (!bUseBothSystems)
		{
			if (Mode == 0 && EnergyPartsA[i].bHaveThisEnPartc)
			{
				if (energyc >= EnergyPartsA[i].delayc && EnergyPartsA[i].repeatc > 0)
				{
					if (!EnergyPartsA[i].bProgressive)
						EnergyPartsA[i].delayc += EnergyPartsA[i].RepeatDelay;
					else
						EnergyPartsA[i].delayc += EnergyPartsA[i].EnLnClass.static.GetTimeExtend(EnergyPartsA[i].RepeatDelay,EnergyPartsA[i].repeatc,EnergyPartsA[i].RepeatTimes);

					EnergyPartsA[i].repeatc--;
					EnergyPartsA[i].EnLnP = MakeEnergy( i, False);

					if (i < 15 && EnergyPartsA[i].repeatc <= 0)
					{
						if (EnergyPartsA[i+1].bWaitForPreviousFX)
							EnergyPartsA[i+1].delayc = EnergyPartsA[i].delayc;
					}
				}
			}
			else if (Mode == 1 && EnergyPartsB[i].bHaveThisEnPartc)
			{
				if (energyc >= EnergyPartsB[i].delayc && EnergyPartsB[i].repeatc > 0)
				{
					if (!EnergyPartsB[i].bProgressive)
						EnergyPartsB[i].delayc += EnergyPartsB[i].RepeatDelay;
					else
						EnergyPartsB[i].delayc += EnergyPartsB[i].EnLnClass.static.GetTimeExtend(EnergyPartsB[i].RepeatDelay,EnergyPartsB[i].repeatc,EnergyPartsB[i].RepeatTimes);
					EnergyPartsB[i].repeatc--;
					EnergyPartsB[i].EnLnP = MakeEnergy( i, True);
					
					if (i < 15 && EnergyPartsB[i].repeatc <= 0)
					{
						if (EnergyPartsB[i+1].bWaitForPreviousFX)
							EnergyPartsB[i+1].delayc = EnergyPartsB[i].delayc;
					}
				}
			}
		}
		else
		{
			if (EnergyPartsA[i].bHaveThisEnPartc)
			{
				if (energyc >= EnergyPartsA[i].delayc && EnergyPartsA[i].repeatc > 0)
				{
					if (!EnergyPartsA[i].bProgressive)
						EnergyPartsA[i].delayc += EnergyPartsA[i].RepeatDelay;
					else
						EnergyPartsA[i].delayc += EnergyPartsA[i].EnLnClass.static.GetTimeExtend(EnergyPartsA[i].RepeatDelay,EnergyPartsA[i].repeatc,EnergyPartsA[i].RepeatTimes);
					EnergyPartsA[i].repeatc--;
					EnergyPartsA[i].EnLnP = MakeEnergy( i, False);

					if (i < 15 && EnergyPartsA[i].repeatc <= 0)
					{
						if (EnergyPartsA[i+1].bWaitForPreviousFX)
							EnergyPartsA[i+1].delayc = EnergyPartsA[i].delayc;
					}
				}
			}

			if (EnergyPartsB[i].bHaveThisEnPartc)
			{
				if (energyc >= EnergyPartsB[i].delayc && EnergyPartsB[i].repeatc > 0)
				{
					if (!EnergyPartsB[i].bProgressive)
						EnergyPartsB[i].delayc += EnergyPartsB[i].RepeatDelay;
					else
						EnergyPartsB[i].delayc += EnergyPartsB[i].EnLnClass.static.GetTimeExtend(EnergyPartsB[i].RepeatDelay,EnergyPartsB[i].repeatc,EnergyPartsB[i].RepeatTimes);
					EnergyPartsB[i].repeatc--;
					EnergyPartsB[i].EnLnP = MakeEnergy( i, True);

					if (i < 15 && EnergyPartsB[i].repeatc <= 0)
					{
						if (EnergyPartsB[i+1].bWaitForPreviousFX)
							EnergyPartsB[i+1].delayc = EnergyPartsB[i].delayc;
					}
				}
			}
		}
	}
}

function ResetEnergy()
{
local byte i;

	For (i=0; i<16; i++)
	{
		EnergyPartsA[i].delayc = EnergyPartsA[i].FirstDelay;
		EnergyPartsA[i].repeatc = EnergyPartsA[i].RepeatTimes + 1;
		EnergyPartsA[i].EnLnP = None;

		EnergyPartsB[i].delayc = EnergyPartsB[i].FirstDelay;
		EnergyPartsB[i].repeatc = EnergyPartsB[i].RepeatTimes + 1;
		EnergyPartsB[i].EnLnP = None;

		
		if (EnergyPartsA[i].bWaitForPreviousFX && i!=0)
			EnergyPartsA[i].delayc = 99999.0;
		if (EnergyPartsB[i].bWaitForPreviousFX && i!=0)
			EnergyPartsB[i].delayc = 99999.0;
	}

	energyc = 0;
}

function ActivateDelay(byte Mode)
{
local byte i;

	bInFiringProcess = Mode + 1;
	firec = WeapSettings[Mode].FireDelay;

	if (WeapSettings[Mode].FireDelaySnd != None)
		PlaySound(WeapSettings[Mode].FireDelaySnd,SLOT_Misc,WeapSettings[Mode].FireDelaySndVolume,,WeapSettings[Mode].FireDelaySndRange*62.5);

	if (WeapSettings[Mode].FireDelayAnim!='' && WeapSettings[Mode].FireDelayAnimRate > 0 && PitchPart!=None)
		PitchPart.PlayAnim(WeapSettings[Mode].FireDelayAnim, WeapSettings[Mode].FireDelayAnimRate, 0.05);
	else if (WeapSettings[Mode].FireDelayAnim!='' && WeapSettings[Mode].FireDelayAnimRate > 0)
		PlayAnim(WeapSettings[Mode].FireDelayAnim, WeapSettings[Mode].FireDelayAnimRate, 0.05);


	For (i = 0; i < 4; i++)
	{
		if (FiringShaking[i].bShakeEnabled && ((FiringShaking[i].ShakeStart == SHK_DuringFire && Mode == 0) || (FiringShaking[i].ShakeStart == SHK_DuringAltFire && Mode == 1)))
		{
			if (FiringShaking[i].bShakeByStep && FiringShaking[i].StepInterval > 0)
				FiringShaking[i].StepAmount = FiringShaking[i].ShakeTime / FiringShaking[i].StepInterval;
			else
				ClientShakes(i);
		}
	}
}

simulated function DelayFX(byte Mode);	//Called at the same time as ActivateDelay (to easilly spawn further effects in the delay time)

function Projectile FixProj(Projectile Proj)
{
	local vector HitLocation, HitNormal, TraceEnd, TraceStart;
	if (Proj != None && Proj.Trace(HitLocation, HitNormal, Proj.Location, Location, false) != None)
	{
		Proj.SetLocation(HitLocation);
	}
	return Proj;
}

function FireTurret( byte Mode, optional bool bForceFire )
{
	local vector P, Pdual;
	local rotator R,TR,PR;
	local vector RealFireOffset;
	local vector E,S,HL,HN;
	local Actor A;
	local byte i;
	local xVehProjDummy xWFX;

	if( bAltFireZooms && Mode==1 )
	{
		if( PlayerPawn(WeaponController)!=None )
			Return;
		else Mode = 0;
	}

	if (PitchPart != None)
		bPhysicalGunAimOnly = Default.bPhysicalGunAimOnly && (Normalize(PitchPart.Rotation).Roll < 50 && Normalize(PitchPart.Rotation).Roll > -50);
	else
		bPhysicalGunAimOnly = Default.bPhysicalGunAimOnly && (Normalize(Rotation).Roll < 50 && Normalize(Rotation).Roll > -50);

	if (!bForceFire)
	{
		if( bFireRestrict || bInFiringProcess > 0)
			Return;
		else if (WeapSettings[Mode].FireDelay > 0 && firec <= 0)
		{
			ActivateDelay(Mode);
			DelayFX(Mode);
			Return;
		}
	}

	//if( Level.NetMode!=NM_DedicatedServer )
	MakeFireFX(Mode);

	/*if( Level.NetMode!=NM_StandAlone )
	{
		FireFXCounter++;
		if( FireFXCounter>=250 )
			FireFXCounter = 1;
	}*/

	For (i = 0; i < 4; i++)
	{
		if (FiringShaking[i].bShakeEnabled && ((FiringShaking[i].ShakeStart == SHK_OnFire && Mode == 0) || (FiringShaking[i].ShakeStart == SHK_OnAltFire && Mode == 1)))
		{
			if (FiringShaking[i].bShakeByStep && FiringShaking[i].StepInterval > 0)
				FiringShaking[i].StepAmount = FiringShaking[i].ShakeTime / FiringShaking[i].StepInterval;
			else
				ClientShakes(i);
		}
	}

	GetTurretCoords(P,R,PR);

	if( bHasPitchPart )
	{
		P+=(PitchActorOffset >> R);
		R = PR;
	}
	else PR = R;

	RealFireOffset = WeapSettings[Mode].FireStartOffset;

	if (WeapSettings[Mode].DualMode == 1 && bTurnFire)
	{
		bTurnFire = False;
		if (WeapSettings[Mode].FireAnim2!='' && WeapSettings[Mode].RefireRate > 0 && PitchPart!=None)
			PitchPart.PlayAnim(WeapSettings[Mode].FireAnim2, WeapSettings[Mode].RefireRate, 0.05);
		else if (WeapSettings[Mode].FireAnim2!='' && WeapSettings[Mode].RefireRate > 0)
			PlayAnim(WeapSettings[Mode].FireAnim2, WeapSettings[Mode].RefireRate, 0.05);
	}
	else if (WeapSettings[Mode].DualMode == 1)
	{
		RealFireOffset.Y = -RealFireOffset.Y;
		if (WeapSettings[Mode].FireAnim1!='' && WeapSettings[Mode].RefireRate > 0 && PitchPart!=None)
			PitchPart.PlayAnim(WeapSettings[Mode].FireAnim1, WeapSettings[Mode].RefireRate, 0.05);
		else if (WeapSettings[Mode].FireAnim1!='' && WeapSettings[Mode].RefireRate > 0)
			PlayAnim(WeapSettings[Mode].FireAnim1, WeapSettings[Mode].RefireRate, 0.05);
		bTurnFire = True;
	}
	else if (WeapSettings[Mode].FireAnim1!='' && WeapSettings[Mode].RefireRate > 0 && PitchPart!=None)
		PitchPart.PlayAnim(WeapSettings[Mode].FireAnim1, WeapSettings[Mode].RefireRate, 0.05);
	else if (WeapSettings[Mode].FireAnim1!='' && WeapSettings[Mode].RefireRate > 0)
		PlayAnim(WeapSettings[Mode].FireAnim1, WeapSettings[Mode].RefireRate, 0.05);

	if (PitchPart != None)
		P = PitchPart.Location;
	else
		P = Location;

	Pdual = P;
	P+=(RealFireOffset >> R);
	
	if (WeapSettings[Mode].DualMode == 2)
	{
		RealFireOffset.Y = -RealFireOffset.Y;
		Pdual+=(RealFireOffset >> R);
	}

	SpawnFireEffects(Mode);

	if (!bPhysicalGunAimOnly)
	{
		if (!WeapSettings[Mode].bInstantHit)
			R = OwnerVehicle.GetFiringRot(WeapSettings[Mode].ProjectileClass.Default.Speed,False,P,PassengerNum);
		else
			R = OwnerVehicle.GetFiringRot(9999,True,P,PassengerNum);
	
		TR = Normalize(R-Rotation);
	}

	if( bPhysicalGunAimOnly || TR.Yaw>3500 || TR.Yaw<-3500 || TR.Pitch>3500 || TR.Pitch<-3500 ) {
		R = PR;
	}
	Instigator = WeaponController;

	if (!WeapSettings[Mode].bInstantHit)
		FixProj(Spawn(WeapSettings[Mode].ProjectileClass,OwnerVehicle,,P,R));
	else
	{
		S = P;
		P = Normal(vector(R)+VRand()*WeapSettings[Mode].HitError);
		E = S+P*80000;
		SpawnTraceEffects(P);
		A = OwnerVehicle.Trace(HL,HN,E,S,True);
		xWFX = Spawn(Class'xVehProjDummy', OwnerVehicle,, S, rotator(P));
		xWFX.Mass = FClamp(WeapSettings[Mode].HitHeavyness, 0, 10);
		TraceProcess(A, HL, HN, Mode);
	}

	if (WeapSettings[Mode].DualMode == 2 && !WeapSettings[Mode].bInstantHit)
		FixProj(Spawn(WeapSettings[Mode].ProjectileClass,OwnerVehicle,,Pdual,R));
	else if (WeapSettings[Mode].DualMode == 2)
	{
		S = Pdual;
		Pdual = Normal(vector(R)+VRand()*WeapSettings[Mode].HitError);
		E = S+Pdual*80000;
		SpawnTraceEffects(PDual);
		A = OwnerVehicle.Trace(HL,HN,E,S,True);
		xWFX = Spawn(Class'xVehProjDummy', OwnerVehicle,, S, rotator(Pdual));
		xWFX.Mass = FClamp(WeapSettings[Mode].HitHeavyness, 0, 10);
		TraceProcess(A, HL, HN, Mode);
	}

	if (!bFireRateByAnim)
		SetTimer(WeapSettings[Mode].RefireRate,False);
	bFireRestrict = True;
}

function SpawnFireEffects(byte Mode);		//Spawn Firing Effects here

function SpawnTraceEffects(vector Dir);		//Spawn tracing effects

function TraceProcess( actor A, vector HitLocation, vector HitNormal, byte Mode)
{
	if( A!=None )
	{
		if( A==Level )
			Spawn(Class'UT_LightWallHitEffect',,,HitLocation+HitNormal,Rotator(HitNormal));
		else
		{
			if ( !A.bIsPawn && !A.IsA('Carcass') )
				spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
			else
            			A.PlaySound(Sound'ChunkHit',, 4.0,,100);
		}

		A.TakeDamage(WeapSettings[Mode].HitDamage,WeaponController,HitLocation,WeapSettings[Mode].HitMomentum*Normal(HitLocation-Location), WeapSettings[Mode].HitType);
	}
}

function Timer()
{

	bFireRestrict = False;
	if( WeaponController==None )
		Return;
	if( WeaponController.bFire!=0 )
		FireTurret(0);
	else if( WeaponController.bAltFire!=0 )
		FireTurret(1);
}

simulated function AnimEnd()
{
	if (bFireRestrict && bFireRateByAnim && bInFiringProcess == 0)
	{
		bFireRestrict = False;
		if( WeaponController==None )
			Return;
		if( WeaponController.bFire!=0 )
			FireTurret(0);
		else if( WeaponController.bAltFire!=0 )
			FireTurret(1);
	}
}

simulated function Tick( float Delta )
{
	local vector Po;
	local rotator Ro,RAdj,PRo;
	local int OldY,OldP;
	local byte j;
	local VehicleAttachment vat;
	local byte i;

	if( OwnerVehicle==None )
		Return;

	For (i = 0; i < 4; i++)
	{
		if (FiringShaking[i].bShakeEnabled && FiringShaking[i].bShakeByStep && FiringShaking[i].StepAmount > 0)
		{
			FiringShaking[i].StepShkCount += Delta;
		
			if (FiringShaking[i].StepShkCount >= FiringShaking[i].StepInterval)
			{
				FiringShaking[i].StepAmount--;
				FiringShaking[i].StepShkCount = 0;
				ClientShakes(i);
			}
		}
	}

	if (bInFiringProcess > 0)
	{
		firec -= Delta;

		if (bUseEnergyFX)
			EnergyGather(Delta,bInFiringProcess-1);

		if (firec <= 0)
		{
			j = bInFiringProcess-1;
			bInFiringProcess = 0;
			FireTurret(j,True);
			ResetEnergy();
		}
			
	}

	if (bRotWithOtherWeap)
	{
		if (UpdateAttachInfoC >= 0.2 && UpdateAttachInfoC < 1.0)
		{
			if (Role == ROLE_Authority && (WAtt == None || WAtt.PassengerNum != RotWithOtherWeapPassN))
				for ( vat=OwnerVehicle.AttachmentList; vat!=None; vat=vat.NextAttachment )
					if (WeaponAttachment(vat)!=None && WeaponAttachment(vat).PassengerNum == RotWithOtherWeapPassN)
					{
						WAtt = WeaponAttachment(vat);
						break;
					}
			UpdateAttachInfoC = 2.0;
		}
		else if (UpdateAttachInfoC < 0.2)
			UpdateAttachInfoC += Delta;
	}	

	if (!bUpdatedPassOffsets)
	{
		bUpdatedPassOffsets = True;
		For (j=0; j<8; j++)
			PassWPosOffset[j] = OwnerVehicle.GetPassengerWOffset(j);
	}

	if( !bFireInit )
	{
		bFireInit = True;
		FireFXCounter = 0;
	}
	//if( OwnerVehicle.AttachmentList==Self )
	if(bMasterPart && OwnerVehicle != None)
		OwnerVehicle.AttachmentsTick(Delta);	
	if( Level.NetMode==NM_Client /* || Level.NetMode==NM_DedicatedServer */ )
		OwnerVehicle.UpdateAttachment(self, Delta);
	if( bDriverWeapon && WeaponController!=OwnerVehicle.Driver )
		WeaponController = OwnerVehicle.Driver;
	if( Level.NetMode!=NM_DedicatedServer && !bInvisGun )
	{
		if( OwnerVehicle.OverlayMat!=None )
		{
			if( OverlayMActor==None )
				OverlayMActor = Spawn(Class'MatOverlayFX',Self);
			OverlayMActor.Texture = OwnerVehicle.OverlayMat;
			if( OwnerVehicle.OverlayTime>=1 )
				OverlayMActor.ScaleGlow = 1;
			else OverlayMActor.ScaleGlow = (OwnerVehicle.OverlayTime/1);
			OverlayMActor.AmbientGlow = OverlayMActor.ScaleGlow * 255;
		}
		else if( OverlayMActor!=None )
		{
			OverlayMActor.Destroy();
			OverlayMActor = None;
		}
	}
	if (!bTurretYawInit)
	{
		bTurretYawInit = true;
		SetTurretYaw();
	}
	GetTurretCoords(Po,Ro,PRo);
	if( PitchPart!=None )
	{
		//PitchPart.SetLocation(Po+(PitchActorOffset >> Ro));
		PitchPart.SetRotation(PRo);
	}
	//Move(Po-Location);
	SetRotation(Ro);
	/*if( Level.NetMode==NM_Client )
	{
		if( FireFXCounter>0 )
		{
			FireFXCounter = 0;
			MakeFireFX();
		}
	}*/
	
	SetTurretYaw();

	if( WeaponController==None )
	{
		bRotatingBarrel = False;
		AmbientSound = Default.AmbientSound;
		Return;
	}
	if( Level.NetMode!=NM_Client || (WeaponController!=None && IsNetOwner(WeaponController)) )
	{
		if( PlayerPawn(WeaponController)==None )
			Ro = GetBotInput(Delta);
		else Ro = GetDriverInput(Delta);
	}
	else if( RepAimPos==vect(0,0,0) )
		Ro = OwnerVehicle.Rotation;
	else Ro = rotator(RepAimPos-Po);
	
	Ro = Normalize(Ro);
	//Ro.Roll = 0;

	OldAimRotation = Ro;
	
	if (OwnerVehicle.bSlopedPhys && OwnerVehicle.GVT!=None)
		RAdj = Normalize(TransformForGroundRot(Ro.Yaw,OwnerVehicle.GVTNormal,Ro.Pitch));
	else
		RAdj = Normalize(TransformForGroundRot(Ro.Yaw,OwnerVehicle.FloorNormal,Ro.Pitch));
	if( RAdj!=Ro )
	{
		Ro.Pitch-=(RAdj.Pitch-Ro.Pitch);
		Ro.Yaw-=(RAdj.Yaw-Ro.Yaw);
	}

	if (!bLimitPitchByCarTop || (bLimitPitchByCarTop && (vector(Rotation) dot vector(OwnerVehicle.Rotation))<CarTopRange))
	{
		if( Ro.Pitch<PitchRange.Min )
			Ro.Pitch = PitchRange.Min;
		else if( Ro.Pitch>PitchRange.Max )
			Ro.Pitch = PitchRange.Max;
	}
	else
	{
		if( Ro.Pitch<CarTopAllowedPitch.Min )
			Ro.Pitch = CarTopAllowedPitch.Min;
		else if( Ro.Pitch>CarTopAllowedPitch.Max )
			Ro.Pitch = CarTopAllowedPitch.Max;
	}
	
	OldY = TurretYaw;
	OldP = TurretPitch;
	TurretYaw = CalcTurnSpeed(RotatingSpeed*Delta,TurretYaw,Ro.Yaw);
	TurretPitch = CalcTurnSpeed(RotatingSpeed*Delta,TurretPitch,Ro.Pitch);
	bRotatingBarrel = (OldY!=TurretYaw || OldP!=TurretPitch);
	if( BarrelTurnSound==None /*|| Level.NetMode==NM_ListenServer || Level.NetMode==NM_DedicatedServer */)
		Return;
	if( !bRotatingBarrel )
		AmbientSound = Default.AmbientSound;
	else AmbientSound = BarrelTurnSound;
}
simulated function GetTurretCoords( optional out vector Pos, optional out rotator TurRot, optional out rotator PitchPartRot )
{
	if( PassengerNum==0 )
		Pos = OwnerVehicle.Location+(TurretOffset >> OwnerVehicle.Rotation);
	//else Pos = OwnerVehicle.GetPassengerWOffset(PassengerNum-1);
	else Pos = OwnerVehicle.Location+(PassWPosOffset[PassengerNum-1] >> OwnerVehicle.Rotation);
	if( bHasPitchPart )
	{
		if (OwnerVehicle.bSlopedPhys && OwnerVehicle.GVT!=None)
		{
			TurRot = TransformForGroundRot(TurretYaw,OwnerVehicle.GVTNormal);
			PitchPartRot = TransformForGroundRot(TurretYaw,OwnerVehicle.GVTNormal,TurretPitch);
		}
		else
		{
			TurRot = TransformForGroundRot(TurretYaw,OwnerVehicle.FloorNormal);
			PitchPartRot = TransformForGroundRot(TurretYaw,OwnerVehicle.FloorNormal,TurretPitch);
		}
	}
	else if (OwnerVehicle.bSlopedPhys && OwnerVehicle.GVT!=None)
	{
		TurRot = TransformForGroundRot(TurretYaw,OwnerVehicle.GVTNormal,TurretPitch);
	}
	else
	{
		TurRot = TransformForGroundRot(TurretYaw,OwnerVehicle.FloorNormal,TurretPitch);
	}
}

simulated function SetTurretYaw()
{
	if (!bRotWithOtherWeap || WAtt == None || WeaponController!=None)
	{
		if( OlVehYaw!=OwnerVehicle.VehicleYaw)
		{
			TurretYaw = (TurretYaw + OwnerVehicle.VehicleYaw-OlVehYaw) & 65535;
			OlVehYaw = OwnerVehicle.VehicleYaw;
		}
	}
	else
	{
		if( OlVehYaw!=WAtt.TurretYaw)
		{
			TurretYaw = (TurretYaw + WAtt.TurretYaw-OlVehYaw) & 65535;
			OlVehYaw = WAtt.TurretYaw;
		}
	}
}

// Called on client and local servers whenever FireFXCounter is added by 1. - Not anymore
// Fire Sound Playing
/*simulated*/ function MakeFireFX(byte Mode )
{
	PlaySound(WeapSettings[Mode].FireSound,SLOT_Misc,WeapSettings[Mode].FireSndVolume,,WeapSettings[Mode].FireSndRange*62.5);
}

simulated function rotator GetDriverInput( float Delta )
{
	if( bAltFireZooms && NetConnection(PlayerPawn(WeaponController).Player)==None )
	{
		if( !bPressingAltZoom && WeaponController.bAltFire!=0 )
		{
			bPressingAltZoom = True;
			PlayerPawn(WeaponController).ToggleZoom();
		}
		else if( bPressingAltZoom && WeaponController.bAltFire==0 )
		{
			bPressingAltZoom = False;
			PlayerPawn(WeaponController).StopZoom();
		}
	}
	RepAimPos = OwnerVehicle.CalcPlayerAimPos(PassengerNum);
	Return rotator(RepAimPos-(Location + (eVect(0,0,ZAimOffset)>>OwnerVehicle.Rotation)));
}
function rotator GetBotInput( float Delta )
{
	if( WeaponController.Target!=None )
		RepAimPos = WeaponController.Target.Location;
	else if( WeaponController.FaceTarget!=None )
		RepAimPos = WeaponController.FaceTarget.Location;
	else RepAimPos = WeaponController.Focus;
	Return rotator(RepAimPos-(Location + (eVect(0,0,ZAimOffset)>>OwnerVehicle.Rotation)));
}
simulated function bool AimingIsOK()
{
local rotator TurRo;

	TurRo.Yaw = TurretYaw;
	TurRo.Pitch = TurretPitch;

	//Return !bRotatingBarrel;
	return (vector(TurRo) dot vector(OldAimRotation)) > 0.855;
	//return (vector(TurRo) dot vector(OldAimRotation)) > 0.915;
}
simulated function WRenderOverlay( Canvas C );

defaultproperties
{
      bDriverWeapon=False
      bInvisGun=False
      bFireRestrict=False
      bFireInit=False
      bRotatingBarrel=False
      bPressingAltZoom=False
      WeaponController=None
      TurretYaw=0
      TurretPitch=0
      TurretOffset=(X=0.000000,Y=0.000000,Z=0.000000)
      RepAimPos=(X=0.000000,Y=0.000000,Z=0.000000)
      FireFXCounter=0
      RotatingSpeed=16000.000000
      BarrelTurnSound=None
      PitchRange=(Max=10000,Min=-5000)
      bAltFireZooms=False
      OlVehYaw=0.000000
      PassengerNum=0
      PitchPart=None
      TurretPitchActor=None
      PitchActorOffset=(X=0.000000,Y=0.000000,Z=0.000000)
      bHasPitchPart=False
      bTurretYawInit=False
      PassWPosOffset(0)=(X=0.000000,Y=0.000000,Z=0.000000)
      PassWPosOffset(1)=(X=0.000000,Y=0.000000,Z=0.000000)
      PassWPosOffset(2)=(X=0.000000,Y=0.000000,Z=0.000000)
      PassWPosOffset(3)=(X=0.000000,Y=0.000000,Z=0.000000)
      PassWPosOffset(4)=(X=0.000000,Y=0.000000,Z=0.000000)
      PassWPosOffset(5)=(X=0.000000,Y=0.000000,Z=0.000000)
      PassWPosOffset(6)=(X=0.000000,Y=0.000000,Z=0.000000)
      PassWPosOffset(7)=(X=0.000000,Y=0.000000,Z=0.000000)
      bUpdatedPassOffsets=False
      OldAimRotation=(Pitch=0,Yaw=0,Roll=0)
      WeapSettings(0)=(ProjectileClass=None,FireStartOffset=(X=0.000000,Y=0.000000,Z=0.000000),RefireRate=0.500000,FireAnim1="None",FireAnim2="None",FireSound=None,FireSndRange=32,FireSndVolume=20,DualMode=0,bInstantHit=False,hitdamage=0,HitType="None",HitError=0.015000,HitMomentum=0.000000,HitHeavyness=1,FireDelay=0.000000,FireDelaySnd=None,FireDelaySndRange=0,FireDelaySndVolume=0,FireDelayAnim="None",FireDelayAnimRate=0.000000)
      WeapSettings(1)=(ProjectileClass=None,FireStartOffset=(X=0.000000,Y=0.000000,Z=0.000000),RefireRate=0.500000,FireAnim1="None",FireAnim2="None",FireSound=None,FireSndRange=32,FireSndVolume=20,DualMode=0,bInstantHit=False,hitdamage=0,HitType="None",HitError=0.015000,HitMomentum=0.000000,HitHeavyness=1,FireDelay=0.000000,FireDelaySnd=None,FireDelaySndRange=0,FireDelaySndVolume=0,FireDelayAnim="None",FireDelayAnimRate=0.000000)
      bFireRateByAnim=False
      bTurnFire=False
      bLimitPitchByCarTop=False
      CarTopRange=0.000000
      CarTopAllowedPitch=(Max=0,Min=0)
      ZAimOffset=0.000000
      bPhysicalGunAimOnly=False
      bRotWithOtherWeap=False
      RotWithOtherWeapPassN=0
      UpdateAttachInfoC=0.000000
      WAtt=None
      firec=0.000000
      bInFiringProcess=0
      bUseEnergyFX=False
      energyc=0.000000
      bUseBothSystems=False
      EnergyPartsA(0)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsA(1)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsA(2)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsA(3)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsA(4)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsA(5)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsA(6)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsA(7)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsA(8)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsA(9)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsA(10)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsA(11)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsA(12)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsA(13)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsA(14)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsA(15)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(0)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(1)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(2)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(3)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(4)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(5)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(6)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(7)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(8)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(9)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(10)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(11)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(12)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(13)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(14)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      EnergyPartsB(15)=(bHaveThisEnPartc=False,EnLnClass=None,EnLnLocOffSet=(X=0.000000,Y=0.000000,Z=0.000000),FirstDelay=0.000000,RepeatDelay=0.000000,RepeatTimes=0,bProgressive=False,bWaitForPreviousFX=False,EnLnP=None,delayc=0.000000,repeatc=0)
      FiringShaking(0)=(bShakeEnabled=False,bShakeByStep=False,ShakeStart=SHK_OnFire,ShakeRadius=0.000000,shaketime=0.000000,ShakeVertMag=0.000000,ShakeRollMag=0.000000,StepInterval=0.000000,StepAmount=0,StepShkCount=0.000000)
      FiringShaking(1)=(bShakeEnabled=False,bShakeByStep=False,ShakeStart=SHK_OnAltFire,ShakeRadius=0.000000,shaketime=0.000000,ShakeVertMag=0.000000,ShakeRollMag=0.000000,StepInterval=0.000000,StepAmount=0,StepShkCount=0.000000)
      FiringShaking(2)=(bShakeEnabled=False,bShakeByStep=False,ShakeStart=SHK_DuringFire,ShakeRadius=0.000000,shaketime=0.000000,ShakeVertMag=0.000000,ShakeRollMag=0.000000,StepInterval=0.000000,StepAmount=0,StepShkCount=0.000000)
      FiringShaking(3)=(bShakeEnabled=False,bShakeByStep=False,ShakeStart=SHK_DuringAltFire,ShakeRadius=0.000000,shaketime=0.000000,ShakeVertMag=0.000000,ShakeRollMag=0.000000,StepInterval=0.000000,StepAmount=0,StepShkCount=0.000000)
      RemoteRole=ROLE_SimulatedProxy
      bCarriedItem=True
      NetPriority=3.000000
}
