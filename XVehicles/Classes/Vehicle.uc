// Base class of all Vehicle classes. (Created by .:..: 8.1.2008)
//*****************************************************************
// Enhancement and fixing of all vehicles classes by Feralidragon (for single player/practise only, as unlike .:..:, I don't
// plan adding online support to any of these in the near future, sorry :|)
// *Fixes:
//
// *Enhancements:
//
// *Addons:
//
//*****************************************************************

Class Vehicle extends VActor
	Abstract
	Config(XVehicles);

#exec AUDIO IMPORT FILE="Sounds\CarAlarm01.wav" NAME="CarAlarm01" GROUP="Vehicles"
#exec AUDIO IMPORT FILE="Sounds\Hijacked.wav" NAME="Hijacked" GROUP="Vehicles"
#exec AUDIO IMPORT FILE="Sounds\VehicleCollision01.WAV" NAME="VehicleCollision01" GROUP="Impacts"
#exec AUDIO IMPORT FILE="Sounds\VehicleCollision02.WAV" NAME="VehicleCollision02" GROUP="Impacts"
#exec AUDIO IMPORT FILE="Sounds\VehicleCollision03.WAV" NAME="VehicleCollision03" GROUP="Impacts"
#exec AUDIO IMPORT FILE="Sounds\VehicleCollision04.WAV" NAME="VehicleCollision04" GROUP="Impacts"
#exec AUDIO IMPORT FILE="Sounds\VehicleCollision05.WAV" NAME="VehicleCollision05" GROUP="Impacts"
#exec AUDIO IMPORT FILE="Sounds\VehicleCollision06.WAV" NAME="VehicleCollision06" GROUP="Impacts"
#exec AUDIO IMPORT FILE="Sounds\VehicleCollision07.WAV" NAME="VehicleCollision07" GROUP="Impacts"
#exec AUDIO IMPORT FILE="Sounds\VehicleHitBullet01.WAV" NAME="VehicleHitBullet01" GROUP="Impacts"
#exec AUDIO IMPORT FILE="Sounds\VehicleHitBullet02.WAV" NAME="VehicleHitBullet02" GROUP="Impacts"
#exec AUDIO IMPORT FILE="Sounds\VehicleHitBullet03.WAV" NAME="VehicleHitBullet03" GROUP="Impacts"
#exec AUDIO IMPORT FILE="Sounds\VehicleHitBullet04.WAV" NAME="VehicleHitBullet04" GROUP="Impacts"
#exec AUDIO IMPORT FILE="Sounds\VehicleHitBullet05.WAV" NAME="VehicleHitBullet05" GROUP="Impacts"
#exec AUDIO IMPORT FILE="Sounds\VehicleHitBullet06.WAV" NAME="VehicleHitBullet06" GROUP="Impacts"
#exec AUDIO IMPORT FILE="Sounds\VehicleExplosion01.WAV" NAME="VehicleExplosion01" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\VehicleExplosion02.WAV" NAME="VehicleExplosion02" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\VehicleExplosion03.WAV" NAME="VehicleExplosion03" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\VehicleExplosion04.WAV" NAME="VehicleExplosion04" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\VehicleExplosion05.WAV" NAME="VehicleExplosion05" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\VehSecExpl01.WAV" NAME="VehSecExpl01" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\VehSecExpl02.WAV" NAME="VehSecExpl02" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\VehSecExpl03.WAV" NAME="VehSecExpl03" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\VehSecExpl04.WAV" NAME="VehSecExpl04" GROUP="Explosions"
#exec AUDIO IMPORT FILE="Sounds\VehSecExpl05.WAV" NAME="VehSecExpl05" GROUP="Explosions"
#exec Texture Import File=NEWTEX\NO.bmp Name=IconNoEnter MIPS=off FLAGS=2 TEXFLAGS=0 GROUP="HUD"
#exec Texture Import File=NEWTEX\CorrectAim.bmp Name=CrCorrectAim MIPS=off FLAGS=2 TEXFLAGS=0 GROUP="HUD"
#exec Texture Import File=NEWTEX\BorderBoxD.pcx Name=BorderBoxD MIPS=off FLAGS=2 TEXFLAGS=0 GROUP="HUD"
#exec Texture Import File=NEWTEX\HealthBar.pcx Name=HealthBar MIPS=off FLAGS=2 TEXFLAGS=0 GROUP="HUD"
#exec Texture Import File=NEWTEX\TransInvis.bmp Name=TransInvis FLAGS=2 GROUP="Misc"
#exec Texture Import File=NEWTEX\MaskInvis.bmp Name=MaskInvis FLAGS=4 GROUP="Misc"
#exec TEXTURE IMPORT NAME=WreckedVeh FILE=NEWTEX\WreckedVeh.bmp GROUP="Misc" LODSET=2

#exec NEW TRUETYPEFONTFACTORY NAME=VehFont FONTNAME="AddElectricCity" HEIGHT=16

var() float AIRating,VehicleGravityScale,WAccelRate;
var float NextWaterDamageTime;
var() int Health, InitialDamage;
var() class<VAIBehaviour> AIClass;
var() class<DriverWeapon> DriverWeaponClass;
var() bool bTeamLocked,
	bShouldRepVehYaw,
	bFPViewUseRelRot,
	bFPRepYawUpdatesView,
	bStationaryTurret,
	bRenderVehicleOnFP,
	bIsWaterResistant,
	bCanFly;
var() byte CurrentTeam;
var() localized string VehicleName,TranslatorDescription,MsgVehicleDesc;
var() vector ExitOffset,BehinViewViewOffset,InsideViewOffset;
var(Sounds) Sound SpawnSound,StartSound,EndSound,EngineSound,IdleSound,ImpactSounds[8],BulletHitSounds[6];
var(Sounds) bool bEngDynSndPitch;
var(Sounds) byte MinEngPitch, MaxEngPitch;
var() config bool bUseBehindView;
var() texture TeamOverlays[4];
var() bool bDriverWOffset;	//Use BehindView offset settings relative to weapon in driver mode
var() bool bMaster;	//Has good updatable attachments?
var() globalconfig bool bTakeAlwaysDamage;
var() bool bSpecialSPACEKEY;	//Use the Space key to do something else (only for driver)
struct WepInfoType
{
	var() class<WeaponAttachment> WeaponClass;
	var() vector WeaponOffset;
	var() bool bInvisibleGun;
};
var() WepInfoType DriverWeapon;
struct PassengersType
{
	var() class<WeaponAttachment> PassengerWeapon; // The weapon class for this passenger (None if nothing)
	var() bool bPassengerWInvis; // For passenger weapon
	var() vector PassengerWOffset; // For passenger weapon
	var() vector CameraOffset; // Camera origin offset (from weapon offset)!
	var() vector CamBehindviewOffset; // Camera behindview offset
	var() bool bIsAvailable; // Set to true if this passenger slot is useable.
	var() string SeatName;
	var WeaponAttachment PGun;
	var DriverWeapon PHGun;
	var PassengerCameraA PassengerCam;
};
var() PassengersType PassengerSeats[8];
var float BaseEyeHeight[9];
var float SightRadius[ArrayCount(BaseEyeHeight)];
var float EnterTime[ArrayCount(BaseEyeHeight)];
var Pawn PendingChangeProps[ArrayCount(BaseEyeHeight)];

struct OverlayMatDispRep
{
	var Texture MatTexture;
	var byte MatDispTime;
};
var VAIBehaviour VehicleAI;
var DriverWeapon DWeapon;
var Texture OverlayMat;
var float OverlayTime,OverlayResetTime;
var bool bResetOLRep;
var WeaponAttachment DriverGun;

var Vehicle PendingBump;
var bool bReadyToRun;
var vector LastCheckOnGroundLocation;
var float LastCheckOnGroundTime;
var bool bLastCheckOnGroundResult;

// -1 to 1.
var int Turning,Rising,Accel;
var int VehicleYaw;

var int LastPackedMove;
var float LastPackedMoveTime;

// Driving pawn
var Pawn Driver,Passengers[8];

var bool bHasPassengers;

var vector FloorNormal, ActualFloorNormal, GVTNormal, ActualGVTNormal;
var VehicleAttachment AttachmentList; // Vehicle attachment list.
var bool bDriving,bOnGround,bOldOnGround,bCameraOnBehindView,bVehicleBlewUp,bClientBlewUp,bHadADriver;
var BotAttractInv BotAttract;

// Bot info
var bool bHasMoveTarget;
var vector MoveDest;
var float MoveTimer;

// Replication variables
struct VehState
{
	var vector Location;
	var vector Velocity;
	var byte YawLow, YawHigh;
	var float ClientTime;
};
var VehState ServerState;
var int ServerState_Yaw;
var float ServerStateTime;
var DriverCameraActor MyCameraAct;

// Someone else's vehicle: last update's path plus a fading error, so updates don't show as jumps
var vector NetPos, NetVel, NetError, NetAccel;
var vector NetVelError;		// shown velocity minus the server's, fades with NetError
var float NetTime, NetYawRate, NetYawError;
var int NetYaw;
// Own vehicle: how far it is from where the server says it should be
var vector PendingMove, PendingVel;
var float PendingYaw;
var OverlayMatDispRep ReplicOverlayMat;

var float ClientLastTime;
var float ServerLastTime;
// Server's idea of the driver's clock: the driver's time minus ours, from the move that got here quickest
var float ClientClock;
var Pawn ClockDriver;
var bool bNewMove;			// a move came in since the last tick
var int HeldKeys;			// keys before that move, packed and one added, 0 if they didn't change

var SavedMoveXV SavedMoves;
var SavedMoveXV FreeMoves;

var VehicleFactory MyFactory;
var() const EPhysics ReqPPPhysics;

// Full vehicles keys display info, write it in form like this: "Press %MoveForward to accelerate|Press %Fire to Fire weapon"
var(Info) localized string VehicleKeyInfoStr;
var string KeysInfo[16];
var byte NumKeysInfo;
var bool bHasInitKeysInfo,bActorKeysInit;

//New ground special handling
var(SlopedPhys) bool bSlopedPhys;
var(SlopedPhys) vector FrontWide, BackWide;
var(SlopedPhys) float ZRange;
var(SlopedPhys) float MaxObstclHeight;
var() bool bDestroyUpsideDown;
var GVehTrailer GVT;
var bool bDisableTeamSpawn; // replaced by class'VehiclesConfig'.default.bDisableTeamSpawn
var() float WDeAccelRate;
var int OldAccelD, VirtOldAccel;
var(Sounds) sound HornSnd;
var() bool bDriverHorn, bHornPrimaryOnly;
var() float HornTimeInterval;
var float NextHornTime;
var float NextHonkTime;
var int WallHitDir;	//Special variable to fix a little visual physical bug
var vector OldHN;
var float ArcGroundTime;
var vector ArcInitDir[2];

//HUD group
var(HUD) texture DriverCrosshairTex, PassCrosshairTex[8];
var(HUD) color DriverCrossColor, PassCrossColor[8];
var(HUD) float DriverCrossScale, PassCrossScale[8];
var(HUD) ERenderStyle DriverCrossStyle, PassCrossStyle[8];

var vector VeryOldVel[2];	//Velocity recorded from last ticks (0-current tick, 1-last tick, etc)
var bool bHitAPawn;
var float bHitAnActor;
var float NextZoneDmgTime;
var bool bHitASmallerVehicle;

//Armor
struct VArmorType
{
	var() float ArmorLevel;		//1.0 = 100% protection, 0.5 = 50%, etc
	var() name ProtectionType;
};
var(Shielding) VArmorType ArmorType[8];

//Vehicle Lights
var(vehicleLights) bool bUseVehicleLights, bUseSignalLights;
var(VehicleLights) texture LightsOverlayer[9];	//First 8 slots for multitextures, 9th slot for Texture (in the case of envmapped polys)
struct VLights
{
	var() vector VLightOffset;
	var() texture VLightTex;
	var() float VSpriteProj;
	var() float VLightScale;
	var VehicleLightsCor VLC;
};
var(VehicleLights) VLights StopLights[8];
var(VehicleLights) VLights BackwardsLights[8];
enum ESignalLights
{
	SL_None,
	SL_Stop,
	SL_Backwards,
};
var ESignalLights SignalLights;
var ESignalLights SignalLightsRepl;
var bool SignalLightsCreated;
var VehicleLightsOv VLov;
var bool bHeadLightInUse;
var bool bHeadLightInUseRepl;
struct VHeadL
{
	var() bool bHaveSpotLight;
	var() byte HeadLightIntensity;
	var() byte HLightHue, HLightSat;
	var() byte HeadCone, HeadDistance;
	var HeadSpotLight HSpot;
};
struct VHLights
{
	var() vector VLightOffset;
	var() texture VLightTex;
	var() float VSpriteProj;
	var() float VLightScale;
	var VehicleLightsCor VLC;
	var() VHeadL VHeadLight;
};
var(VehicleLights) VHLights HeadLights[8];
var(VehicleLights) sound HeadLightOn, HeadLightOff;
var float HeadLightAccum;

//Specials
struct VSpecials
{
	var() bool bSpecialAct;
	var() string SpecialDesc;
	var bool bSpeOn;
};

var(Specials) VSpecials Specials[8];

//Misc
var() float GroundPower;
var float FallingLenghtZ;
var int FirstHealth;
var() bool bBigVehicle;		//Solves the "too heavy" bug on slopes for big vehicles
var float RefMaxArcSpeed, MinArcSpeed;
var(SlopedPhys) bool bArcMovement;

var(WaterFX) globalconfig bool bHaveGroundWaterFX;
var VehWaterAttach VehFoot;
var(WaterFX) int FootZoneDmgDiv;
var const float RefMaxWaterSpeed;
var float SecCount;
var ZoneInfo FootVehZone[8];

var float LastTeleportTime; // for fix flicker teleport between two locations
var int LastTeleportYaw; // for support teleports with change yaw
var bool bLastTeleport;

var int Reverse;
var float ReverseTime;

var bool bInBump;

var Pawn LastDriver;
var float LastDriverTime;

var bool DoChangeSeat;

var float BotDriverJumpZ;

// Bot progress watchdog
var vector BotCheckPos;
var float BotCheckTime;
var byte BotStrikes;		// checks in a row without progress
var byte BotIdle;			// same, but also counts bots with a reason to wait
var float BotBanTime;		// bots stay out of this vehicle until then

const BotCheckDelay = 2.0;
const BotMinProgress = 250.0;	// net uu from the last place it counted as moving
const BotMaxStrikes = 4;
const BotBanSeconds = 90.0;	// longer than the factory reset, so a wedged vehicle goes home

var float YawRemainder;		// part of a turn that the int yaw has not taken yet

// Moved by script in steps of at most SimStep, so a 20 Hz server and a 165 fps client stay on one path
var bool bScriptMove;		// moved by SimMove, not by native physics
var bool bGroundSim;		// on the ground it keeps to the floor, see GroundMove
var vector PivotShift;		// part of the next move that comes from turning about the rear axle
var vector LastLocation;	// where the last frame started, OldLocation needs native physics
var float NextScrapeTime;
var float SimDelta;			// length of the step in hand
var vector DriveVel;		// speed GroundDrive left it with, anything on top of that came from outside
var bool bDriveVel;

const SimStep = 0.0166667;
const WalkableZ = 0.7;
const NetSettle = 10.0;		// per second, how fast a remote vehicle returns to the server's path
const NormalDone = 0.99999;	// floor normal this close to its target has arrived, ~0.25 degrees

// Visible ride, see UpdateBody. Doesn't touch collision or movement
var vector RideOffset;		// where the ground puts the body, from Location
var vector BodyNormal, BodyNormalRate;
var vector BodyVelocity, BodyAccel;
var float BodyZ, BodyZRate, BodyTargetZ, BodyTargetRate;
var float RideZ;			// lagged RideOffset.Z, it steps when wheels leave or find the ground
var DriverCameraActor GunnerView;	// the local player's view from a passenger seat
var float BodyPitch, BodyPitchRate, BodyRoll, BodyRollRate;
var bool bBodyReady;
var vector BodyLean, BodyLeanRate;	// tilt of a flying craft
var float TurnRate;			// yaw per second now
var float CornerZ[4];		// ground under each corner

// Leaving
var Pawn LastExitPawn;
var float LastExitTime;

var PreventEnter PreventEnter;

enum EDropFlag
{
	DF_None,                // Not drop flag at all.
	DF_Driver,				// Only driver, not passengers.
	DF_All,					// All.
};
var() EDropFlag DropFlag;

var VehicleFlag VehicleFlag;
var() vector VehicleFlagOffset;
var VehicleState VehicleState;
var float VehicleStateNextCheck;

var float WaitForDriver;

var float LastFix;
var() Sound FixSounds[4];

var class<LocalMessagePlus> ClassPureHitSound;

var Decal Shadow;

//Damage FX
struct VDamageGFX
{
	var() bool bHaveThisGFX;
	var() bool bHaveFlames;
	var() vector DmgFXOffset;
	var() byte FXRange;
	var() class<effects> DmgFlamesClass;
	var() class<effects> DmgBlackSmkClass;
	var() class<effects> DmgLightSmkClass;
};

var(DamageFX) bool bDamageFXInWater;
var(DamageFX) VDamageGFX DamageGFX[4];
var(DamageFX) texture WreckedTex;
var(DamageFX) int DestroyedExplDmg;

struct VExplDmgFX
{
	var() bool bHaveThisExplFX;
	var() class<effects> ExplClass;
	var() float ExplSize;
	var() name AttachName;
	var() bool bUseCoordOffset;	//use ExplFXOffSet instead of AttachClass
	var() bool bSymetricalCoordX;	//Eg.: if ExplFXOffSet.X = 3.0, then the expl fx will also spawned on X = -3.0
	var() bool bSymetricalCoordY;
	var() vector ExplFXOffSet;
};

var(DamageFX) VExplDmgFX ExplosionGFX[16];
var(DamageFX) sound RndExplosionSnd[5];
var(DamageFX) sound RndSecExplosionSnd[5];
var(DamageFX) bool UseExplosionSnd1, UseExplosionSnd2;
var(DamageFX) byte RndExploSndVol;
var(DamageFX) float RndExploSndRange;
Var(DamageFX) bool bExplShake;
var(DamageFX) float ExplShakeTime, ExplShakeMag;
var float DmgFXCount;

var(Wrecked) float WreckPartColHeight, WreckPartColRadius;

//Shielding
var(Shielding) bool bEnableShield;
var(Shielding) bool bProtectAgainst;	//If true, shield will 'protect against' ShieldType[], if false, shield will 'protect from everything but' ShieldType[]
var(Shielding) name ShieldType[16];
var(Shielding) float ShieldLevel;

var bool bReplicated;

var Pawn StubPawn; // used only default value

const SmallDrawScale = 0.0001;

replication
{
	// Variables the server should send to the client.
	reliable if (Role == ROLE_Authority)
		Driver, bDriving, Health, bVehicleBlewUp, ReplicOverlayMat, bTeamLocked, CurrentTeam, Passengers,
		bReadyToRun, Specials, DriverGun, ServerState, bHasPassengers, SignalLightsRepl, bHeadLightInUseRepl, // new ones
		bReplicated, VehicleGravityScale;
	reliable if (Role == ROLE_Authority && bNetOwner)
		bCameraOnBehindView, MyCameraAct, WAccelRate;
	// Functions client can call.
	reliable if (Role < ROLE_Authority)
		ServerPerformPackedMove, ServerSetBehindView;
}

function Spawned()
{
	Super.Spawned();
	PlaySound(SpawnSound, SLOT_Misc);
	SpawnStubPawn(self);
	StubPawn = None;
}

static final function Pawn SpawnStubPawn(Actor Caller)
{
	local Pawn TracePawn;
	if (Class'Vehicle'.default.StubPawn == None ||
		Class'Vehicle'.default.StubPawn.Level != Caller.Level)
	{
		TracePawn = Caller.Spawn(Class'FlockPawn');
		TracePawn.Texture = Texture'TransInvis';
		TracePawn.RemoteRole = ROLE_None;
		TracePawn.DrawScale = 0.0001;
		TracePawn.bProjTarget = false;
		TracePawn.SetCollision(false, false, false);
		TracePawn.SetCollisionSize(1, 1);
		// prevent be killed
		TracePawn.Health = 100123456;
		TracePawn.ReducedDamageType = 'All';
		TracePawn.ReducedDamagePct = 1.0;
		Class'Vehicle'.default.StubPawn = TracePawn;
	}
	return Class'Vehicle'.default.StubPawn;
}

function AnalyzeZone(ZoneInfo newZone)
{
	if (newZone != None && newZone.DamagePerSec > 0)
		TakeDamage(FMax(1, newZone.DamagePerSec/FootZoneDmgDiv), None, Location, vect(0, 0, 0), newZone.DamageType);
}

static function float GetAngularSpeed(float LinVel, float Delta, float WRadius)
{
local float rrad;

	rrad = Delta*(LinVel / WRadius);
	return (rrad*32768/pi);
}

function ActivateSpecial( byte SpecialN);	//SpecialN: 7 = Key 9

simulated function SetSignalLights(ESignalLights InSignalLights)
{
	local int i;
	if (bUseSignalLights && SignalLights != InSignalLights && Level.NetMode != NM_DedicatedServer)
	{
		if (!SignalLightsCreated && (Self.IsA('WheeledCarPhys') || Self.IsA('TreadCraftPhys')))
		{
			For (i = 0; i < ArrayCount(StopLights); i++)
			{
				if (StopLights[i].VLightTex != None)
				{
					StopLights[i].VLC = Spawn(Class'VehicleLightsCor', Self);
					StopLights[i].VLC.POffSet = StopLights[i].VLightOffset;
					StopLights[i].VLC.Texture = StopLights[i].VLightTex;
					StopLights[i].VLC.SpriteProjForward = StopLights[i].VSpriteProj;
					StopLights[i].VLC.DrawScale = StopLights[i].VLightScale;
				}
			}
	
			For (i = 0; i < ArrayCount(BackwardsLights); i++)
			{
				if (BackwardsLights[i].VLightTex != None)
				{
					BackwardsLights[i].VLC = Spawn(Class'VehicleLightsCor', Self);
					BackwardsLights[i].VLC.POffSet = BackwardsLights[i].VLightOffset;
					BackwardsLights[i].VLC.Texture = BackwardsLights[i].VLightTex;
					BackwardsLights[i].VLC.SpriteProjForward = BackwardsLights[i].VSpriteProj;
					BackwardsLights[i].VLC.DrawScale = BackwardsLights[i].VLightScale;
				}
			}
			SignalLightsCreated = true;
		}
	
		if (SignalLights == SL_Stop || InSignalLights == SL_Stop)
			for (i = 0; i < ArrayCount(StopLights); i++)
				if (StopLights[i].VLC != None)
					StopLights[i].VLC.bHidden = SignalLights == SL_Stop;
		if (SignalLights == SL_Backwards || InSignalLights == SL_Backwards)
			for (i = 0; i < ArrayCount(BackwardsLights); i++)
				if (BackwardsLights[i].VLC != None)
					BackwardsLights[i].VLC.bHidden = SignalLights == SL_Backwards;
	}
	
	SignalLights = InSignalLights;
	SignalLightsRepl = SignalLights;
}

function SwitchVehicleLights()
{
	if (!bHeadLightInUse && bUseVehicleLights)
		UpdateVehicleLights(true);
	else if (bUseVehicleLights)
		UpdateVehicleLights(false);
}

simulated function UpdateVehicleLights(bool bInHeadLightInUse)
{
	local int i;

	if (bInHeadLightInUse && !bHeadLightInUse)
	{	
		if (HeadLightOn != None && Level.NetMode != NM_Client)
			PlaySound(HeadLightOn);

		if (Level.NetMode != NM_DedicatedServer)
		{
			For (i = 0; i < ArrayCount(LightsOverlayer); i++)
				if (LightsOverlayer[i] != None)
				{
					VLov = Spawn(Class'VehicleLightsOv', Self);
					break;
				}
	
			if (VLov != None)
			{
				if (LightsOverlayer[8] != None)
					VLov.Texture = LightsOverlayer[8];
				else
					VLov.Texture = Texture'TransInvis';
				VLov.Mesh = Mesh;
				VLov.DrawScale = DrawScale;
				
				For (i = 0; i < ArrayCount(MultiSkins); i++)
					if (LightsOverlayer[i] != None)
						VLov.MultiSkins[i] = LightsOverlayer[i];
					else
						VLov.MultiSkins[i] = Texture'TransInvis';
			}
		}

		For (i = 0; i < ArrayCount(HeadLights); i++)
			if (HeadLights[i].VLightTex != None)
			{
				if (Level.NetMode != NM_DedicatedServer)
				{
					HeadLights[i].VLC = Spawn(Class'VehicleLightsCor', Self);
					HeadLights[i].VLC.POffSet = HeadLights[i].VLightOffset;
					HeadLights[i].VLC.Texture = HeadLights[i].VLightTex;
					HeadLights[i].VLC.SpriteProjForward = HeadLights[i].VSpriteProj;
					HeadLights[i].VLC.DrawScale = HeadLights[i].VLightScale;
					HeadLights[i].VLC.bHidden = false;
				}
	
				if (HeadLights[i].VHeadLight.bHaveSpotLight && Level.NetMode != NM_Client)
				{
					HeadLights[i].VHeadLight.HSpot = Spawn(Class'HeadSpotLight', Self);
					HeadLights[i].VHeadLight.HSpot.POffSet = HeadLights[i].VLightOffset;
					HeadLights[i].VHeadLight.HSpot.LightBrightness = HeadLights[i].VHeadLight.HeadLightIntensity;
					HeadLights[i].VHeadLight.HSpot.LightHue = HeadLights[i].VHeadLight.HLightHue;
					HeadLights[i].VHeadLight.HSpot.LightSaturation = HeadLights[i].VHeadLight.HLightSat;
					HeadLights[i].VHeadLight.HSpot.LightCone = HeadLights[i].VHeadLight.HeadCone;
					HeadLights[i].VHeadLight.HSpot.LightRadius = HeadLights[i].VHeadLight.HeadDistance;
				}
			}
	}
	else if (!bInHeadLightInUse && bHeadLightInUse)
	{	
		if (HeadLightOff != None && Level.NetMode != NM_Client)
			PlaySound(HeadLightOff);
		
		if (VLov != None && Level.NetMode != NM_DedicatedServer)
			VLov.Destroy();

		For (i = 0; i < ArrayCount(HeadLights); i++)
		{
			if (HeadLights[i].VLC != None && Level.NetMode != NM_DedicatedServer)
				HeadLights[i].VLC.Destroy();
			
			if (HeadLights[i].VHeadLight.HSpot != None && Level.NetMode != NM_Client)
				HeadLights[i].VHeadLight.HSpot.Destroy();
		}
	}
	
	bHeadLightInUse = bInHeadLightInUse;
	bHeadLightInUseRepl = bInHeadLightInUse;
}

simulated function InitKeysInfo()
{
	local int i,j;
	local string S,Ch,Ks;
	local bool bLoopOK;

	if( !Default.bHasInitKeysInfo )
	{
		Default.bHasInitKeysInfo = True;
		S = VehicleKeyInfoStr;
		While( !bLoopOK )
		{
			i = InStr(S,"|");
			if( i==-1 )
			{
				bLoopOK = True;
				Ch = S;
			}
			else
			{
				Ch = Left(S,i);
				S = Mid(S,i+1);
			}
			i = InStr(Ch,"%");
			if( i!=-1 )
			{
				Ks = Mid(Ch,i+1);
				j = InStr(Ks,"%");
				if( j!=-1 )
					Ks = Left(Ks,j);
				else j = 0;
				Ks = Class'KeyBindObject'.Static.FindKeyBinding(Ks,Self);
				if( Ks=="" )
					Continue;
				Ch = Left(Ch,i)$Ks$Mid(Ch,j+i+2);
				i = InStr(Ch,"%");
				While( i>0 )
				{
					Ks = Mid(Ch,i+1);
					j = InStr(Ks,"%");
					if( j!=-1 )
						Ks = Left(Ks,j);
					else j = 0;
					Ks = Class'KeyBindObject'.Static.FindKeyBinding(Ks,Self);
					Ch = Left(Ch,i)$Ks$Mid(Ch,j+i+2);
					i = InStr(Ch,"%");
				}
			}
			Default.KeysInfo[Default.NumKeysInfo] = Ch;
			if( (++Default.NumKeysInfo)==ArrayCount(KeysInfo) )
				bLoopOK = True;
		}
	}
	bActorKeysInit = True;
	NumKeysInfo = Default.NumKeysInfo;
	For( i=0; i<NumKeysInfo; i++ )
		KeysInfo[i] = Default.KeysInfo[i];
}
simulated function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();
	
	bReplicated = Role == ROLE_Authority;
	
	if (Level.NetMode != NM_Client)
		class'XVehiclesHUD'.static.SpawnHUD(self);

	FirstHealth = Health;
	
	if (Level.NetMode != NM_DedicatedServer && !bSlopedPhys)
		Shadow = Spawn(class'VehicleShadow', self);
		
	BotDriverJumpZ = 1.0;
	
	//*****************************************
	//Ground handling
	//*****************************************
	if (bSlopedPhys)
	{
		GVT = Spawn(Class'GVehTrailer', Self);
		GVT.Texture = Texture;
		GVT.Mesh = Mesh;
		GVT.Skin = Skin;
		GVT.ScaleGlow = ScaleGlow;
		GVT.DrawScale = DrawScale;
		
		For (i=0; i<8; i++)
			GVT.MultiSkins[i] = MultiSkins[i];

		bHidden = True;
		if (Shadow != None)
			Shadow.Destroy();

		FrontWide.Y = Abs(FrontWide.Y);
		FrontWide.X = Abs(FrontWide.X);
		FrontWide.Z = Abs(FrontWide.Z);
		BackWide.Y = Abs(BackWide.Y);
		BackWide.X = -Abs(BackWide.X);
		BackWide.Z = Abs(BackWide.Z);
	}
	//*****************************************
	
	ShowState();
	
	if (Level.NetMode == NM_Client)
		return;

	if (InitialDamage > 0)
		TakeImpactDamage(InitialDamage, None, "InitialDamage", 'InitialDamage');

	if (!bReadyToRun && (Self.IsA('WheeledCarPhys') || Self.IsA('TreadCraftPhys')))
		SetPhysics(PHYS_Falling);

	if (!bHaveGroundWaterFX)
		VehFoot = Spawn(Class'VehWaterAttach',Self);

	/*if( Level.NetMode!=NM_Client ) // fixed above
	{*/
		VehicleYaw = Rotation.Yaw;
		if( VehicleAI==None )
		{
			if( AIClass==None )
				AIClass = Class'VAIBehaviour';
			VehicleAI = Spawn(AIClass);
			if( VehicleAI==None )
			{
				Error("Failed to spawn Vehicle AI");
				Return;
			}
			VehicleAI.VehicleOwner = Self;
		}
		if( DWeapon==None )
		{
			if( DriverWeaponClass==None )
				DriverWeaponClass = Class'DriverWeapon';
			DWeapon = SpawnWeapon(DriverWeaponClass);
		}
		if( DriverGun==None && DriverWeapon.WeaponClass!=None )
		{
			DriverGun = WeaponAttachment(AddAttachment(DriverWeapon.WeaponClass));
			DriverGun.bMasterPart = True;
			if( DriverGun!=None )
			{
				DriverGun.bDriverWeapon = True;
				DriverGun.bInvisGun = DriverWeapon.bInvisibleGun;
				DriverGun.TurretOffset = DriverWeapon.WeaponOffset;
			}
		}
		else if (DriverWeapon.WeaponClass==None && !bMaster)
			AddAttachment(Class'MasterAttach');

		For( i=0; i<ArrayCount(PassengerSeats); i++ )
		{
			if( PassengerSeats[i].bIsAvailable )
			{
				if( PassengerSeats[i].PGun==None && PassengerSeats[i].PassengerWeapon!=None )
				{
					PassengerSeats[i].PGun = WeaponAttachment(AddAttachment(PassengerSeats[i].PassengerWeapon));
					if( PassengerSeats[i].PGun!=None )
					{
						PassengerSeats[i].PGun.SetOwner(None);
						PassengerSeats[i].PGun.bInvisGun = PassengerSeats[i].bPassengerWInvis;
						PassengerSeats[i].PGun.TurretOffset = PassengerSeats[i].PassengerWOffset;
						PassengerSeats[i].PGun.PassengerNum = i+1;
					}
				}
			}
		}
	//}
	
	ClientLastTime = -1;
	ServerLastTime = -1;
	
	SetTimer(0.5, true);
	
	SetPropertyText("ClassPureHitSound", "Class'PureHitSound'");
	if (ClassPureHitSound == None)
		SetPropertyText("ClassPureHitSound", "Class'NN_HitSound'");
		
	if (Level.NetMode < NM_Client) // NM_StandAlone included for demorec support
		ServerPackState(0);
}

function InitInventory(Inventory Inv)
{
	Inv.MaxDesireability = AIRating*100;
	Inv.setCollisionSize(CollisionRadius + 10, Inv.CollisionHeight);
	Inv.PrePivot.Z = Inv.CollisionHeight - CollisionHeight;
	Inv.ItemName = VehicleName;
	// weapon specific
	if (Weapon(Inv) != None)
		Weapon(Inv).AIRating = AIRating;
}

function ChangeBackView()
{
	if (MyCameraAct != None)
		MyCameraAct.ChangeView();
}

function PassengerChangeBackView( byte SeatN)
{
	if (SeatN < ArrayCount(PassengerSeats) && PassengerSeats[SeatN].PassengerCam != None)
		PassengerSeats[SeatN].PassengerCam.ChangeView();
}

simulated function DriverCameraActor GetCam(DriverWeapon Weapon)
{
	local DriverCameraActor ret;
	local int SeatNum;
//	log(self @ Weapon @ Weapon.SeatNumber @ PassengerSeats[Weapon.SeatNumber].PassengerCam @ PassengerSeats[Weapon.SeatNumber].PHGun);	
	if (!Weapon.bPassengerGun)
	{
		if (DWeapon == None)
			DWeapon = Weapon;
		ret = MyCameraAct;
	}
	else if (Weapon.SeatNumber < ArrayCount(PassengerSeats))
	{
		if (PassengerSeats[Weapon.SeatNumber].PHGun == None)
			PassengerSeats[Weapon.SeatNumber].PHGun = Weapon;
		ret = PassengerSeats[Weapon.SeatNumber].PassengerCam;	
	}
	if (ret == None)
	{
		SeatNum = Weapon.SeatNumber;
		if (Weapon.bPassengerGun)
			SeatNum++;
		foreach AllActors(class'DriverCameraActor', ret)
			if (ret.VehicleOwner == self && ret.SeatNum == SeatNum)
				break;
	}
	return ret;
}

function KeepCams()
{
	local int i;

	if (MyCameraAct != None)
		MyCameraAct.KeepView();
		
	for (i = 0; i < 8; i++)
	{
		if (PassengerSeats[i].PassengerCam != None)
			PassengerSeats[i].PassengerCam.KeepView();
	}
}

// Owner pressed fire
function FireWeapon( bool bAltFire )
{
	local int i;

	if( bAltFire )
		i = 1;
	
	if (DriverGun == None && Passengers[0] == None && PassengerSeats[0].PGun != None)
	{
		PassengerSeats[0].PGun.FireTurret(i);
		return;
	}

	if (bDriverHorn && ((bHornPrimaryOnly && !bAltFire) || !bHornPrimaryOnly))
	{
		if( PlayerPawn(Driver)==None || NextHornTime>Level.TimeSeconds )
			return;
		NextHornTime = Level.TimeSeconds+HornTimeInterval;
		if( Instigator!=None )
			MakeNoise(5);
	
		if( HornSnd!=None )
			PlaySound(HornSnd,SLOT_Misc,2,,1600);
	
		return;
	}

	if( DriverGun!=None )
		DriverGun.FireTurret(i);
}

function Honk()
{
	if (NextHonkTime > Level.TimeSeconds)
		return;
	NextHonkTime = Level.TimeSeconds + 2;
	if (Instigator != None)
		MakeNoise(5);

	PlaySound(Sound'Horn', SLOT_Misc, 2, , 3000);
}

// Return normal for acceleration direction.
simulated function vector GetAccelDir(int InTurn, int InRise, int InAccel)
{
	Return vector(Rotation)*InAccel;
}

// Client -> Server, the players movement keys pressed.
simulated function ServerPerformMove(int InRise, int InTurn, int InAccel)
{
	local int i;
	i = InRise*9 + InTurn*3 + InAccel;
	if (i == LastPackedMove && Level.TimeSeconds - LastPackedMoveTime < 0.5)
		return;
	LastPackedMove = i;
	LastPackedMoveTime = Level.TimeSeconds;
	ServerPerformPackedMove(LastPackedMoveTime, Class'XVEnums'.static.IntToE28(i + 13));
}

function ServerPerformPackedMove(float InClientTime, XVEnums.E28 Bits)
{
	// the tick about to run still owes the old keys the time before this move was made
	if (HeldKeys == 0 && PackKeys() != int(Bits))
		HeldKeys = PackKeys() + 1;
	UnpackKeys(int(Bits));

	ClientLastTime = InClientTime;
	ServerLastTime = Level.TimeSeconds;
	bNewMove = true;
}

function int PackKeys()
{
	return (Rising + 1)*9 + (Turning + 1)*3 + Accel + 1;
}

function UnpackKeys(int i)
{
	Accel = (i % 3) - 1;
	i /= 3;
	Turning = (i % 3) - 1;
	i /= 3;
	Rising = (i % 3) - 1;
}

// How long the newest keys have been down by now, on the driver's clock
function float MoveAge()
{
	local float Sample;

	// a move is at least as old as it looks, so the youngest looking one sets the clock
	Sample = ClientLastTime - Level.TimeSeconds;
	if (ClockDriver != Driver || Sample > ClientClock || ClientClock - Sample > 0.5)
	{
		ClientClock = Sample;
		ClockDriver = Driver;
	}
	// keys read in a frame count from the start of that frame
	return Level.TimeSeconds + ClientClock - ClientLastTime + 0.008;
}

simulated function string GetWeaponName(byte Seat)
{
	if (Seat == 0)
		return VehicleName;
	else
		return PassengerSeats[--Seat].SeatName;
}

function DriverWeapon SpawnWeapon(class<DriverWeapon> DriverWeaponClass, optional int Seat, optional Actor Owned)
{
	local DriverWeapon wep;
	
	if (Owned == None)
		Owned = self;
	wep = Spawn(DriverWeaponClass,self);
	if (Owned != self)
		wep.ChangeOwner(Owned);
	if (Seat == 0) // driver
	{
		wep.ItemName = VehicleName;
		wep.SetupWeapon(DriverGun);
	}
	else
	{
		Seat--;
		wep.ItemName = PassengerSeats[Seat].SeatName;
		wep.SetupWeapon(PassengerSeats[Seat].PGun);
		wep.InventoryGroup = Seat + 2;
		wep.Charge = wep.InventoryGroup; // hack for net
		if (wep.ItemName == "")
			wep.ItemName = VehicleName;
	}
	return wep;
}

simulated function vector GetStateOffset()
{
	local vector Offset;
	
	if (DriverWeapon.WeaponClass == None || !bDriverWOffset)
		Offset = vect(0, 0, 1) * CollisionHeight;
	else
	{
		Offset = DriverWeapon.WeaponOffset;
		Offset.Z += DriverWeapon.WeaponClass.default.CollisionHeight;
	}
	return Offset;
}

simulated function bool IsNetOwned()
{
	local int i;
	if (Driver != None && IsNetOwner(Driver))
		return true;

	for (i = 0; i < ArrayCount(Passengers); i++)
		if (Passengers[i] != None && IsNetOwner(Passengers[i]))
			return true;
			
	return false;
}

function ShowFlagOnRoof()
{
	local int i;
	local VehicleFlag Prev;
	local CTFReplicationInfo CTFRI;
	
	for (Prev = VehicleFlag; Prev != None; Prev = Prev.Next)
		Prev.LastCheck = 0;
	
	if (Driver != None)
		CheckFlag(Driver);

	for (i = 0; i < ArrayCount(Passengers); i++)
		if (Passengers[i] != None)
			CheckFlag(Passengers[i]);
			
	if (Level.Game != None && CTFReplicationInfo(Level.Game.GameReplicationInfo) != None)
	{
		CTFRI = CTFReplicationInfo(Level.Game.GameReplicationInfo);
		for (i = 0; i < ArrayCount(CTFRI.FlagList); i++)
			if (IsGoodFlag(CTFRI.FlagList[i]) && 
				CTFRI.FlagList[i].Holder != None &&
				DriverWeapon(CTFRI.FlagList[i].Holder.Weapon) != None &&
				DriverWeapon(CTFRI.FlagList[i].Holder.Weapon).VehicleOwner == self)
				AddFlag(CTFRI.FlagList[i]);
	}
	
	i = 0;
	for (Prev = VehicleFlag; Prev != None; Prev = Prev.Next)
		if (Prev.LastCheck != Level.TimeSeconds)
			Prev.Destroy();
		else
			Prev.Pos = i++;
}

function CheckFlag(Pawn Pawn) {
	if (Pawn.PlayerReplicationInfo != None && 
		IsGoodFlag(Pawn.PlayerReplicationInfo.HasFlag, Pawn))
		AddFlag(Pawn.PlayerReplicationInfo.HasFlag);
}

function bool IsGoodFlag(Decoration Flag, optional Pawn Holder)
{
	return Flag != None && !Flag.IsA('PureFlag') && !Flag.IsA('WarmupFlag') &&
		(Holder == None || CTFFlag(Flag) == None || CTFFlag(Flag).Holder == Holder);
}

function AddFlag(Decoration HasFlag)
{
	local VehicleFlag Prev;
	if (VehicleFlag == None)
		VehicleFlag = Spawn(class'VehicleFlag', self).SetFlag(HasFlag);
	else
	{
		for (Prev = VehicleFlag; Prev != None; Prev = Prev.Next)
			if (Prev.MyFlag == HasFlag)
				break;
			else if (Prev.Next == None)
				Prev.Next = Spawn(class'VehicleFlag', self).SetFlag(HasFlag);
		Prev.SetFlag(HasFlag);
	}
}

simulated function ShowState(optional bool bFromTick)
{
	local bool bUsed;
	
	bUsed = Driver != None || bHasPassengers;
				
	if ((!bFromTick && (bUsed || VehicleFlag != None)) ||
		(VehicleFlag != None && VehicleFlag.LastCheck < Level.TimeSeconds - 1))
		ShowFlagOnRoof();
	
	if (Level.NetMode == NM_DedicatedServer)
	{
		VehicleStateNextCheck = Level.TimeSeconds + 3600;
		return;
	}
	
	if (!bReplicated)
		return;
	
	VehicleStateNextCheck = Level.TimeSeconds + 0.2;
	
	if (class'VehiclesConfig'.default.bHideState)
	{
		if (VehicleState != None)
			VehicleState.Destroy();
		return;
	}
	// show state icon
	
	if (VehicleState == None)
		VehicleState = Spawn(class'VehicleState', self);
	
	VehicleState.SetState(CurrentTeam, bTeamLocked, bUsed);
}

function TryDropFlag(Pawn Other)
{
	if (Other.PlayerReplicationInfo != None && Other.PlayerReplicationInfo.HasFlag != None)
		Other.PlayerReplicationInfo.HasFlag.Drop(vect(0,0,0));
}

function AddShield(Pawn Other)
{
	if (Other.FindInventoryType(Class'DriverShield') == None)
		Other.AddInventory( Other.Spawn(Class'DriverShield', Other));
}

function DriverEnter( Pawn Other, optional int MyPitch, optional int MyYaw )
{
	local rotator R;
	local WeaponAttachment WA;
	bHadADriver = True;
	bTeamLocked = False;
	bHasMoveTarget = False;
	Driver = Other;
	//log("DriverEnter" @ Driver);
	SetOwner(Other);
	Instigator = Other;
	PlaySound(StartSound,SLOT_Misc);
	AmbientSound = EngineSound;
	ChangeCollision(Other, true, 0);
	if (DriverGun != None)
	{
		DriverGun.WeaponController = Other;
		WA = DriverGun;
	}
	else if (Passengers[0] == None && PassengerSeats[0].PGun != None)
	{
		PassengerSeats[0].PGun.WeaponController = Other;
		PassengerSeats[0].PGun.SetOwner(Other);
		WA = PassengerSeats[0].PGun;
	}
	if (MyCameraAct == None)
	{
		R = Rotation;
		R.Roll = 0;
		MyCameraAct = Spawn(Class'DriverCameraActor', Self, , , R);
		MyCameraAct.GunAttachM = DriverGun;
		if (DriverGun == None && DriverWeapon.WeaponClass == None)
			MyCameraAct.GunAttachM = PassengerSeats[0].PGun;
	}
	if (DWeapon == None)
		DWeapon = SpawnWeapon(DriverWeaponClass);
	DWeapon.NotifyNewDriver(Other);
	DWeapon.ChangeOwner(Other);
	SwitchWeapon(Other, DWeapon);
	AddShield(Other);
	if (Other.Inventory != None)
		Other.Inventory.ChangedWeapon();
	if (Other.CarriedDecoration != None)
		Other.DropDecoration();
	if (DropFlag != DF_None)
		TryDropFlag(Other);
	if (PlayerPawn(Other) != None)
	{
		//PlayerPawn(Other).ClientMessage(VehicleName, 'Pickup');
		PlayerPawn(Other).ReceiveLocalizedMessage(class'EnterMessagePlus', 1, None, None, Self);
		if (MyYaw != 0)
			R.Yaw = MyYaw;
		else
			R.Yaw = VehicleYaw;
		R.Pitch = MyPitch;
		PlayerPawn(Other).ClientSetRotation(R);
		PlayerPawn(Other).bBehindView = False;
		PlayerPawn(Other).EndZoom();
		Other.GoToState('PlayerFlying');
	}
	MyCameraAct.SetCamOwner(Other);
	GoToState('VehicleDriving');
	CheckForEmpty();
	ShowState();
	Other.ClearPaths();
	ChangeProps(Other, true, 0, WA);
	BotCheckPos = Location;
	BotCheckTime = Level.TimeSeconds;
	BotStrikes = 0;
	BotIdle = 0;
}

function DebugDump(coerce string Place) {
	Log(Place);
	Driver.ConsoleCommand("WayTo FlagBase");
}

function bool GetCollideActors(Pawn Other)
{
	// AI need CollideActors for ride on top of movers.
	return Other == Driver && PlayerPawn(Other) == None && 
		(Mover(Other.Base) != None || Mover(Base) != None || 
		(Other.MoveTarget != None && Mover(Other.MoveTarget.Base) != None));
}

function ChangeCollision(Pawn Other, bool bInside, int Seat)
{
	Local vector L;
	Local Bot Bot;
	if (bInside)
	{
		Other.DrawScale = SmallDrawScale;
		Other.Visibility = 255;
		if (Other.Weapon == Other.PendingWeapon) // Restore back for enable XVehiclesHUD.HandlePickupQuery blocker.
		{
			if (Seat == 0)
				Other.Weapon = DWeapon;
			else
				Other.Weapon = PassengerSeats[Seat - 1].PHGun;
		}
		Other.SetCollision(GetCollideActors(Other), False, False);
		L = Location;
		L.Z += Other.default.CollisionHeight - CollisionHeight;
		if (PlayerPawn(Other) != None)
			Other.SetCollisionSize(0, 0);
		if (Other.Location != L)
			Other.SetLocation(L);
	}
	else if (!DoChangeSeat)
	{
		Other.DrawScale = Other.default.DrawScale;
		// bCollideActors necessary for collide with movers.
		if (Health > 0)
		{
			Other.Weapon = Other.PendingWeapon; // Need set here for disable XVehiclesHUD.HandlePickupQuery blocker.
			Other.SetCollision(True,False,False); // after move be set to true
		}
		Other.bCollideWorld = True;
		Other.Visibility = Other.default.Visibility;
		Other.SetCollisionSize(Other.default.CollisionRadius, Other.default.CollisionHeight);
		if (Other.Region.Zone == None)
			; // skip
		else if (Other.Region.Zone.bPainZone)
			Other.PainTime = 0.01;
		else if (Other.Region.Zone.bWaterZone)
			Other.PainTime = Other.UnderWaterTime;
	}
	Bot = Bot(Other);
	if (Bot != None)
	{
		if (bInside)
		{
			Bot.FootStep1 = None;
			Bot.FootStep2 = None;
			Bot.FootStep3 = None;
			Bot.JumpSound = None;
			Bot.LandGrunt = None;
			Bot.Land = None;
			Bot.WaterStep = None;
			Bot.bCollideWorld = True; // for paths work
			Bot.SetCollisionSize(Bot.default.CollisionRadius, Bot.default.CollisionHeight);
			if (Bot == Driver) {
				BotDriverJumpZ = Bot.JumpZ;
				Bot.JumpZ = 1;
				Bot.bCanJump = true;
				Bot.bCanSwim = bIsWaterResistant; // not help :(
				Bot.bCanFly = bCanFly;
				Bot.MaxStepHeight = MaxObstclHeight;
			}
		}
		else
		{
			Bot.FootStep1 = Bot.default.FootStep1;
			Bot.FootStep2 = Bot.default.FootStep2;
			Bot.FootStep3 = Bot.default.FootStep3;
			Bot.JumpSound = Bot.default.JumpSound;
			Bot.LandGrunt = Bot.default.LandGrunt;
			Bot.Land = Bot.default.Land;
			Bot.WaterStep = Bot.default.WaterStep;
			if (Bot == Driver) {
				Bot.JumpZ = BotDriverJumpZ;
				Bot.bCanJump = Bot.default.bCanJump;
				Bot.bCanSwim = Bot.default.bCanSwim;
				Bot.bCanFly = Bot.default.bCanFly;
				Bot.MaxStepHeight = Bot.default.MaxStepHeight;
			}
			Bot.PreSetMovement();
		}
	}
}

function ChangeProps(Pawn Other, bool bInside, int Seat, optional WeaponAttachment WA)
{
	Local Bot Bot;
	if (bInside)
	{
		BaseEyeHeight[Seat] = Other.BaseEyeHeight;
		if (WA != None)	
			Other.BaseEyeHeight = WA.GetBaseEyeHeight();
		SightRadius[Seat] = Other.SightRadius;
		Other.SightRadius = 64000;
		EnterTime[Seat] = Level.TimeSeconds;
	}
	else
	{
		Other.BaseEyeHeight = BaseEyeHeight[Seat];
		Other.SightRadius = SightRadius[Seat];
		EnterTime[Seat] = 0;
	}
	Bot = Bot(Other);
	if (Bot != None)
	{
		if (bInside)
		{
			PendingChangeProps[Seat] = Bot;
		}
		else
		{
			PendingChangeProps[Seat] = None;
			// restore network usage
			Bot.NetUpdateFrequency = Bot.default.NetUpdateFrequency;
			Bot.NetPriority = Bot.default.NetPriority;
			
			if (!Bot.bDeleteMe && Bot.Health > 0)
				Bot.WhatToDoNext('', '');
		}
	}
}

function RestartPawn(Pawn Other)
{
    local ENetRole OldRole;
    local PlayerPawn PP;
    local Bot Bot;
    local name OldPlayerReStartState;
    
    if (Other.IsInState('Dying'))
    	return;
    
    // fix UT bug
    Bot = Bot(Other);
    if (Bot != None) 
    {
    	Bot.PreSetMovement(); // for set bCanSwim
    	if (Other.Region.Zone != None && Other.Region.Zone.bWaterZone && Other.bCanSwim)
    		Other.setPhysics(PHYS_Swimming);
    	else
	    	Other.SetPhysics(PHYS_Falling);
	    	
	    if (Bot.NextState == 'RangedAttack')
		{
			Bot.NextState = 'Roaming';
			Bot.NextLabel = 'Begin';
		}
	    if (Bot.PlayerReStartState == 'PlayerWalking')
		    Bot.PlayerReStartState = 'Attacking';
		// preserve old state
		OldPlayerReStartState = Bot.PlayerReStartState;
		Bot.PlayerReStartState = Bot.GetStateName();
		if (Bot.PlayerReStartState == 'RangedAttack')
			Bot.PlayerReStartState = 'Roaming';
	}
    
    Other.ClientRestart();
    if (Bot != None) 
    	Bot.PlayerReStartState = OldPlayerReStartState;
    if (Other.RemoteRole == ROLE_AutonomousProxy)
    {
		PP = PlayerPawn(Other);

		// OldUnreal fix: ClientReStart only runs on the client side if we call this on a dedicated server
		// The server _tries_ to call the function, but ProcessRemoteFunction absorbs the call because RemoteRole==ROLE_AutonomousProxy
		// This horrible hack ensures the server also calls ClientReStart so the client and server sync up
		//
		// Without this fix, the player gets stuck in state CheatFlying and PHYS_Falling when switching from ghost/fly to walk
		// As for tanks it make on server player walk in water;
		if (PP != None && NetConnection(PP.Player) != None)
		{
			OldRole = PP.RemoteRole;
			PP.RemoteRole = ROLE_None;
			PP.ClientRestart();
			PP.RemoteRole = OldRole;
		}
	}
}

function Timer()
{
	local int Seat;
	local float T;
	local Pawn P;
	if (Driver != None || bHasPassengers)
	{
		T = Level.TimeSeconds - 1;
		for (Seat = 0; Seat < ArrayCount(PendingChangeProps); Seat++)
		{
			if (PendingChangeProps[Seat] != None && EnterTime[Seat] != 0 && EnterTime[Seat] <= T &&
				PendingChangeProps[Seat].LightType == LT_None)
			{
				P = PendingChangeProps[Seat];
				PendingChangeProps[Seat] = None;
				// reduce network usage
				P.NetUpdateFrequency = 10;
				//P.NetPriority = 0.5;
			}
		}
	}
}

function Actor GetFlagGoal(Pawn Pawn)
{
	local Actor FlagGoal;
	FlagGoal = FlagBase(Pawn.MoveTarget);
	if (FlagGoal == None)
	{
		FlagGoal = CTFFlag(Pawn.MoveTarget);
		if (FlagGoal != None && CTFFlag(FlagGoal).bHome)
			FlagGoal = CTFFlag(FlagGoal).HomeBase;
	}
	if (Pawn.PlayerReplicationInfo != None && FlagBase(FlagGoal) != None && 
		(FlagBase(FlagGoal).Team == Pawn.PlayerReplicationInfo.Team) ==
		(Pawn.PlayerReplicationInfo.HasFlag == None))
		return None;
	if (FlagGoal == None && (IsImportantMoveTarget(Pawn) || TravelToInventory(Pawn)))
		return Pawn.MoveTarget;
	return FlagGoal;
}

function bool NeedReturnBackAfter(Actor FlagGoal)
{
	return (Inventory(FlagGoal) != None || DropFlag == DF_None || 
		(CTFFlag(FlagGoal) != None && CurrentTeam == CTFFlag(FlagGoal).Team)) &&
		!HealthTooLowFor(Driver);
}

function float GetGoalCollisionRadius(Actor FlagGoal)
{
	if (Inventory(FlagGoal) != None)
		return FlagGoal.CollisionRadius;
	return Class'CTFFlag'.Default.CollisionRadius;
}

// Room for this pawn at Offset from the vehicle? Moves nothing
function bool ExitSpotFree(Pawn P, vector Offset, out vector Spot)
{
	local vector Ex, Start, End, HL, HN, Up;
	local int k;

	Ex.X = P.default.CollisionRadius;
	Ex.Y = Ex.X;
	Ex.Z = P.default.CollisionHeight;
	Up = vect(0,0,1);
	Offset.Z = 0;
	// higher tries are for ground that rises on this side
	for (k = 0; k < 3; k++)
	{
		Start = Location + Up*(45*k);
		End = Start + Offset;
		if (FastTrace(Start, Location) && Trace(HL, HN, End, Start, true, Ex) == None)
		{
			if (Trace(HL, HN, End - Up*300, End, false, Ex) != None)
				End = HL + Up;
			Spot = End;
			return true;
		}
	}
	return false;
}

// Asked side, then all the way around, then the roof
function bool FindExitSpot(Pawn P, vector ExitVect, out vector Spot)
{
	local rotator R, Turn;
	local vector Way;
	local float Reach;
	local int i;

	R.Yaw = VehicleYaw;
	Way = ExitVect;
	Reach = FMax(VSize(ExitVect), CollisionRadius + P.default.CollisionRadius + 12);
	Way.Z = 0;
	if (Way == vect(0,0,0))
		Way = vect(0,1,0);
	Way = Normal(Way)*Reach;
	for (i = 0; i < 16; i++)
	{
		// 0, 180, 90, 270, then the diagonals, then all of it again further out
		Turn.Yaw = (i & 1)*32768 + ((i >> 1) & 1)*16384 + ((i >> 2) & 1)*8192;
		if (ExitSpotFree(P, ((Way*(1.0 + 0.45*(i >> 3))) >> Turn) >> R, Spot))
			return true;
	}
	Spot = Location + vect(0,0,1)*(CollisionHeight + P.default.CollisionHeight + 12);
	return FastTrace(Spot, Location);
}

function ProcessExit(Pawn Pawn, DriverCameraActor Camera)
{
	local Bot Bot;
	local Actor FlagGoal;
	local Vector SmallMove, OrigVelocity;
	
	if (Pawn != None)
	{
		OrigVelocity = Pawn.Velocity;
		Bot = Bot(Pawn);
		if (Bot != None)
		{
			Bot.EnemyDropped = None; // Prevent dumb moves
			FlagGoal = GetFlagGoal(Bot);
			if (FlagGoal != None && NeedReturnBackAfter(FlagGoal) &&
				VSize(FlagGoal.Location - Bot.Location) < 
				(GetGoalCollisionRadius(FlagGoal) + Bot.CollisionRadius))
			{
				if (!Pawn.IsInState('GameEnded') && (Level.Game == None || !Level.Game.bGameEnded))
					Bot.Velocity += Normal(Location - Bot.Location)*Bot.GroundSpeed; // try enter back
				Bot.MoveTarget = self;
				Bot.Destination = Location;
			}
		}
		Pawn.MoveTimer = -1; // time to refresh paths
		if (!Pawn.IsInState('GameEnded') && (Level.Game == None || !Level.Game.bGameEnded) && OrigVelocity != Velocity && Pawn.Base != self)
			Pawn.Velocity += Velocity; // inertial exit
		Pawn.Weapon = Pawn.PendingWeapon;
		Pawn.ChangedWeapon();
		if (Pawn != none)
		{
			if (Pawn.Weapon != None && Pawn.Weapon.Owner != None)
				Pawn.Weapon.BringUp();
			if (PlayerPawn(Pawn) != None && Pawn.bDuck != 0)
				PreventEnter = Spawn(class'PreventEnter', Pawn);
			if (!DoChangeSeat) {
				Pawn.SetCollision(True, True, True);
				// make touch with anything here
				if (Health > 0)
				{
					SmallMove = Normal(Pawn.Location - Location);
					if (Pawn.Move(SmallMove))
						Pawn.Move(-SmallMove);
				}
			}
		}
	}
	if (PlayerPawn(Pawn) != None)
	{
		PlayerPawn(Pawn).ViewTarget = None;
		PlayerPawn(Pawn).EndZoom();
		Pawn.ClientSetLocation(Pawn.Location, Rotation);
	}
	else if (Pawn != None)
		Pawn.SetRotation(rotator(Pawn.Location - Location));
	Camera.SetCamOwner(None);
}

singular function DriverLeft( optional bool bForcedLeave, optional coerce string Reason )
{
	local vector ExitVect, Spot;
	local bool bFree;

	if( Driver!=None )
	{
		if (!Driver.bDeleteMe && !DoChangeSeat)
		{
			// decide first, a refused exit has to leave the driver as seated
			ExitVect = GetExitOffset(Driver);
			if (Bot(Driver) == None && (Normal(Velocity) Dot Normal(ExitVect >> Rotation)) > 0.35 &&
				(Normal(Velocity) Dot Normal((ExitVect + vect(0,-2,0)*ExitVect.Y) >> Rotation)) <= 0.35)
				ExitVect.Y = -ExitVect.Y;
			bFree = FindExitSpot(Driver, ExitVect, Spot);
			if (!bFree && !bForcedLeave)
			{
				if (PlayerPawn(Driver) != None)
					Driver.ClientMessage("No room to get out here.", 'CriticalEvent');
				return;
			}
		}
		PlaySound(EndSound,SLOT_Misc);

		if( Driver.bDeleteMe )
			Driver = None;
		else
		{
//			Log(self @ Level.TimeSeconds @ "DriverLeft" @ Driver @ bForcedLeave @ Reason);
			Driver.DrawScale = Driver.Default.DrawScale;
			if( PlayerPawn(Driver)!=None )
			{
				if (Driver.Health>0 && Driver.IsInState('PlayerFlying'))
					Driver.GoToState('PlayerWalking');
			}
			RestartPawn(Driver);
			ChangeCollision(Driver, false, 0);

			if (DoChangeSeat)
				; // stays aboard, ChangeSeat puts the pawn in its new seat
			else if (!bFree || !Driver.SetLocation(Spot))
				Driver.Move(Location + (ExitVect >> Rotation) - Driver.Location);
			ProcessExit(Driver, MyCameraAct);
			LastDriver = Driver;
			LastDriverTime = Level.TimeSeconds;
			if (!DoChangeSeat)
			{
				LastExitPawn = Driver;
				LastExitTime = Level.TimeSeconds;
			}
		}
	}
	if( DriverGun!=None )
		DriverGun.WeaponController = None;
	else if (Passengers[0] == None && PassengerSeats[0].PGun != None)
	{
		PassengerSeats[0].PGun.WeaponController = None;
		PassengerSeats[0].PGun.SetOwner(None);
	}
	if( DWeapon!=None )
	{
		DWeapon.NotifyDriverLeft(Driver);
		DWeapon.ChangeOwner(Self);
	}
	//log("DriverLeft" @ Driver);
	if (PlayerPawn(Driver) != None)
		WaitForDriver = Level.TimeSeconds + 30;
	else
		WaitForDriver = Level.TimeSeconds + 10;
	if (Driver != None)
	{
		Driver.ClearPaths();
		ChangeProps(Driver, false, 0);
	}
	Driver = None;
	//SetOwner(None); Set to none 1 sec later to avoid unwanted functions errors.
	if (!bDeleteMe && Health > 0)
		CheckForEmpty();
	ShowState();
}
simulated function VehicleAttachment AddAttachment( class<VehicleAttachment> AttachClass )
{
	local VehicleAttachment W;

	W = Spawn(AttachClass,Self);
	if( W==None )
		Return None;
	W.OwnerVehicle = Self;
	if( AttachmentList==None )
		AttachmentList = W;
	else
	{
		W.NextAttachment = AttachmentList;
		AttachmentList = W;
	}
	return W;
}
simulated function Destroyed()
{
	local VehicleAttachment W,NW;
	local int i;
	if (Role != ROLE_Authority && PlayerPawn(Owner) != None && Owner.CollisionRadius != Owner.default.CollisionRadius)
		Owner.SetCollisionSize(Owner.default.CollisionRadius, Owner.CollisionHeight);
	if( Driver!=None )
		DriverLeft(True, "Destroyed");
	For( i=0; i<ArrayCount(Passengers); i++ )
	{
		if( Passengers[i]!=None )
			PassengerLeave(i,True);
		if( PassengerSeats[i].PHGun!=None )
			PassengerSeats[i].PHGun.Destroy();
		if( PassengerSeats[i].PassengerCam!=None )
			PassengerSeats[i].PassengerCam.Destroy();
	}
	if( MyFactory!=None )
		MyFactory.NotifyVehicleDestroyed(self);
	For( W=AttachmentList; W!=None; W=NW )
	{
		NW = W.NextAttachment;
		if( W.bAutoDestroyWithVehicle )
			W.Destroy();
		else W.NotifyVehicleDestroyed();
	}
	if( MyCameraAct!=None )
		MyCameraAct.Destroy();
	if( BotAttract!=None )
	{
		BotAttract.Destroy();
		BotAttract = None;
	}
	if( DWeapon!=None )
		DWeapon.Destroy();
	if (VehicleFlag != None)
		VehicleFlag.Destroy();
	if (VehicleState != None)
		VehicleState.Destroy();
	if (Shadow != None)
		Shadow.Destroy();
	DestroyMoves(FreeMoves);
	DestroyMoves(SavedMoves);
	FreeMoves = None;
	SavedMoves = None;
	Super.Destroyed();
}
simulated function DestroyMoves(SavedMoveXV Move)
{
	local SavedMoveXV Next;
	while (Move != None)
	{
		Next = Move.NextMove;
		Move.Destroy();
		Move = Next;
	}
}

// Client update vehicle pos/rot/vel
simulated function ClientUpdateState(float Delta)
{
	local vector Pos, Vel, Step;
	local float T, Part;
	local int Yaw, Turn;
	local SavedMoveXV CurrentMove;
	local PlayerPawn LocalPlayer;
	local bool bMine;

	if (class'VActor'.Default.StaticPP != None)
		LocalPlayer = class'VActor'.Default.StaticPP.Actor;
	else
		LocalPlayer = FindNetOwner(self);
	bMine = LocalPlayer != None && LocalPlayer == Driver;

	if (ServerState.ClientTime != 0)
	{
		if (ServerState.ClientTime > 0)
		{ // ignore specal init value -1, which need for set VehicleYaw initially
			ServerStateTime = Level.TimeSeconds;
			if (bMine)
				ServerStateTime = ServerState.ClientTime;
		}
		ServerState_Yaw = ServerState.YawLow + (ServerState.YawHigh << 8);
		ServerState.ClientTime = 0;
		ServerState.Velocity /= 15.f;

		if (bMine)
		{
			// replay moves since the server's state, then work the difference off
			Pos = ServerState.Location;
			Vel = ServerState.Velocity;
			Yaw = ServerState_Yaw;
			CurrentMove = SavedMoves;
			while (CurrentMove != None)
			{
				if (CurrentMove.TimeStamp <= ServerStateTime)
				{
					SavedMoves = CurrentMove.NextMove;
					CurrentMove.NextMove = FreeMoves;
					FreeMoves = CurrentMove;
					FreeMoves.Clear();
					CurrentMove = SavedMoves;
				}
				else
				{
					// try real replay can screwed non-linear calls and need hardly rework all physics to stateless
					// replay via simple assumptions
					Vel += CurrentMove.SavedVelocity - CurrentMove.Velocity;
					Yaw += CurrentMove.SavedYaw - CurrentMove.Yaw;
					Pos += CurrentMove.SavedLocation - CurrentMove.Acceleration;
					CurrentMove = CurrentMove.NextMove;
				}
			}
			ServerStateTime = Level.TimeSeconds;
			Step = Pos - Location;
			if (VSize(Step) > SnapDistance(Vel))
			{
				SetLocation(Pos);
				Velocity = Vel;
				VehicleYaw = Yaw;
				PendingMove = vect(0,0,0);
				PendingVel = vect(0,0,0);
				PendingYaw = 0;
			}
			else
			{
				if (bGroundSim && bOnGround)
					Step.Z = 0; // both ends are set down on the same floor
				// states are stamped to a server tick, a small error along the way of travel may just be the clock
				Part = VSize(Vel);
				if (Part > 100)
				{
					T = Step dot Normal(Vel);
					if (Abs(T) < Part*0.06)
						Step -= Normal(Vel)*T*0.75;
				}
				PendingMove = Step;
				PendingVel = Vel - Velocity;
				PendingYaw = (Yaw - VehicleYaw) << 16 >> 16;
			}
		}
		else
		{
			T = Level.TimeSeconds - NetTime;
			if (NetTime > 0 && T > 0.005)
			{
				NetAccel = (ServerState.Velocity - NetVel)/FMax(T, 0.03);
				NetYawRate += (float((ServerState_Yaw - NetYaw) << 16 >> 16)/T - NetYawRate)*0.5;
			}
			NetVelError += NetVel - ServerState.Velocity;
			NetPos = ServerState.Location;
			NetVel = ServerState.Velocity;
			NetYaw = ServerState_Yaw;
			// a crash really does stop it, smooth only so much
			if (VSize(NetVelError) > 500)
				NetVelError = Normal(NetVelError)*500;
			// this frame's travel is still to come, restarting at now loses it on every update
			NetTime = Level.TimeSeconds - Delta;
			NetError = Location - NetPos;
			if (VSize(NetError) > SnapDistance(NetVel))
			{
				NetError = vect(0,0,0);
				NetVelError = vect(0,0,0);
			}
			NetYawError = (VehicleYaw - NetYaw) << 16 >> 16;
			if (Abs(NetYawError) > 8192)
				NetYawError = 0;
			Velocity = NetVel;
		}
	}

	if (ServerStateTime == 0)
	{ // demoplay from demo recorded on client
		Velocity = ServerState.Velocity;
		Step = ServerState.Location - Location;
		if ((Step dot Step) > 122500) // 350*350
			SetLocation(ServerState.Location);
		else if ((Step dot Step) > 1)
			MoveSmooth(Step*(1.0 - Exp(-6.3*Delta)));
		if (bScriptMove)
			Move(Velocity*Delta); // nothing else moves it now
		if (bShouldRepVehYaw)
			VehicleYaw = ServerState.YawLow + (ServerState.YawHigh << 8);
	}
	else if (bMine)
	{
		Part = 1.0 - Exp(-9.0*Delta);
		Step = PendingMove*Part;
		PendingMove -= Step;
		if ((Step dot Step) > 0.0001)
			Move(Step);
		Vel = PendingVel*Part;
		PendingVel -= Vel;
		Velocity += Vel;
		if (bShouldRepVehYaw)
		{
			T = PendingYaw*Part;
			PendingYaw -= T;
			Turn = AddYaw(T);
			if (Turn != 0 && bFPRepYawUpdatesView && !bCameraOnBehindView && Driver != None)
				Driver.ViewRotation.Yaw += Turn;
		}
	}
	else if (NetTime > 0)
	{
		T = FMin(Level.TimeSeconds - NetTime, 0.35);
		// critically damped spring back to the server's path, same at any frame time
		Step = (NetVelError + NetError*NetSettle)*Delta;
		Part = Exp(-NetSettle*Delta);
		NetVelError = (NetVelError - Step*NetSettle)*Part;
		NetError = (NetError + Step)*Part;
		Pos = NetPos + NetVel*T + NetError;
		if (Pos != Location)
			Move(Pos - Location);
		if (bShouldRepVehYaw)
		{
			NetYawError *= Exp(-12.0*Delta);
			VehicleYaw = NetYaw + NetYawRate*FMin(T, 0.2) + NetYawError;
		}
	}
}
// Past this a correction gives up and teleports, grows with speed
simulated function float SnapDistance(vector Speed)
{
	return 350 + VSize(Speed)*0.2;
}

// Server send to client vehicle pos/rot/vel
function ServerPackState(float Delta)
{
	ServerState.Location = Location;
	ServerState.Velocity = Velocity*15.f;
	if (bShouldRepVehYaw)
	{
		ServerState.YawLow = byte(VehicleYaw);
		ServerState.YawHigh = byte(VehicleYaw >> 8);
	}
	ServerState.ClientTime = ClientLastTime;
	if (PlayerPawn(Driver) != None && ClientLastTime >= 0 && ClockDriver == Driver)
		ServerState.ClientTime = Level.TimeSeconds + ClientClock;
	else if (PlayerPawn(Driver) != None && Level.TimeSeconds != ServerLastTime)
		ServerState.ClientTime += Level.TimeSeconds - ServerLastTime;
	else if (ClientLastTime < 0 && PlayerPawn(Driver) == None && Velocity != vect(0,0,0))
		ServerState.ClientTime = 1; // not the initial state: clients predict from arrival
}

// Turn the vehicle without losing the fraction of a unit each tick. Returns the whole units applied.
simulated function int AddYaw(float Change)
{
	local int Whole;
	YawRemainder += Change;
	Whole = YawRemainder;
	YawRemainder -= Whole;
	VehicleYaw += Whole;
	return Whole;
}

simulated function DmgFXGen(byte Mode)
{
	local int i;
	local vector CDmgOffSet;

	if (!bDamageFXInWater && Region.Zone.bWaterZone)
		return;

	DmgFXCount = 0;

	For( i=0; i<4; i++)
	{
		if (DamageGFX[i].bHaveThisGFX)
		{	
			CDmgOffSet = DamageGFX[i].DmgFXOffset;
			CDmgOffSet.X += Rand(DamageGFX[i].FXRange*2) - DamageGFX[i].FXRange;
			CDmgOffSet.Y += Rand(DamageGFX[i].FXRange*2) - DamageGFX[i].FXRange;
	
			if (bSlopedPhys && GVT!=None)
			{
				if (Mode == 0 || Mode == 1)
					Spawn(DamageGFX[i].DmgLightSmkClass,,, Location + GVT.PrePivot + (CDmgOffSet >> Rotation));
				else if (Mode == 2)
					Spawn(DamageGFX[i].DmgBlackSmkClass,,, Location + GVT.PrePivot + (CDmgOffSet >> Rotation));
				else
				{
					Spawn(DamageGFX[i].DmgBlackSmkClass,,, Location + GVT.PrePivot + (CDmgOffSet >> Rotation));
					if (DamageGFX[i].bHaveFlames)
						Spawn(DamageGFX[i].DmgFlamesClass,,, Location + GVT.PrePivot + (CDmgOffSet >> Rotation));
				}
			}
			else
			{
				if (Mode == 0 || Mode == 1)
					Spawn(DamageGFX[i].DmgLightSmkClass,,, Location + (CDmgOffSet >> Rotation));
				else if (Mode == 2)
					Spawn(DamageGFX[i].DmgBlackSmkClass,,, Location + (CDmgOffSet >> Rotation));
				else
				{
					Spawn(DamageGFX[i].DmgBlackSmkClass,,, Location + (CDmgOffSet >> Rotation));
					if (DamageGFX[i].bHaveFlames)
						Spawn(DamageGFX[i].DmgFlamesClass,,, Location + (CDmgOffSet >> Rotation));
				}
			}
		}
	}
}

simulated function AfterTeleport(float YawChange)
{
	VehicleYaw += YawChange;
	if (Driver != None)
		Driver.ViewRotation.Yaw += YawChange;
}

// Main tick
simulated function Tick( float Delta )
{
	local bool bIsNetOwner, bGameEnded, bHere, bSplit;
	local float Left, Step, OldFor;
	local int NewKeys;
	local SavedMoveXV NewMove;

	if (Pawn(Base) != None)
		SetBase(None);
	
	if (bLastTeleport)
	{
		AfterTeleport(Rotation.Yaw - LastTeleportYaw);		
		bLastTeleport = false;
	}
	
	if (!class'VehiclesConfig'.default.bDisableTeamSpawn)
	{
		if (Level.NetMode == NM_Client)
		{
			if (ReplicOverlayMat.MatTexture != None)
			{
				SetOverlayMat(ReplicOverlayMat.MatTexture,float(ReplicOverlayMat.MatDispTime)/25.f);
				ReplicOverlayMat.MatTexture = None;
			}
		}
		else if (bResetOLRep && OverlayResetTime<Level.TimeSeconds)
		{
			bResetOLRep = False;
			ReplicOverlayMat.MatTexture = None;
			ReplicOverlayMat.MatDispTime = 0;
		}
		if (Level.NetMode != NM_DedicatedServer)
		{
			if (OverlayMat != None)
			{
				if (OverlayMActor == None)
					OverlayMActor = Spawn(Class'MatOverlayFX', Self);
				OverlayMActor.Texture = OverlayMat;
				if (OverlayTime >= 1)
					OverlayMActor.ScaleGlow = 1;
				else OverlayMActor.ScaleGlow = OverlayTime;
				OverlayMActor.AmbientGlow = OverlayMActor.ScaleGlow * 255;
				OverlayTime -= Delta;
				if (OverlayTime <= 0)
					OverlayMat = None;
			}
			else if (OverlayMActor != None)
			{
				OverlayMActor.Destroy();
				OverlayMActor = None;
			}
		}
	}

	if (!bReadyToRun && (IsA('WheeledCarPhys') || IsA('TreadCraftPhys')))
	{
		if (AttachmentList == None)
			AttachmentsTick(Delta);
		return;
	}

	PendingBump = None;
	LastLocation = Location;
	if (bScriptMove && Physics != PHYS_None)
		SetPhysics(PHYS_None);

	VeryOldVel[1] = VeryOldVel[0];
	VeryOldVel[0] = Velocity;

	if (Level.NetMode != NM_DedicatedServer && Health*2 < FirstHealth)
	{
		if (Health*5 < FirstHealth)
		{
			DmgFXCount += Delta;
			if (DmgFXCount > (0.065 + FRand()*0.15))
				DmgFXGen(3);
		}
		else if (Health*4 < FirstHealth)
		{
			DmgFXCount += Delta;
			if (DmgFXCount > (0.1 + FRand()*0.15))
				DmgFXGen(2);
		}
		else if (Health*3 < FirstHealth)
		{
			DmgFXCount += Delta;
			if (DmgFXCount > (0.1 + FRand()*0.15))
				DmgFXGen(1);
		}
		else
		{
			DmgFXCount += Delta;
			if (DmgFXCount > (0.5 + FRand()))
				DmgFXGen(0);
		}
	}

	if (bHitAPawn || bHitASmallerVehicle)
	{
		bHitAPawn = False;
		bHitASmallerVehicle = False;
		Velocity = VeryOldVel[1];
		VeryOldVel[0] = VeryOldVel[1];
	}
	if (bHitAnActor > 0)
	{
		Velocity = VeryOldVel[1] * bHitAnActor;
		VeryOldVel[0] = VeryOldVel[1] * bHitAnActor;
		bHitAnActor = 0;
	}
	
	if (Level.NetMode == NM_Client)
	{		
		if( bVehicleBlewUp )
		{
			if( !bClientBlewUp )
			{
				SpawnExplosionFX();
				bClientBlewUp = True;
			}
			Return;
		}
		
		bIsNetOwner = IsNetOwner(Driver);
		if (bIsNetOwner && SavedMoves != None)
		{
			NewMove = SavedMoves;
			while (NewMove.NextMove != None)
				NewMove = NewMove.NextMove;
		}

		ClientUpdateState(Delta);
		
		if (bIsNetOwner)
		{
			// I'm  a client, so I'll save my moves in case I need to replay them
			// Get a SavedMove actor to store the movement in.
			if (SavedMoves == None)
			{
				SavedMoves = GetFreeMove();
				NewMove = SavedMoves;
			}
			else
			{	
				NewMove.NextMove = GetFreeMove();
				NewMove = NewMove.NextMove;
			}
		}
	}
	
	if (Level.NetMode != NM_DedicatedServer && Level.NetMode != NM_ListenServer && VehicleState != None)
		VehicleState.bHidden = VehicleState.Mass >= Level.TimeSeconds;

	if (Driver != None && !bDeleteMe)
		UpdateDriverPos();
	bGameEnded = (Driver != None && Driver.IsInState('GameEnded')) || (Level.Game != None && Level.Game.bGameEnded);
	if (!bDriving || bGameEnded)
	{
		Turning = 0;
		Rising = 0;
		Accel = 0;
	}
	if (bGameEnded)
	{
		Velocity = vect(0, 0, 0);
		ActualFloorNormal = FloorNormal;
		ActualGVTNormal = GVTNormal;
	}
	else if (Level.NetMode<NM_Client || IsNetOwner(Driver))
	{
		if( Driver==None || ((Driver.bDeleteMe || Driver.Health<=0) && Level.NetMode<NM_Client) )
		{
			if( Level.NetMode<NM_Client )
			{
				if( Driver!=None )
					Driver.DrawScale = Driver.Default.DrawScale;
				if( Driver!=None && Driver.bDeleteMe )
					Driver = None;
				DriverLeft(True, "Tick");
			}
		}
		else if( PlayerPawn(Driver)==None )
			ReadBotInput(Delta);
		else if( NetConnection(PlayerPawn(Driver).Player)==None )
			ReadDriverInput(PlayerPawn(Driver),Delta);
	}

	if (NewMove != None)
	{
		NewMove.TimeStamp = Level.TimeSeconds;
		NewMove.Delta = Delta;
		NewMove.Velocity = Velocity;
		NewMove.Acceleration = Location;
		NewMove.Yaw = VehicleYaw;
		NewMove.Rise = Rising;
		NewMove.Turn = Turning;
		NewMove.Accel = Accel;
	}

	bHere = Level.NetMode < NM_Client || IsNetOwner(Driver);
	if (Level.NetMode == NM_Client && bScriptMove)
		bCollideWorld = bHere; // remote vehicles just follow the server
	Left = Delta;
	if (Level.NetMode != NM_Client && Level.NetMode != NM_Standalone)
	{
		// clocks drift, let the estimate come down slowly
		ClientClock -= 0.005*Delta;
		if (bNewMove)
		{
			OldFor = Delta - MoveAge();
			if (HeldKeys != 0 && OldFor > 0.002 && bDriving && !bGameEnded && bScriptMove)
			{
				// the old keys held until part way through this tick
				bSplit = true;
				NewKeys = PackKeys();
				UnpackKeys(HeldKeys - 1);
			}
		}
		bNewMove = false;
		HeldKeys = 0;
	}
	do
	{
		Step = Left;
		if (bScriptMove && bHere && Step > SimStep*1.25)
			Step = FMax(SimStep, Delta/8); // a long hitch must not cost more time to catch up on
		if (bSplit)
		{
			if (OldFor > 0.002)
			{
				Step = FMin(Step, OldFor);
				OldFor -= Step;
			}
			else
			{
				UnpackKeys(NewKeys);
				bSplit = false;
			}
		}
		Left -= Step;
		SimulateStep(Step, bHere);
	} until (Left <= 0 || bDeleteMe);
	if (bSplit)
		UnpackKeys(NewKeys);
	if (bDeleteMe)
		return;

	if (NewMove != None)
	{
		NewMove.SavedVelocity = Velocity;
		NewMove.SavedYaw = VehicleYaw;
		NewMove.SavedLocation = Location;
	}
	if (Level.NetMode < NM_Client) // NM_StandAlone included for demorec support
		ServerPackState(Delta);
	if (GVT != None)
	{
		if (Level.NetMode != NM_DedicatedServer)
			UpdateBody(Delta);
		else
			GVT.PrePivot = RideOffset; // guns fire from the body, so it has to be where clients see it
	}
	if (GunnerView != None)
	{
		if (GunnerView.bDeleteMe || GunnerView.VehicleOwner != self)
			GunnerView = None;
		else
			GunnerView.UpdateView(0);
	}

	if (bHasPassengers && !bDeleteMe)
		UpdatePassengerPos();
	if (Region.Zone.bWaterZone && !bIsWaterResistant && NextWaterDamageTime<Level.TimeSeconds &&
		Region.Zone.DamagePerSec <= 0)
	{
		NextWaterDamageTime = Level.TimeSeconds+0.25;
		TakeDamage(25,None,Location,vect(0,0,0),'drowned');
	}
	//Further zone support
	if (Region.Zone.bKillZone)
		TakeDamage(Health*3,None,Location,vect(0,0,0),'FuckedUp');
	else if (Region.Zone.DamagePerSec > 0 && NextZoneDmgTime<Level.TimeSeconds)
	{
		NextZoneDmgTime = Level.TimeSeconds + 1;
		TakeDamage(Region.Zone.DamagePerSec,None,Location,vect(0,0,0),Region.Zone.DamageType);
	}

	if (AttachmentList == None)
		AttachmentsTick(Delta);

	if ((VehicleStateNextCheck < Level.TimeSeconds) ||
		(VehicleFlag != None && VehicleFlag.LastCheck < Level.TimeSeconds - 1))
		ShowState(true);

	if (SignalLights != SignalLightsRepl)
		SetSignalLights(SignalLightsRepl);
	if (bHeadLightInUse != bHeadLightInUseRepl)
		UpdateVehicleLights(bHeadLightInUseRepl);

}

// One step of a frame: floor, driver input, then the move
simulated function SimulateStep(float Delta, bool bHere)
{
	local bool bSlopedG;
	local float f, ArcRatio;
	const ArcMovementScale = 2.5;

	SimDelta = Delta;
	bSlopedG = CheckOnGround();
	if (bGroundSim && bHere)
		bSlopedG = bOnGround;

	if (ArcGroundTime > 0)
		ArcGroundTime -= Delta;

	if (Region.Zone.bWaterZone)
		f = 0.35;
	else
		f = 1.0;

	if( ActualFloorNormal!=FloorNormal && (!bArcMovement || (bSlopedG && bArcMovement)))
	{
		if (bArcMovement && !bOldOnGround)
			ArcGroundTime = 0.8;

		if (ArcGroundTime > 0)
			FloorNormal = NormalWeightSum(35*f*Delta, ActualFloorNormal, FloorNormal);
		else
			FloorNormal = NormalWeightSum(6*f*Delta, ActualFloorNormal, FloorNormal);

		if ( (ActualFloorNormal Dot FloorNormal) > NormalDone )
			FloorNormal = ActualFloorNormal;
	}
	//Arc movement physics
	else if (bArcMovement && !bSlopedG && Velocity.Z > Region.Zone.ZoneGravity.Z*ArcMovementScale)
	{
		ArcRatio = Velocity.Z/FMin(-1.0, Region.Zone.ZoneGravity.Z);
		if (ArcRatio < 0.25)
		{
			ArcRatio = FMax(0.0, 0.5*(ArcRatio - 0.1));
			if (bOldOnGround)
			{
				ActualFloorNormal = FloorNormal;
				ActualGVTNormal = GVTNormal;
			}
		}
		else
		{
			ArcRatio = FClamp((Region.Zone.ZoneGravity.Z*ArcMovementScale - Velocity.Z)/
				FMin(-1.0, Region.Zone.ZoneGravity.Z), 0.0, 1.0);
		}
		if (ArcRatio > 0)
			ActualFloorNormal = Normal(ActualFloorNormal*8 + vector(Rotation)*GetMovementDir()*ArcRatio);
		if (ActualFloorNormal == vect(0,0,0))
			ActualFloorNormal = FloorNormal;
		else if (ActualFloorNormal.Z <= 0.1)
		{
			ActualFloorNormal.Z = 0.1;
			ActualFloorNormal = Normal(ActualFloorNormal);
		}
		// X dot X == VSize(X)*VSize(X)
		if (ActualFloorNormal!=FloorNormal && (Velocity dot Velocity) > 0)
		{
			FloorNormal = NormalWeightSum(ArcAmount(Velocity)*f*Delta, ActualFloorNormal, FloorNormal);
			if ( (ActualFloorNormal Dot FloorNormal) > NormalDone )
				FloorNormal = ActualFloorNormal;
		}

		// X dot X == VSize(X)*VSize(X)
		if (bSlopedPhys && (Velocity dot Velocity) > 0)
		{
			if (ArcRatio > 0)
				ActualGVTNormal = Normal(ActualGVTNormal*8 + vector(Rotation)*GetMovementDir()*ArcRatio);
			if (ActualGVTNormal == vect(0,0,0))
				ActualGVTNormal = GVTNormal;
			else if (ActualGVTNormal.Z <= 0.1)
			{
				ActualGVTNormal.Z = 0.1;
				ActualGVTNormal = Normal(ActualGVTNormal);
			}

			if (GVTNormal!=ActualGVTNormal)
			{
				GVTNormal = NormalWeightSum(ArcAmount(Velocity)*f*Delta, ActualGVTNormal, GVTNormal);
				if ( (ActualGVTNormal Dot GVTNormal) > NormalDone )
					GVTNormal = ActualGVTNormal;
			}
		}
	}
	if (bSlopedPhys && bSlopedG && GVTNormal!=ActualGVTNormal && (!bGroundSim || Level.NetMode == NM_DedicatedServer))
	{
		// smoothly change floor if not sloped and on the ground
		if (ArcGroundTime > 0)
			GVTNormal = NormalWeightSum(35*f*Delta, ActualGVTNormal, GVTNormal);
		else
			GVTNormal = NormalWeightSum(14*f*Delta, ActualGVTNormal, GVTNormal);

		if ( (ActualGVTNormal Dot GVTNormal) > NormalDone )
			GVTNormal = ActualGVTNormal;
	}
	bOwnerNoSee = False;
	if (!bGroundSim || !bHere)
		bOnGround = bSlopedG;

	UpdateDriverInput(Delta);

	if (bDeleteMe)
		return;
	if (bScriptMove && bHere)
	{
		if (bGroundSim && bOnGround)
			GroundMove(Delta);
		else
			AirMove(Delta);
	}
	bOldOnGround = bSlopedG;
}

// Not on the floor: keep moving after each hit for the rest of the step
simulated function AirMove(float Delta)
{
	local vector Want, Start, Ex, HL, HN;
	local float Done;
	local Actor A;
	local int i;

	Ex.X = CollisionRadius;
	Ex.Y = CollisionRadius;
	Ex.Z = CollisionHeight;
	bDriveVel = false;
	for (i = 0; i < 3 && Delta > 0.0001; i++)
	{
		Want = Velocity*Delta;
		// X dot X == VSize(X)*VSize(X)
		if ((Want dot Want) < 0.0001)
			return;
		Start = Location;
		Move(Want);
		if (bDeleteMe)
			return;
		Done = ((Location - Start) dot Want)/(Want dot Want);
		if (Done >= 0.995)
			return;
		// same sweep the move failed on, a short trace can miss what it grazes
		A = Trace(HL, HN, Location + Want*(1 - Done) + Normal(Want)*10, Location, true, Ex);
		if (A == None)
			return;
		HitWall(HN, A);
		if (bDeleteMe)
			return;
		Delta *= 1 - Done;
		// landed: the rest of the step goes on along the ground, or the car stands still for a frame
		if (bGroundSim && bOnGround)
		{
			GroundMove(Delta);
			return;
		}
	}
}

// Upward speed from outside the drive that throws it off the ground
simulated function float LaunchSpeed()
{
	return Sqrt(2*10*Abs(Region.Zone.ZoneGravity.Z)*VehicleGravityScale);
}

// Go up and along, then set down on the floor, so only a wall counts as a hit
simulated function GroundMove(float Delta)
{
	local vector Flat, Start, Ex, HL, HN, Up, Lost;
	local float Z0, Len, Done, Part, Reach, Into;
	local Actor A;
	local int i;

	Up = vect(0,0,1);
	Ex.X = CollisionRadius;
	Ex.Y = CollisionRadius;
	Ex.Z = CollisionHeight;
	Z0 = Location.Z;
	Flat = Velocity*Delta + PivotShift;
	Flat.Z = 0;
	PivotShift = vect(0,0,0);
	Len = VSize(Flat);
	Part = 1;
	for (i = 0; i < 3 && (Flat dot Flat) > 0.0001; i++)
	{
		Start = Location;
		Move(Flat + Up*(VSize(Flat)*1.25 + 2));
		if (bDeleteMe)
			return;
		Done = ((Location - Start) dot Flat)/(Flat dot Flat);
		if (Done >= 0.99)
			break;
		Flat *= 1 - Done;
		Part *= 1 - Done;
		// a low ceiling stops the lift, not the car
		Start = Location;
		Move(Flat);
		if (bDeleteMe)
			return;
		Done = ((Location - Start) dot Flat)/(Flat dot Flat);
		if (Done >= 0.99)
			break;
		Flat *= 1 - Done;
		Part *= 1 - Done;
		A = Trace(HL, HN, Location + Normal(Flat)*10, Location, true, Ex);
		if (A == None)
		{
			// running along a wall it touches: the sweep finds nothing, so slide and work the wall out from what was lost
			Start = Location;
			MoveSmooth(Flat);
			if (bDeleteMe)
				return;
			Lost = Flat - (Location - Start);
			Lost.Z = 0;
			if ((Lost dot Lost) > 0.01*(Flat dot Flat))
				GroundHit(-Normal(Lost), Level);
			break;
		}
		if (Pawn(A) != None || Vehicle(A) != None)
			break; // Bump has dealt with it
		if (HN.Z < WalkableZ && StepOver(Flat, Z0))
			break;
		GroundHit(HN, A);
		if (bDeleteMe)
			return;
		Flat = Velocity*Delta*Part;
		Flat.Z = 0;
	}

	// any floor it could have rolled down to keeps it, only a drop lets go
	Reach = Location.Z - Z0 + 6 + FMax(4, Len*1.5);
	A = Trace(HL, HN, Location - Up*Reach, Location, false, Ex);
	if (A != None && HN.Z >= WalkableZ)
	{
		Move(Up*(HL.Z - Location.Z));
		if (HN != ActualFloorNormal)
		{
			// running into a rise costs the speed that went into it, as it always did. A crest costs none
			Lost = Velocity - ActualFloorNormal*(Velocity dot ActualFloorNormal);
			Into = Normal(Lost) dot HN;
			if (Into < -0.01)
				Velocity *= Sqrt(FMax(0, 1.0 - 0.4*Into*Into));
		}
		ActualFloorNormal = HN;
		return;
	}
	bOnGround = false;
	Move(Up*(Z0 + Velocity.Z*Delta - Location.Z));
}

// Up and along, GroundMove sets it down after and the ride hides the height change
simulated function bool StepOver(vector Flat, float Floor)
{
	local vector Start;
	local float Rise;

	// from the floor the move began on, so what it can climb doesn't depend on the frame
	Rise = Floor + MaxObstclHeight*1.05 + 1 - Location.Z;
	if (MaxObstclHeight <= 0 || Rise <= 0)
		return false;
	Start = Location;
	Move(vect(0,0,1)*Rise);
	Move(Flat);
	if (((Location - Start) dot Flat) > 0.5*(Flat dot Flat))
		return true;
	// too high: back down now, or it hangs there for a frame
	SetLocation(Start);
	return false;
}

// Wall hit on the ground: speed along the wall stays, the rest goes
simulated function GroundHit(vector HitNormal, Actor Wall)
{
	local vector N, Old, Way;
	local float Hit, Speed, Along;
	local rotator R;
	local int Turn;

	N = HitNormal;
	N.Z = 0;
	if (N == vect(0,0,0))
		return;
	N = Normal(N);
	Hit = Velocity dot N;
	if (Hit >= 0)
		return;
	Old = Velocity;
	Speed = VSize(Old);
	// a real hit comes off the wall a little, leaning on it doesn't, or it hammers
	if (Hit < -150)
		Velocity -= N*Hit*1.05;
	else
		Velocity -= N*Hit;
	if (Wall != Level && Wall.Brush == None)
		return;
	Along = Normal(Old) dot Normal(Velocity);
	// glancing hit turns the nose along the wall
	R.Yaw = VehicleYaw;
	Way = vector(R);
	Way -= N*(Way dot N);
	if ((Way dot Way) > 0.01)
	{
		// a touch past the wall's line, or it leans on the wall for good
		Way = Normal(Way) + N*0.03;
		Turn = (rotator(Way).Yaw - VehicleYaw) << 16 >> 16;
		if (Abs(Turn) < 14000)
		{
			Turn = AddYaw(FClamp(Turn*5, -15000, 15000)*SimDelta);
			if (Turn != 0 && !bCameraOnBehindView && Driver != None)
				Driver.ViewRotation.Yaw += Turn;
		}
	}
	if (Speed > 500 && Along < -0.2)
		TakeImpactDamage((Speed - 500)/2, None, "GroundHit_1");
	else if (Speed > 600 && Along < 0)
		TakeImpactDamage((Speed - 600)/4, None, "GroundHit_2");
	else if (Speed > 1300 && Along < 0.3)
		TakeImpactDamage((Speed - 1300)/5, None, "GroundHit_3");
	else if (NextScrapeTime < Level.TimeSeconds && -Hit > 120)
	{
		NextScrapeTime = Level.TimeSeconds + 0.4;
		TakeImpactDamage(0, None, "GroundHit_4");
	}
}

// In the air and something got in the way.
simulated function AirContact(vector HitNormal, Actor Wall)
{
	local float Into;

	Into = Velocity dot HitNormal;
	if (HitNormal.Z >= WalkableZ && Into <= 0)
	{
		FellToGround();
		Velocity -= HitNormal*Into;
		ActualFloorNormal = HitNormal;
		bOnGround = true;
		return;
	}
	if (Into < 0)
	{
		GroundHit(HitNormal, Wall);
		Into = Velocity dot HitNormal;
		if (Into < 0)
			Velocity -= HitNormal*Into;
	}
}

// Plane the speed lies in: the four corners where it has them, so a crest turns it over the length of the car
simulated function vector DrivePlane()
{
	if (bSlopedPhys && GVT != None && ActualGVTNormal.Z >= WalkableZ)
		return ActualGVTNormal;
	return ActualFloorNormal;
}

// Ground speed as the original drove it: one speed, aimed where the wheels point. Per second, so the step doesn't matter
simulated function GroundDrive(float Delta, float TopSpeed, float Friction, int SteerYaw, bool bHandbrake)
{
	local vector X, Y, Z, Slope, Flat;
	local rotator R;
	local float F, S, Cur, Brake, Speed, Rate;

	// a blast can throw it, anything less stays on the ground
	if (bDriveVel && ((Velocity - DriveVel) dot ActualFloorNormal) > LaunchSpeed()*1.5)
	{
		bOnGround = false;
		bDriveVel = false;
		return;
	}
	Z = DrivePlane();
	R.Yaw = VehicleYaw + SteerYaw;
	X = vector(R);
	X = Normal(X - Z*(X dot Z));
	Y = Normal(Z cross X);
	// the plane turned under it: the speed turns too, none is lost. A push off the ground isn't speed
	Flat = Velocity - Z*(Velocity dot Z);
	Speed = VSize(Flat);
	if (bDriveVel)
		Speed = FMin(VSize(Velocity), FMax(Speed, VSize(DriveVel)));
	if ((Flat dot Flat) > 0.01)
		Flat = Normal(Flat)*Speed;
	F = Flat dot X;
	S = Flat dot Y;

	if (ActualGVTNormal.Z >= 0.5)
		Slope = CalcGravityStrength(Region.Zone.ZoneGravity*(VehicleGravityScale/GroundPower), ActualGVTNormal);
	else
		Slope = CalcGravityStrength(Region.Zone.ZoneGravity*(VehicleGravityScale/GroundPower), Z);
	Slope /= Friction/8.f + 1.f;
	F += (Slope dot X)*Delta;
	S += (Slope dot Y)*Delta;

	// the original turned its speed to the wheels a frame at a time, this is that at 100 frames a second
	Rate = 100.0*Loge(1.0 + TopSpeed*Friction/10.0/FMax(50.0, Abs(F) + Abs(S)));
	if (bHandbrake)
		Rate *= 0.05;
	Cur = S*Exp(-Rate*Delta);
	// what the slide gives up goes back into the speed, a turn costs none
	if (Abs(F) > Abs(S))
	{
		Brake = Sqrt(F*F + S*S - Cur*Cur);
		if (F < 0)
			F = -Brake;
		else
			F = Brake;
	}
	S = Cur;

	if (Accel != 0 && F*Accel < -16)
	{
		Brake = WDeAccelRate*3*Friction*Delta;
		if (Abs(F) <= Brake)
			F = 0;
		else if (F > 0)
			F -= Brake;
		else
			F += Brake;
		if (SignalLights != SL_Stop)
			SetSignalLights(SL_Stop);
	}
	else if (Accel != 0)
	{
		OldAccelD = Accel;
		Cur = F*Accel;
		// a slide is part of the speed too
		Brake = Sqrt(FMax(0, TopSpeed*TopSpeed - S*S));
		if (Cur < Brake)
			Cur = FMin(Brake, Cur + WAccelRate*Delta);
		else if (Abs(S) < 50)
			Cur += WAccelRate*Delta/100; // a hill gave it this, stays until a climb takes it
		F = Cur*Accel;
		if (Accel < 0)
		{
			if (SignalLights != SL_Backwards)
				SetSignalLights(SL_Backwards);
		}
		else if (SignalLights != SL_None)
			SetSignalLights(SL_None);
	}
	else
	{
		Brake = WDeAccelRate*Friction*Delta;
		if (bHandbrake)
			Brake *= 1.5;
		if (Abs(F) <= Brake)
			F = 0;
		else if (F > 0)
			F -= Brake;
		else
			F += Brake;
		if (SignalLights != SL_None)
			SetSignalLights(SL_None);
	}

	Velocity = X*F + Y*S;
	DriveVel = Velocity;
	bDriveVel = true;
}

// How hard the vehicle is pushed, the body leans against this
simulated function TrackAccel(float Delta, float Rate)
{
	local vector Now;

	if (Delta <= 0)
		return;
	if (Level.NetMode == NM_Client && !IsNetOwner(Driver))
		Now = NetAccel;
	else
		Now = (Velocity - BodyVelocity)/Delta;
	BodyVelocity = Velocity;
	BodyAccel += (Now - BodyAccel)*(1.0 - Exp(-Rate*Delta));
}

// Turn towards a heading, speed builds and fades so it doesn't move like a turret
simulated function FollowYaw(int WantYaw, float MaxRate, float Delta)
{
	local float Want;

	Want = FClamp(((WantYaw - VehicleYaw) << 16 >> 16)*12.0, -MaxRate, MaxRate);
	TurnRate += (Want - TurnRate)*(1.0 - Exp(-22.0*Delta));
	AddYaw(TurnRate*Delta);
}

// Lean towards the push through a spring
simulated function UpdateLean(vector Target, float Delta)
{
	const CraftFreq = 8.0;
	const CraftDamp = 0.65;

	BodyLeanRate += (CraftFreq*CraftFreq*(Target - BodyLean) - 2*CraftDamp*CraftFreq*BodyLeanRate)*Delta;
	BodyLean += BodyLeanRate*Delta;
}

// Body on springs: follows the ground, squats under power, dives under brakes, leans out of corners
simulated function UpdateBody(float Delta)
{
	local vector Y, X, Target, N;
	local rotator R;
	local float Step, W, Long, Lat, Top;
	// dead beat and firm: the original set the body straight on the ground, this only takes the steps out
	const HeaveFreq = 30.0;		// rad/s
	const HeaveDamp = 1.0;
	const TiltFreq = 20.0;
	const TiltDamp = 1.0;
	const LeanFreq = 12.0;
	const LeanDamp = 1.0;

	R.Yaw = VehicleYaw;
	X = vector(R);
	Y = vect(0,0,1) cross X;
	if (!bBodyReady || Abs(Location.Z + RideOffset.Z - BodyZ) > 250)
	{
		bBodyReady = true;
		BodyZ = Location.Z + RideOffset.Z;
		RideZ = RideOffset.Z;
		BodyTargetZ = BodyZ;
		BodyZRate = 0;
		BodyTargetRate = 0;
		BodyNormal = GVTNormal;
		BodyNormalRate = vect(0,0,0);
		BodyVelocity = Velocity;
	}
	if (Delta <= 0)
		return;
	TrackAccel(Delta, 14.0);
	Target.X = GVT.PrePivot.X + (RideOffset.X - GVT.PrePivot.X)*(1.0 - Exp(-20.0*Delta));
	Target.Y = GVT.PrePivot.Y + (RideOffset.Y - GVT.PrePivot.Y)*(1.0 - Exp(-20.0*Delta));
	RideZ += (RideOffset.Z - RideZ)*(1.0 - Exp(-25.0*Delta));
	W = Location.Z + RideZ;
	BodyTargetRate += ((W - BodyTargetZ)/Delta - BodyTargetRate)*(1.0 - Exp(-30.0*Delta));
	BodyTargetZ = W;
	Long = FClamp(BodyAccel dot X, -1500, 1500);
	Lat = FClamp(BodyAccel dot Y, -1500, 1500);
	if (!bOnGround)
	{
		Long = 0;
		Lat = 0;
	}
	Top = 2500.0/FMax(2500, Mass);
	while (Delta > 0)
	{
		Step = FMin(Delta, SimStep);
		Delta -= Step;
		BodyZRate += (HeaveFreq*HeaveFreq*(BodyTargetZ - BodyZ) + 2*HeaveDamp*HeaveFreq*(BodyTargetRate - BodyZRate))*Step;
		BodyZ += BodyZRate*Step;
		BodyPitchRate += (LeanFreq*LeanFreq*(-Long*0.00003*Top - BodyPitch) - 2*LeanDamp*LeanFreq*BodyPitchRate)*Step;
		BodyPitch += BodyPitchRate*Step;
		BodyRollRate += (LeanFreq*LeanFreq*(-Lat*0.00003*Top - BodyRoll) - 2*LeanDamp*LeanFreq*BodyRollRate)*Step;
		BodyRoll += BodyRollRate*Step;
		if (bOnGround)
		{
			BodyNormalRate += (TiltFreq*TiltFreq*(ActualGVTNormal - BodyNormal) - 2*TiltDamp*TiltFreq*BodyNormalRate)*Step;
			BodyNormal += BodyNormalRate*Step;
		}
	}
	if (BodyZ > BodyTargetZ + 32)
		BodyZ = BodyTargetZ + 32;
	else if (BodyZ < BodyTargetZ - 32)
		BodyZ = BodyTargetZ - 32;
	if (bOnGround)
	{
		N = Normal(BodyNormal);
		GVTNormal = Normal(N + X*BodyPitch + Y*BodyRoll);
	}
	else
	{
		BodyNormal = GVTNormal;
		BodyNormalRate = vect(0,0,0);
	}
	Target.Z = BodyZ - Location.Z;
	GVT.PrePivot = Target;
}

simulated function SavedMoveXV GetFreeMove()
{
	local SavedMoveXV s;

	if (FreeMoves == None)
		return Spawn(class'SavedMoveXV', self);
	else
	{
		s = FreeMoves;
		FreeMoves = FreeMoves.NextMove;
		s.NextMove = None;
		return s;
	}
}

simulated function float ArcAmount(vector VelArc)
{
	VelArc.Z = 0;
	return VehicleGravityScale*Abs(Region.Zone.ZoneGravity.Z/950)*RefMaxArcSpeed/FMax(VSize(VelArc),MinArcSpeed*VehicleGravityScale);
}

// Where a gun is this frame, guns move after the camera has run
simulated function vector GunPlace(WeaponAttachment Gun)
{
	if (bSlopedPhys && GVT != None)
		return GVT.PrePivot + Location + (Gun.TurretOffset >> Rotation);
	return Location + (Gun.TurretOffset >> Rotation);
}

simulated function UpdateAttachment(WeaponAttachment vat, float Delta)
{
local vector WPosA;
local rotator WRotA;
local Actor AttachBase;

	AttachBase = vat.Base;
	if (vat.bRotWithOtherWeap && WeaponAttachment(vat.Base) == None && vat.WAtt != None)
		AttachBase = vat.WAtt;
	if (AttachBase == None)
		AttachBase = self;
//	if (Vat.base != AttachBase)
//		Log(self @ vat @ Vat.base @ AttachBase @ vat.bRotWithOtherWeap);

	WPosA = GunPlace(vat);
	//log(self @ vat @ WPosA @ vat.Location @ "|" @ GVT.PrePivot @ Location @ vat.TurretOffset @ Rotation @ "|" @ (vat.TurretOffset >> Rotation));
	if (WPosA != vat.Location && !vat.Move(WPosA - vat.Location))
		vat.SetLocation(WPosA);
	if (Vat.base != AttachBase)
		vat.setBase(AttachBase);

	if (vat.PitchPart != None)
	{
		if (vat.bHasPitchPart)
		{
			if (bSlopedPhys && GVT != None)
				WRotA = vat.TransformForGroundRot(vat.TurretYaw, GVTNormal);
			else
				WRotA = vat.TransformForGroundRot(vat.TurretYaw, FloorNormal);
		}
		else
		{
			if (bSlopedPhys && GVT != None)
				WRotA = vat.TransformForGroundRot(vat.TurretYaw, GVTNormal, vat.TurretPitch);
			else
				WRotA = vat.TransformForGroundRot(vat.TurretYaw, FloorNormal, vat.TurretPitch);
		}
		WPosA += (vat.PitchActorOffset >> WRotA);
		if (WPosA != vat.PitchPart.Location && !vat.PitchPart.Move(WPosA - vat.PitchPart.Location))
			vat.PitchPart.SetLocation(WPosA);
		if (vat.PitchPart.base != AttachBase)
			vat.PitchPart.setBase(AttachBase);
	}
}

simulated function AttachmentsTick( float Delta ) // Update attachment's location here!
{
local VehicleAttachment vat;

	For ( vat=AttachmentList; vat!=None; vat=vat.NextAttachment )
	{
		if (WeaponAttachment(vat)!=None)
			UpdateAttachment(WeaponAttachment(vat), Delta);
	}

	if (VehFoot != None && Location != LastLocation)
	{
		if (bSlopedPhys && GVT!=None)
			VehFoot.SetLocation(Location + GVT.PrePivot);
		else
			VehFoot.SetLocation(Location);

		VehFoot.Move(CollisionHeight*vect(0,0,-1));
	}
/*	
	if (Owner != None)
	{
		DbgRole = Role;
		Role = Role_Authority;
		DbgTmr2 = Float(ConsoleCommand("DbgTmr"));
		Role = DbgRole;
		DbgTmr = DbgTmr2 - DbgTmr;
		Log(self @ (1/DbgTmr) @ (Vsize(Location - OldLocation)/DbgTmr) @ DbgMsg);
		DbgTmr = DbgTmr2;
	}
*/
}

simulated function CheckBase(Actor PossibleBase, optional Actor Ac[4])
{
	local int i, j, score, best, all;
	
	if (PossibleBase == None)
	{
		for (i = 0; i < ArrayCount(Ac); i++)
		{
			if (Ac[i] == None)
				all++;
			if (Mover(Ac[i]) == None)
				continue;
			score = 1;
			for (j = i + 1; j < ArrayCount(Ac); j++)
				if (Ac[j] == Ac[i])
					score++;
			if (PossibleBase != None && score <= best)
				continue;
			PossibleBase = Ac[i];
			best = score;
		}
		if (PossibleBase != None && (all - best) >= best)
			PossibleBase = None;
	}
	if (Base != PossibleBase)
		SetBase(PossibleBase);
}

// Ground under the four corners, places and tilts the body
simulated function SampleCorners()
{
	local vector S, E, sHL[4], sHN[4], Off[4], Range, MLoc, CrossedVect[2], GVTLoc, Foot;
	local actor Ac;
	local int b, Stand;
	local byte bHang[4];
	local float Low, High;

	Off[0] = FrontWide;
	Off[1] = FrontWide;
	Off[1].Y = -FrontWide.Y;
	Off[2] = BackWide;
	Off[3] = BackWide;
	Off[3].Y = -BackWide.Y;
	Range.Z = -Abs(ZRange);
	Range = Range >> Rotation;
	High = Location.Z - CollisionHeight + 6;
	Low = High - 6 - CollisionRadius*0.9;
	for (b = 0; b < 4; b++)
	{
		S = Location + (Off[b] >> Rotation);
		E = S + Range;
		Ac = Trace(sHL[b], sHN[b], E, S, False);
		if (Abs(int(sHL[b].X)) > 900100200.0 || // check if got nan as HitLocation
			Abs(int(sHL[b].Y)) > 900100200.0 || // such can happen if trace start already inside mover
			Abs(int(sHL[b].Z)) > 900100200.0)
			Ac = None;
		if (Ac == None || sHL[b].Z < Low)
		{
			// nothing it could stand on, the wheel hangs
			sHL[b] = E;
			bHang[b] = 1;
			CornerZ[b] = Low;
			continue;
		}
		sHL[b].Z = FMin(sHL[b].Z, High);
		CornerZ[b] = sHL[b].Z;
		Foot += sHL[b];
		Stand++;
	}
	// a hanging corner goes with the floor through the ones that stand: level over an edge, full tilt on a steep slope
	if (Stand > 0)
		Foot /= Stand;
	else
	{
		Foot = Location;
		Foot.Z -= CollisionHeight;
	}
	for (b = 0; b < 4; b++)
		if (bHang[b] != 0)
			sHL[b].Z = Foot.Z - ((sHL[b].X - Foot.X)*ActualFloorNormal.X + (sHL[b].Y - Foot.Y)*ActualFloorNormal.Y)/FMax(0.5, ActualFloorNormal.Z);
	MLoc = (sHL[0] + sHL[1] + sHL[2] + sHL[3]) / 4 -
		(vect(0.5,0,0)*(FrontWide.X + BackWide.X) >> Rotation);
	CrossedVect[0] = Normal(sHL[0] - sHL[3]);
	CrossedVect[1] = Normal(sHL[1] - sHL[2]);
	ActualGVTNormal = Normal(CrossedVect[0] cross CrossedVect[1]);
	if (ActualGVTNormal.Z < 0)
		ActualGVTNormal = -ActualGVTNormal;
	GVTLoc = MLoc - Normal(Range)*CollisionHeight;
	RideOffset = GVTLoc - Location;
	S = ActualGVTNormal;
	S.Z = 0;
	RideOffset.Z = FClamp(RideOffset.Z, -FMax(MaxObstclHeight,
		CollisionRadius*FMin(1.0, VSize(S)/FMax(0.707, S.Z))), 0);
}

// Vehicle is currently on ground?
simulated function bool CheckOnGround()
{
	local vector End,Start,Ex,HL,HN;
	local actor PossibleBase;
	local bool ret;

	if (Location == LastCheckOnGroundLocation &&
		Level.TimeSeconds < LastCheckOnGroundTime + 0.2 && Mover(Base) == None)
		return bLastCheckOnGroundResult;

	Start = Location;
	Start.Z -= CollisionHeight - 1;
	End = Start;
	End.Z -= 6;
	if (Level.NetMode == NM_Client && !bCollideWorld)
		End.Z -= 18; // someone else's vehicle is only near the floor here
	Ex.X = CollisionRadius;
	Ex.Y = Ex.X;

	PossibleBase = Trace(HL, HN, End, Start, False, Ex);
	if (PossibleBase == None)
	{
		if (bGroundSim)
		{
			if (bOnGround && bSlopedPhys && GVT != None)
				SampleCorners();
			else
				RideOffset = vect(0,0,0);
		}
		else if (bLastCheckOnGroundResult)
		{ // No ground - preserve old vehicle rotation in air.
			ActualFloorNormal = NormalWeightSum(0.1, ActualFloorNormal, FloorNormal);
			ActualGVTNormal = NormalWeightSum(0.1, ActualGVTNormal, GVTNormal);
		}
	}
	else
	{
		ActualFloorNormal = HN;
		if (bSlopedPhys && GVT != None)
			SampleCorners();
		ret = ActualFloorNormal.Z >= WalkableZ;
	}
	CheckBase(PossibleBase);
	LastCheckOnGroundLocation = Location;
	LastCheckOnGroundTime = Level.TimeSeconds;
	bLastCheckOnGroundResult = ret;
	return ret;
}

simulated function ResetPhysics(Pawn Other)
{
	local EPhysics Desired;

	if (PlayerPawn(Other) != None)
	{
		Desired = ReqPPPhysics;
		if (Other.IsInState('PlayerWalking'))
			Other.GotoState('PlayerFlying');
	}
	else if (bCanFly)
		Desired = PHYS_Flying;
	else if (SubmarinePhys(self) != None)
		Desired = PHYS_Swimming;
	else
		Desired = PHYS_Walking;
	if (Other.Physics != Desired)
		Other.SetPhysics(Desired);
}

simulated function SwitchWeapon(Pawn Other, Weapon Weap)
{
	if (Other.Weapon == Weap)
		return;
	if ( Other.Weapon != None )
	{
		Other.ClientPutDown(Other.Weapon, Weap);		
		Other.PendingWeapon = Other.Weapon;
		Other.Weapon.GoToState('');
		Other.Weapon.TweenDown(); // for remove ambient sound
		// weird hack for prevent call AnimEnd which set Weapon to ClientPending if ClientPending not None
		Other.Weapon.AnimRate = 0;
		Other.Weapon.TweenRate = 0;
	}
	Other.Weapon = Weap;
}

simulated function ResetPawn(Pawn Other, rotator R, Weapon Weap)
{
	local vector L;
	local float Radius;
	local bool CollideActors;
	
	L = Location;
	L.Z += Other.default.CollisionHeight - CollisionHeight;
	
	if (PlayerPawn(Other) == None)
		Radius = Other.default.CollisionRadius;
	else
		Radius = 0; 
		
	if (Other.CollisionRadius != Radius && Level.NetMode < NM_Client)
		Other.SetCollisionSize(Radius, Other.CollisionHeight);

	if (Other.Location != L)
		Other.SetLocation(L);
		
	if (Weap != None && Other.Weapon != Weap)
		SwitchWeapon(Other, Weap);

	Other.Velocity = Velocity;
	Other.Visibility = 255;
	if (Level.NetMode < NM_Client)
	{
		CollideActors = GetCollideActors(Other);
		if (Other.bCollideActors != CollideActors)
			Other.SetCollision(CollideActors);
		Other.DrawScale = SmallDrawScale;
		Other.SetRotation(R);
		if( PlayerPawn(Other)==None )
			Other.ViewRotation = R;
	}
	else 
		Other.SetRotation(Rotation);
	if (Level.NetMode < NM_Client /*|| IsNetOwner(Other)*/)
		ResetPhysics(Other);
		
	if (Other.IsInState('FallingState'))
	{
		if ( (Other.NextState != '') && (Other.NextState != 'FallingState') )
			Other.GotoState(Other.NextState, Other.NextLabel);
		else
			Other.GotoState('Attacking');
	}
}

// Make sure driver is directly in center of vehicle.
simulated function UpdateDriverPos()
{
	local rotator R;

	R = Rotation;
	if( DriverGun!=None )
		R.Yaw = DriverGun.TurretYaw;
	else if (MyCameraAct != None && MyCameraAct.GunAttachM != None && Passengers[0] == None )
		R.Yaw = MyCameraAct.GunAttachM.TurretYaw;
	ResetPawn(Driver, R, DWeapon);
}
function int GetNextFreeSeat(int start)
{
	local int i;
	for (i = Arraycount(Passengers) - 1; i > start; i--)
		if (PassengerSeats[i].bIsAvailable && PassengerSeats[i].PGun != None && Passengers[i] == None)
			return i;
	return -1;
}
simulated function UpdatePassengerPos()
{
	local int i, NextFreeSeat;
	local rotator R;
	local bool bForceExit;
	local Bot Bot;

	For (i = 0; i < Arraycount(Passengers); i++)
	{
		if (Passengers[i] != None)
		{
			if (Level.NetMode < NM_Client)
			{
				bForceExit = Passengers[i].bDeleteMe || Passengers[i].Health <= 0;
				if (bForceExit || HealthTooLowFor(Passengers[i]) || !CrewFit(Passengers[i]))
				{
					PassengerLeave(i, bForceExit);
					Continue;
				}
			}
			
			R = Rotation;
			if (Level.NetMode < NM_Client && PassengerSeats[i].PGun != None)
					R.Yaw = PassengerSeats[i].PGun.TurretYaw;
			ResetPawn(Passengers[i], R, PassengerSeats[i].PHGun);
			
			if (Level.NetMode < NM_Client && Bot(Passengers[i]) != None)
			{
				Bot = Bot(Passengers[i]);
				NextFreeSeat = GetNextFreeSeat(i);
				if (NextFreeSeat != -1)
					ChangeSeat(NextFreeSeat + 1, true, i);
				else if ((Bot.PlayerReplicationInfo.HasFlag != None && PlayerPawn(Driver) == None && 
					(Driver == None || Driver.PlayerReplicationInfo.HasFlag == None)) ||
					(Driver == None && (WaitForDriver < Level.TimeSeconds || LastDriver == None || LastDriver == Bot ||
					DriverWeapon(LastDriver.Weapon) != None ||
					(Bot(LastDriver) != None && VSize(LastDriver.Location - Location) > 1000) ||
					(PlayerPawn(LastDriver) != None && VSize(LastDriver.Location - Location) > 2000))) || 
					(Bot(Driver) != None && Bot(Driver).Orders == 'Follow' && Bot(Driver).OrderObject == Bot &&
					Driver.PlayerReplicationInfo.HasFlag == None) ||
					(Level.Game.IsA('Greed') && Bot.Orders == 'Freelance' && 
					Bot(Driver) != None && Bot(Driver).Orders != 'Freelance' && 
					DeathMatchPlus(Level.Game).GameThreatAdd(Bot, Bot) > DeathMatchPlus(Level.Game).GameThreatAdd(Bot, Driver)))
					ChangeSeat(0, true, i); // become driver
				else if ((CTFFlag(Bot.MoveTarget) != None && Bot.PlayerReplicationInfo.HasFlag == None) ||
					(FlagBase(Bot.MoveTarget) != None && Bot.PlayerReplicationInfo.HasFlag != None &&
					Abs(VSize(Bot.MoveTarget.Location - Location) - VSize(ExitOffset)) < 
					Bot.default.CollisionRadius + class'CTFFlag'.default.CollisionRadius) && NeedStop(Bot))
					PassengerLeave(i, false);
			}
		}
	}
}

// Update vehicle velocity/rotation as driver selects their movements
simulated function UpdateDriverInput( float Delta );

simulated function DoSpecialSpaceKey();	//Run whatever code when space is pressed and bSpecialSPACEKEY=True

// Read whatever input driver is pressing now
simulated function ReadDriverInput( PlayerPawn Other, float DeltaTime )
{
	if( Other.bWasForward )
		Accel = 1;
	else if( Other.bWasBack )
		Accel = -1;
	else Accel = 0;
	if( Other.bWasLeft )
		Turning = -1;
	else if( Other.bWasRight )
		Turning = 1;
	else Turning = 0;
	
	if (!bSpecialSPACEKEY)
	{
		if( Other.bDuck!=0 )
		{
			Other.bPressedJump = False;
			Rising = -1;
		}
		else if (bGroundSim)
		{
			// held, not pressed, the press stays set in this state and locks the handbrake on
			Other.bPressedJump = False;
			Rising = int(Other.aUp > 0);
		}
		else if( Other.bPressedJump )
			Rising = 1;
		else Rising = 0;
	}
	else
		DoSpecialSpaceKey();
		
	if( Level.NetMode==NM_Client )
		ServerPerformMove(Rising, Turning, Accel);
	/*if( MyCameraAct!=None )
	{
		if( Other.bBehindView && Other.ViewTarget==MyCameraAct )
		{
			Other.bBehindView = False;
			bUseBehindView = !bUseBehindView;
			ServerSetBehindView(bUseBehindView);
			SaveConfig();
		}
		else if( bCameraOnBehindView!=bUseBehindView )
			ServerSetBehindView(bUseBehindView);
	}*/
	
	// for compat
//	MoveDest = Location + GetMovementDir()*600*vector(Rotation);
	MoveDest = CalcPlayerAimPos(0);
}

function vector GetExitOffset(Pawn Other)
{
	local vector Goal, HL, HN, Extent;
	local bool bIsMoveTarget;
	local int i;
	if (Bot(Other) != None)
	{
		Goal = Other.Destination;		
		if (Goal == Location)
		{
			if (Other.RouteCache[1] != None)
				Goal = Other.RouteCache[1].Location;
			else if (Other.RouteCache[0] != None)
				Goal = Other.RouteCache[0].Location;
			else
				return ExitOffset;
		}
		bIsMoveTarget = Other.MoveTarget != None && Goal == Other.MoveTarget.Location;
		if (bIsMoveTarget && Other.RouteCache[0] == Other.MoveTarget && Other.RouteCache[1] != None)
		{
			HL = Goal - Location;
			for (i = 1; i < ArrayCount(Other.RouteCache); i++)
				if (Other.RouteCache[i] != None &&
					(Other.RouteCache[i].Location - Location) dot HL < 0)
				{
					Other.MoveTarget = Other.RouteCache[i];
					Other.Destination = Other.MoveTarget.Location;
					Goal = Other.Destination;
					break;
				}
		}
		Extent.X = Other.CollisionRadius;
		Extent.Y = Extent.X;
		if (Other.Trace(HL, HN, Goal - vect(0,0,1)*(Other.CollisionHeight + 1), Goal, true, Extent) != None)
			Goal = HL + vect(0,0,1)*Other.CollisionHeight;
		/*
		if ((!bCanFly || HoverCraftPhys(self) != None) && bIsMoveTarget && 
			(UTJumpPad(Other.MoveTarget) != None || FlagBase(Other.MoveTarget) != None || 
			(CTFFlag(Other.MoveTarget) != None && CTFFlag(Other.MoveTarget).bHome)))
			return ExitOffset;
		*/
		Goal -= Location;
		Goal = Normal(Goal)*VSize(ExitOffset) << Rotation;
		if (!bIsMoveTarget)
			return Goal;
		if (Abs(Goal.X) >= Other.MoveTarget.CollisionRadius)
			Goal.X = Goal.X*(Abs(Goal.X) - Other.MoveTarget.CollisionRadius)/Abs(Goal.X);
		return Normal(Goal)*VSize(ExitOffset);
	}
	return ExitOffset;
}

// Update server behindview
function ServerSetBehindView( bool bNewView )
{
	bCameraOnBehindView = bNewView;
	if( PlayerPawn(Owner)!=None )
		PlayerPawn(Owner).bBehindView = False;
}

function bool HealthTooLowFor(Pawn Other)
{
	if (PlayerPawn(Other) != None)
		return false;
	return Health < Min(100, default.Health/5);
}
function bool CrewFit(Pawn Other)
{
	local Bot Bot, DBot;
	Bot = Bot(Other);
	if (Bot == None || Driver == None || Driver == Other)
		return true;
	if (Domination(Level.Game) != None && PlayerPawn(Driver) != None && DriverGun == None && 
		(Bot.Orders != 'Follow' || Bot.OrderObject != Driver))
		return false;
	if (Bot.Orders == 'Freelance')
		return true;
	if (PlayerPawn(Driver) != None && Other.PlayerReplicationInfo != None && Other.PlayerReplicationInfo.HasFlag != None)
		return true;
	DBot = Bot(Driver);
	if (Bot.Orders == 'Follow')
		return (Pawn(Bot.OrderObject) != None && DriverWeapon(Pawn(Bot.OrderObject).Weapon) != None && 
			DriverWeapon(Pawn(Bot.OrderObject).Weapon).VehicleOwner == self) || 
			(DBot != None && DBot.Orders == Bot.Orders && Bot.OrderObject == DBot.OrderObject);
	if (DBot == None)
		return false;
	if (Dbot.Orders == 'Follow' && DBot.OrderObject == Bot)
		return true;
	if (Bot.Orders == 'Attack')
		return DBot.Orders == 'Attack';
	// Defend, Hold and other unknown possible orders
	return DBot.Orders == Bot.Orders && Bot.OrderObject == DBot.OrderObject;
}
// True when a bot has no reason to be moving right now.
function bool BotIsBusy(Bot B)
{
	if (B.IsInState('RangedAttack') || (B.Enemy != None && B.LineOfSightTo(B.Enemy)))
		return true;
	if ((B.Orders == 'Hold' || B.Orders == 'Defend') && B.OrderObject != None &&
		VSize(B.OrderObject.Location - Location) < 1500)
		return true;
	if (B.Orders == 'Follow' && B.OrderObject != None && VSize(B.OrderObject.Location - Location) < 1000)
		return true;
	return FlagPassenger() != None && VSize(Velocity) < 50;
}

// A bot driver that stops getting anywhere first repaths, then backs off, then gets out.
function CheckBotProgress()
{
	local Bot B;
	local float Moved;

	B = Bot(Driver);
	if (B == None || StationaryPhys(self) != None || Level.TimeSeconds < BotCheckTime + BotCheckDelay)
		return;
	Moved = VSize(Location - BotCheckPos);
	BotCheckTime = Level.TimeSeconds;
	if (Moved >= BotMinProgress)
		BotIdle = 0;
	else if (BotIdle < 255)
		BotIdle++;
	if (Moved >= BotMinProgress || BotIsBusy(B))
	{
		BotCheckPos = Location;
		BotStrikes = 0;
		return;
	}
	BotStrikes++;
	if (BotStrikes >= BotMaxStrikes)
	{
		BotStrikes = 0;
		BotBanTime = Level.TimeSeconds + BotBanSeconds;
		DriverLeft(False, "Stuck");
		if (Driver != None)
			DriverLeft(True, "Stuck forced");
	}
	else if (BotStrikes == 1)
	{
		B.MoveTimer = -1;
		bHasMoveTarget = False;
	}
	else
	{
		Reverse = -GetMovementDir();
		ReverseTime = Level.TimeSeconds + 1.5;
	}
}

// Passenger holding a flag that the driver does not hold.
function Pawn FlagPassenger()
{
	local int i;
	if (Driver != None && Driver.PlayerReplicationInfo != None && Driver.PlayerReplicationInfo.HasFlag != None)
		return None;
	for (i = 0; i < ArrayCount(Passengers); i++)
		if (Passengers[i] != None && Passengers[i].PlayerReplicationInfo != None &&
			Passengers[i].PlayerReplicationInfo.HasFlag != None)
			return Passengers[i];
	return None;
}

// Flag carrier riding with a bot is home and just has to get out
function bool CarrierIsHome()
{
	local CTFReplicationInfo R;
	local Pawn P;
	local byte Team;

	P = FlagPassenger();
	if (P == None || Driver.PlayerReplicationInfo == None)
		return false;
	R = CTFReplicationInfo(Level.Game.GameReplicationInfo);
	Team = Driver.PlayerReplicationInfo.Team;
	if (R == None || Team >= ArrayCount(R.FlagList) || R.FlagList[Team] == None)
		return false;
	return VSize(R.FlagList[Team].HomeBase.Location - Location) < 800;
}

// Figure out a good move for bots
function ReadBotInput( float Delta )
{
	local vector V, VS, T, HitLocation, HitNormal, X, Y, Z;
	local float S;
	local int Dir;
	local Bot Bot;
	local bool bFits;

	if ((Driver != None && (Driver.IsInState('GameEnded') || Driver.IsInState('Dying'))) || Level.Game.bGameEnded)
		return;
	
	if (HealthTooLowFor(Driver))
		DriverLeft(False, "HealthTooLowFor");
	if (Driver == None)
		return;
	if (NeedStop(Driver))
	{
		Bot = Bot(Driver);
		V = Driver.Destination;
		if (Driver.MoveTarget != None)
			V = Driver.MoveTarget.Location;
		V -= Location;
		// X dot X == VSize(X)*VSize(X)
		S = V dot V;
		if (Driver.IsInState('ImpactJumping') || Driver.MoveTarget == None || S < CollisionRadius*CollisionRadius*4)
			DriverLeft(False, "NeedStop near");
		else if ((Velocity dot Velocity) < 2500 /* 50*50 */ && S < 2250000 /* 1500*1500 */ && 
			Driver.LineOfSightTo(Driver.MoveTarget))
			DriverLeft(False, "NeedStop stuck");
		if (Driver == None && Bot != None)
		{
			Bot.EnemyDropped = None; // prevent dumb moves
			if (!HasPassengers())
				foreach RadiusActors(class'Bot', Bot, 800)
					if ((!Level.Game.bTeamGame || Bot.PlayerReplicationInfo.Team != CurrentTeam) && 
						DriverWeapon(Bot.Weapon) == None && BotDesireability2(Bot) > 0)
						Bot.EnemyDropped = DWeapon; // enemy bots wanna steal vehicle
		}
	}
	if (Driver == None)
		return;
		
	Bot = Bot(Driver);
	if (Bot != None && Bot.EnemyDropped != None)
		Bot.EnemyDropped = None; // Driver not chase for dropped weapons

	if (CarrierIsHome())
	{
		Accel = 0;
		Turning = 0;
		Rising = 0;
		return;
	}
	
	S = Min(100, CollisionRadius - 20);

	if( !bHasMoveTarget )
	{
		bHasMoveTarget = True;
		V = MoveDest;
		MoveDest = VehicleAI.GetNextMoveTarget();
//		log(Level.TimeSeconds @ self @ "GetNextMoveTarget" @ MoveDest);
		if (V == MoveDest)
		{
			X = MoveDest - Driver.Location;
			Y = Normal(X);
			VS.X = CollisionRadius;
			VS.Y = VS.X;
			VS.Z = FMax(16, CollisionHeight - MaxObstclHeight - Abs(Y.Z)*CollisionRadius);
			T = Location + Min(CollisionRadius, VSize(X))*GetMovementDir()*Y;
			if (Trace(HitLocation, HitNormal, T, Location, true, VS) != None && 
				 HitNormal.Z < 0.7 && VSize(HitLocation - Location) < 0.5*CollisionRadius)
			{
				//Log(0 @ HitNormal @ VSize(HitLocation - Location) @ VSize(HitLocation - T));
				GetAxes(rotator(MoveDest - Driver.Location), X, Y, Z);
				Dir = 1;
				if ((Y dot HitNormal) < 0)
					Dir = -1;
				//log(1 @ X dot HitNormal @ Y dot HitNormal @ HitLocation);
				if (((X dot HitNormal) < -0.999 || 
					Trace(HitLocation, HitNormal, T, Location + Y*Dir*CollisionRadius, true, VS) != None) && 
					Driver.PointReachable(MoveDest))
				{
					//log(2 @ X dot HitNormal @ Y dot HitNormal @ HitLocation);
					
					Driver.SetCollisionSize(CollisionRadius, CollisionHeight);
					//log(self @ driver @ MoveDest @ Driver.PointReachable(MoveDest));
					bFits = Driver.PointReachable(MoveDest);
					Driver.SetCollisionSize(Driver.default.CollisionRadius, Driver.default.CollisionHeight);
					// next to a wall nothing that size reaches anything, so only leave if stuck
					if (!bFits && BotIdle >= 2)
						DriverLeft(False, "PointReachable");
					if (Driver == None)
						return;
				}
				else
					MoveDest.Z += 0.1; // for not be equal next time
			}
		}
		V = Location - MoveDest;
		V.Z = 0;
		// X dot X == VSize(X)*VSize(X)
		if ((V dot V) < S*S)
		{
			Driver.MoveTimer = -1.f;
			Driver.MoveTarget = None;
			Driver.StopWaiting();
			bHasMoveTarget = False;
			Return;
		}
		MoveTimer = Level.TimeSeconds + FMin(0.25, VSize(Location - MoveDest)/Fmax(1, Vsize(Velocity))/4);
//		log(Level.TimeSeconds @ self @ "MoveTimer" @ MoveTimer @ MoveTimer - Level.TimeSeconds);
	}
	V = Location - MoveDest;
	V.Z = 0;
	// X dot X == VSize(X)*VSize(X)
	if (MoveTimer <= Level.TimeSeconds || (V dot V) < S*S)
	{
		bHasMoveTarget = False;
		Return;
	}
	Turning = ShouldTurnFor(MoveDest);
	Rising = ShouldRiseFor(MoveDest);
	Accel = ShouldAccelFor(MoveDest);
	
	if (bUseVehicleLights)
	{
		HeadLightAccum += Delta;
		if (HeadLightAccum >= 1.0)
		{
			HeadLightAccum = 0;
			// once per 15 seconds, try randomly switch light on or off
			if (FRand()*32767.0 < 2184.46 && FRand() < 0.5)
				SwitchVehicleLights();
		}
	}
	
//	if (Accel == 0) log(self @ "Move" @ v @ Turning @ Accel @ (Normal(MoveDest-Location) dot vector(Rotation)));
}

function bool AtFlagBase(Pawn pDriver)
{
	local FlagBase FlagBase;
	local CTFReplicationInfo CTFRI;
	local CTFFlag CTFFlag;
	FlagBase = FlagBase(pDriver.MoveTarget);
	if (FlagBase == None)
		return false;
	if (pDriver.PlayerReplicationInfo.HasFlag == None && 
		pDriver.PlayerReplicationInfo.Team == FlagBase.Team)
		return false;
	CTFRI = CTFReplicationInfo(Level.Game.GameReplicationInfo);
	if (CTFRI == None || Level.Game.IsA('OneFlagCTFGame') || Level.Game.IsA('CaptureFourFlags'))
		return true;
	CTFFlag = CTFRI.FlagList[FlagBase.Team];
	if (CTFFlag == None || CTFFlag.bHome)
		return true;
}

function bool NeedStop(Pawn pDriver)
{
	if (pDriver == None || PlayerPawn(pDriver) != None)
		return false;
	if (VehicleExit(pDriver.MoveTarget) != None || 
		JumpSpot(pDriver.MoveTarget) != None ||		
		pDriver.IsInState('ImpactJumping') ||
		(pDriver.MoveTarget == None && JumpSpot(pDriver.RouteCache[0]) != None))
		return true;
	if (pDriver.PlayerReplicationInfo != None)
	{
		if (CTFFlag(pDriver.MoveTarget) != None && pDriver.PlayerReplicationInfo.HasFlag != pDriver.MoveTarget)
			return true;
		if (AtFlagBase(pDriver))
		{
			if (Level.Game.IsA('OneFlagCTFGame'))
			{
				if (pDriver.PlayerReplicationInfo.HasFlag != None &&
					!pDriver.MoveTarget.IsA('NeutralFlagBase') && 
					FlagBase(pDriver.MoveTarget).Team != pDriver.PlayerReplicationInfo.Team)
					return true;
				if (pDriver.PlayerReplicationInfo.HasFlag == None && 
					pDriver.MoveTarget.IsA('NeutralFlagBase'))
					return true;
			}
			else
			{
				if ((FlagBase(pDriver.MoveTarget).Team != pDriver.PlayerReplicationInfo.Team) == 
					(pDriver.PlayerReplicationInfo.HasFlag == None))
					return true;
			}
			return true;
		}
	}
	if (UTJumpPad(pDriver.MoveTarget) != None && 
		pDriver.MoveTarget == pDriver.RouteCache[0] &&
		UTJumpPad(pDriver.RouteCache[1]) != None && 
		string(pDriver.RouteCache[1].Tag) ~= UTJumpPad(pDriver.RouteCache[0]).URL)
		return true;
	if (Driver == pDriver && IsImportantMoveTarget(pDriver))
		return true;
	if (Driver == pDriver && TravelToInventory(pDriver))
		return true;
	return false;
}

function bool TravelToInventory(Pawn pDriver) 
{
	local int i;
	if (Inventory(pDriver.MoveTarget) != None && 
		(pDriver.Enemy == None || VSize(pDriver.Enemy.Location - pDriver.Location) > 8000 || 
		!pDriver.FastTrace(pDriver.Enemy.Location)))
	{
		if (pDriver.RouteCache[0] == None)
			return true;
		for (i = ArrayCount(pDriver.RouteCache) - 1; i > 0 && pDriver.RouteCache[i] == None; i--);
		if (i < ArrayCount(pDriver.RouteCache) - 1 && InventorySpot(pDriver.RouteCache[i]) != None &&
			InventorySpot(pDriver.RouteCache[i]).markedItem == pDriver.MoveTarget)
			return true;
	}
	return false;
}

static function bool IsImportantMoveTarget(Pawn Seeker)
{
	local Actor MoveTarget;
	MoveTarget = Seeker.MoveTarget;
	if (MoveTarget != None && (
		(MoveTarget.bGameRelevant && DriverWeapon(MoveTarget) == None && BotAttractInv(MoveTarget) == None &&
		// Ensure it is not a transit nav point.
		(MoveTarget != Seeker.RouteCache[0] || Seeker.RouteCache[1] == None)) ||
		(FortStandard(MoveTarget) != None && FortStandard(MoveTarget).bTriggerOnly)
		))
		return true;
	return false;
}

function bool AboutToCrash(out int Accel)
{
	local float Dir;
	local vector HitLocation, HitNormal;
	local int ret, check, i;
	local Actor A, FlagGoal;
	local Vehicle Veh;

	Dir = VSize(Velocity);
	// brake for take flag
	if (Dir > 100)
	{
		FlagGoal = GetFlagGoal(Driver);
		if (FlagGoal != None && NeedReturnBackAfter(FlagGoal) &&
			VSize(FlagGoal.Location - Location) < 
			(class'FlagBase'.default.CollisionRadius + CollisionRadius + Dir/4))
		{
			Accel = -GetMovementDir(); // brake via reverse
			return true;
		}
	}	
	if (Reverse != 0 && ReverseTime < Level.TimeSeconds)
		Reverse = 0;
	if (Dir > 0)
	{
		ret = GetMovementDir();
		check = ret;
		for (i = 0; i < 2; i++)
		{
			// about to crash?
			A = Trace(HitLocation, HitNormal, Location + check*Dir/2*vector(Rotation), , true,
				vect(1,1,0)*CollisionRadius + vect(0,0,1)*(CollisionHeight - MaxObstclHeight));
			if (A != None)
			{
				Veh = Vehicle(A);
				// pass flag carrier
				if (Veh != None && Veh.CurrentTeam == CurrentTeam && Veh.VehicleFlag != None)
				{
					if (bCanFly)
					{
						Rising = 1;
						return false;
					}
					Reverse = -check;
					ReverseTime = Level.TimeSeconds + 1;
					break;
				}
			}
			if (i == 0 && Reverse == 0)
				break;
			check *= -1;
		}
	}
	if (Reverse != 0)
	{
		Accel = Reverse;
		return true;
	}
	// take 500 as crash speed. So use 490 as check
	if (Dir > 490 || bCanFly)
	{
		if (A == None)
			return false;
		if (A == Level && HitNormal.Z > 0.5) // slope?
			return false;
		if (Pawn(A) != None)
			return false; // teammates protected and can be taken as passengers, all other must die
		if (Veh != None && Veh.CurrentTeam != CurrentTeam && 
			(Veh.Driver != None || Veh.HasPassengers()))
			return false; // crash into enemy non-empty vehicle for make damage
		if (Veh != None && Veh.CurrentTeam == CurrentTeam)
		{
			if (bCanFly)
			{
				Rising = 1;
				return false;
			}
			if (Veh.Driver != None && 
				(Normal(Veh.Velocity) dot Normal(Velocity)) > 0.5 &&
				VSize(Veh.Velocity) > VSize(Velocity) - 490)
				return false; // not slow down when follow teammate vehicle
			Honk(); // make signal here, for notify other driver :)
		}
//		Log("Detect crash into" @ A @ HitLocation @ HitNormal);
		if (Dir > 490)
		{
			Accel = -ret; // brake via reverse
			return true;
		}
	}
	return false;
}

// Returns the bot value for accel target
function int ShouldAccelFor( vector AcTarget )
{
	local int ret;
	
	if (AboutToCrash(ret))
		return ret;
			
	if( (AcTarget-Location) dot vector(Rotation) > 0 )
		ret = 1;
	else
		ret = -1;
	return ret;
}

// Returns the bot turning value for target
function int ShouldTurnFor( vector AcTarget, optional float YawAdjust, optional float DeadZone )
{
	local vector X,Y,Z;
	local rotator R;
	local float Res;
	
	if (!bOnGround && !bCanFly)
		return 0;
	
	if (DeadZone == 0)
		DeadZone = 0.001;
		
	R = Rotation;
	R.Yaw += YawAdjust;

	GetAxes(R,X,Y,Z);
	Res = Normal(AcTarget-Location) dot Y;
//	log("ShouldTurnFor" @ Res @ "YawAdjust" @ YawAdjust);
	if( Abs(Res) < DeadZone )
		Return 0;
	else if( Res>0 )
		Return -1;
	else Return 1;
}

function int ShouldRiseFor( vector AcTarget )
{
	return 0;
}

// Pawn can enter this vehicle?
function bool CanEnter(Pawn Other, optional bool bIgnoreDuck, optional bool bIgnoreTrace)
{
	local vector HL, HN;
	if (Other.Health <= 0 || 
		DriverWeapon(Other.Weapon) != None ||
		Other.IsInState('PlayerWaiting') || 
		Other.IsInState('GameEnded') || 
		Level.Game.bGameEnded || 
		!Other.bCollideActors ||
		(Other == LastExitPawn && Level.TimeSeconds < LastExitTime + 0.75) || // just got out, on purpose
		(!bIgnoreDuck && PlayerPawn(Other) != None && (Other.bDuck == 0 ||
		(PreventEnter != None && PreventEnter.Instigator == Other))))
		return false;
	if (bIgnoreTrace)
		return true;
	if (!Other.FastTrace(Location) || 
		(VSize(Other.Location - Location) > 10 && Other.Trace(HL, HN, Location, , true) != self))
		return false;
	return true;
}
function bool IsTeamLockedFor(Pawn Other)
{
	return Level.Game.bTeamGame && Other.PlayerReplicationInfo != None && 
		Other.PlayerReplicationInfo.Team <= 3 && Other.PlayerReplicationInfo.Team != CurrentTeam &&
		(bTeamLocked || Driver != None || HasPassengers());
}

// 1 - Forward
// -1 - Reversed
simulated function int GetMovementDir()
{
	if( (vector(Rotation) dot Velocity)>0 )
		Return 1;
	else Return -1;
}

function float BotDesireability2(Pawn Bot)
{
//	local vector L;
//	Log(self @ "BotDesireability 1" @ Bot.GetHumanName() @ Bot.MoveTarget);
	if (bDeleteMe )
		Return -19;
//	Log(self @ "BotDesireability 2" @ Bot.GetHumanName() @ CurrentTeam @ CanEnter(Bot) @ 
//		IsTeamLockedFor(Bot) @ VehicleAI.PawnCanDrive(Bot) @ Bot.bIsPlayer);
	if (!CanEnter(Bot, false, true) || IsTeamLockedFor(Bot) || !VehicleAI.PawnCanDrive(Bot))
		Return -18;
/*	if (!Bot.actorReachable(self))
	{
		L = Bot.Location - Location;
		L.z = 0;
		L = Normal(L)*(CollisionRadius + 10);
		Move(L);
		Log("Moved!" @ L);
	}*/
//	Log(self @ "BotDesireability 3" @ Bot.GetHumanName() @ VehicleAI.GetVehAIRating(Bot) @ Bot.actorReachable(self));
	Return VehicleAI.GetVehAIRating(Bot);
}

Auto State EmptyVehicle
{
	Ignores FireWeapon, ReadDriverInput, ReadBotInput, DriverLeft;

	function ServerPerformPackedMove(float InClientTime, XVEnums.E28 Bits)
	{
		Turning = 0;
		Rising = 0;
		Accel = 0;
		
		ClientLastTime = InClientTime;
		ServerLastTime = Level.TimeSeconds;
	}
	function MessageLocalPLs()
	{
		local Pawn P;

		for (P = Level.PawnList; P != None; P = P.NextPawn)
		{
			if (P.bIsPlayer && PlayerPawn(P) != None && VSize(P.Location - Location) < (CollisionRadius + 100 + P.CollisionRadius) && 
				CanEnter(P, True) && !IsTeamLockedFor(P))
				P.ReceiveLocalizedMessage(class'EnterMessagePlus', 0, None, None, self);
			if (P.bIsPlayer && Bot(P) != None && VSize(P.Location - Location) < Min(CollisionRadius, CollisionHeight) && 
				BotDesireability2(Bot(P)) > 0) {
				Bump(P);
				if (!IsInState('EmptyVehicle'))
					break;
			}
		}
	}
	singular function Bump(Actor Other)
	{
		local Pawn Seeker;
		Global.Bump(Other);
		if (Other == None || !Other.bIsPawn || Other.bDeleteMe)
			return;
		Seeker = Pawn(Other);
		if (!Seeker.bIsPlayer || !CanEnter(Seeker) || !VehicleAI.PawnCanDrive(Seeker, true))
			return;
		if (IsTeamLockedFor(Seeker))
		{
			Seeker.ClientMessage("This" @ VehicleName @ "is team locked.", 'CriticalEvent');
			return;
		}
		else if(Seeker.PlayerReplicationInfo != None && Seeker.PlayerReplicationInfo.Team <= 3 &&
			Seeker.PlayerReplicationInfo.Team != CurrentTeam)
		{
			CurrentTeam = Seeker.PlayerReplicationInfo.Team;
			SetOverlayMat(TeamOverlays[CurrentTeam], 0.5);
			PlaySound(Sound'CarAlarm01', SLOT_None, 2, , 2000);
			if (PlayerPawn(Seeker) != None)
				PlayerPawn(Seeker).ClientPlaySound(Sound'Hijacked', , true);
		}
		DriverEnter(Seeker);
	}
	function Timer()
	{
		local PlayerPawn PP;
		Global.Timer();
		foreach RadiusActors(class'PlayerPawn', PP, CollisionRadius + 100)
			if (CanEnter(PP)) {
				Bump(PP);
				if (!IsInState('EmptyVehicle'))
					break;
			}
	}
	function BeginState()
	{
		AmbientSound = IdleSound;
		SoundPitch = Default.SoundPitch;
		bDriving = False;
		// Hit breaks on.
		Turning = 0;
		Rising = 0;
		Accel = 0;
		if( BotAttract==None )
		{
			BotAttract = Spawn(Class'BotAttractInv',Self);
		}
	}
	function EndState()
	{
		bDriving = Driver != None;
		if( BotAttract!=None )
		{
			BotAttract.Destroy();
			BotAttract = None;
		}
		LifeSpan = 0;
	}
Begin:
	Sleep(Level.TimeDilation);
	if( Owner!=None )
		SetOwner(None);
	MessageLocalPLs(); // Message every second.
	GoTo'Begin';
}

State VehicleDriving
{
	singular function Bump(Actor Other)
	{
		local byte Fr;
		local Pawn Seeker;

		Global.Bump(Other);
		if (Other == None || !Other.bIsPawn || Other.bDeleteMe)
			return;
		Seeker = Pawn(Other);
		if (!Seeker.bIsPlayer || !CanAddPassenger(Seeker, Fr) || !VehicleAI.PawnCanPassenge(Seeker, Fr))
			return;
		PassengerEnter(Seeker, Fr);
	}
	function Timer()
	{
		local PlayerPawn PP;
		local byte Fr;
		local int i;
		Global.Timer();
		if (Driver != None)
		{
			Driver.MakeNoise(2.0);
			// sometimes wrong order of events produce pickup flag after pass enter check, so it fixed here
			if (DropFlag != DF_None)
				TryDropFlag(Driver);
			CheckBotProgress();
		}
		if (DropFlag == DF_All)
			for (i = 0; i < ArrayCount(Passengers); i++)
				if (Passengers[i] != None)
					TryDropFlag(Passengers[i]);
		foreach RadiusActors(class'PlayerPawn', PP, CollisionRadius + 100)
			if (CanAddPassenger(PP, fr))
				Bump(PP);
	}
	function Touch(Actor Other)
	{
		if (NeedTouch(Other) && Driver != None)
			Other.Touch(Driver);
	}
	function UnTouch(Actor Other)
	{
		if (NeedTouch(Other) && Driver != None)
			Other.UnTouch(Driver);
	}
}

function bool NeedTouch(Actor Other)
{
	return Triggers(Other) != None || ControlPoint(Other) != None;
}

simulated event SetInitialState()
{
	if( Level.NetMode==NM_Client )
		Return; // Do not set a state on clients!
	if( InitialState!='' )
		GotoState( InitialState );
	else GotoState( 'Auto' );
}
simulated function vector FixCameraPos(vector V, vector S)
{
	local vector HL,HN,X,Y,Z;
	local float P;
	const ViewGap = 20.0;

	// trace past the view so it eases in before the wall
	X = Normal(V - S)*ViewGap;
	if( Trace(HL,HN,V + X,S,False) != None )
	{
		if (VSize(HL - S) > ViewGap + 5)
			V = HL - X;
		else
			V = HL+HN*5;
	}
	GetAxes(Rotation, X, Y, Z);
	P = (V - S) dot Z;
	if (P < 0)
		V -= P*Z;
	return V;
}
simulated function CalcCameraPos( out vector Pos, out rotator Rot, float Mult, optional byte SeatNumber, optional DriverCameraActor Cam )
{
	local vector V,S;
	local WeaponAttachment Gun;
	local Pawn WeaponController;

	if( SeatNumber>0 )
	{
		SeatNumber--;
		if (PassengerSeats[SeatNumber].PGun != None)
			WeaponController = PassengerSeats[SeatNumber].PGun.WeaponController;
		else
			WeaponController = Passengers[SeatNumber];
		if( WeaponController == None )
			Rot = Rotation;
		else if (PlayerPawn(WeaponController) != None && PlayerPawn(WeaponController).Player != None)
			Rot = WeaponController.ViewRotation;
		else 
		{
			if (bSlopedPhys && GVT!=None)
				Rot = TransformForGroundRot(Rot.Yaw,GVTNormal,Rot.Pitch);
			else
				Rot = TransformForGroundRot(Rot.Yaw,FloorNormal,Rot.Pitch);
		}
		bOwnerNoSee = False;
		if (bSlopedPhys && GVT!=None)
			S = GVT.PrePivot + Location+((PassengerSeats[SeatNumber].PassengerWOffset+PassengerSeats[SeatNumber].CameraOffset*Mult) >> Rotation);
		else
			S = Location+((PassengerSeats[SeatNumber].PassengerWOffset+PassengerSeats[SeatNumber].CameraOffset*Mult) >> Rotation);
		V = S+((PassengerSeats[SeatNumber].CamBehindviewOffset*Mult) >> Rot);
		if (Cam != None)
			V.Z += Cam.HeightLag;
		Pos = FixCameraPos(V, S);
		if (Cam != None)
			Pos = Cam.EasePull(V, Pos, Rot);
		Return;
	}
	Gun = DriverGun;
	if (Gun == None && Passengers[0] == None && Cam != None)
		Gun = Cam.GunAttachM;
	if( Pawn(Owner)==None )
		Rot = Rotation;
	else if (PlayerPawn(Owner) != None && PlayerPawn(Owner).Player != None)
		Rot = Pawn(Owner).ViewRotation;
	else if (Gun != None)
	{
		Rot = Gun.TurretYaw*rot(0,1,0) + Gun.TurretPitch*rot(1,0,0);
		if (bSlopedPhys && GVT!=None)
			Rot = TransformForGroundRot(Rot.Yaw,GVTNormal,Rot.Pitch);
		else
			Rot = TransformForGroundRot(Rot.Yaw,FloorNormal,Rot.Pitch);
	}
	else if (Velocity dot vector(Rotation) >= 0)
	 	Rot = Rotation;
	else
		Rot = Rotation + rot(0,32768,0);

	if( !bCameraOnBehindView )
	{
		if (bSlopedPhys && GVT!=None)
			Pos = GVT.PrePivot +Location+(InsideViewOffset >> Rotation);
		else
			Pos = Location+(InsideViewOffset >> Rotation);
		bOwnerNoSee = True;
		if( !bFPViewUseRelRot )
			Return;

		if (bSlopedPhys && GVT!=None)
			Rot = TransformForGroundRot(Rot.Yaw,GVTNormal,Rot.Pitch);
		else
			Rot = TransformForGroundRot(Rot.Yaw,FloorNormal,Rot.Pitch);
		Return;
	}
	bOwnerNoSee = False;
	if (bDriverWOffset && Gun != None)
		V = GunPlace(Gun)+((BehinViewViewOffset*Mult) >> Rot);
	else if (bSlopedPhys && GVT!=None)
		V = GVT.PrePivot + Location+((BehinViewViewOffset*Mult) >> Rot);
	else
		V = Location+((BehinViewViewOffset*Mult) >> Rot);
	if (Cam != None)
		V.Z += Cam.HeightLag;
	Pos = FixCameraPos(V, Location);
	if (Cam != None)
		Pos = Cam.EasePull(V, Pos, Rot);
}
function rotator GetFiringRot( float ProjSpeed, bool bInstantHit, vector PStartPos, optional byte SeatN )
{
	local vector End, Start, HL, HN, vAim;
	local rotator Aim;
	local DriverCameraActor Cam;
	local Pawn WeaponController;
	local float AimError;

	AimError = (1.0 + 2*int(bInstantHit))*550;
	if( bInstantHit )
		ProjSpeed = 999999;
	if( SeatN>0 )
	{
		SeatN--;
		WeaponController = PassengerSeats[SeatN].PGun.WeaponController;
		if( PlayerPawn(WeaponController)==None && WeaponController != None )
			return WeaponController.AdjustAim(ProjSpeed,PStartPos,AimError,True,True);
		
		Cam = PassengerSeats[SeatN].PassengerCam;
		if (Passengers[SeatN] == None)
		{
			Cam = MyCameraAct;
			SeatN = 255; // for get zero in (SeatN+1) for next code
		}
		if (Cam != None)
		{
			CalcCameraPos(Start,Aim,Cam.CurrentViewMult,SeatN+1);
			Start = AdjustCamTraceStart(Start, Aim, Cam);
		}
		else
			CalcCameraPos(Start,Aim,1.0,SeatN+1);
		End = Start+vector(Aim)*8000;

		if( Trace(HL,HN,End,Start,True)==None )
			return rotator(End-PStartPos);
		else 
			return rotator(HL-PStartPos);
	}
	if (Driver == None)
		if (DriverGun != None)
			return DriverGun.Rotation;
		else
			return Rotation;
	if (PlayerPawn(Driver) == None)
		return Driver.AdjustAim(ProjSpeed, PStartPos, AimError, True, True);
		
	if (MyCameraAct != None)
	{
		CalcCameraPos(Start, Aim, MyCameraAct.CurrentViewMult);
		Start = AdjustCamTraceStart(Start, Aim, MyCameraAct);
	}
	else
		CalcCameraPos(Start, Aim, 1.0);
	
	vAim = vector(Aim);
	End = Start + 40000*vAim;
	if (Trace(HL, HN, End, Start, True) == None)
		return rotator(End - PStartPos);
	else 
		return rotator(HL - PStartPos + 10*vAim);
}
simulated function vector AdjustCamTraceStart(vector Start, rotator Aim, DriverCameraActor Cam)
{
	local vector Dir;
	if (Cam != None && Cam.GunAttachM != None)
	{
		Dir = vector(Aim);
		Start += Dir*((Cam.GunAttachM.Location - Start + 
			(Cam.GunAttachM.WeapSettings[0].FireStartOffset >> Cam.GunAttachM.Rotation)) dot Dir);
	}
	return Start;
}
simulated function vector CalcPlayerAimPos( optional byte SeatN )
{
	local vector End,Start,HL,HN;
	local rotator Aim;
	local DriverCameraActor Cam;
	
	if ((SeatN == 0 || (SeatN == 1 && Passengers[0] == None)) && MyCameraAct != None)
	{
		Cam = MyCameraAct;
		CalcCameraPos(Start,Aim,Cam.CurrentViewMult);
	}
	else if (SeatN > 0 && PassengerSeats[SeatN-1].PassengerCam != None)
	{
		Cam = PassengerSeats[SeatN-1].PassengerCam;
		CalcCameraPos(Start,Aim,Cam.CurrentViewMult,SeatN);
	}
	else 
		CalcCameraPos(Start,Aim,1.0,SeatN);
	Start = AdjustCamTraceStart(Start, Aim, Cam);
		
	End = Start+vector(Aim)*40000;
	if( Trace(HL,HN,End,Start,True)==None || HL == Start )
		return End;
	else return HL;
}
simulated function RenderCanvasOverlays( Canvas C, DriverCameraActor Cam, byte Seat )
{
	local float X, Y, XS, XL, YL, LastY;
	local int i, o;
	Local Pawn CamOwner;
	local ChallengeHud HUD;
	local string str, exit;
	local WeaponAttachment Gun;
	local texture CrosshairTex;
	local color CrossColor;
	local float CrossScale;
	local ERenderStyle CrossStyle;
	
	HUD = ChallengeHud(C.Viewport.Actor.myHUD);

	// Draw health bar:	
	C.Style = ERenderStyle.STY_Normal;
	
	if (HUD == None || HUD.MyFonts == None)
		Y = C.ClipY/6*5;
	else
	{ // place health bar above CTF messages
		C.Font = HUD.MyFonts.GetBigFont(C.ClipX);
		C.StrLen("TEST", XL, YL);
		Y = class'CTFMessage2'.static.GetOffset(1, YL, C.ClipY) - YL;
	}
	LastY = Y;
		
	//XS = C.ClipX/3*2;
	XS = C.ClipX/4;
	X = C.ClipX/2;
	DrawHealthBar(C, Health, FirstHealth, X, Y, XS, 24);
	//C.Font = Font'MedFont';
	C.Font = Font'VehFont';

//	C.DrawColor.R = 192;
//	C.DrawColor.G = 192;
//	C.DrawColor.B = 192;
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;

	C.StrLen(string(Health),XL,YL);
	C.SetPos(C.ClipX/2-XL/2,Y+5);
	C.DrawText(string(Health),False);
	
	if (VehicleState != None)
	{
		VehicleState.bHidden = true;
		VehicleState.Mass = Level.TimeSeconds + 1;
	}

	if( bRenderVehicleOnFP && Seat==0 && !bCameraOnBehindView )
	{
		bOwnerNoSee = False;
		C.DrawActor(Self,False);
		bOwnerNoSee = True;

		if (!bSlopedPhys)
			bHidden = False;
	}

	// Draw aim OK crosshair
	if( DriverCrosshairTex!=None && Seat==0 && DriverGun!=None)
	{
		Gun = DriverGun;
		CrosshairTex = DriverCrosshairTex;
		CrossColor = DriverCrossColor;
		CrossScale = DriverCrossScale;
		CrossStyle = DriverCrossStyle;
	}
	else if((Seat > 0 && PassCrosshairTex[Seat-1]!=None && Cam!=None && Cam.GunAttachM!=None) || 
		(Seat == 0 && PassCrosshairTex[0]!=None && DriverGun == None && Passengers[0] == None))
	{
		Gun = Cam.GunAttachM;
		i = Seat - 1;
		if (Seat == 0)
			i = 0;
		CrosshairTex = PassCrosshairTex[i];
		CrossColor = PassCrossColor[i];
		CrossScale = PassCrossScale[i];
		CrossStyle = PassCrossStyle[i];
	}
	if (Gun != None)
	{
		if (PlayerPawn(Gun.WeaponController) != None && class'DriverWeapon'.default.UseStandardCrosshair && 
			ClassIsChildOf(class<GameInfo>(DynamicLoadObject(C.ViewPort.Actor.GameReplicationInfo.GameClass, class'Class')), class'DeathMatchPlus'))
		{
			if (PlayerPawn(Gun.WeaponController).Handedness == -1)
				C.SetPos(C.ClipX*0.503-(CrosshairTex.USize*CrossScale/2),C.ClipY*0.504-(CrosshairTex.VSize*CrossScale/2));
			else if (PlayerPawn(Gun.WeaponController).Handedness == 1)
				C.SetPos(C.ClipX*0.497-(CrosshairTex.USize*CrossScale/2),C.ClipY*0.496-(CrosshairTex.VSize*CrossScale/2));
			else
				C.SetPos(C.ClipX*0.5-(CrosshairTex.USize*CrossScale/2),C.ClipY*0.5-(CrosshairTex.VSize*CrossScale/2));
		}
		else
			C.SetPos(C.ClipX*0.5-(CrosshairTex.USize*CrossScale/2),C.ClipY*0.5-(CrosshairTex.VSize*CrossScale/2));

		C.Style = CrossStyle;
		C.DrawColor = CrossColor;
		C.DrawIcon(CrosshairTex, CrossScale);
		Gun.WRenderOverlay(C);
	}
	C.Style = ERenderStyle.STY_Normal;

	o = 3; /*CurrentTeam; // use yellow always
	if( o>3 )
		o = 0;*/
	C.DrawColor = Class'UnrealTeamScoreBoard'.Default.TeamColor[o];
	C.Font = class'FontInfo'.Static.GetStaticSmallFont(C.ClipX);
	C.StrLen("ATST",XL,YL);
	if( Seat>0 && Driver!=None && Driver.PlayerReplicationInfo!=None )
	{
		C.SetPos(0,C.ClipY*2/3);
		C.DrawText(" Driver -" @ Driver.PlayerReplicationInfo.PlayerName);
		o = 1;
	}
	else o = 0;
	For( i=0; i<Arraycount(Passengers); i++ )
	{
		if( Passengers[i]!=None && Passengers[i].PlayerReplicationInfo!=None && (i+1)!=Seat )
		{
			C.SetPos(0,C.ClipY*2/3-YL*o);
			C.DrawText("" @ PassengerSeats[i].SeatName @ "-" @ Passengers[i].PlayerReplicationInfo.PlayerName);
			o++;
		}
	}
	// draw only if HP not visible
	if (HUD == None || HUD.bHideAllWeapons)
	{
		if( !bActorKeysInit )
			InitKeysInfo();
		C.Font = class'FontInfo'.Static.GetStaticAReallySmallFont(C.ClipX);
		XS = 4;
		For (i = 0; i < NumKeysInfo; i++)
		{
			if( KeysInfo[i]!="" )
			{
				C.TextSize(KeysInfo[i], XL, YL);
				C.SetPos(C.ClipX - XL - 4, XS);
				C.DrawText(KeysInfo[i]);
				XS+=YL;
			}
		}
	}
	
	// note for spectators
	CamOwner = Cam.GetCamOwner();
	if (CamOwner != None && HUD != None && C.Viewport.Actor != CamOwner)
	{	
		C.Font = class'FontInfo'.Static.GetStaticSmallFont( C.ClipX );
		C.bCenter = true;
		C.Style = ERenderStyle.STY_Normal;
		C.DrawColor = class'ChallengeHUD'.default.CyanColor * HUD.TutIconBlink;
		C.SetPos(4, C.ClipY - 96 * HUD.Scale);
		C.DrawText(HUD.LiveFeed $ CamOwner.PlayerReplicationInfo.PlayerName, true);
		C.bCenter = false;
		C.DrawColor = HUD.WhiteColor;
		C.Style = HUD.Style;
	}
	else
	{
		// draw info most important info
		exit = Class'KeyBindObject'.Static.FindKeyBinding("ThrowWeapon", self);
		if (exit == "")
			exit = "ThrowWeapon";
		str = "Main keys: <" $ exit $ "> = exit";
		if (Seat > 0)
			str = str $ ", <1> = change seat";
		else if (PassengerSeats[0].bIsAvailable)
			str = str $ ", <2> = change seat";
		if (StationaryPhys(self) != None)
			str = str $ ", <Back/Forward> = change zoom";
		C.Font = class'FontInfo'.Static.GetStaticSmallFont(C.ClipX);
		C.TextSize(str, XL, YL);
		C.SetPos((C.ClipX - XL)/2, class'PickupMessagePlus'.static.GetOffset(0, YL, C.ClipY) + YL);
		C.DrawText(str);
		
		if (class'XVehiclesHUD'.default.EnterCount <= 3 && 
			!IsDemoPlayback(Level) && class'XVehiclesHUD'.default.UsedHUD != None)
		{
			if (class'XVehiclesHUD'.default.UsedHUD.EnterLast <= Level.TimeSeconds)
			{
				class'XVehiclesHUD'.default.EnterCount++;
				class'XVehiclesHUD'.static.StaticSaveConfig();
			}
			class'XVehiclesHUD'.default.UsedHUD.EnterLast = Level.TimeSeconds + 3;
			
			exit = "<" $ exit $ "> = exit key";
			C.Font = class'FontInfo'.Static.GetStaticMediumFont(C.ClipX);
			C.TextSize(exit, XL, YL);
			C.SetPos((C.ClipX - XL)/2, class'CriticalEventPlus'.static.GetOffset(0, YL, C.ClipY) + YL);
			C.DrawText(exit);
		}
	}
	
	if( AttachmentList!=None )
		AttachmentList.AddCanvasOverlay(C);

	C.CurY = LastY;
}

// This function is NOT called by engine, its for Custom Mods to render vehcle status from a third person.
simulated function DrawVehicleStatus( Canvas C, vector CameraPos, rotator CameraRot )
{
	local float RendSize,X,Y,XS,YS,XL,YL,OffS;
	local int i;

	RendSize = VSize(CameraPos-Location)*(C.ViewPort.Actor.FovAngle/90.f);
	if( RendSize>4000 || (Driver!=None && Driver==C.ViewPort.Actor) )
		Return;
	For( i=0; i<ArrayCount(PassengerSeats); i++ )
	{
		if( Passengers[i]!=None && Passengers[i]==C.ViewPort.Actor )
			Return;
	}
	RendSize/=4000;
	RendSize = 1.1-RendSize;
	if( RendSize>1 )
		RendSize = 1;
	C.Style = 1;
	XS = 75.f*RendSize;
	YS = 8.f*RendSize;
	if( !bDriving )
	{
		if( bTeamLocked && C.ViewPort.Actor.PlayerReplicationInfo!=None && !C.ViewPort.Actor.PlayerReplicationInfo.bIsSpectator
		 && C.ViewPort.Actor.PlayerReplicationInfo.Team<=3 && C.ViewPort.Actor.PlayerReplicationInfo.Team!=CurrentTeam
		 && WorldToScreen(Location,C.ViewPort.Actor,CameraPos,CameraRot,C.ClipX,C.ClipY,X,Y) )
		{
			C.DrawColor.R = 255;
			C.DrawColor.G = 0;
			C.DrawColor.B = 0;
			C.SetPos(X-16f*RendSize,Y-16f*RendSize);
			C.DrawIcon(Texture'IconNoEnter',RendSize/2);
		}
		if( WorldToScreen(Location+vect(0,0,1)*CollisionHeight,C.ViewPort.Actor,CameraPos,CameraRot,C.ClipX,C.ClipY,X,Y) )
			DrawHealthBar(C,Health,Default.Health,X,Y-YS,XS,YS);
		if( CurrentTeam<=3 )
		{
			C.DrawColor = Class'UnrealTeamScoreBoard'.Default.TeamColor[CurrentTeam];
			C.Font = class'FontInfo'.Static.GetStaticSmallFont(C.ClipX);
			For( i=0; i<ArrayCount(PassengerSeats); i++ )
			{
				if( Passengers[i]!=None && Passengers[i].PlayerReplicationInfo!=None )
				{
					C.StrLen(Passengers[i].PlayerReplicationInfo.PlayerName,XL,YL);
					C.SetPos(X-XL/2,Y-YS-YL-1-OffS);
					OffS+=YL;
					C.DrawTextClipped(Passengers[i].PlayerReplicationInfo.PlayerName);
				}
			}
		}
	}
	else if( C.ViewPort.Actor.PlayerReplicationInfo!=None && (C.ViewPort.Actor.PlayerReplicationInfo.bIsSpectator
	 || (C.ViewPort.Actor.PlayerReplicationInfo.Team<=3 && C.ViewPort.Actor.PlayerReplicationInfo.Team==CurrentTeam))
	 && WorldToScreen(Location + CollisionHeight*1.1*vect(0,0,1),C.ViewPort.Actor,CameraPos,CameraRot,C.ClipX,C.ClipY,X,Y) )
	{
		C.DrawColor = Class'UnrealTeamScoreBoard'.Default.TeamColor[CurrentTeam];
		C.Font = class'FontInfo'.Static.GetStaticSmallFont(C.ClipX);
		if( Driver!=None && Driver.PlayerReplicationInfo!=None )
		{
			C.StrLen(Driver.PlayerReplicationInfo.PlayerName,XL,YL);
			C.SetPos(X-XL/2,Y-YS-YL-1);
			C.DrawTextClipped(Driver.PlayerReplicationInfo.PlayerName);
			OffS = YL;
		}
		For( i=0; i<ArrayCount(PassengerSeats); i++ )
		{
			if( Passengers[i]!=None && Passengers[i].PlayerReplicationInfo!=None )
			{
				C.StrLen(Passengers[i].PlayerReplicationInfo.PlayerName,XL,YL);
				C.SetPos(X-XL/2,Y-YS-YL-1-OffS);
				OffS+=YL;
				C.DrawTextClipped(Passengers[i].PlayerReplicationInfo.PlayerName);
			}
		}
		DrawHealthBar(C,Health,Default.Health,X,Y-YS,XS,YS);
	}
}
simulated function DrawHealthBar(Canvas C, int Health, int MaxHealth, int X, int Y, float HBWeight, float HBHeight )
{
	local float			HealthPct;

	if( Health>MaxHealth )
		Health = MaxHealth;

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	C.SetPos(X - HBWeight*0.5, Y);
//	C.DrawTile(Texture'BorderBoxD',HBWeight,HBHeight,0,0,64,64);
	C.DrawTile(Texture'Misc',HBWeight,HBHeight,60,60,64,64);
	
	HealthPct = float(Health) / float(MaxHealth);
	
	if (Health < (MaxHealth/5))
	{
		C.DrawColor.R = 96;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
	}
	else if (Health < (MaxHealth/4))
	{
		C.DrawColor.R = 255;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
	}
	else if (Health < (MaxHealth/3))
	{
		C.DrawColor.R = 255;
		C.DrawColor.G = 128;
		C.DrawColor.B = 0;
	}
	else if (Health < (MaxHealth/2))
	{
		C.DrawColor.R = 192;
		C.DrawColor.G = 192;
		C.DrawColor.B = 0;
	}
	else
	{
		C.DrawColor.R = 0;
		C.DrawColor.G = 255;
		C.DrawColor.B = 64;
	}
	
	C.SetPos(X - HBWeight * 0.5, Y);
//	C.DrawTile(Texture'HealthBar',HBWeight * HealthPct, HBHeight,0,0,64,64);
	C.DrawTile(Texture'Misc',HBWeight * HealthPct, HBHeight,60,60,64,64);
}

function vector VectorProjection(vector VProjector, vector VProjectedOn)
{
	return VProjectedOn + Normal(-VProjectedOn)*(((-VProjectedOn) dot ( VProjector - VProjectedOn )) / VSize( VProjectedOn));
}

simulated function Bump(Actor Other)
{
	if (bInBump)
		return;
	bInBump = true;
	SingularBump(Other);
	bInBump = false;
}

// not singular because v436 share singularity flag with state version of function
simulated function SingularBump(Actor Other)
{
	local vector OtVel,MyVel;
	local float Sp, Dmg;
	local vector Dir;
	local vector befOtVel, befMyVel, NVelH;
	local Pawn RealInstigator, RealOtherInstigator;
	local Vehicle Veh;
	
	if (Other == None || Other.bDeleteMe)
		return;
// log(Self @ Level.TimeSeconds @ "Bump" @ Other);
	Veh = Vehicle(Other);
	if (Veh != None)
	{
		Dir = Other.Location-Location;
		Dir.Z = 0;
		Sp = VSize(Dir) - (CollisionRadius + Other.CollisionRadius);
		if (Sp < -1 && StationaryPhys(self) == None) // stuck inside other
		{
			Sp -= 1;
			MoveSmooth(Sp*Normal(Dir));
			if (bCanFly)
				Rising = 1;
		}
		if( PendingBump==Other )
			Return; // Just bumped...

		OtVel = Other.Velocity;
		MyVel = Velocity;
		Dir = Normal(Other.Location-Location);

		befOtVel = Veh.VeryOldVel[1];
		befMyVel = VeryOldVel[1];
		
		if (Accel == 0)
		{
			if ((Normal(OtVel) dot vector(Rotation)) >= 0)
				OldAccelD = 1;
			else
				OldAccelD = -1;
				
			VirtOldAccel = OldAccelD;
		}

		Veh.PendingBump = Self;
		
		NVelH = Velocity - Other.Velocity;
		Sp = VSize(NVelH);
		
		RealInstigator = Instigator;
		if ((Velocity Dot Dir) <= 0)
			RealInstigator = Other.Instigator;
			
		RealOtherInstigator = Other.Instigator;
		if ((Other.Velocity Dot -Dir) <= 0)
			RealOtherInstigator = Instigator;
		
		if (Role == ROLE_Authority && Sp > 500)
		{
			Dmg = (Sp - 500) / 8;
/*
			log(self @ Health @ Vsize(Velocity) @ "make" @ Dmg @ "damage to" @ 
				Veh @ Veh.Health @ Vsize(Veh.Velocity) @ "via" @ Sp @ "at" $ chr(13) $ chr(10) $
				ConsoleCommand("BackTrace"));
// */
			Other.TakeDamage(Dmg,RealInstigator,Location,NVelH*Mass,'Crushed');
			TakeDamage(Dmg,RealOtherInstigator,Other.Location,NVelH*Other.Mass,'Crushed');
		}
		
		if (Other.Mass/Mass >= 2.0 && (Velocity Dot Dir)>0 )
			Velocity *= 0.25;
		else if (Other.Mass/Mass >= 2.0 || StationaryPhys(Other) != None)
		{
			Velocity = Other.Velocity * 1.15;
			Move((Veh.Location - Veh.LastLocation)*1.5);
		}
		else if ((Mass/Other.Mass >= 2.0 && (Velocity Dot Dir) > 0) || StationaryPhys(self) != None)
		{
			Other.Velocity = Velocity * 1.15;
			Other.Move((Location - LastLocation)*1.5);
			bHitASmallerVehicle = True;
		}
		else if (Mass/Other.Mass >= 2.0)
			Other.Velocity *= 0.25;
		else
		{
			if (Role == ROLE_Authority)
			{
				Sp = VSize(NVelH) * (Mass/Other.Mass);
				if( Sp>250 )
					Other.TakeDamage((Sp-200)/20,RealInstigator,Location,200*Normal(Velocity)*Mass,'Crushed');
		
				Sp = VSize(NVelH) * (Other.Mass/Mass);
				if( Sp>250 )
					TakeDamage((Sp-200)/20,RealOtherInstigator,Other.Location,200*Normal(OtVel)*Other.Mass,'Crushed');
			}
	
			NVelH = (Mass*befMyVel + Other.Mass*befOtVel) / (Mass+Other.Mass);	//Inelastic collision calculation (not the most realistic for vehicles, but good, reliable and simple enough for the main objectve)
	
			if (Self.IsA('WheeledCarPhys') || Self.IsA('TreadCraftPhys'))
			{
				if ( Vector(Rotation) Dot Normal(NVelH) > 0)
				{
					NVelH = VectorProjection(NVelH, 65535*vector(Rotation));
					OldAccelD = 1;
				}
				else
				{
					NVelH = VectorProjection(NVelH, -65535*vector(Rotation));
					OldAccelD = -1;
				}
	
				Veh.OldAccelD = OldAccelD;
			}
	
			Other.Velocity = NVelH;
			Velocity = NVelH*0.99;
		}
		
	}
	else if( (Normal(Velocity) Dot Normal(Other.Location-Location))>0 ) // We ran into this object.
	{
		if (!Other.bStatic && Other.bMovable)
		{
			if (Other.bIsPawn)
			{
				if (Other.Mass < Mass/3)
					bHitAPawn = True;
			}
			else if (Other.IsA('Decoration'))
			{
				if (Decoration(Other).bPushable)
				{
					bHitAnActor = 1.0f - 1.5*Other.Mass/Mass;
					PushDeco(Decoration(Other));
				}
			}
	
			if (Role == ROLE_Authority)
			{
				Dir = Normal(Other.Location - Location);
				Sp = Velocity dot Dir;
				if ((Owner == Other) || (Level.Game.bTeamGame && Pawn(Other) != None && Pawn(Other).PlayerReplicationInfo != None && 
					Pawn(Other).PlayerReplicationInfo.Team == CurrentTeam))
					; // not make any damage for same team, also for driver which exit recently too
				else if( Sp > 200 )
					Other.TakeDamage((Sp-100)/7*Mass/500.f,Instigator,Other.Location+Normal(Location-Other.Location)*Other.CollisionRadius,
						FMin(Mass*100, VSize(Velocity)*Other.Mass)*Normal(Velocity),'Crushed');
				// bad idea can cause recursive calls if pawn in middle between two vehicles.				
				/* else if (bHitAPawn)
					Other.MoveSmooth(Dir*3); */
			}
		}
		else if (Role == ROLE_Authority && VSize(VeryOldVel[1]) > 500)
			TakeImpactDamage((VSize(VeryOldVel[1]) - 500)/2,None, "Bump");
	}
}

function PushDeco(Decoration Deco)
{
	local float speed, oldZ;

	if (Deco != None)
	{
		Deco.bBobbing = false;
        oldZ = Deco.Velocity.Z;
        speed = VSize(Velocity);
        Deco.Velocity = Velocity * FMin(120.0, 20 + speed)/speed;
        if ( Deco.Physics == PHYS_None ) {
            Deco.Velocity.Z = 25;
            if (!Deco.bPushSoundPlaying) 
		Deco.PlaySound(Deco.PushSound, SLOT_Misc,0.25);
            Deco.bPushSoundPlaying = True;           
        }
        else
            Deco.Velocity.Z = oldZ;
        Deco.SetPhysics(PHYS_Falling);
        Deco.SetTimer(0.3,False);
        Deco.Instigator = Driver;
	}

}

simulated function bool CanGetOver( float MSHV, float AllowedZVal ) // Check if maxstepheight value allows to get over this
{
	local vector Start,End,Ex,NVe,HL,HN;
	local Actor A;
//	local vector MovVect;

	if (bSlopedPhys && GVT!=None)
	{
		if( MSHV<=0 )
			Return False;
		Ex.X = CollisionRadius;
		Ex.Y = Ex.X;
		Ex.Z = CollisionHeight;
		Start = Location;
		Start.Z += MSHV;
		NVe = vector(Rotation);
		if (NVe dot Velocity < 0)
			NVe = -NVe;
		NVe.Z = 0;
		NVe = Normal(NVe);
		End = Start + NVe*64;
		A = Trace(HL, HN, End, Start, True, Ex);
//Log(A @ VSize(HL-Start) @ MSHV @ (HL-Start) @ HN @ NVe);
		if (A != None)
		{
//			if( HN.Z>=AllowedZVal )
			if (VSize(Start-HL) >= 2*MSHV) // 30 degrees, almost same as AllowedZVal = 0.85, which is 31 degrees.
			{
				MSHV = HL.Z - (Location.Z - CollisionHeight) + 1;
//				MovVect = vect(0,0,1)*MSHV+NVe*VSize(Start-HL);
				if (!Move(vect(0,0,1)*MSHV))
				{
					Move(-12*NVe);
					Move(vect(0,0,1)*MSHV);
					Move(12*NVe);
				}
				Move(NVe*Min(12, VSize(Start-HL)));
				//Move(MovVect);
				//SetLocation(Location + MovVect);
				HitWall(HN,A);
				Return True;
			}
//			else
//				MoveSmooth(HN*16);
	
			Return False;
		}
		Start = End;
		End.Z-=MSHV;
		A = Trace(HL,HN,End,Start,True,Ex);
		
		if (A!=None)
			MSHV = HL.Z - (Location.Z - CollisionHeight) + 1;
		if (!Move(vect(0,0,1)*MSHV))
		{
			Move(-12*NVe);
			Move(vect(0,0,1)*MSHV);
			Move(12*NVe);
		}
		Move(NVe*12);
		//Move(MovVect);
		//SetLocation(Location + MovVect);
		HitWall(HN,A);
		Return True;

		/*
		if( A!=None && HN.Z>=AllowedZVal)
		{
			MSHV = HL.Z - (Location.Z - CollisionHeight) + 1;
			MovVect = vect(0,0,1)*MSHV+NVe*12;
			//Move(MovVect);
			SetLocation(Location + MovVect);
			HitWall(HN,A);
			Return True;
		}
	
		Return False;
		*/
	}
	else
		Super.CanGetOver( MSHV, AllowedZVal);
}

simulated function FellToGround();

simulated singular function Landed( vector HitNormal)
{
//	Log(self @ Level.TimeSeconds @ "Landed" @ HitNormal);
	HitWall(HitNormal, None);
	if (Driver != None)
	{
		if (Driver.IsInState('wandering'))
			Driver.GotoState('Attacking');
		else if (Driver.NextState == 'wandering')
		{
			Driver.NextState = 'Attacking';
			Driver.NextLabel = 'Begin';
		}
	}
}

simulated singular function HitWall( vector HitNormal, Actor Wall )
{
	local vector V;
	local float BMulti,VSpee;
	local vector OtherHitN;
//	Log(Name @ Level.TimeSeconds @ Location @ Velocity @ "HitWall" @ HitNormal @ Wall @ FallingLenghtZ);

	OtherHitN = HitNormal;

//	if (Bot(Driver) != None)
//		Driver.HitWall(HitNormal, Wall);

	if (!bReadyToRun && (Self.IsA('WheeledCarPhys') || Self.IsA('TreadCraftPhys')))
	{
		bReadyToRun = True;
		SetPhysics(PHYS_Projectile);
		return;
	}
	
	if (Level.NetMode == NM_Client && Driver == None && VSize(ServerState.Velocity) == 0)
	{
		if (VSize(Velocity) != 0)
			Velocity = ServerState.Velocity;
		if (Physics == PHYS_Falling)
			SetPhysics(PHYS_Projectile);
		return;
	}
	
	if ((GVTNormal.Z < -0.7 || FloorNormal.Z < -0.7) && HitNormal.Z > 0.7 && bDestroyUpsideDown)	//Upside down
	{
		TakeImpactDamage(Health*2, None, "HitWall_1"/* @ GVTNormal @ FloorNormal @ HitNormal*/);
		return;
	}

/*
	if ((Normal(Region.Zone.ZoneGravity) dot HitNormal) > 0.65)
	{
		V = Velocity;
		HitNormal.Z = 0;
		if( (Normal(Velocity) Dot HitNormal)>0 )
			Velocity = SetUpNewMVelocity(Velocity,HitNormal,0.5);
		else Velocity = SetUpNewMVelocity(Velocity,HitNormal,0.05);
		if( Wall!=Level && Wall.Brush==None )
			Return;
		BMulti = (Normal(V) Dot Normal(Velocity));
		VSpee = VSize(V);
		if( VSpee>500 && BMulti<-0.2 )
			TakeImpactDamage((VSpee-500)/2,None, "HitWall_2");
		else if( VSpee>600 && BMulti<0 )
			TakeImpactDamage((VSpee-600)/4,None, "HitWall_3");
		else if( VSpee>1300 && BMulti<0.3 )
			TakeImpactDamage((VSpee-1300)/5,None, "HitWall_4");
		else if (HitNormal.Z<0.45)
			TakeImpactDamage(0,None, "HitWall_5");

		MoveSmooth(-Normal(Velocity)*16);
		return;
	}
*/

	if (bGroundSim)
	{
		AirContact(HitNormal, Wall);
		return;
	}

	if (!bOnGround && HitNormal.Z > 0.65)
		FellToGround();

	if (bBigVehicle)
		MoveSmooth(OtherHitN/4);

	if (bSlopedPhys && Abs(FloorNormal.Z - HitNormal.Z) > 0.45)
	{
		HitNormal.Z = 0;

		// if OtherHitN.Z < 0 - get over can not be applied
		// Unfortunately BSP bugs can produce obstacles with such hit normal, but can be get over
		if( bOnGround /*&& OtherHitN.Z >= 0*/ && CanGetOver(MaxObstclHeight, 0.85) )
			Return;
		else if (VSize(HitNormal) > 0) // bounce from walls on collide. 
			MoveSmooth(HitNormal*16);
			
		HitNormal = OtherHitN;

		/*if (Abs(FloorNormal.Z - HitNormal.Z) < 0.75)
			MoveSmooth(HitNormal*16);*/
	}

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
		ActualGVTNormal = HitNormal;
		Velocity = SetUpNewMVelocity(Velocity,HitNormal,0);
		Return;
	}
	if( VSize(Normal(V)-Normal(Velocity))>0.85 || (bOnGround && !CanYawUpTo(Rotation,TransformForGroundRot(VehicleYaw,HitNormal),1500)))
	{
		if (HitNormal.Z >= 0)
		{
			if (HitNormal.Z < 0.8 && bSlopedPhys)	//Avoid jumping in simple slopes
			{
				if( bOnGround && CanGetOver(MaxObstclHeight,0.85) )
					Return;
			}
			else if (!bSlopedPhys)
			{
				if( bOnGround && CanGetOver(35,0.85) )
					Return;
			}
		}

		/*if (bSlopedPhys && (HitNormal Dot ActualFloorNormal) > 0.5 )
			ActualGVTNormal = ActualFloorNormal;*/

		bOnGround = False;
		V = Velocity;
		if( (Normal(Velocity) Dot HitNormal)>0 )
			Velocity = SetUpNewMVelocity(Velocity,HitNormal,0.5);
		else Velocity = SetUpNewMVelocity(Velocity,HitNormal,0.05);
		if( Wall!=Level && Wall.Brush==None )
			Return;
		BMulti = (Normal(V) Dot Normal(Velocity));
		VSpee = VSize(V);
		if( VSpee>500 && BMulti<-0.2 )
			TakeImpactDamage((VSpee-500)/2,None, "HitWall_6");
		else if( VSpee>600 && BMulti<0 )
			TakeImpactDamage((VSpee-600)/4,None, "HitWall_7");
		else if( VSpee>1300 && BMulti<0.3 )
			TakeImpactDamage((VSpee-1300)/5,None, "HitWall_8");
		else if (HitNormal.Z<0.45)
			TakeImpactDamage(0,None, "HitWall_9");

		Move(OtherHitN*3);
	}
	else
	{
		Velocity = SetUpNewMVelocity(Velocity,HitNormal,0);
		ActualFloorNormal = HitNormal;
		ActualGVTNormal = HitNormal;
		bOnGround = True;
	}
}

function TakeImpactDamage(int Damage, Pawn InstigatedBy, optional coerce string Reason, optional name DamageType)
{
// if (Damage > 0) Log(self @ Level.TimeSeconds @ "TakeImpactDamage" @ Damage @ InstigatedBy @ Reason @ Chr(13) $ Chr(10) $ ConsoleCommand("BACKTRACE"));
	if (DamageType == '')
		DamageType = 'BumpWall';
	TakeDamage(Damage, InstigatedBy, Location, vect(0,0,0), DamageType);
}

function FixDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	local string str;
	local Actor A;
	
	if (LifeSpan != 0)
		LifeSpan = FMax(LifeSpan, 5);
	
	if (Health >= FirstHealth)
	{
		if (DamageType == 'zapped' && EventInstigator != None && PulseGun(EventInstigator.Weapon) != None && 
			PulseGun(EventInstigator.Weapon).IsInState('AltFiring') && EventInstigator.Weapon.AmmoType != None)
			EventInstigator.Weapon.AmmoType.AddAmmo(1);
		return;
	}
	
	if (Health <= 0)
		return;
	Health += Damage;
	if (Health > FirstHealth)
		Health = FirstHealth;
	
	A = spawn(class'UT_SpriteSmokePuff', , , HitLocation);
	
	if (Health == FirstHealth || Level.TimeSeconds - LastFix > 1)
	{
		if (A != None && int(Level.TimeSeconds) % 3 == 0)
			A.PlaySound(FixSounds[Rand(ArrayCount(FixSounds))]);
		if (EventInstigator != None)
		{
			str = VehicleName;
			if (str == "")
				str = GetHumanName();
			EventInstigator.ClientMessage("You fix" @ str @ "damage up to" @ Health @ "out of" @ FirstHealth);
		}
		if (Pawn(Owner) != None && Owner != Instigator)
			Pawn(Owner).ClientMessage("Your vehicle is being fixed!", 'CriticalEvent');
	
		LastFix = Level.TimeSeconds;
	}
}

function bool IsSameTeam(Pawn Pawn)
{
	return Level.Game.bTeamGame && Pawn != none && Pawn.PlayerReplicationInfo != None && 
		Pawn.PlayerReplicationInfo.Team == CurrentTeam;
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
{
	local bool bHadPass;
	local int i, shldset, shldtkn;
//	Log(self @ Level.TimeSeconds @ "Health" @ Health @ "TakeDamage" @ Damage @ InstigatedBy @ hitlocation @ momentum @ damageType @ InstigatedBy.DamageScaling $ chr(13) $ chr(10) $ ConsoleCommand("BackTrace"));

	if (!bVehicleBlewUp && !(Level.Game != None && Level.Game.bGameEnded))
	{
		if (bDeleteMe || Level.NetMode == NM_Client)
			Return;
		if (damageType == 'jolted' && Damage > 100)
			Damage *= 0.05; // reduce instagib damage
		if (instigatedBy != None && damageType == 'zapped' && class'VehiclesConfig'.default.bPulseAltHeal &&
			(!Level.Game.bTeamGame || IsSameTeam(instigatedBy)))
		{
			FixDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
			return;
		}
		else if (Driver == None)
		{
			For (i = 0; i < Arraycount(Passengers); i++)
			{
				if (Passengers[i] != None)
				{
					bHadPass = True;
					Damage = Level.Game.ReduceDamage(Damage, DamageType, Passengers[i], instigatedBy);
					if (Damage > 0 && IsSameTeam(instigatedBy))
						Damage = 0;
					Break;
				}
			}
			if (!bTakeAlwaysDamage && !bHadPass && IsSameTeam(instigatedBy))
				Damage = 0;
			else
				Damage = Level.Game.ReduceDamage(Damage, DamageType, SpawnStubPawn(self), instigatedBy);
		}
		else if (Driver.ReducedDamageType == 'All') // God mode on!
			Damage = 0;
		else
		{
			Damage = Level.Game.ReduceDamage(Damage, DamageType, Driver, instigatedBy);
			if (Damage > 0 && IsSameTeam(instigatedBy))
				Damage = 0;
		}
		if (instigatedBy != None)
		{
			if( Driver!=None )
				Driver.damageAttitudeTo(instigatedBy);
			For( i=0; i<Arraycount(Passengers); i++ )
			{
				if( Passengers[i]!=None )
					Passengers[i].damageAttitudeTo(instigatedBy);
			}
		}
	
		For (i=0; i<ArrayCount(ArmorType); i++)
		{
			if (ArmorType[i].ArmorLevel < 0.0 || ArmorType[i].ArmorLevel > 1.0)
				ArmorType[i].ArmorLevel = 1.0;
			if (ArmorType[i].ProtectionType != '' && ArmorType[i].ProtectionType == damageType)
				Damage -= (Damage*ArmorType[i].ArmorLevel);
		}
	
		if (bEnableShield)
		{
			For(i = 0; i < ArrayCount(ShieldType); i++)
			{
				if (ShieldType[i] != '')
				{
					shldset++;
					if (bProtectAgainst && ShieldType[i] == damageType)
						Damage -= (Damage*ShieldLevel);
					else if (!bProtectAgainst && ShieldType[i] != damageType)
						shldtkn++;
				}
			}
			if (!bProtectAgainst && shldset == shldtkn)
				Damage -= (Damage*ShieldLevel);
		}
	
		if( damageType!='BumpWall' && Damage > 0)
			PlaySound(BulletHitSounds[Rand(ArrayCount(BulletHitSounds))],SLOT_Pain,FClamp(float(Damage)/20,0.75,2));
		else if (damageType=='BumpWall')
			PlaySound(ImpactSounds[Rand(ArrayCount(ImpactSounds))],SLOT_Pain,FClamp(float(Damage)/50,0.75,2));
		
		if (instigatedBy != None)
			MakeHitSound(PlayerPawn(instigatedBy), Damage);
		
		Health-=Damage;
		Velocity+=momentum/Mass;
		if( Health<=0 )
		{
			Instigator = instigatedBy;
			KillDriver(instigatedBy, damageType);
			Instigator = instigatedBy;
			GoToState('BlownUp');
		} 
		else if (Damage > 0)
			CheckForEmpty();
	}
}

State BlownUp
{
Ignores DriverEnter,Tick,ServerPackState,Bump;

	function PassengerEnter( Pawn Other, byte Seat, optional int MyPitch, optional int MyYaw );

Begin:
	bVehicleBlewUp = True;
	//if( Level.NetMode!=NM_DedicatedServer )
		SpawnExplosionFX();
	Sleep(0.25);
	Destroy();
}

function KillDriver( Pawn Killer, name damageType )
{
	local Pawn D;
	local int i;

	if( Driver!=None )
	{
		D = Driver;
		DriverLeft(True, "KillDriver");
		D.Died(Killer, damageType, Location);
	}
	For( i=0; i<ArrayCount(Passengers); i++ )
	{
		if( Passengers[i]!=None )
		{
			D = Passengers[i];
			PassengerLeave(i,True);
			D.Died(Killer, damageType, Location);
		}
	}
}

// make hit sound for UTPure
function MakeHitSound(PlayerPawn Instigator, int Damage)
{
	local Pawn Damaged, P;
	local int i;
	if (Instigator == None || ClassPureHitSound == None)
		return;
	if (Driver != None)
		Damaged = Driver;
	else
		For (i = 0; i < ArrayCount(Passengers); i++)
			if (Passengers[i] != None)
			{
				Damaged = Passengers[i];
				break;
			}
	if (Damaged == None)
		return;
	Instigator.ReceiveLocalizedMessage(ClassPureHitSound, Damage, Damaged.PlayerReplicationInfo, 
		Instigator.PlayerReplicationInfo);
	for (P = Level.PawnList; P != None; P = P.NextPawn)
		if (Spectator(P) != None && Spectator(P).ViewTarget != None && 
			(Spectator(P).ViewTarget == Instigator || 
			Spectator(P).ViewTarget == DriverCameraActor(Instigator.ViewTarget)))
			P.ReceiveLocalizedMessage(ClassPureHitSound, Damage, Damaged.PlayerReplicationInfo, 
				Instigator.PlayerReplicationInfo);
}

simulated function CastVectorialExpl(byte j, vector EXHOffSet)
{
local Effects exhx;

	if (bSlopedPhys && GVT!=None)
		exhx = Spawn(ExplosionGFX[j].ExplClass,,, Location + GVT.PrePivot + (EXHOffSet >> Rotation));
	else
		exhx = Spawn(ExplosionGFX[j].ExplClass,,, Location + (EXHOffSet >> Rotation));

	exhx.DrawScale = ExplosionGFX[j].ExplSize;
}

simulated function ClientShakes(float dist)
{
local PlayerPawn PP;
local float d;

	if (bExplShake && ExplShakeTime > 0 && ExplShakeMag > 0)
	{
		ForEach RadiusActors(Class'PlayerPawn', PP, dist)
			if (DriverWeapon(PP.Weapon) == None || class'VehiclesConfig'.default.bAllowCameraShakeInVehicle)
			{
				d = dist - VSize(PP.Location - Location);
				PP.ShakeView( ExplShakeTime, d*ExplShakeMag/dist , d*ExplShakeMag/10/dist);
			}
	}
}


simulated function SpawnExplosionFX()
{
	local VehicleAttachment W,NW;
	local Effects exhx;
	local TornOffCarPartActor WT;
	local int i, rnd;
	local vector vxc;

	rnd = Min(Rand(5),4);

	HurtRadius(DestroyedExplDmg,FMax(CollisionRadius,CollisionHeight)*3.25,'VehicleExplosion',Mass*25,Location);

	ClientShakes(FMax(CollisionRadius,CollisionHeight)*4.5);

	if (UseExplosionSnd1)
		i++;
	if (UseExplosionSnd2)
		i+=2;

	if (i == 3 && Rand(100)>=50)
		i = 1;
	else if (i == 3)
		i = 2;

	//Custom primary sound
	if (RndExplosionSnd[rnd] != None && i==1)
	{
		PlaySound(RndExplosionSnd[rnd],SLOT_Pain,RndExploSndVol,,RndExploSndRange);
		PlaySound(RndExplosionSnd[rnd],SLOT_Misc,RndExploSndVol,,RndExploSndRange);
	}

	rnd = Min(Rand(5),4);

	//Custom secondary sound
	if (RndSecExplosionSnd[rnd] != None && i==2)
	{
		PlaySound(RndSecExplosionSnd[rnd],SLOT_Pain,RndExploSndVol,,RndExploSndRange);
		PlaySound(RndSecExplosionSnd[rnd],SLOT_Misc,RndExploSndVol,,RndExploSndRange);
	}

	SetCollision(False,False,False);
	bHidden = True;

	//Custom explosion set
	if (Level.NetMode != NM_DedicatedServer)
		for (i = 0; i < ArrayCount(ExplosionGFX); i++)
		{
			if (ExplosionGFX[i].bHaveThisExplFX)
			{
				if (ExplosionGFX[i].bUseCoordOffset)
				{
					vxc = ExplosionGFX[i].ExplFXOffSet;
	
					CastVectorialExpl( i, vxc);
	
					if (ExplosionGFX[i].bSymetricalCoordX)
					{
						vxc.X = -vxc.X;
						CastVectorialExpl( i, vxc);
					}
	
					if (ExplosionGFX[i].bSymetricalCoordY)
					{
						vxc.Y = -vxc.Y;
						CastVectorialExpl( i, vxc);
						
						if (ExplosionGFX[i].bSymetricalCoordX)
						{
							vxc.X = -vxc.X;
							CastVectorialExpl( i, vxc);
						}
					}
				}
				else if (ExplosionGFX[i].AttachName != '')
				{
					For( W=AttachmentList; W!=None; W=W.NextAttachment )
					{
						if (W.IsA(ExplosionGFX[i].AttachName))
						{
							exhx = Spawn(ExplosionGFX[i].ExplClass,,, W.Location);
							exhx.DrawScale = ExplosionGFX[i].ExplSize;
						}
					}
				}
				else
				{
					exhx = Spawn(ExplosionGFX[i].ExplClass,,, Location);
					exhx.DrawScale = ExplosionGFX[i].ExplSize;
				}
					
			}
		}

	For( W=AttachmentList; W!=None; W=NW )
	{
		NW = W.NextAttachment;
		if( W.bAutoDestroyWithVehicle )
		{
			if( RemoteRole != ROLE_None || Level.NetMode!=NM_DedicatedServer ) // Make these parts "fly off" with the vehicle.
			{
				WT = Spawn(Class'TornOffCarPartActor',Self,,W.Location,W.Rotation);
				if (WT != None)
				{
					if (Level.NetMode==NM_DedicatedServer)
						WT.RemoteRole = ROLE_SimulatedProxy;
					WT.CopyDisplayFrom(W,Self);
					WT.SetInitialSpeed(W.PartMass);
					WT.SetCollisionSize(W.CollisionRadius,W.CollisionHeight);
				}

				if (W.IsA('WeaponAttachment'))
				{
					if (WeaponAttachment(W).bHasPitchPart && WeaponAttachment(W).PitchPart!=None)
					{
						WT = Spawn(Class'TornOffCarPartActor',Self,,WeaponAttachment(W).PitchPart.Location,WeaponAttachment(W).PitchPart.Rotation);
						if (WT != None)
						{
							if (Level.NetMode==NM_DedicatedServer)
								WT.RemoteRole = ROLE_SimulatedProxy;
							WT.CopyDisplayFrom(WeaponAttachment(W).PitchPart,Self);
							WT.SetInitialSpeed(WeaponAttachment(W).PitchPart.PartMass);
							WT.SetCollisionSize(WeaponAttachment(W).PitchPart.CollisionRadius,WeaponAttachment(W).PitchPart.CollisionHeight);
						}
					}
				}
			}

			W.Destroy();
		}
		else W.NotifyVehicleDestroyed();
	}
	AttachmentList = None;

	if (bSlopedPhys && GVT!=None)
		WT = Spawn(Class'TornOffCarPartActor',Self,,GVT.PrePivot + Location,Rotation);
	else
		WT = Spawn(Class'TornOffCarPartActor',Self,,Location,Rotation);

	if (WT != None)
	{
		WT.CopyDisplayFrom(Self,Self);
		WT.SetInitialSpeed(Byte(VehicleGravityScale-1));
		WT.SetCollisionSize(WreckPartColRadius,WreckPartColHeight);
	}

	SpawnFurtherParts();

	bMovable = False;

	if (bSlopedPhys && GVT!=None)
		GVT.Destroy();
	
}

simulated function SpawnFurtherParts();	//use this to spawn further destroyed parts if needed or add more effects

/*simulated function SpawnExplosionFX()
{
	local SilentBallExplosion S;
	local VehicleAttachment W,NW;
	local TornOffCarPartActor WT;
	local int i;
	local Fragment Fr;

	S = Spawn(Class'SilentBallExplosion');
	if( S==None )
		Return;
	S.DrawScale*=CollisionRadius/10;

	if( Level.NetMode!=NM_DedicatedServer )
	{
		for( i=Rand(10); i<20; i++ )
		{
			Fr = Spawn(Class'Fragment1',,,Location+VRand()*CollisionHeight);
			If (Fr!=none && !Fr.bdeleteme)
			{
				Fr.CalcVelocity(Velocity+VRand()*800,0);
				Fr.Skin = texture'JSteelBarrel2';
				Fr.DrawScale = 0.5+1.5*FRand();
			}
		}
	}
	PlaySound(Sound'Explo1',SLOT_Pain,2);
	PlaySound(Sound'Explo1',SLOT_Misc,2);
	SetCollision(False,False,False);
	bHidden = True;

	if (bSlopedPhys && GVT!=None)
		GVT.bHidden = True;

	bMovable = False;
	For( W=AttachmentList; W!=None; W=NW )
	{
		NW = W.NextAttachment;
		if( W.bAutoDestroyWithVehicle )
		{
			if( Level.NetMode!=NM_DedicatedServer ) // Make these parts "fly off" with the vehicle.
			{
				WT = Spawn(Class'TornOffCarPartActor',Self,,W.Location,W.Rotation);
				WT.CopyDisplayFrom(W);
			}
			W.Destroy();
		}
		else W.NotifyVehicleDestroyed();
	}
	AttachmentList = None;
}*/


simulated function SetOverlayMat( Texture MatTex, float MatDispTime )
{
	if (!class'VehiclesConfig'.default.bDisableTeamSpawn)
	{
		if( Level.NetMode>NM_StandAlone && Level.NetMode<NM_Client )
		{
			ReplicOverlayMat.MatTexture = MatTex;
			ReplicOverlayMat.MatDispTime = byte(MatDispTime*25.f);
			bResetOLRep = True;
			OverlayResetTime = Level.TimeSeconds+0.25;
		}
		if( Level.NetMode!=NM_DedicatedServer )
		{
			OverlayMat = MatTex;
			OverlayTime = MatDispTime;
		}
	}
}

// Called whenever driver or passenger wants to change seat.
function ChangeSeat( byte SeatNum, bool bWasPassenger, byte PassengerNum )
{
	local Pawn InvPawn,OthPawn;

	if( !bWasPassenger )
		InvPawn = Driver;
	else
		InvPawn = Passengers[PassengerNum];
	if( InvPawn==None || SeatNum>ArrayCount(PassengerSeats) || (SeatNum>0 && !PassengerSeats[SeatNum-1].bIsAvailable) )
		Return;
	if( SeatNum==0 )
	{
		if( !bWasPassenger )
			Return;
		if( bDriving )
		{
			if( PlayerPawn(Driver)!=None )
				Return;
			DoChangeSeat = true;
			// Allow player swap places with bots!
			OthPawn = Driver;
			DriverLeft(True, "ChangeSeat 1");
			PassengerLeave(PassengerNum,True);
			DriverEnter(InvPawn,
				PassengerSeats[PassengerNum].PassengerCam.Rotation.Pitch, 
				PassengerSeats[PassengerNum].PassengerCam.Rotation.Yaw);
			PassengerEnter(OthPawn,PassengerNum);
			DoChangeSeat = false;
		}
		else
		{
			DoChangeSeat = true;
			PassengerLeave(PassengerNum,True);
			DriverEnter(InvPawn, 
				PassengerSeats[PassengerNum].PassengerCam.Rotation.Pitch, 
				PassengerSeats[PassengerNum].PassengerCam.Rotation.Yaw);
			DoChangeSeat = false;
		}
	}
	else
	{
		if( (bWasPassenger && (PassengerNum+1)==SeatNum) )
			Return;
		if( !PassengerSeatAvailable(SeatNum-1) )
		{
			if( PlayerPawn(Passengers[SeatNum-1])!=None )
				Return;
			DoChangeSeat = true;
			if( bWasPassenger )
				PassengerLeave(PassengerNum,True);
			else DriverLeft(True, "ChangeSeat 2");
			OthPawn = Passengers[SeatNum-1];
			PassengerLeave(SeatNum-1,True);
			PassengerEnter(InvPawn,SeatNum-1, 
				MyCameraAct.Rotation.Pitch, 
				MyCameraAct.Rotation.Yaw);
			if( bWasPassenger )
				PassengerEnter(OthPawn,PassengerNum);
			else DriverEnter(OthPawn);
			DoChangeSeat = false;
		}
		else
		{
			DoChangeSeat = true;
			if( bWasPassenger )
				PassengerLeave(PassengerNum,True);
			else DriverLeft(True, "ChangeSeat 3");
			PassengerEnter(InvPawn,SeatNum-1, 
				MyCameraAct.Rotation.Pitch, 
				MyCameraAct.Rotation.Yaw);
			DoChangeSeat = false;
		}
	}
}

function bool CanAddPassenger( Pawn Other, optional out byte FreeSlot )
{
	local int i;

	if( !CanEnter(Other) || (Level.Game.bDeathMatch && !Level.Game.bTeamGame) )
		Return False;
	if (Level.Game.bTeamGame && Level.Game.bDeathMatch && Driver != None && Driver.PlayerReplicationInfo != None)
	{
		if( Other.PlayerReplicationInfo==None || Other.PlayerReplicationInfo.Team!=Driver.PlayerReplicationInfo.Team )
			Return False;
	}
	For( i=0; i<ArrayCount(PassengerSeats); i++ )
	{
		if( PassengerSeats[i].bIsAvailable && Passengers[i]==None )
		{
			FreeSlot = i;
			Return True;
		}
	}
	Return False;
}
simulated function bool HasPassengers()
{
	local int i;

	For( i=0; i<ArrayCount(PassengerSeats); i++ )
	{
		if( PassengerSeats[i].bIsAvailable && Passengers[i]!=None )
		{
			if (Passengers[i].PlayerReplicationInfo != None)
				CurrentTeam = Passengers[i].PlayerReplicationInfo.Team;
			bHasPassengers = true;
			Return True;
		}
	}
	bHasPassengers = false;
	Return False;
}
function bool HasFreePassengerSeat(optional out byte SeatNum)
{
	local int i;

	for (i = ArrayCount(PassengerSeats) - 1; i >= 0; i--)
	{
		if (PassengerSeats[i].bIsAvailable && Passengers[i] == None)
		{
			SeatNum = i;
			return true;
		}
	}
	return false;
}
function bool PassengerSeatAvailable( byte SNum )
{
	if( SNum>=ArrayCount(PassengerSeats) )
		Return False;
	Return (PassengerSeats[SNum].bIsAvailable && Passengers[SNum]==None);
}
function PassengerEnter( Pawn Other, byte Seat, optional int MyPitch, optional int MyYaw )
{
	local rotator R, RotRollZero;

	RotRollZero = Rotation;
	RotRollZero.Roll = 0;
	ChangeCollision(Other, true, Seat + 1);
	Passengers[Seat] = Other;
	if (PassengerSeats[Seat].PGun != None)
	{
		if (Seat == 0 && DriverGun == None && PlayerPawn(Driver) != None && 
			PassengerSeats[Seat].PGun.WeaponController == Driver)
			PlayerPawn(Driver).EndZoom();
		PassengerSeats[Seat].PGun.WeaponController = Other;
		PassengerSeats[Seat].PGun.SetOwner(Other);
	}
	if (PassengerSeats[Seat].PHGun == None)
	{
		PassengerSeats[Seat].PHGun = SpawnWeapon(DriverWeaponClass,Seat + 1,Other);
		PassengerSeats[Seat].PHGun.bPassengerGun = True;
		PassengerSeats[Seat].PHGun.SeatNumber = Seat;
	}
	else PassengerSeats[Seat].PHGun.ChangeOwner(Other);
	PassengerSeats[Seat].PHGun.NotifyNewDriver(Other);
	SwitchWeapon(Other, PassengerSeats[Seat].PHGun);
	AddShield(Other);
	if (Other.Inventory != None)
		Other.Inventory.ChangedWeapon();	
	if (Other.CarriedDecoration != None)
		Other.DropDecoration();
	if (DropFlag == DF_All)
		TryDropFlag(Other);
	if (PlayerPawn(Other) != None)
	{
		//Other.ClientMessage(PassengerSeats[Seat].SeatName,'Pickup');
		Other.ReceiveLocalizedMessage(class'EnterMessagePlus', Seat + 2, None, None, Self);
		if (MyYaw != 0)
			R.Yaw = MyYaw;
		else if (PassengerSeats[Seat].PGun != None)
			R.Yaw = PassengerSeats[Seat].PGun.TurretYaw;
		else R.Yaw = VehicleYaw;
		R.Pitch = MyPitch;
		PlayerPawn(Other).ClientSetRotation(R);
		PlayerPawn(Other).bBehindView = False;
		PlayerPawn(Other).EndZoom();
		Other.GoToState('PlayerFlying');
	}
	if (PassengerSeats[Seat].PassengerCam == None)
	{
		PassengerSeats[Seat].PassengerCam = Spawn(Class'PassengerCameraA',Other,,,RotRollZero);
		PassengerSeats[Seat].PassengerCam.VehicleOwner = Self;
		PassengerSeats[Seat].PassengerCam.SeatNum = Seat+1;
		PassengerSeats[Seat].PassengerCam.GunAttachM = PassengerSeats[Seat].PGun;
	}
	else PassengerSeats[Seat].PassengerCam.SetOwner(Other);
	PassengerSeats[Seat].PassengerCam.setCamOwner(Other);
	
	bHasPassengers = true;
	CheckForEmpty();
	ShowState();
	
	ChangeProps(Other, true, Seat + 1, PassengerSeats[Seat].PGun);
}
function PassengerLeave( byte Seat, optional bool bForcedLeave )
{
	local vector ExitVect, Spot;
	local Pawn Other;
	local bool bFree;

	if (Passengers[Seat] != None)
	{
		if (!Passengers[Seat].bDeleteMe && !DoChangeSeat)
		{
			ExitVect = GetExitOffset(Passengers[Seat]);
			if (Bot(Passengers[Seat]) == None && (Normal(Velocity) Dot Normal(ExitVect >> Rotation)) > 0.35 &&
				(Normal(Velocity) Dot Normal((ExitVect + vect(0,-2,0)*ExitVect.Y) >> Rotation)) <= 0.35)
				ExitVect.Y = -ExitVect.Y;
			bFree = FindExitSpot(Passengers[Seat], ExitVect, Spot);
			if (!bFree && !bForcedLeave)
			{
				if (PlayerPawn(Passengers[Seat]) != None)
					Passengers[Seat].ClientMessage("No room to get out here.", 'CriticalEvent');
				return;
			}
		}
		if (Passengers[Seat].bDeleteMe)
			Passengers[Seat] = None;
		else
		{
			Passengers[Seat].DrawScale = Passengers[Seat].Default.DrawScale;
			if (PlayerPawn(Passengers[Seat]) != None && Passengers[Seat].Health > 0 && 
				Driver != None && Driver.IsInState('PlayerFlying'))
				Passengers[Seat].GoToState('PlayerWalking');
			RestartPawn(Passengers[Seat]);
			ChangeCollision(Passengers[Seat], false, Seat + 1);

			if (DoChangeSeat)
				; // stays aboard, ChangeSeat puts the pawn in its new seat
			else if (!bFree || !Passengers[Seat].SetLocation(Spot))
				Passengers[Seat].Move(Location + (ExitVect >> Rotation) - Passengers[Seat].Location);
			ProcessExit(Passengers[Seat], PassengerSeats[Seat].PassengerCam);
			if (!DoChangeSeat)
			{
				LastExitPawn = Passengers[Seat];
				LastExitTime = Level.TimeSeconds;
			}
		}
	}
	if (PassengerSeats[Seat].PGun != None)
	{
		if (Seat == 0 && DriverGun == None)
			Other = Driver;
		PassengerSeats[Seat].PGun.WeaponController = Other;
		PassengerSeats[Seat].PGun.SetOwner(Other);
	}
	if (PassengerSeats[Seat].PHGun != None)
	{
		PassengerSeats[Seat].PHGun.NotifyDriverLeft(Driver);
		PassengerSeats[Seat].PHGun.ChangeOwner(None);
	}
	if (PassengerSeats[Seat].PassengerCam != None && PassengerSeats[Seat].PassengerCam.Owner != None )
		PassengerSeats[Seat].PassengerCam.SetCamOwner(None);
	if (Passengers[Seat] != None)
	{
		ChangeProps(Passengers[Seat], false, Seat + 1);
	}
	Passengers[Seat] = None;

	HasPassengers();
	CheckForEmpty();
	ShowState();
}
function PassengerFireWeapon( bool bAltFire, byte Seat )
{
	local int i;

	if( PassengerSeats[Seat].PGun==None )
		Return;
	if( bAltFire )
		i = 1;
	PassengerSeats[Seat].PGun.FireTurret(i);
}

simulated function CheckForEmpty()
{
	local bool bEmpty;
	
	bEmpty = Driver == None && Health > 0 && !bDeleteMe;
	if (!bEmpty || MyFactory == None || HasPassengers())
		LifeSpan = 0;
	else if (LifeSpan == 0)
		LifeSpan = MyFactory.VehicleResetTime;
	if (bEmpty && !IsInState('EmptyVehicle'))
		GoToState('EmptyVehicle');
}

/*simulated function vector GetPassengerWOffset( byte Seat )
{
	Return Location+(PassengerSeats[Seat].PassengerWOffset >> Rotation);
}*/

simulated function vector GetPassengerWOffset( byte Seat )
{
	Return PassengerSeats[Seat].PassengerWOffset;
}

// AI hint.
function bool IsWorthyPassengerSeats()
{
	local int i;

	For( i=0; i<8; i++ )
	{
		if( PassengerSeats[i].bIsAvailable && Passengers[i]==None )
			Return (PassengerSeats[i].PGun!=None); // We don't want to enter empty passenger seats!
	}
}

// Returns the AVRiL rocket aim position
simulated function vector GetAimPosition()
{
	Return Location;
}

simulated function Detach(Actor Other)
{
	Super.Detach(Other);
	if (Pawn(Other) != None)
		Other.Velocity += Velocity; // inertial detach
}

simulated function bool PreTeleport( Teleporter InTeleporter )
{
	if (LastTeleportTime > 0 && Level.TimeSeconds < LastTeleportTime + 2)
		return true; // block
	LastTeleportTime = Level.TimeSeconds;
	LastTeleportYaw = Rotation.Yaw;
	bLastTeleport = true;
	return false; // allow
}

function float GetVehAIRatingScale(Pawn Seeker)
{
	return 1;
}

defaultproperties
{
	AIRating=1.000000
	VehicleGravityScale=1.000000
	WAccelRate=250.000000
	Health=100
	AIClass=Class'VAIBehaviour'
	DriverWeaponClass=Class'DriverWeapon'
	bShouldRepVehYaw=True
	VehicleName="Vehicle"
	MsgVehicleDesc="Zoom out the HUD to read the help in the top right corner of the screen."
	ExitOffset=(Y=45.000000)
	BehinViewViewOffset=(X=-650.000000,Z=120.000000)
	InsideViewOffset=(X=5.000000,Y=-15.000000)
	SpawnSound=Sound'XVehicles.Effects.BWeaponSpawn1'
	ImpactSounds(0)=Sound'XVehicles.Impacts.VehicleCollision01'
	ImpactSounds(1)=Sound'XVehicles.Impacts.VehicleCollision02'
	ImpactSounds(2)=Sound'XVehicles.Impacts.VehicleCollision03'
	ImpactSounds(3)=Sound'XVehicles.Impacts.VehicleCollision04'
	ImpactSounds(4)=Sound'XVehicles.Impacts.VehicleCollision05'
	ImpactSounds(5)=Sound'XVehicles.Impacts.VehicleCollision06'
	ImpactSounds(6)=Sound'XVehicles.Impacts.VehicleCollision07'
	BulletHitSounds(0)=Sound'XVehicles.Impacts.VehicleHitBullet01'
	BulletHitSounds(1)=Sound'XVehicles.Impacts.VehicleHitBullet02'
	BulletHitSounds(2)=Sound'XVehicles.Impacts.VehicleHitBullet03'
	BulletHitSounds(3)=Sound'XVehicles.Impacts.VehicleHitBullet04'
	BulletHitSounds(4)=Sound'XVehicles.Impacts.VehicleHitBullet05'
	BulletHitSounds(5)=Sound'XVehicles.Impacts.VehicleHitBullet06'
	bUseBehindView=True
	TeamOverlays(0)=FireTexture'UnrealShare.Belt_fx.ShieldBelt.RedShield'
	TeamOverlays(1)=FireTexture'UnrealShare.Belt_fx.ShieldBelt.BlueShield'
	TeamOverlays(2)=FireTexture'UnrealShare.Belt_fx.ShieldBelt.Greenshield'
	TeamOverlays(3)=FireTexture'UnrealShare.Belt_fx.ShieldBelt.N_Shield'
	bTakeAlwaysDamage=True
	PassengerSeats(0)=(CamBehindviewOffset=(X=-80.000000,Z=30.000000),SeatName="Passenger Seat")
	PassengerSeats(1)=(CamBehindviewOffset=(X=-80.000000,Z=30.000000),SeatName="Passenger Seat")
	PassengerSeats(2)=(CamBehindviewOffset=(X=-80.000000,Z=30.000000),SeatName="Passenger Seat")
	PassengerSeats(3)=(CamBehindviewOffset=(X=-80.000000,Z=30.000000),SeatName="Passenger Seat")
	PassengerSeats(4)=(CamBehindviewOffset=(X=-80.000000,Z=30.000000),SeatName="Passenger Seat")
	PassengerSeats(5)=(CamBehindviewOffset=(X=-80.000000,Z=30.000000),SeatName="Passenger Seat")
	PassengerSeats(6)=(CamBehindviewOffset=(X=-80.000000,Z=30.000000),SeatName="Passenger Seat")
	PassengerSeats(7)=(CamBehindviewOffset=(X=-80.000000,Z=30.000000),SeatName="Passenger Seat")
	FloorNormal=(Z=1.000000)
	ActualFloorNormal=(Z=1.000000)
	GVTNormal=(Z=1.000000)
	ActualGVTNormal=(Z=1.000000)
	bCameraOnBehindView=True
	ReqPPPhysics=PHYS_Flying
	MaxObstclHeight=35.000000
	bDisableTeamSpawn=True
	WDeAccelRate=100.000000
	OldAccelD=1
	VirtOldAccel=1
	OldHN=(X=10.000000)
	DriverCrosshairTex=Texture'XVehicles.HUD.CrCorrectAim'
	PassCrosshairTex(0)=Texture'XVehicles.HUD.CrCorrectAim'
	PassCrosshairTex(1)=Texture'XVehicles.HUD.CrCorrectAim'
	PassCrosshairTex(2)=Texture'XVehicles.HUD.CrCorrectAim'
	PassCrosshairTex(3)=Texture'XVehicles.HUD.CrCorrectAim'
	PassCrosshairTex(4)=Texture'XVehicles.HUD.CrCorrectAim'
	PassCrosshairTex(5)=Texture'XVehicles.HUD.CrCorrectAim'
	PassCrosshairTex(6)=Texture'XVehicles.HUD.CrCorrectAim'
	PassCrosshairTex(7)=Texture'XVehicles.HUD.CrCorrectAim'
	DriverCrossColor=(R=110,G=255,B=110)
	PassCrossColor(0)=(R=110,G=255,B=110)
	PassCrossColor(1)=(R=110,G=255,B=110)
	PassCrossColor(2)=(R=110,G=255,B=110)
	PassCrossColor(3)=(R=110,G=255,B=110)
	PassCrossColor(4)=(R=110,G=255,B=110)
	PassCrossColor(5)=(R=110,G=255,B=110)
	PassCrossColor(6)=(R=110,G=255,B=110)
	PassCrossColor(7)=(R=110,G=255,B=110)
	DriverCrossScale=1.000000
	PassCrossScale(0)=1.000000
	PassCrossScale(1)=1.000000
	PassCrossScale(2)=1.000000
	PassCrossScale(3)=1.000000
	PassCrossScale(4)=1.000000
	PassCrossScale(5)=1.000000
	PassCrossScale(6)=1.000000
	PassCrossScale(7)=1.000000
	DriverCrossStyle=STY_Translucent
	PassCrossStyle(0)=STY_Translucent
	PassCrossStyle(1)=STY_Translucent
	PassCrossStyle(2)=STY_Translucent
	PassCrossStyle(3)=STY_Translucent
	PassCrossStyle(4)=STY_Translucent
	PassCrossStyle(5)=STY_Translucent
	PassCrossStyle(6)=STY_Translucent
	PassCrossStyle(7)=STY_Translucent
	ArmorType(0)=(ArmorLevel=0.600000,ProtectionType="Corroded")
	ArmorType(1)=(ArmorLevel=0.500000,ProtectionType="shredded")
	ArmorType(2)=(ArmorLevel=0.300000,ProtectionType="jolted")
	ArmorType(3)=(ArmorLevel=0.100000,ProtectionType="RocketDeath")
	HeadLightOn=Sound'UnrealShare.Pickups.FSHLITE2'
	HeadLightOff=Sound'UnrealShare.Pickups.FSHLITE1'
	GroundPower=1.000000
	RefMaxArcSpeed=250.000000
	MinArcSpeed=250.000000
	bHaveGroundWaterFX=True
	FootZoneDmgDiv=20
	RefMaxWaterSpeed=3500.000000
	LastTeleportYaw=-1
	LastFix=-100.000000
	FixSounds(0)=Sound'UnrealShare.Dispersion.number1'
	FixSounds(1)=Sound'UnrealShare.Dispersion.number2'
	FixSounds(2)=Sound'UnrealShare.Dispersion.number3'
	FixSounds(3)=Sound'UnrealShare.Dispersion.number4'
	DamageGFX(0)=(DmgFlamesClass=Class'VehDmgFire',DmgBlackSmkClass=Class'VehEngBlackSmoke',DmgLightSmkClass=Class'VehEngLightSmoke')
	DamageGFX(1)=(DmgFlamesClass=Class'VehDmgFire',DmgBlackSmkClass=Class'VehEngBlackSmoke',DmgLightSmkClass=Class'VehEngLightSmoke')
	DamageGFX(2)=(DmgFlamesClass=Class'VehDmgFire',DmgBlackSmkClass=Class'VehEngBlackSmoke',DmgLightSmkClass=Class'VehEngLightSmoke')
	DamageGFX(3)=(DmgFlamesClass=Class'VehDmgFire',DmgBlackSmkClass=Class'VehEngBlackSmoke',DmgLightSmkClass=Class'VehEngLightSmoke')
	WreckedTex=Texture'XVehicles.Misc.WreckedVeh'
	DestroyedExplDmg=320
	ExplosionGFX(0)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	ExplosionGFX(1)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	ExplosionGFX(2)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	ExplosionGFX(3)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	ExplosionGFX(4)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	ExplosionGFX(5)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	ExplosionGFX(6)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	ExplosionGFX(7)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	ExplosionGFX(8)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	ExplosionGFX(9)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	ExplosionGFX(10)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	ExplosionGFX(11)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	ExplosionGFX(12)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	ExplosionGFX(13)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	ExplosionGFX(14)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	ExplosionGFX(15)=(ExplClass=Class'VehExplosionFX',ExplSize=1.000000)
	RndExplosionSnd(0)=Sound'XVehicles.Explosions.VehicleExplosion01'
	RndExplosionSnd(1)=Sound'XVehicles.Explosions.VehicleExplosion02'
	RndExplosionSnd(2)=Sound'XVehicles.Explosions.VehicleExplosion03'
	RndExplosionSnd(3)=Sound'XVehicles.Explosions.VehicleExplosion04'
	RndExplosionSnd(4)=Sound'XVehicles.Explosions.VehicleExplosion05'
	RndSecExplosionSnd(0)=Sound'XVehicles.Explosions.VehSecExpl01'
	RndSecExplosionSnd(1)=Sound'XVehicles.Explosions.VehSecExpl02'
	RndSecExplosionSnd(2)=Sound'XVehicles.Explosions.VehSecExpl03'
	RndSecExplosionSnd(3)=Sound'XVehicles.Explosions.VehSecExpl04'
	RndSecExplosionSnd(4)=Sound'XVehicles.Explosions.VehSecExpl05'
	UseExplosionSnd1=True
	UseExplosionSnd2=True
	RndExploSndVol=75
	RndExploSndRange=5250.000000
	bExplShake=True
	ExplShakeTime=0.650000
	ExplShakeMag=1650.000000
	WreckPartColHeight=64.000000
	WreckPartColRadius=64.000000
	bProtectAgainst=True
	ShieldType(0)="shot"
	ShieldLevel=0.900000
	bCanTeleport=True
	Physics=PHYS_Projectile
	RemoteRole=ROLE_SimulatedProxy
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
	bProjTarget=True
	bBounce=True
	Mass=900.000000
	NetPriority=3.000000
}
