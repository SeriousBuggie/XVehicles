// Weapon Attachments for vehicles.
// Network code: Client rotate turret by RepAimPos. Owners use GetDriverInput/GetBotInput
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
var bool bYawFromContr;
var byte PassengerNum;
var VehicleAttachment PitchPart;
var() class<VehicleAttachment> TurretPitchActor;
var() vector PitchActorOffset;
var bool bHasPitchPart, bTurretYawInit;
var vector PassWPosOffset[8]; 
var bool bUpdatedPassOffsets;
var rotator OldAimRotation;
var float NextTimeRangedAttack;

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
var bool bSkipFiringShaking;

var() class<Actor> HitMark;

replication
{
	// Variables the server should send to the client.
	reliable if (Role == ROLE_Authority)
		bInvisGun, TurretOffset, FireFXCounter,
		PitchPart, WAtt, ClientFireEffect;
	reliable if (Role == ROLE_Authority && bNetInitial)
		TurretYaw,TurretPitch;
	reliable if (Role == ROLE_Authority && bNetOwner)
		PassengerNum;
	reliable if (Role == ROLE_Authority && !bDriverWeapon && (!bInvisGun || bNetOwner))
		WeaponController;
	reliable if (Role == ROLE_Authority && !bInvisGun)
		bDriverWeapon;
	reliable if (Role == ROLE_Authority && (!bNetOwner || bDemoRecording))
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
		if (Level.NetMode != NM_Client)
			PitchPart = Spawn(TurretPitchActor, Self);
		if (Level.NetMode == NM_DedicatedServer)
			PitchPart.Disable('Tick');

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
	
	if (Role != ROLE_Authority)
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
	bSkipFiringShaking = false;
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

function float GetProjSpeed(byte Mode, vector P, rotator R)
{
	return WeapSettings[Mode].ProjectileClass.Default.Speed;
}

function FireTurret( byte Mode, optional bool bForceFire )
{
	local vector P, Pdual, L;
	local rotator R,Rdual,TR,PR;
	local vector RealFireOffset;
	local vector E,S,HL,HN;
	local Actor A;
	local byte i;
	local xVehProjDummy xWFX;
	
	//Log(self @ OwnerVehicle @ WeaponController.getHumanName() @ WeaponController.bFire @ WeaponController.bAltFire);
	
	if ((WeaponController != None && WeaponController.IsInState('GameEnded')) || Level.Game.bGameEnded)
		return;

	if (bAltFireZooms && Mode == 1)
	{
		if (PlayerPawn(WeaponController) != None)
			return;
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
	bSkipFiringShaking = false;

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
		L = PitchPart.Location;
	else
		L = Location;
	P = L;

	Pdual = P;
	P+=(RealFireOffset >> R);
	
	if (WeapSettings[Mode].DualMode == 2)
	{
		RealFireOffset.Y = -RealFireOffset.Y;
		Pdual+=(RealFireOffset >> R);
		Rdual = R;
	}

	SpawnFireEffects(Mode);

	if (!bPhysicalGunAimOnly)
	{
		if (!WeapSettings[Mode].bInstantHit)
		{
			R = OwnerVehicle.GetFiringRot(GetProjSpeed(Mode, P, R),False,P,PassengerNum);
			if (WeapSettings[Mode].DualMode == 2)
				Rdual = OwnerVehicle.GetFiringRot(GetProjSpeed(Mode, Pdual, Rdual),False,Pdual,PassengerNum);
		}
		else
		{
			R = OwnerVehicle.GetFiringRot(9999,True,P,PassengerNum);
			if (WeapSettings[Mode].DualMode == 2)
				Rdual = OwnerVehicle.GetFiringRot(9999,True,Pdual,PassengerNum);
		}
	
		TR = Rotation;
		if (PitchPart != None)
			TR = PitchPart.Rotation;
		TR = Normalize(R-TR);
	}

	if( bPhysicalGunAimOnly || TR.Yaw>3500 || TR.Yaw<-3500 || TR.Pitch>3500 || TR.Pitch<-3500 ) {
		if (OwnerVehicle.Trace(HL, HN, L + vector(PR)*40000, L, True) != None)
		{
			if ((HL - P) dot (P - L) <= 0)
				HL = L + vector(PR)*(16 + vector(PR) dot (P - L));
			R = rotator(HL - P);
			Rdual = rotator(HL - Pdual);
		}
		else
		{
			R = PR;
			Rdual = PR;
		}
	}
	Instigator = WeaponController;
	
	FireEffect();
	if (Level.NetMode == NM_DedicatedServer)
		ClientFireEffect();

	if (!WeapSettings[Mode].bInstantHit)
		FixProj(Spawn(WeapSettings[Mode].ProjectileClass,OwnerVehicle,,P,R));
	else
	{
		S = P;
		P = Normal(vector(R)+VRand()*FRand()*WeapSettings[Mode].HitError);
		E = S+P*80000;
		SpawnTraceEffects(P);
		A = OwnerVehicle.Trace(HL,HN,E,S,True);
		xWFX = Spawn(Class'xVehProjDummy', OwnerVehicle,, S, rotator(P));
		if (xWFX != None)
			xWFX.Mass = FClamp(WeapSettings[Mode].HitHeavyness, 0, 10);
		TraceProcess(A, HL, HN, Mode);
	}

	if (WeapSettings[Mode].DualMode == 2 && !WeapSettings[Mode].bInstantHit)
		FixProj(Spawn(WeapSettings[Mode].ProjectileClass,OwnerVehicle,,Pdual,Rdual));
	else if (WeapSettings[Mode].DualMode == 2)
	{
		S = Pdual;
		Pdual = Normal(vector(Rdual)+VRand()*FRand()*WeapSettings[Mode].HitError);
		E = S+Pdual*80000;
		SpawnTraceEffects(PDual);
		A = OwnerVehicle.Trace(HL,HN,E,S,True);
		xWFX = Spawn(Class'xVehProjDummy', OwnerVehicle,, S, rotator(Pdual));
		if (xWFX != None)
			xWFX.Mass = FClamp(WeapSettings[Mode].HitHeavyness, 0, 10);
		TraceProcess(A, HL, HN, Mode);
	}

	if (!bFireRateByAnim)
		SetTimer(WeapSettings[Mode].RefireRate,False);
	bFireRestrict = True;
}

simulated function ClientFireEffect()
{
	FireEffect();
}

simulated function FireEffect()
{
	if (WeaponController != None && DriverWeapon(WeaponController.Weapon) != None &&
		DriverWeapon(WeaponController.Weapon).Affector != None)
		DriverWeapon(WeaponController.Weapon).Affector.FireEffect();
}

function SpawnFireEffects(byte Mode);		//Spawn Firing Effects here

function SpawnTraceEffects(vector Dir);		//Spawn tracing effects

function TraceProcess( actor A, vector HitLocation, vector HitNormal, byte Mode)
{
	if( A!=None )
	{
		if( A==Level )
			Spawn(HitMark,,,HitLocation+HitNormal*8,Rotator(HitNormal));
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
	if (Bot(WeaponController) != None && WeaponController.bFire + WeaponController.bAltFire > 0 && 
		WeaponController.Enemy == None && (!WeaponController.IsInState('RangedAttack') || !Bot(WeaponController).bComboPaused))
		Bot(WeaponController).StopFiring();
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
	local int Diff,OldY,OldP;
	local byte i, j;
	local VehicleAttachment vat;
	local bool bNeedFiringShaking;

	if (OwnerVehicle == None)
		Return;

	if (!bSkipFiringShaking)
	{
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
				if (!bNeedFiringShaking && FiringShaking[i].StepAmount > 0)
					bNeedFiringShaking = true;
			}
		}
		bSkipFiringShaking = !bNeedFiringShaking;
	}

	if (bInFiringProcess > 0)
	{
		firec -= Delta;

		if (bUseEnergyFX)
			EnergyGather(Delta, bInFiringProcess - 1);

		if (firec <= 0)
		{
			j = bInFiringProcess - 1;
			bInFiringProcess = 0;
			FireTurret(j,True);
			ResetEnergy();
		}	
	}
	else if (WeaponController != None && !bFireRestrict && WeaponController.bFire + WeaponController.bAltFire > 0)
		Timer();

	if (bRotWithOtherWeap && UpdateAttachInfoC < 1.0)
	{
		if (UpdateAttachInfoC >= 0.2)
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
		For (j = 0; j < ArrayCount(PassWPosOffset); j++)
			PassWPosOffset[j] = OwnerVehicle.GetPassengerWOffset(j);
	}

	if (!bFireInit)
	{
		bFireInit = True;
		FireFXCounter = 0;
	}
	//if (OwnerVehicle.AttachmentList==Self)
	if (bMasterPart && OwnerVehicle != None)
		OwnerVehicle.AttachmentsTick(Delta);
	if (Level.NetMode==NM_Client /* || Level.NetMode==NM_DedicatedServer */)
		OwnerVehicle.UpdateAttachment(self, Delta);
	if (bDriverWeapon && WeaponController != OwnerVehicle.Driver)
		WeaponController = OwnerVehicle.Driver;
	if (Level.NetMode!=NM_DedicatedServer && !bInvisGun)
	{
		if (OwnerVehicle.OverlayMat != None)
		{
			if (OverlayMActor == None)
				OverlayMActor = Spawn(Class'MatOverlayFX', Self);
			OverlayMActor.Texture = OwnerVehicle.OverlayMat;
			if (OwnerVehicle.OverlayTime >= 1)
				OverlayMActor.ScaleGlow = 1;
			else
				OverlayMActor.ScaleGlow = OwnerVehicle.OverlayTime/1;
			OverlayMActor.AmbientGlow = OverlayMActor.ScaleGlow * 255;
		}
		else if (OverlayMActor != None)
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
	GetTurretCoords(Po, Ro, PRo);
	if (PitchPart != None && PitchPart.Rotation != PRo)
	{
		//PitchPart.SetLocation(Po+(PitchActorOffset >> Ro));
		PitchPart.SetRotation(PRo);
	}
	//Move(Po-Location);
	if (Rotation != Ro)
		SetRotation(Ro);
	/*if (Level.NetMode == NM_Client)
	{
		if (FireFXCounter > 0)
		{
			FireFXCounter = 0;
			MakeFireFX();
		}
	}*/
	
	SetTurretYaw();

	if (WeaponController == None)
	{
		bRotatingBarrel = False;
		AmbientSound = Default.AmbientSound;
		Return;
	}
	if (Level.NetMode != NM_Client || (WeaponController != None && IsNetOwner(WeaponController)))
	{
		if (PlayerPawn(WeaponController) == None)
			Ro = GetBotInput(Delta);
		else
			Ro = GetDriverInput(Delta);
	}
	else if (RepAimPos == vect(0,0,0))
		Ro = OwnerVehicle.Rotation;
	else
		Ro = rotator(RepAimPos - Po);
	
	Ro = Normalize(Ro);
	//Ro.Roll = 0;

	OldAimRotation = Ro;
	
	if (OwnerVehicle.bSlopedPhys && OwnerVehicle.GVT!=None)
		RAdj = Normalize(TransformForGroundRot(Ro.Yaw,OwnerVehicle.GVTNormal,Ro.Pitch,true));
	else
		RAdj = Normalize(TransformForGroundRot(Ro.Yaw,OwnerVehicle.FloorNormal,Ro.Pitch,true));
	if( RAdj!=Ro )
		Ro = RAdj;

	if (!bLimitPitchByCarTop || (bLimitPitchByCarTop && 
		(vector(Rotation) dot vector(OwnerVehicle.Rotation)) < CarTopRange))
	{
		if (Ro.Pitch < PitchRange.Min)
			Ro.Pitch = PitchRange.Min;
		else if (Ro.Pitch > PitchRange.Max)
			Ro.Pitch = PitchRange.Max;
	}
	else
	{
		if (Ro.Pitch < CarTopAllowedPitch.Min)
			Ro.Pitch = CarTopAllowedPitch.Min;
		else if (Ro.Pitch > CarTopAllowedPitch.Max)
			Ro.Pitch = CarTopAllowedPitch.Max;
	}

	OldY = TurretYaw;
	OldP = TurretPitch;
	TurretYaw = CalcTurnSpeed(RotatingSpeed*Delta, TurretYaw, Ro.Yaw);
	TurretPitch = CalcTurnSpeed(RotatingSpeed*Delta, TurretPitch, Ro.Pitch);
	
	bRotatingBarrel = (OldY != TurretYaw || OldP != TurretPitch);
	if (BarrelTurnSound == None /*|| Level.NetMode==NM_ListenServer || Level.NetMode==NM_DedicatedServer */)
		Return;
	if (!bRotatingBarrel)
		AmbientSound = Default.AmbientSound;
	else
		AmbientSound = BarrelTurnSound;
}
simulated function GetTurretCoords( optional out vector Pos, optional out rotator TurRot, optional out rotator PitchPartRot )
{
	if (PassengerNum == 0)
		Pos = OwnerVehicle.Location + (TurretOffset >> OwnerVehicle.Rotation);
	//else Pos = OwnerVehicle.GetPassengerWOffset(PassengerNum-1);
	else
		Pos = OwnerVehicle.Location + (PassWPosOffset[PassengerNum-1] >> OwnerVehicle.Rotation);
	if (PitchPart != None)
	{
		if (OwnerVehicle.bSlopedPhys && OwnerVehicle.GVT != None)
		{
			TurRot = TransformForGroundRot(TurretYaw, OwnerVehicle.GVTNormal);
			PitchPartRot = PitchPart.TransformForGroundRot(TurretYaw, OwnerVehicle.GVTNormal, TurretPitch);
		}
		else
		{
			TurRot = TransformForGroundRot(TurretYaw,OwnerVehicle.FloorNormal);
			PitchPartRot = PitchPart.TransformForGroundRot(TurretYaw, OwnerVehicle.FloorNormal, TurretPitch);
		}
	}
	else if (OwnerVehicle.bSlopedPhys && OwnerVehicle.GVT != None)
	{
		TurRot = TransformForGroundRot(TurretYaw, OwnerVehicle.GVTNormal, TurretPitch);
	}
	else
	{
		TurRot = TransformForGroundRot(TurretYaw, OwnerVehicle.FloorNormal, TurretPitch);
	}
}

simulated function SetTurretYaw()
{
	if (!bRotWithOtherWeap || WAtt == None || WeaponController != None)
	{
		if (bYawFromContr)
		{
			bYawFromContr = false;
			OlVehYaw = OwnerVehicle.VehicleYaw;
		}
		else if (OlVehYaw != OwnerVehicle.VehicleYaw)
		{
			TurretYaw += OwnerVehicle.VehicleYaw - OlVehYaw;
			OlVehYaw = OwnerVehicle.VehicleYaw;
		}
	}
	else
	{
		if (!bYawFromContr)
		{
			bYawFromContr = true;
			OlVehYaw = WAtt.TurretYaw;
		}
		else if (OlVehYaw != WAtt.TurretYaw)
		{
			TurretYaw += WAtt.TurretYaw - OlVehYaw;			
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
	Return GetAimForPos(RepAimPos);
}
simulated function rotator GetAimForPos(vector Pos)
{
	local vector offset, Aim;
	local rotator ret;
	Aim.z = ZAimOffset;
	Offset = Aim >> OwnerVehicle.Rotation;
	ret = rotator(Pos - (Location + offset));
	if (PitchPart != None)
	{
		Aim = PitchActorOffset;
		Aim.Z = ZAimOffset;
		Offset = Aim >> OwnerVehicle.Rotation;
		ret.pitch = rotator(Pos - (Location + Offset)).pitch;
	}
	Return ret;
}
function vector CorrectAim(vector AimPoint, float CollisionHeight)
{
	local vector Loc, Dir, NewAimPoint;
	if (CollisionHeight > 2)
	{
		if (PitchPart != None)
			Loc = PitchPart.Location;
		else
			Loc = Location;
		Dir = AimPoint - Loc;
		if (Dir.Z > 0 && rotator(Dir).Pitch > 300) {
			NewAimPoint = AimPoint;
			NewAimPoint.Z += CollisionHeight;
			if (FastTrace(NewAimPoint, Loc))
				AimPoint = NewAimPoint;
		}
	}
	return AimPoint;
}
function rotator GetBotInput( float Delta )
{
	local vector HL, HN, S;
	if( !WeaponController.IsInState('GameEnded') && 
		!Level.Game.bGameEnded &&
		!SeeEnemy(WeaponController.Target) &&
		!SeeEnemy(WeaponController.Enemy) &&
		!SeeEnemy(WeaponController.FaceTarget) )
	{
		if (FindEnemy() && WeaponController.Target != None)
			RepAimPos = CorrectAim(WeaponController.Target.Location, WeaponController.Target.CollisionHeight);
		else if (WeaponController.MoveTarget != None && Pawn(WeaponController.MoveTarget) == None && 
			Vsize(WeaponController.Focus - WeaponController.MoveTarget.Location) < 10)
			RepAimPos = OwnerVehicle.MoveDest;
		else if (PassengerNum > 0 && OwnerVehicle.Driver != None && WeaponController.MoveTarget == None &&
			Vsize(WeaponController.Focus - WeaponController.Destination) < 10)
			RepAimPos = OwnerVehicle.MoveDest;
		else if (WeaponController.MoveTarget == None && 
			Vsize(WeaponController.Focus - WeaponController.Destination) < 10)
			RepAimPos = OwnerVehicle.MoveDest;
		else		
			RepAimPos = WeaponController.Focus;
	}
	if (Level.Game.bTeamGame && WeaponController.MoveTarget != None && 
		(WeaponController.bFire > 0 || WeaponController.bAltFire > 0) &&
		VSize(RepAimPos - WeaponController.MoveTarget.Location) < 10 && 
		Pawn(WeaponController.MoveTarget) != None && Pawn(WeaponController.MoveTarget).PlayerReplicationInfo != None &&
		Pawn(WeaponController.MoveTarget).PlayerReplicationInfo.Team == WeaponController.PlayerReplicationInfo.Team)
		WeaponController.StopFiring();
	if (RepAimPos == OwnerVehicle.MoveDest)
	{
		if ((WeaponController.bFire > 0 || WeaponController.bAltFire > 0) &&
			!WeaponController.IsInState('RangedAttack'))
			WeaponController.StopFiring();
		if (VSize(Location - RepAimPos) < 2000)
			RepAimPos = GetLastVisiblePathPoint();
		if (OwnerVehicle.bCanFly)
		{
			S = RepAimPos;
			S.Z -= OwnerVehicle.CollisionHeight*OwnerVehicle.VehicleAI.AirFlyScale;
			if (OwnerVehicle.Trace(HL, HN, S, RepAimPos) != None)
				HL.Z += OwnerVehicle.Driver.CollisionHeight;
			else
				HL = S;
			RepAimPos.Z = HL.Z;
		}
	}
	Return GetAimForPos(RepAimPos);
}
function vector GetLastVisiblePathPoint()
{
	local int i;
	for (i = ArrayCount(WeaponController.RouteCache) - 1; i >= 0; i--)
		if (WeaponController.RouteCache[i] != None && 
			FastTrace(WeaponController.RouteCache[i].Location))
			return WeaponController.RouteCache[i].Location;
	return RepAimPos;
}
function Actor TraceHit(Bot Bot, Actor A, out vector HL, out vector HN)
{
	HL = A.Location;
	if (PitchPart != None)
		HN = PitchPart.Location;
	else
		HN = Location;
	if (!Bot.FastTrace(HL, HN)) return Level;
	return OwnerVehicle.Trace(HL, HN, HL, HN, true);
}
function bool IsVisible(Pawn Who, Pawn ForWho) {
	local int i;
	if (DriverWeapon(Who.Weapon) != None)
		return true;
	// from APawn::LineOfSightTo
	i = Min(5000, 5000*(16.0 + Who.Visibility)*0.015);	
	return i == 5000 || VSize(Who.Location - ForWho.Location) <= i;
}
function bool FindEnemy()
{
	local Pawn P;
	local Bot Bot;
	local float Dist, BestDist, BestVehDist[2];
	local Actor Hit, Best, BestVeh[2];
	local vector HL, HN, Extent;
	local name BotState;
	local Vehicle Veh;
	local int i;
	
	Bot = Bot(WeaponController);
	if (Bot == None || NextTimeRangedAttack > Level.TimeSeconds)
		return false;
	if (Bot.Enemy != None) {
		// from APawn::LineOfSightTo
		i = Min(5000, 5000*(16.0 + Bot.Enemy.Visibility)*0.015);
		if (VSize(Bot.Enemy.Location - Bot.Location) <= i)
			return false; // let's engine handle this
		if (i == 5000 || DriverWeapon(Bot.Enemy.Weapon) != None) {
			Hit = TraceHit(Bot, Bot.Enemy, HL, HN);
			if (Hit != Level && (Hit == Bot.Enemy || 
				(DriverWeapon(Bot.Enemy.Weapon) != None && DriverWeapon(Bot.Enemy.Weapon).VehicleOwner == Hit)))
				Best = Bot.Enemy;
		}
	}
	BotState = Bot.GetStateName();
	if (BotState == 'RangedAttack' || BotState == 'FallingState' || BotState == 'TakeHit' || BotState == 'ImpactJumping')
		return false;
	if (Best == None && OwnerVehicle.FastTrace(OwnerVehicle.MoveDest, OwnerVehicle.Location))
	{
		Extent.X = OwnerVehicle.CollisionRadius;
		Extent.Y = Extent.X;
		Extent.Z = OwnerVehicle.CollisionHeight;
		foreach OwnerVehicle.TraceActors(class'Vehicle', Veh, HL, HN, OwnerVehicle.MoveDest, OwnerVehicle.Location, Extent)
			// Other can be LevelInfo in v436
			if (Veh.IsA('Vehicle') && Veh != OwnerVehicle && Veh.HealthTooLowFor(Bot) && 
				Veh.Driver == None && !Veh.HasPassengers() && 
				!(Level.TimeSeconds - Veh.LastFix <= 5 && OwnerVehicle.CurrentTeam == Veh.CurrentTeam))
			{
				Best = Veh;
				break;
			}
	}		
	if (Best == None)
		for( P=Level.PawnList; P!=None; P=P.NextPawn )
		{
			if (P.Health <= 0 || FlockPawn(P) != None || FlockMasterPawn(P) != None || 
				(P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.bIsSpectator) ||
				Bot.AttitudeTo(P) > ATTITUDE_Frenzy || !IsVisible(P, Bot))
				continue; // check not spectator and other stuff
			Hit = TraceHit(Bot, P, HL, HN);
			if (Hit == Level)
				continue;
			if (Hit != P && (DriverWeapon(P.Weapon) == None || DriverWeapon(P.Weapon).VehicleOwner != Hit))
				continue;
			HL = P.Location - OwnerVehicle.Location;
			// X dot X == VSize(X)*VSize(X)
			Dist = HL dot HL;
			if (Best == None || Dist < BestDist)
			{
				Best = P;
				BestDist = Dist;
			}
		}
	if (Best == None && Bot.PlayerReplicationInfo != None)
		Best = AttackVehicle(self, Bot, 80000);
	if (Best == None)
		return false;
//	Log(Bot @ "FindEnemy" @ Best @ BestDist @ Hit @ Bot.GetStateName() @ Bot.NextState @ Bot.NextLabel);
//	log(Bot @ self @ BotState @ Bot.NextState @ Bot.NextLabel);
	NextTimeRangedAttack = Level.TimeSeconds + RangedAttack(Bot, Best, 1.0) + 0.1; // pause for allow do some pathing
	return true;
}
static function float RangedAttack(Bot Bot, Actor Target, float SpecialPause)
{
	Bot.Target = Target;
	Bot.bComboPaused = true;
	Bot.SpecialPause = SpecialPause; // calculate exact time for shoot
	Bot.MoveTimer = -1f; // time refresh path
	Bot.NextState = Bot.GetStateName();
	Bot.NextLabel = 'Begin';
	Bot.GotoState('RangedAttack');
	return SpecialPause;
}
static function Vehicle AttackVehicle(WeaponAttachment Weap, Bot Bot, float MaxDistance)
{
	local Vehicle Veh, BestVeh[2];
	local float Dist, BestDist, BestVehDist[2];
	local int i, VehTeam;
	local vector HL, HN;
	
	foreach Bot.RadiusActors(class'Vehicle', Veh, MaxDistance)
		if (Weap == None || Veh != Weap.OwnerVehicle)
		{
			if (Veh.CurrentTeam == Bot.PlayerReplicationInfo.Team && 
				(Veh.Driver != None || Veh.bHasPassengers || Veh.Level.TimeSeconds - Veh.LastFix > 15))
				continue;
			VehTeam = Veh.CurrentTeam;
			if (Veh.MyFactory != None)
				VehTeam = Veh.MyFactory.TeamNum;
			if (VehTeam != Bot.PlayerReplicationInfo.Team && !Veh.HealthTooLowFor(None))
				i = 0;
			else if (VehTeam == Bot.PlayerReplicationInfo.Team && Veh.HealthTooLowFor(None))
				i = 1;
			else
				continue;
			if (Weap != None)
			{
				if (Veh != Weap.TraceHit(Bot, Veh, HL, HN))
					continue;
			}
			else
			{
				if (!Bot.FastTrace(Veh.Location) || 
					Veh != Bot.Trace(HL, HN, Veh.Location, Bot.Location, true))
					continue;
			}
			HL = Veh.Location - Bot.Location;
			// X dot X == VSize(X)*VSize(X)
			Dist = HL dot HL;
			if (BestVeh[i] == None || Dist < BestVehDist[i])
			{
				BestVeh[i] = Veh;
				BestVehDist[i] = Dist;
			}
		}
	if (BestVeh[0] != None)
		return BestVeh[0];
	else
		return BestVeh[1];
}

function Actor GetVehicle(Actor Sender)
{
	if (Pawn(Sender) != None && DriverWeapon(Pawn(Sender).Weapon) != None)
		return DriverWeapon(Pawn(Sender).Weapon).VehicleOwner;
	return Sender;
}

function bool CorrectPos(out vector EnemyLocation, vector FireLocation, int Z)
{
	local vector Shift;
	Shift.Z = Z;
	if (!FastTrace(EnemyLocation + Shift, FireLocation))
		return false;
	EnemyLocation += Shift;
	return true;
}

function bool SeeEnemy(Actor Enemy)
{
	local vector P, Dir, EnemyLocation, FireLocation;
	local float VProj, V1, V, SightRadius, BaseEyeHeight;
	local rotator R;
	local bool bFastTrace, bCanSee;
	if (Enemy == None || (Pawn(Enemy) != None && Pawn(Enemy).Health <= 0))
		return false;
	Enemy = GetVehicle(Enemy);
	FireLocation = Location;
	FireLocation.Z += ZAimOffset;
	
	bCanSee = WeaponController.CanSee(Enemy) || WeaponController.LineOfSightTo(Enemy);
	
	if (!bCanSee)
		return false;
	EnemyLocation = Enemy.Location;
	if (!FastTrace(EnemyLocation, FireLocation))
	{
		if (CorrectPos(EnemyLocation, FireLocation, 0.5*Enemy.CollisionHeight) || 
			CorrectPos(EnemyLocation, FireLocation, -0.5*Enemy.CollisionHeight) ||
			CorrectPos(EnemyLocation, FireLocation, 1.0*Enemy.CollisionHeight) ||
			CorrectPos(EnemyLocation, FireLocation, -1.0*Enemy.CollisionHeight))
			; // do nothing, already corrected inside calls
	}
	RepAimPos = EnemyLocation;

	if (bPhysicalGunAimOnly && WeapSettings[0].ProjectileClass != None)
	{
		V = VSize(Enemy.Velocity);
		if (V >= 0.0001)
		{
			if (PitchPart != None)
			{
				P = PitchPart.Location;
				R = PitchPart.Rotation;
			}
			else
			{
				P = Location;
				R = Rotation;
			}
		
			P += (WeapSettings[0].FireStartOffset >> R);
			
			Dir = EnemyLocation - P;
			
			VProj = Fmax(1, WeapSettings[0].ProjectileClass.default.Speed);
			V1 = Normal(Dir) dot Enemy.Velocity;		
			V = VProj*VProj + V1*V1 - V*V; 
			
			if (V > V1*V1)
			{
				RepAimPos += Enemy.Velocity * VSize(Dir)/(Sqrt(V) - V1);
				if ( !FastTrace(RepAimPos))
					RepAimPos = 0.5 * (RepAimPos + EnemyLocation);
			}
		}
	}
	RepAimPos = CorrectAim(RepAimPos, Enemy.CollisionHeight);

	return true;
}

function float GetBaseEyeHeight() {
	return Location.Z + ZAimOffset - OwnerVehicle.Location.Z - OwnerVehicle.CollisionHeight + 
		class'TournamentPlayer'.default.CollisionHeight;
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
simulated function WRenderOverlay( Canvas C )
{
	local vector HL, HN, CamLoc;
	local rotator CamRot;
	local Actor ViewActor;
	local float X, Y;
	local Texture Crossh;
	
	if (OwnerVehicle == None)
		return;
	
	X = ZAimOffset;
	if (PitchPart != None)
	{
		ViewActor = PitchPart;
		X -= PitchActorOffset.Z;
	}	
	else
		ViewActor = self;
	CamLoc = vector(ViewActor.Rotation);
	HN.Z = X;
	HN = ViewActor.Location + (HN >> ViewActor.Rotation);
	HL = HN + CamLoc*40000;
	OwnerVehicle.Trace(HL, HN, HL, HN, true);
	
	C.ViewPort.Actor.PlayerCalcView(ViewActor, CamLoc, CamRot);
	WorldToScreen(HL, C.ViewPort.Actor, CamLoc, CamRot, C.ClipX, C.ClipY, X, Y);

	Crossh = Texture'Botpack.Crosshair6';
	C.SetPos(X - Crossh.USize/2, Y - Crossh.VSize/2);
	C.DrawColor = class'ChallengeHUD'.default.WhiteColor;
	C.Style = ERenderStyle.STY_Translucent;
	C.DrawIcon(Crossh,1.0);
}

defaultproperties
{
	RotatingSpeed=16000.000000
	PitchRange=(Max=10000,Min=-5000)
	WeapSettings(0)=(RefireRate=0.500000,FireSndRange=32,FireSndVolume=20,HitError=0.015000,HitHeavyness=1)
	WeapSettings(1)=(RefireRate=0.500000,FireSndRange=32,FireSndVolume=20,HitError=0.015000,HitHeavyness=1)
	FiringShaking(1)=(ShakeStart=SHK_OnAltFire)
	FiringShaking(2)=(ShakeStart=SHK_DuringFire)
	FiringShaking(3)=(ShakeStart=SHK_DuringAltFire)
	HitMark=Class'Botpack.UT_LightWallHitEffect'
	RemoteRole=ROLE_SimulatedProxy
	bCarriedItem=True
	NetPriority=3.000000
}
