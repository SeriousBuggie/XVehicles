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
var() bool bTeamLocked,bShouldRepVehYaw,bFPViewUseRelRot,bFPRepYawUpdatesView,bStationaryTurret,bRenderVehicleOnFP,bIsWaterResistant;
var() byte CurrentTeam;
var() localized string VehicleName,TranslatorDescription,MsgVehicleDesc;
var() vector ExitOffset,BehinViewViewOffset,InsideViewOffset;
var(Sounds) sound StartSound,EndSound,EngineSound,IdleSound,ImpactSounds[8],BulletHitSounds[6];
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

// -1 to 1.
var int Turning,Rising,Accel;
var int VehicleYaw,ReplVehicleYaw;

// Driving pawn
var Pawn Driver,Passengers[8];

var vector FloorNormal,ActualFloorNormal, GVTNormal, ActualGVTNormal;
var VehicleAttachment AttachmentList; // Vehicle attachment list.
var bool bDriving,bOnGround,bOldOnGround,bCameraOnBehindView,bVehicleBlewUp,bClientBlewUp,bHadADriver;
var float ResetTimer;
var BotAttractInv BotAttract;

// Bot info
var bool bHasMoveTarget;
var vector MoveDest;
var float MoveTimer;

// Replication variables
var vector VehPos,VehVeloc,SimVehVeloc,SimPosUpd;
var bool bUpdatingPos;
var byte UpdTimeLeft;
var DriverCameraActor MyCameraAct;
var OverlayMatDispRep ReplicOverlayMat;

var VehicleFactory MyFactory;
var const EPhysics ReqPPPhysics;

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
var() bool bDisableTeamSpawn;
var() float WDeAccelRate;
var int OldAccelD, VirtOldAccel;
var(Sounds) sound HornSnd;
var() bool bDriverHorn, bHornPrimaryOnly;
var() float HornTimeInterval;
var float NextHornTime;
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
var VehicleLightsOv VLov;
var bool bHeadLightInUse;
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

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		VehPos,VehVeloc,Driver,bDriving,Health,bVehicleBlewUp,ReplicOverlayMat,bTeamLocked,CurrentTeam,Passengers,
		bReadyToRun, Specials; // new ones
	reliable if( Role==ROLE_Authority && bNetOwner )
		bCameraOnBehindView,MyCameraAct,WAccelRate,DriverGun;
	reliable if( Role==ROLE_Authority && bShouldRepVehYaw )
		ReplVehicleYaw;
	// Functions client can call.
	reliable if( Role<ROLE_Authority )
		ServerPreformMove,ServerSetBehindView;
	// Functions server can call.
	reliable if( Role==ROLE_Authority )
		ClientSetTranslatorMsg;
}

function AnalyzeZone( ZoneInfo newZone)
{
	if (newZone != None && newZone.DamagePerSec > 0)
		TakeDamage(Max(1,newZone.DamagePerSec/FootZoneDmgDiv),None,Location,vect(0,0,0),newZone.DamageType);
}

static function float GetAngularSpeed(float LinVel, float Delta, float WRadius)
{
local float rrad;

	rrad = Delta*(LinVel / WRadius);
	return (rrad*32768/pi);
}

function ActivateSpecial( byte SpecialN);	//SpecialN: 7 = Key 9

function SwitchVehicleLights()
{
local byte i;

	if (!bHeadLightInUse && bUseVehicleLights)
	{
		bHeadLightInUse = True;
		
		if (HeadLightOn!=None)
			PlaySound(HeadLightOn);

		VLov = Spawn(Class'VehicleLightsOv', Self);

		if (LightsOverlayer[8] != None)
			VLov.Texture = LightsOverlayer[8];
		else
			VLov.Texture = Texture'TransInvis';
		VLov.Mesh = Mesh;
		VLov.DrawScale = DrawScale;
		
		For (i=0; i<8; i++)
		{
			if (LightsOverlayer[i] != None)
				VLov.MultiSkins[i] = LightsOverlayer[i];
			else
				VLov.MultiSkins[i] = Texture'TransInvis';
		}

		For (i=0; i<ArrayCount(HeadLights); i++)
		{
			if (HeadLights[i].VLightTex != None)
			{
			HeadLights[i].VLC = Spawn(Class'VehicleLightsCor', Self);
			HeadLights[i].VLC.POffSet = HeadLights[i].VLightOffset;
			HeadLights[i].VLC.Texture = HeadLights[i].VLightTex;
			HeadLights[i].VLC.SpriteProjForward = HeadLights[i].VSpriteProj;
			HeadLights[i].VLC.DrawScale = HeadLights[i].VLightScale;

			if (HeadLights[i].VHeadLight.bHaveSpotLight)
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
	}
	else if (bUseVehicleLights)
	{
		bHeadLightInUse = False;
		
		if (HeadLightOff!=None)
			PlaySound(HeadLightOff);
		
		if (VLov!=None)
			VLov.Destroy();

		For (i=0; i<ArrayCount(HeadLights); i++)
		{
			if (HeadLights[i].VLC != None)
				HeadLights[i].VLC.Destroy();
			
			if (HeadLights[i].VHeadLight.HSpot != None)
				HeadLights[i].VHeadLight.HSpot.Destroy();
		}
	}
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
	local byte i;
	local rotator RotZeroRoll;

	Super.PostBeginPlay();

	FirstHealth = Health;
	
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

		FrontWide.Y = Abs(FrontWide.Y);
		FrontWide.X = Abs(FrontWide.X);
		FrontWide.Z = Abs(FrontWide.Z);
		BackWide.Y = Abs(BackWide.Y);
		BackWide.X = -Abs(BackWide.X);
		BackWide.Z = Abs(BackWide.Z);
	}
	//*****************************************
	
	if( Level.NetMode==NM_Client )
		return;	

	if (InitialDamage > 0)
		TakeImpactDamage(InitialDamage,None);

	if (!bReadyToRun && (Self.IsA('WheeledCarPhys') || Self.IsA('TreadCraftPhys')))
		SetPhysics(PHYS_Falling);


	//*****************************************
	//Signal Lights
	//*****************************************
	if (bUseSignalLights && (Self.IsA('WheeledCarPhys') || Self.IsA('TreadCraftPhys')))
	{
		For (i=0; i<ArrayCount(StopLights); i++)
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

		For (i=0; i<ArrayCount(BackwardsLights); i++)
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
	}


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
		RotZeroRoll = Rotation;
		RotZeroRoll.Roll = 0;
		if( MyCameraAct==None )
			MyCameraAct = Spawn(Class'DriverCameraActor',Self,,,RotZeroRoll);
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
}

function ChangeBackView()
{
	if (MyCameraAct != None)
		MyCameraAct.ChangeView();
}

function PassengerChangeBackView( byte SeatN)
{
	if (SeatN < 8 && PassengerSeats[SeatN].PassengerCam != None)
		PassengerSeats[SeatN].PassengerCam.ChangeView();
}

function KeepCams()
{
local byte i;

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
	local byte i;

	if (bDriverHorn && ((bHornPrimaryOnly && !bAltFire) || !bHornPrimaryOnly))
	{
		if( PlayerPawn(Driver)==None || NextHornTime>Level.TimeSeconds )
			Return;
		NextHornTime = Level.TimeSeconds+HornTimeInterval;
		if( Instigator!=None )
			MakeNoise(5);
	
		if( HornSnd!=None )
			PlaySound(HornSnd,SLOT_Misc,2,,1600);
	
		Return;
	}

	if( bAltFire )
		i = 1;
	if( DriverGun!=None )
		DriverGun.FireTurret(i);
}

// Return normal for acceleration direction.
simulated function vector GetAccelDir( int InTurn, int InRise, int InAccel )
{
	Return vector(Rotation)*InAccel;
}

// Client -> Server, the players movement keys pressed.
function ServerPreformMove( byte InRise, byte InTurn, byte InAccel )
{
	Turning = int(InTurn)-1;
	Rising = int(InRise)-1;
	Accel = int(InAccel)-1;
	if( Turning>1 )
		Turning = 1;
	if( Rising>1 )
		Rising = 1;
	if( Accel>1 )
		Accel = 1;
}

function DriverWeapon SpawnWeapon(class<DriverWeapon> DriverWeaponClass, optional int Seat, optional Actor Owned)
{
	local DriverWeapon wep;
	
	if (Owned == None)
		Owned = self;
	wep = Spawn(DriverWeaponClass,Owned);
	wep.VehicleOwner = Self;
	if (Seat == 0) // driver
	{
		wep.ItemName = VehicleName;
	}
	else
	{
		Seat--;
		wep.ItemName = PassengerSeats[Seat].SeatName;
		if (wep.ItemName == "")
			wep.ItemName = VehicleName;
	}
	return wep;
}

function DriverEnter( Pawn Other )
{
	local rotator R;
	
	bHadADriver = True;
	Other.DrawScale = 0;
	bTeamLocked = False;
	Driver = Other;
	SetOwner(Other);
	Instigator = Other;
	PlaySound(StartSound,SLOT_Misc);
	AmbientSound = EngineSound;
	Other.SetCollision(False,False,False);
	Other.SetCollisionSize(0,0);
	if( DriverGun!=None )
		DriverGun.WeaponController = Other;
	if( DWeapon==None )
		DWeapon = SpawnWeapon(DriverWeaponClass);
	DWeapon.NotifyNewDriver(Other);
	DWeapon.SetOwner(Other);
	if( Other.Weapon!=None )
	{
		Other.PendingWeapon = Other.Weapon;
		Other.Weapon.GoToState('');
	}
	Other.Weapon = DWeapon;
	if( PlayerPawn(Other)!=None )
	{
		ClientSetTranslatorMsg();
		R.Yaw = VehicleYaw;
		R.Pitch = -4000;
		PlayerPawn(Other).ClientSetRotation(R);
		PlayerPawn(Other).ViewTarget = MyCameraAct;
		PlayerPawn(Other).bBehindView = False;
		if( Other.PlayerReplicationInfo!=None && Other.PlayerReplicationInfo.HasFlag!=None )
			Other.GoToState('FeigningDeath');
		Other.GoToState('PlayerFlying');
	}
	GoToState('VehicleDriving');
}
singular function DriverLeft( optional bool bForcedLeave )
{
local vector ExitVect;

	if( Driver!=None )
	{
		PlaySound(EndSound,SLOT_Misc);

		if( Driver.bDeleteMe )
			Driver = None;
		else
		{
			Driver.DrawScale = Driver.Default.DrawScale;
			if( PlayerPawn(Driver)!=None && Driver.Health>0 )
				Driver.GoToState('PlayerWalking');
			if( PlayerPawn(Driver)!=None )
				Driver.ClientRestart();
			Driver.SetCollision(True,False,False);
			Driver.SetCollisionSize(Driver.Default.CollisionRadius,Driver.Default.CollisionHeight);

			ExitVect = ExitOffset;
			if ((Normal(Velocity) Dot Normal(ExitVect >> Rotation)) > 0.35)
				ExitVect.Y = -ExitVect.Y;
			if( !bForcedLeave && !Driver.Move(Location+(ExitVect >> Rotation) - Driver.Location) )
			{
				ExitVect.Y = -ExitVect.Y;
				if (!bForcedLeave && !Driver.Move(Location+(ExitVect >> Rotation) - Driver.Location))
				{
					Driver.SetCollision(False,False,False);
					Driver.SetCollisionSize(0,0);
					if( PlayerPawn(Driver)!=None )
						Driver.GoToState('PlayerFlying');
					Return;
				}
			}
			Driver.SetCollision(True,True,True);
			if( PlayerPawn(Driver)!=None )
			{
				PlayerPawn(Driver).ViewTarget = None;
				PlayerPawn(Driver).EndZoom();
				Driver.ClientSetRotation(Rotation);
			}
			Driver.Weapon = Driver.PendingWeapon;
			if( Driver.Weapon!=None )
				Driver.Weapon.BringUp();
		}
	}
	if( DriverGun!=None )
		DriverGun.WeaponController = None;
	if( DWeapon!=None )
	{
		DWeapon.NotifyDriverLeft(Driver);
		DWeapon.SetOwner(Self);
	}
	Driver = None;
	//SetOwner(None); Set to none 1 sec later to avoid unwanted functions errors.
	if( !bDeleteMe && Health>0 )
		CheckForEmpty();
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
	local byte i;

	if( Driver!=None )
		DriverLeft(True);
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
	Super.Destroyed();
}
// Client update vehicle pos/rot/vel
simulated function ClientUpdateState( float Delta )
{
	local float Dist;

	if( bUpdatingPos )
	{
		Move(SimPosUpd);
		UpdTimeLeft--;
		if( UpdTimeLeft==0 )
		{
			bOnGround = CheckOnGround();
			bUpdatingPos = False;
		}
	}
	if( VehPos!=vect(0,0,0) ) // Give an interpolation for location updates
	{
		Dist = VSize(VehPos-Location);
		if( Dist>350 || Dist<=5 )
		{
			bOnGround = CheckOnGround();
			bUpdatingPos = False;
			SetLocation(VehPos);
		}
		else
		{
			UpdTimeLeft = (Dist/5);
			bUpdatingPos = True;
			if( UpdTimeLeft==0 )
				UpdTimeLeft = 1;
			else if( UpdTimeLeft>50 )
				UpdTimeLeft = 50;
			SimPosUpd = (VehPos-Location)/UpdTimeLeft;
		}
	}	
	if( VehVeloc!=SimVehVeloc )
	{
		SimVehVeloc = VehVeloc;
		Velocity = VehVeloc/15.f;
	}
	if( bShouldRepVehYaw && ReplVehicleYaw!=0 )
	{
		if( bFPRepYawUpdatesView && !bCameraOnBehindView && Driver!=None && IsNetOwner(Driver) )
			Driver.ViewRotation.Yaw+=(ReplVehicleYaw-VehicleYaw);
		VehicleYaw = ReplVehicleYaw;
		ReplVehicleYaw = 0;
	}
}
// Server send to client vehicle pos/rot/vel
function ServerPackState( float Delta)
{
	VehPos = Location;
	VehVeloc = Velocity*15.f;
	if( bShouldRepVehYaw )
		ReplVehicleYaw = VehicleYaw;
}

simulated function DmgFXGen(byte Mode)
{
local byte i;
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


// Main tick
simulated function Tick( float Delta )
{
local bool bSlopedG;
local float f;

	if (!bReadyToRun && (Self.IsA('WheeledCarPhys') || Self.IsA('TreadCraftPhys')))
	{
		if (AttachmentList == None)
			AttachmentsTick(Delta);
		return;
	}

	PendingBump = None;
	
	bSlopedG = CheckOnGround();

	VeryOldVel[1] = VeryOldVel[0];
	VeryOldVel[0] = Velocity;

	if (Health < (FirstHealth/5))
	{
		DmgFXCount += Delta;
		if (DmgFXCount > (0.065 + FRand()*0.15))
			DmgFXGen(3);
	}
	else if (Health < (FirstHealth/4))
	{
		DmgFXCount += Delta;
		if (DmgFXCount > (0.1 + FRand()*0.15))
			DmgFXGen(2);
	}
	else if (Health < (FirstHealth/3))
	{
		DmgFXCount += Delta;
		if (DmgFXCount > (0.1 + FRand()*0.15))
			DmgFXGen(1);
	}
	else if (Health < (FirstHealth/2))
	{
		DmgFXCount += Delta;
		if (DmgFXCount > (0.5 + FRand()))
			DmgFXGen(0);
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
	
	if( Level.NetMode==NM_Client )
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
		ClientUpdateState(Delta);
	}

	if (!bDisableTeamSpawn)
	{
		if( Level.NetMode==NM_Client )
		{
			if( ReplicOverlayMat.MatTexture!=None )
			{
				SetOverlayMat(ReplicOverlayMat.MatTexture,float(ReplicOverlayMat.MatDispTime)/25.f);
				ReplicOverlayMat.MatTexture = None;
			}
		}
		else if( bResetOLRep && OverlayResetTime<Level.TimeSeconds )
		{
			bResetOLRep = False;
			ReplicOverlayMat.MatTexture = None;
			ReplicOverlayMat.MatDispTime = 0;
		}
		if( Level.NetMode!=NM_DedicatedServer)
		{
			if( OverlayMat!=None )
			{
				if( OverlayMActor==None )
					OverlayMActor = Spawn(Class'MatOverlayFX',Self);
				OverlayMActor.Texture = OverlayMat;
				if( OverlayTime>=1 )
					OverlayMActor.ScaleGlow = 1;
				else OverlayMActor.ScaleGlow = (OverlayTime/1);
				OverlayMActor.AmbientGlow = OverlayMActor.ScaleGlow * 255;
				OverlayTime-=Delta;
				if( OverlayTime<=0 )
					OverlayMat = None;
			}
			else if( OverlayMActor!=None )
			{
				OverlayMActor.Destroy();
				OverlayMActor = None;
			}
		}
	}
	if( bDriving && (Level.NetMode<NM_Client || IsNetOwner(Driver)) )
	{
		if( Driver==None || ((Driver.bDeleteMe || Driver.Health<=0) && Level.NetMode<NM_Client) )
		{
			if( Level.NetMode<NM_Client )
			{
				if( Driver!=None )
					Driver.DrawScale = Driver.Default.DrawScale;
				if( Driver!=None && Driver.bDeleteMe )
					Driver = None;
				DriverLeft(True);
			}
		}
		else if( PlayerPawn(Driver)==None )
			ReadBotInput(Delta);
		else if( NetConnection(PlayerPawn(Driver).Player)==None )
			ReadDriverInput(PlayerPawn(Driver),Delta);
	}

	if (ArcGroundTime > 0)
		ArcGroundTime -= Delta;

	if (!Region.Zone.bWaterZone)
		f = 1.0;
	else
		f = 0.35;

	if( ActualFloorNormal!=FloorNormal && (!bArcMovement || (bSlopedG && bArcMovement)))
	{
		if (bArcMovement && !bOldOnGround)
			ArcGroundTime = 0.8;
		
		if (ArcGroundTime > 0)
			FloorNormal = Normal(35*f*Delta * ActualFloorNormal + (1 - 35*f*Delta) * FloorNormal);
		else
			FloorNormal = Normal(6*f*Delta * ActualFloorNormal + (1 - 6*f*Delta) * FloorNormal);

		if ( (ActualFloorNormal Dot FloorNormal) > 0.999 )
				FloorNormal = ActualFloorNormal;
	}
	//Arc movement physics
	else if (bArcMovement && !bSlopedG)
	{
		ActualFloorNormal = Normal(vector(Rotation) * (Velocity*20 dot vector(Rotation)));
		if (ActualFloorNormal == vect(0,0,0))
			ActualFloorNormal = FloorNormal;

		if (bOldOnGround && VSize(Velocity) > MinArcSpeed * 2.5)
		{
			FloorNormal = ArcInitDir[0];
			GVTNormal = ArcInitDir[0];
		}
			

		if (ActualFloorNormal!=FloorNormal && VSize(Velocity) > 0)
		{
			FloorNormal = Normal(ArcAmount(Velocity)*f*Delta * ActualFloorNormal + (1 - ArcAmount(Velocity)*f*Delta) * FloorNormal);
			if ( (ActualFloorNormal Dot FloorNormal) > 0.999 )
				FloorNormal = ActualFloorNormal;
		}

		if (bSlopedPhys && VSize(Velocity) > 0)
		{
			ActualGVTNormal = Normal(vector(Rotation) * (Velocity*20 dot vector(Rotation)));
			if (ActualGVTNormal == vect(0,0,0))
				ActualGVTNormal = GVTNormal;

			if (GVTNormal!=ActualGVTNormal)
			{
				GVTNormal = Normal(ArcAmount(Velocity)*f*Delta * ActualGVTNormal + (1 - ArcAmount(Velocity)*f*Delta) * GVTNormal);
				if ( (ActualGVTNormal Dot GVTNormal) > 0.999 )
					GVTNormal = ActualGVTNormal;
			}
		}
		
	}

	if (bSlopedPhys && bSlopedG && GVTNormal!=ActualGVTNormal)
	{
		// smoothly change floor if not sloped and on the ground

		if (ArcGroundTime > 0)
			GVTNormal = Normal(35*f*Delta * ActualGVTNormal + (1 - 35*f*Delta) * GVTNormal);
		else
			GVTNormal = Normal(14*f*Delta * ActualGVTNormal + (1 - 14*f*Delta) * GVTNormal);

		if ( (ActualGVTNormal Dot GVTNormal) > 0.999 )
			GVTNormal = ActualGVTNormal;

	}
	bOwnerNoSee = False;
	if( Driver!=None )
		UpdateDriverPos();
	if( bOnGround && !bSlopedG )
		bOnGround = False;
	UpdateDriverInput(Delta);
	UpdatePassengerPos();
	if( Level.NetMode>NM_StandAlone && Level.NetMode<NM_Client )
		ServerPackState(Delta);
	if( !bIsWaterResistant && Region.Zone.bWaterZone && NextWaterDamageTime<Level.TimeSeconds && Region.Zone.DamagePerSec <= 0)
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

	bOldOnGround = bSlopedG;

	if (AttachmentList == None)
		AttachmentsTick(Delta);
}

function float ArcAmount(vector VelArc)
{
	VelArc.Z = 0;
	return VehicleGravityScale*Abs(Region.Zone.ZoneGravity.Z/950)*RefMaxArcSpeed/FMax(VSize(VelArc),MinArcSpeed*VehicleGravityScale);
}

simulated function UpdateAttachment(WeaponAttachment vat, float Delta)
{
local vector WPosA;
local rotator WRotA;
local byte i;
local Actor AttachBase;
local WeaponAttachment WA;

	AttachBase = vat.Base;
	if (AttachBase == None)
		AttachBase = self;
	if (vat.bRotWithOtherWeap && WeaponAttachment(vat.Base) == None && vat.WAtt != None)
		AttachBase = vat.WAtt;
//	if (Vat.base != AttachBase)
//		Log(self @ vat @ Vat.base @ AttachBase @ vat.bRotWithOtherWeap);

	if (bSlopedPhys && GVT!=None)
		WPosA = GVT.PrePivot + Location + (vat.TurretOffset >> Rotation);
	else
		WPosA = Location + (vat.TurretOffset >> Rotation);

	if (!vat.Move(WPosA - vat.Location))
		vat.SetLocation(WPosA);
	if (Vat.base != AttachBase)
		vat.setBase(AttachBase);
		
	if (Vat.base != AttachBase)
		Log(Vat.base @ AttachBase);

	if (vat.PitchPart != None)
	{
		if( vat.bHasPitchPart )
		{
			if (bSlopedPhys && GVT!=None)
				WRotA = vat.TransformForGroundRot(vat.TurretYaw,GVTNormal);
			else
				WRotA = vat.TransformForGroundRot(vat.TurretYaw,FloorNormal);
		}
		else
		{
			if (bSlopedPhys && GVT!=None)
				WRotA = vat.TransformForGroundRot(vat.TurretYaw,GVTNormal,vat.TurretPitch);
			else
				WRotA = vat.TransformForGroundRot(vat.TurretYaw,FloorNormal,vat.TurretPitch);
		}
		WPosA += (vat.PitchActorOffset >> WRotA);
		if (!vat.PitchPart.Move(WPosA - vat.PitchPart.Location))
			vat.PitchPart.SetLocation(WPosA);
		if (Vat.PitchPart.base != AttachBase)
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

	if (VehFoot != None && Location != OldLocation)
	{
		if (bSlopedPhys && GVT!=None)
			VehFoot.SetLocation(Location + GVT.PrePivot);
		else
			VehFoot.SetLocation(Location);

		VehFoot.Move(CollisionHeight*vect(0,0,-1));
	}
}

// Vehicle is currently on ground?
simulated function bool CheckOnGround()
{
	local vector End,Start,Ex,HL,HN;

	local vector sHL[4],sHN[4], ePointsOffSet[4], MLoc, CrossedVect[2], GVTLoc, CurArcDir;
	local actor Ac[4];
	local byte b, AcCount;
	local actor WAs, WBs;
	local vector WHL, WHN, WSt, WEnd, WExt;
	local bool isNotAble;

	Start = Location;
	Start.Z-=(CollisionHeight-1);
	End = Start;
	End.Z-=6;
	Ex.X = CollisionRadius;
	Ex.Y = Ex.X;

	if( Trace(HL,HN,End,Start,False,Ex)==None )
	{
		ePointsOffSet[0] = FrontWide;
		ePointsOffSet[1] = ePointsOffSet[0];
		ePointsOffSet[1].Y = -FrontWide.Y;
		ePointsOffSet[2] = BackWide;
		ePointsOffSet[3] = ePointsOffSet[2];
		ePointsOffSet[3].Y = -BackWide.Y;

		For (b=0; b<4; b++)
		{
			Start = Location + (ePointsOffSet[b] >> Rotation);
			End = Start + (eVect(0,0,-Abs(ZRange)) >> Rotation);
			Ac[b] = Trace(sHL[b],sHN[b],End,Start,False);
			if (Ac[b] != None)
				AcCount++;
		}

		if (AcCount == 4)
		{
			MoveSmooth(vect(0,0,-1));
			MLoc = (sHL[0] + sHL[1] + sHL[2] + sHL[3]) / 4;
			CrossedVect[0] = Normal(sHL[0] - sHL[3]);
			CrossedVect[1] = Normal(sHL[1] - sHL[2]);
			ActualGVTNormal = Normal(CrossedVect[0] cross CrossedVect[1]);
			if (ActualGVTNormal.Z < 0)
				ActualGVTNormal = -ActualGVTNormal;
			GVTLoc = MLoc + ActualGVTNormal*CollisionHeight;
			if (GVT != None)
				GVT.PrePivot = GVTLoc - Location;

			/*isNotAble = ((sHN[0].Z > sHN[2].Z && sHN[0].Z > 0 && sHN[2].Z > 0 && (sHN[0].Z - sHN[2].Z) > 0.45
				&& sHN[1].Z > sHN[3].Z && sHN[1].Z > 0 && sHN[3].Z > 0 && (sHN[1].Z - sHN[3].Z) > 0.45)
					||
				(sHN[0].Z < sHN[2].Z && sHN[0].Z > 0 && sHN[2].Z > 0 && (sHN[2].Z - sHN[0].Z) > 0.45
				&& sHN[1].Z < sHN[3].Z && sHN[1].Z > 0 && sHN[3].Z > 0 && (sHN[3].Z - sHN[1].Z) > 0.45))
				&& VehicleGravityScale*(Region.Zone.ZoneGravity.Z/8) < VSize(Velocity)/350;*/

			if (Trace(HL,HN,End,Start,False)!=None)
			{
				For (b=0; b<4; b++)
				{
					if (HN.Z - sHN[b].Z >= 0.45 && HN.Z >= 0 && sHN[b].Z >= 0)
					//if ((HN dot sHN[b]) < 0.535)
						isNotAble = True;
				}
			}

			if (!isNotAble)
			{
				ActualFloorNormal = ActualGVTNormal;
				return True;
			}
		}

		return False;
	}

	if (bSlopedPhys && GVT!=None)
	{
		if (Location != OldLocation)
		{
			ePointsOffSet[0] = FrontWide;
			ePointsOffSet[1] = ePointsOffSet[0];
			ePointsOffSet[1].Y = -FrontWide.Y;
			ePointsOffSet[2] = BackWide;
			ePointsOffSet[3] = ePointsOffSet[2];
			ePointsOffSet[3].Y = -BackWide.Y;

			//************************************************************************
			//Walls climbing bug fix
			//************************************************************************
			WSt = Location + GVT.PrePivot;
			WExt.X = FMax(FrontWide.Y,BackWide.Y);
			WExt.Y = WExt.X;
			WExt.Z = CollisionHeight - MaxObstclHeight;
			WEnd = WSt + vector(Rotation)*OldAccelD*(WExt.X + 2);
			WAs = Trace(WHL,WHN,WEnd,WSt,False,WExt);

			if (WAs == None)
			{
				if (WallHitDir == -Accel && WallHitDir!=0)
				{
					WEnd = WSt + vector(Rotation)*WallHitDir*(WExt.X + 2);
					WBs = Trace(WHL,WHN,WEnd,WSt,False,WExt);
					
					if (WBs == None)
					{
						WallHitDir = 0;
						WHN = HN;
					}
				}
				else
					WHN = HN;
			}
			else
				WallHitDir = OldAccelD;
			//************************************************************************

			For (b=0; b<4; b++)
			{
				Start = Location + (ePointsOffSet[b] >> Rotation);
				End = Start + (eVect(0,0,-Abs(ZRange)) >> Rotation);
				Ac[b] = Trace(sHL[b],sHN[b],End,Start,False);
				if (Ac[b] != None && (sHN[b] dot WHN > 0.5) /*&& (ActualFloorNormal dot sHN[b] >= 0.3)*/)
					AcCount++;
			}
		}

		if (bArcMovement && AcCount > 2)
		{
			ArcInitDir[0] = FloorNormal;
			ArcInitDir[1] = GVTNormal;
		}

		if (AcCount == 4)
		{
			MLoc = (sHL[0] + sHL[1] + sHL[2] + sHL[3]) / 4;
			CrossedVect[0] = Normal(sHL[0] - sHL[3]);
			CrossedVect[1] = Normal(sHL[1] - sHL[2]);
			ActualGVTNormal = Normal(CrossedVect[0] cross CrossedVect[1]);
			if (ActualGVTNormal.Z < 0)
				ActualGVTNormal = -ActualGVTNormal;
			GVTLoc = MLoc + ActualGVTNormal*CollisionHeight;
			GVT.PrePivot = GVTLoc - Location;
		}
		else if (Location != OldLocation)
			ActualGVTNormal = HN;
	}

	if ((Location != OldLocation || !bSlopedPhys) /*&& (HN dot ActualFloorNormal) <= 0.5*/)
		ActualFloorNormal = HN;
	
	Return True;
}


// Make sure driver is directly in center of vehicle.
simulated function UpdateDriverPos()
{
	local rotator R;

	Driver.SetLocation(Location);
	Driver.Velocity = Velocity;
	if( Level.NetMode<NM_Client )
	{
		if( Driver.bCollideActors )
			Driver.SetCollision(false);
		Driver.DrawScale = 0;
		if( DriverGun!=None )
			R.Yaw = DriverGun.TurretYaw;
		else R.Yaw = Rotation.Yaw;
		Driver.SetRotation(R);
		if( PlayerPawn(Driver)==None )
			Driver.ViewRotation = R;
	}
	else Driver.SetRotation(Rotation);
	if( (Level.NetMode<NM_Client || IsNetOwner(Driver)) && Driver.Physics!=ReqPPPhysics )
		Driver.SetPhysics(ReqPPPhysics);
}
simulated function UpdatePassengerPos()
{
	local byte i;
	local rotator R;

	For( i=0; i<Arraycount(Passengers); i++ )
	{
		if( Passengers[i]!=None )
		{
			if( Passengers[i].bDeleteMe || Passengers[i].Health<=0 )
			{
				if( Level.NetMode<NM_Client )
					PassengerLeave(i,True);
				Continue;
			}
			Passengers[i].SetLocation(Location);
			Passengers[i].Velocity = Velocity;
			if( Level.NetMode<NM_Client )
			{
				if( Passengers[i].bCollideActors )
					Passengers[i].SetCollision(false);
				Passengers[i].DrawScale = 0;
				if( PassengerSeats[i].PGun!=None )
					R.Yaw = PassengerSeats[i].PGun.TurretYaw;
				else R = Rotation;
				Passengers[i].SetRotation(R);
			}
			else Passengers[i].SetRotation(Rotation);
			if( (Level.NetMode<NM_Client || IsNetOwner(Passengers[i])) && Passengers[i].Physics!=ReqPPPhysics )
				Passengers[i].SetPhysics(ReqPPPhysics);
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
		else if( Other.bPressedJump )
			Rising = 1;
		else Rising = 0;
	}
	else
		DoSpecialSpaceKey();
		
	if( Level.NetMode==NM_Client )
		ServerPreformMove(byte(Rising+1),byte(Turning+1),byte(Accel+1));
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
}

// Update server behindview
function ServerSetBehindView( bool bNewView )
{
	bCameraOnBehindView = bNewView;
	if( PlayerPawn(Owner)!=None )
		PlayerPawn(Owner).bBehindView = False;
}

// Figure out a good move for bots
function ReadBotInput( float Delta )
{
	local vector V;

	if( !bHasMoveTarget )
	{
		bHasMoveTarget = True;
		MoveDest = VehicleAI.GetNextMoveTarget();
		V = Location-MoveDest;
		V.Z = 0;
		if( VSize(V)<100 )
		{
			Driver.MoveTimer = 0;
			Driver.MoveTarget = None;
			Driver.StopWaiting();
			bHasMoveTarget = False;
			Return;
		}
		MoveTimer = Level.TimeSeconds+2;
	}
	V = Location-MoveDest;
	V.Z = 0;
	if( MoveTimer<Level.TimeSeconds || VSize(V)<100 )
	{
		bHasMoveTarget = False;
		Return;
	}
	Turning = ShouldTurnFor(MoveDest);
	Rising = 0;
	Accel = ShouldAccelFor(MoveDest);
}

// Returns the bot value for accel target
function int ShouldAccelFor( vector AcTarget )
{
	if( (Normal(AcTarget-Location) dot vector(Rotation))>0 )
		Return 1;
	else Return -1;
}

// Returns the bot turning value for target
function int ShouldTurnFor( vector AcTarget )
{
	local vector X,Y,Z;
	local float Res;

	GetAxes(Rotation,X,Y,Z);
	Res = Normal(AcTarget-Location) dot Y;
	if( Abs(Res)<0.1 )
		Return 0;
	else if( Res>0 )
		Return -1;
	else Return 1;
}

// Pawn can enter this vehicle?
function bool CanEnter( Pawn Other, optional bool bIgnoreDuck )
{
	if( Other.Health<=0 || (!bIgnoreDuck && PlayerPawn(Other)!=None && Other.bDuck==0) || DriverWeapon(Other.Weapon)!=None ||
		Other.IsInState('PlayerWaiting') || !Other.bCollideActors )
		Return False;
	Return True;
}
function bool IsTeamLockedFor( Pawn Other )
{
	Return ((bTeamLocked || HasPassengers()) && Level.Game.bTeamGame && Level.Game.bDeathMatch && Other.PlayerReplicationInfo!=None
	 && Other.PlayerReplicationInfo.Team<=3 && Other.PlayerReplicationInfo.Team!=CurrentTeam);
}

Auto State EmptyVehicle
{
Ignores FireWeapon,ReadDriverInput,ReadBotInput,DriverLeft;

	function ServerPreformMove( byte InRise, byte InTurn, byte InAccel )
	{
		Turning = 0;
		Rising = 0;
		Accel = 0;
	}
	function MessageLocalPLs()
	{
		local Pawn P;

		For( P=Level.PawnList; P!=None; P=P.NextPawn )
		{
			if( P.bIsPlayer && PlayerPawn(P)!=None && VSize(P.Location-Location)<(CollisionRadius+100+P.CollisionRadius) && CanEnter(P,True)
			 && !IsTeamLockedFor(P) )
//				P.ClientMessage("Hold 'Crouch' key to enter this"@VehicleName,'Pickup');
				P.ReceiveLocalizedMessage( class'EnterMessagePlus', 0, None, None, self );
		}
	}
	singular function Bump( Actor Other )
	{
		Global.Bump(Other);
		if( Other.bDeleteMe )
			Return;
		if( !Other.bIsPawn || !CanEnter(Pawn(Other)) )
			Return;
		if( IsTeamLockedFor(Pawn(Other)) )
		{
			Pawn(Other).ClientMessage("This"@VehicleName@"is team locked.",'RedCriticalEvent');
			Return;
		}
		else if( Pawn(Other).PlayerReplicationInfo!=None && Pawn(Other).PlayerReplicationInfo.Team<=3
		 && Pawn(Other).PlayerReplicationInfo.Team!=CurrentTeam && bTeamLocked)
		{
			CurrentTeam = Pawn(Other).PlayerReplicationInfo.Team;
			SetOverlayMat(TeamOverlays[CurrentTeam],0.5);
			PlaySound(Sound'CarAlarm01',SLOT_Misc,2,,400);
			if( PlayerPawn(Other)!=None )
				PlayerPawn(Other).ClientPlaySound(Sound'Hijacked');
		}
		if( !VehicleAI.PawnCanDrive(Pawn(Other)) )
			Return;
		DriverEnter(Pawn(Other));
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
			if( BotAttract!=None )
				BotAttract.VehicleOwner = Self;
		}
	}
	function EndState()
	{
		bDriving = True;
		if( BotAttract!=None )
		{
			BotAttract.Destroy();
			BotAttract = None;
		}
	}
	function Tick( float Delta )
	{
		if( ResetTimer!=Default.ResetTimer && Level.TimeSeconds>ResetTimer )
			Destroy();
		else Global.Tick(Delta);
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
	singular function Bump( Actor Other )
	{
		local byte Fr;

		Global.Bump(Other);
		if( Other.bDeleteMe || !Other.bIsPawn || !CanAddPassenger(Pawn(Other),Fr) || !VehicleAI.PawnCanPassenge(Pawn(Other),Fr) )
			Return;
		PassengerEnter(Pawn(Other),Fr);
	}
	function Touch( Actor Other )
	{
		if( Triggers(Other)!=None && Driver!=None )
			Other.Touch(Driver);
	}
}

simulated event SetInitialState()
{
	if( Level.NetMode==NM_Client )
		Return; // Do not set a state on clients!
	if( InitialState!='' )
		GotoState( InitialState );
	else GotoState( 'Auto' );
}
simulated function ClientSetTranslatorMsg()
{
	local Inventory I;
	local int Count;
	local PlayerPawn PP;

	ServerSetBehindView(bUseBehindView);
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	if( Level.NetMode==NM_Client )
	{
		ForEach AllActors(Class'PlayerPawn',PP)
		{
			if( PP.Player!=None )
				Break;
		}
	}
	else PP = PlayerPawn(Owner);
	if( PP==None )
		Return;
	PP.bBehindView = False;
	if( MyCameraAct!=None )
		PP.ViewTarget = MyCameraAct;
	PP.ClientMessage(VehicleName,'Pickup');
	For( I=PP.Inventory; (I!=None && Count<2000); I=I.Inventory )
	{
		if( Translator(I)!=None )
		{
			PP.ClientMessage(MsgVehicleDesc);
			Translator(I).NewMessage = TranslatorDescription;
			Return;
		}
		Count++;
	}
}
simulated function vector FixCameraPos(vector V, vector S)
{
	local vector HL,HN,X,Y,Z;
	local float P;
	if( Trace(HL,HN,V,S,False) != None )
		V = HL+HN*5;
	GetAxes(Rotation, X, Y, Z);
	P = (V - S) dot Z;
	if (P < 0)
		V -= P*Z;
	return V;
}
simulated function CalcCameraPos( out vector Pos, out rotator Rot, float Mult, optional byte SeatNumber )
{
	local vector V,S;

	if( SeatNumber>0 )
	{
		SeatNumber--;
		if( Passengers[SeatNumber]==None )
			Rot = Rotation;
		else Rot = Passengers[SeatNumber].ViewRotation;
		bOwnerNoSee = False;

		if (bSlopedPhys && GVT!=None)
			S = GVT.PrePivot + Location+((PassengerSeats[SeatNumber].PassengerWOffset+PassengerSeats[SeatNumber].CameraOffset*Mult) >> Rotation);
		else
			S = Location+((PassengerSeats[SeatNumber].PassengerWOffset+PassengerSeats[SeatNumber].CameraOffset*Mult) >> Rotation);
		V = S+((PassengerSeats[SeatNumber].CamBehindviewOffset*Mult) >> Rot);
		Pos = FixCameraPos(V, S);
		Return;
	}
	if( Pawn(Owner)==None )
		Rot = Rotation;
	else Rot = Pawn(Owner).ViewRotation;
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
	if (bSlopedPhys && GVT!=None)
	{
		if (!bDriverWOffset || DriverGun == None)
			V = GVT.PrePivot + Location+((BehinViewViewOffset*Mult) >> Rot);
		else
			V = GVT.PrePivot + DriverGun.Location+((BehinViewViewOffset*Mult) >> Rot);
	}
	else
	{
		if (!bDriverWOffset || DriverGun == None)
			V = Location+((BehinViewViewOffset*Mult) >> Rot);
		else
			V = DriverGun.Location+((BehinViewViewOffset*Mult) >> Rot);
	}
	Pos = FixCameraPos(V, Location);
}
function rotator GetFiringRot( float ProjSpeed, bool bInstantHit, vector PStartPos, optional byte SeatN )
{
	local vector End,Start,HL,HN;
	local rotator Aim;

	if( bInstantHit )
		ProjSpeed = 99999;
	if( SeatN>0 )
	{
		SeatN--;
		if( PlayerPawn(Passengers[SeatN])==None )
			Return Passengers[SeatN].AdjustAim(ProjSpeed,PStartPos,200,True,True);
		
		if (PassengerSeats[SeatN].PassengerCam != None)
			CalcCameraPos(Start,Aim,PassengerSeats[SeatN].PassengerCam.CurrentViewMult,SeatN+1);
		else
			CalcCameraPos(Start,Aim,1.0,SeatN+1);
		End = Start+vector(Aim)*8000;

		if( Trace(HL,HN,End,Start,True)==None )
			return rotator(End-PStartPos);
		else 
			return rotator(HL-PStartPos);
	}
	if( PlayerPawn(Driver)==None )
		Return Driver.AdjustAim(ProjSpeed,PStartPos,200,True,True);
		
	if (MyCameraAct != None)
		CalcCameraPos(Start,Aim,MyCameraAct.CurrentViewMult);
	else
		CalcCameraPos(Start,Aim,1.0);
	
	End = Start+vector(Aim)*40000;
	if( Trace(HL,HN,End,Start,True)==None )
		return rotator(End-PStartPos);
	else 
		return rotator(HL-PStartPos);
}
simulated function vector CalcPlayerAimPos( optional byte SeatN )
{
	local vector End,Start,HL,HN;
	local rotator Aim;

	if (SeatN > 0 && PassengerSeats[SeatN-1].PassengerCam != None)
		CalcCameraPos(Start,Aim,PassengerSeats[SeatN-1].PassengerCam.CurrentViewMult,SeatN);
	else if (SeatN == 0 && MyCameraAct != None)
		CalcCameraPos(Start,Aim,MyCameraAct.CurrentViewMult);
	else
		CalcCameraPos(Start,Aim,1.0,SeatN);
		
	End = Start+vector(Aim)*40000;
	if( Trace(HL,HN,End,Start,True)==None )
		return End;
	else return HL;
}
simulated function RenderCanvasOverlays( Canvas C, DriverCameraActor Cam, byte Seat )
{
	local float X,Y,XS,HP,XL,YL;
	local byte i,o;

	// Draw health bar:	
	C.Style = ERenderStyle.STY_Normal;

	Y = C.ClipY/6*5;
	//XS = C.ClipX/3*2;
	XS = C.ClipX/4;
	X = C.ClipX/2;
	DrawHealthBar(C, Health, FirstHealth, X, Y, XS, 24);
/*
	C.DrawColor.R = 192;
	C.DrawColor.G = 192;
	C.DrawColor.B = 192;

	C.SetPos(X,Y);
	C.DrawTile(Texture'Misc',XS,24,0,0,122,16);

	if (Health < (FirstHealth/5))
	{
		C.DrawColor.R = 96;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
	}
	else if (Health < (FirstHealth/4))
	{
		C.DrawColor.R = 255;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
	}
	else if (Health < (FirstHealth/3))
	{
		C.DrawColor.R = 255;
		C.DrawColor.G = 128;
		C.DrawColor.B = 0;
	}
	else if (Health < (FirstHealth/2))
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

	HP = float(Health)/float(FirstHealth);
	C.SetPos(X,Y);
	C.DrawTile(Texture'Misc',XS*HP,24,0,16,122.f*HP,16);
*/
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

	if( bRenderVehicleOnFP && Seat==0 && !bCameraOnBehindView )
	{
		bOwnerNoSee = False;
		C.DrawActor(Self,False);
		bOwnerNoSee = True;

		if (!bSlopedPhys)
			bHidden = False;
	}

	// Draw aim OK crosshair
	if( DriverCrosshairTex!=None && Seat==0 && DriverGun!=None && DriverGun.AimingIsOK())
	{
		/*C.SetPos(C.ClipX/2-AimLockedOnCrosshairTex.USize/2,C.ClipY/2-AimLockedOnCrosshairTex.VSize/2);
		C.DrawColor.R = 110;
		C.DrawColor.G = 255;
		C.DrawColor.B = 110;*/

		if (PlayerPawn(Driver) != None && class'DriverWeapon'.default.UseStandardCrosshair && 
			ClassIsChildOf(class<GameInfo>(DynamicLoadObject(C.ViewPort.Actor.GameReplicationInfo.GameClass, class'Class')), class'DeathMatchPlus'))
		{
			if (PlayerPawn(Driver).Handedness == -1)
				C.SetPos(C.ClipX*0.503-(DriverCrosshairTex.USize*DriverCrossScale/2),C.ClipY*0.504-(DriverCrosshairTex.VSize*DriverCrossScale/2));
			else if (PlayerPawn(Driver).Handedness == 1)
				C.SetPos(C.ClipX*0.497-(DriverCrosshairTex.USize*DriverCrossScale/2),C.ClipY*0.496-(DriverCrosshairTex.VSize*DriverCrossScale/2));
			else
				C.SetPos(C.ClipX*0.5-(DriverCrosshairTex.USize*DriverCrossScale/2),C.ClipY*0.5-(DriverCrosshairTex.VSize*DriverCrossScale/2));
		}
		else
			C.SetPos(C.ClipX*0.5-(DriverCrosshairTex.USize*DriverCrossScale/2),C.ClipY*0.5-(DriverCrosshairTex.VSize*DriverCrossScale/2));

		C.Style = DriverCrossStyle;
		C.DrawColor = DriverCrossColor;
		C.DrawIcon(DriverCrosshairTex,DriverCrossScale);
		DriverGun.WRenderOverlay(C);
	}
	else if( Seat > 0 && PassCrosshairTex[Seat-1]!=None && Cam!=None && Cam.GunAttachM!=None && Cam.GunAttachM.AimingIsOK())
	{
		/*C.SetPos(C.ClipX/2-AimLockedOnCrosshairTex.USize/2,C.ClipY/2-AimLockedOnCrosshairTex.VSize/2);
		C.DrawColor.R = 110;
		C.DrawColor.G = 255;
		C.DrawColor.B = 110;*/

		if (PlayerPawn(Cam.GunAttachM.WeaponController) != None && 
			ClassIsChildOf(class<GameInfo>(DynamicLoadObject(C.ViewPort.Actor.GameReplicationInfo.GameClass, class'Class')), class'DeathMatchPlus'))
		{
			if (PlayerPawn(Cam.GunAttachM.WeaponController).Handedness == -1)
				C.SetPos(C.ClipX*0.503-(PassCrosshairTex[Seat-1].USize*PassCrossScale[Seat-1]/2),C.ClipY*0.504-(PassCrosshairTex[Seat-1].VSize*PassCrossScale[Seat-1]/2));
			else if (PlayerPawn(Cam.GunAttachM.WeaponController).Handedness == 1)
				C.SetPos(C.ClipX*0.497-(PassCrosshairTex[Seat-1].USize*PassCrossScale[Seat-1]/2),C.ClipY*0.496-(PassCrosshairTex[Seat-1].VSize*PassCrossScale[Seat-1]/2));
			else
				C.SetPos(C.ClipX*0.5-(PassCrosshairTex[Seat-1].USize*PassCrossScale[Seat-1]/2),C.ClipY*0.5-(PassCrosshairTex[Seat-1].VSize*PassCrossScale[Seat-1]/2));
		}
		else
			C.SetPos(C.ClipX*0.5-(PassCrosshairTex[Seat-1].USize*PassCrossScale[Seat-1]/2),C.ClipY*0.5-(PassCrosshairTex[Seat-1].VSize*PassCrossScale[Seat-1]/2));

		C.Style = PassCrossStyle[Seat-1];
		C.DrawColor = PassCrossColor[Seat-1];
		C.DrawIcon(PassCrosshairTex[Seat-1],PassCrossScale[Seat-1]);
		Cam.GunAttachM.WRenderOverlay(C);
	}
	C.Style = ERenderStyle.STY_Normal;

	o = CurrentTeam;
	if( o>3 )
		o = 0;
	C.DrawColor = Class'UnrealTeamScoreBoard'.Default.TeamColor[o];
	C.Font = Font'SmallFont';
	C.StrLen("ATST",XL,YL);
	if( Seat>0 && Driver!=None && Driver.PlayerReplicationInfo!=None )
	{
		C.SetPos(15,C.ClipY-50);
		C.DrawText("Driver -"@Driver.PlayerReplicationInfo.PlayerName);
		o = 1;
	}
	else o = 0;
	For( i=0; i<Arraycount(Passengers); i++ )
	{
		if( Passengers[i]!=None && Passengers[i].PlayerReplicationInfo!=None && (i+1)!=Seat )
		{
			C.SetPos(15,C.ClipY-50-YL*o);
			C.DrawText(PassengerSeats[i].SeatName@"-"@Passengers[i].PlayerReplicationInfo.PlayerName);
			o++;
		}
	}
	if( !bActorKeysInit )
		InitKeysInfo();
	XS = 34;
	For( i=0; i<NumKeysInfo; i++ )
	{
		if( KeysInfo[i]!="" )
		{
			C.TextSize(KeysInfo[i],XL,YL);
			C.SetPos(C.ClipX-XL-4,XS);
			C.DrawText(KeysInfo[i]);
			XS+=YL;
		}
	}
	
	if( AttachmentList!=None )
		AttachmentList.AddCanvasOverlay(C);
}

// This function is NOT called by engine, its for Custom Mods to render vehcle status from a third person.
simulated function DrawVehicleStatus( Canvas C, vector CameraPos, rotator CameraRot )
{
	local float RendSize,X,Y,XS,YS,XL,YL,OffS;
	local byte i;

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
			C.Font = Font'SmallFont';
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
	 && WorldToScreen(Location+vect(0,0,1)*CollisionHeight*1.1,C.ViewPort.Actor,CameraPos,CameraRot,C.ClipX,C.ClipY,X,Y) )
	{
		C.DrawColor = Class'UnrealTeamScoreBoard'.Default.TeamColor[CurrentTeam];
		C.Font = Font'SmallFont';
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

singular simulated function Bump( Actor Other )
{
	local vector OtVel,MyVel;
	local float Sp;
	local vector V, Dir;
	local vector befOtVel, befMyVel, NVelH;

	if( Vehicle(Other)!=None )
	{
		if( PendingBump==Other )
			Return; // Just bumped...

		OtVel = Other.Velocity;
		MyVel = Velocity;
		Dir = Normal(Other.Location-Location);

		befOtVel = Vehicle(Other).VeryOldVel[1];
		befMyVel = VeryOldVel[1];
		
		if (Accel == 0)
		{
			if ((Normal(OtVel) dot vector(Rotation)) >= 0)
				OldAccelD = 1;
			else
				OldAccelD = -1;
				
			VirtOldAccel = OldAccelD;
		}

		Vehicle(Other).PendingBump = Self;

		if (Other.Mass/Mass >= 2.0 && (Normal(Velocity) Dot Dir)>0 )
		{
			Other.TakeDamage(VSize(Other.Velocity) * (Mass/Other.Mass) / 20,Instigator,Location,Velocity*Mass,'Crushed');
			TakeDamage(VSize(Velocity) * (Other.Mass/Mass) / 20,Instigator,Location,Velocity*Mass,'Crushed');
			Velocity *= 0.25;
		}
		else if (Other.Mass/Mass >= 2.0)
		{
			Other.TakeDamage(VSize(Other.Velocity) * (Mass/Other.Mass) / 20,Instigator,Location,Velocity*Mass,'Crushed');
			TakeDamage(VSize(Velocity) * (Other.Mass/Mass) / 20,Instigator,Location,Velocity*Mass,'Crushed');
			Velocity = Other.Velocity * 1.15;
			Move((Other.Location - Other.OldLocation)*1.5);
		}
		else if (Mass/Other.Mass >= 2.0 && (Normal(Velocity) Dot Dir)>0 )
		{
			Other.TakeDamage(VSize(Velocity) * (Mass/Other.Mass) / 20,Instigator,Location,Velocity*Mass,'Crushed');
			TakeDamage(VSize(Velocity) * (Other.Mass/Mass) / 20,Instigator,Location,Velocity*Mass,'Crushed');
			Other.Velocity = Velocity * 1.15;
			Other.Move((Location - OldLocation)*1.5);
			bHitASmallerVehicle = True;
		}
		else if (Mass/Other.Mass >= 2.0)
		{
			Other.TakeDamage(VSize(Other.Velocity) * (Mass/Other.Mass) / 20,Instigator,Location,Velocity*Mass,'Crushed');
			TakeDamage(VSize(Other.Velocity) * (Other.Mass/Mass) / 20,Instigator,Location,Velocity*Mass,'Crushed');
			Other.Velocity *= 0.25;
		}
		else
		{

		Sp = FMax(VSize(Velocity),VSize(Other.Velocity)) * (Mass/Other.Mass);
		if( Sp>250 )
			Other.TakeDamage((Sp-200)/10,Instigator,Location,Velocity*Mass,'Crushed');

		Sp = FMax(VSize(Velocity),VSize(Other.Velocity)) * (Other.Mass/Mass);
		if( Sp>250 )
			TakeDamage((Sp-200)/10,Other.Instigator,Other.Location,OtVel*Other.Mass,'Crushed');

		NVelH = (Mass*befMyVel + Other.Mass*befOtVel) / (Mass+Other.Mass);	//Inelastic collision calculation (not the most realistic for vehicles, but good, reliable and simple enough for the main objectve)

		if (Self.IsA('WheeledCarPhys') || Self.IsA('TreadCraftPhys'))
		{
			if ( Vector(Rotation) Dot Normal(NVelH) > 0)
			{
				NVelH = VectorProjection(NVelH, vector(Rotation)*65535);
				OldAccelD = 1;
			}
			else
			{
				NVelH = VectorProjection(NVelH, -vector(Rotation)*65535);
				OldAccelD = -1;
			}


			Vehicle(Other).OldAccelD = OldAccelD;
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
			if ((Other.Mass + Mass)/2 < Mass/3*2 && Mass > Other.Mass)
				bHitAPawn = True;
		}
		else if (Other.IsA('Decoration'))
		{
			if (Decoration(Other).bPushable)
			{
				bHitAnActor = (Mass*1.5 - Other.Mass) / (Mass*1.5);
				PushDeco(Decoration(Other));
			}
		}

		if( VSize(Velocity)>200)
			Other.TakeDamage((VSize(Velocity)-100)/7*Mass/500.f,Instigator,Other.Location+Normal(Location-Other.Location)*Other.CollisionRadius
			 ,Velocity*Other.Mass,'Crushed');
		}
		else if (VSize(VeryOldVel[1]) > 300)
			TakeImpactDamage(VSize(VeryOldVel[1])/(Mass/500),None);
		else if (bHitAPawn && VSize(Velocity)>16)
		{
			Other.TakeDamage(0,Instigator,Other.Location+Normal(Location-Other.Location)*Other.CollisionRadius
			 ,Velocity*2**Other.Mass,'Crushed');
		}
		else if (bHitAPawn)
			Other.Move(vector(Rotation)*Accel*3);
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
	local vector Start,End,Ex,NVe,HL,HN, HN2;
	local Actor A;
	local vector MovVect;
	
	if (bSlopedPhys && GVT!=None)
	{
		if( MSHV<=0 )
			Return False;
		Ex.X = CollisionRadius;
		Ex.Y = Ex.X;
		Start = Location;
		Start.Z-=(CollisionHeight-MSHV);
		NVe = Velocity;
		NVe.Z = 0;
		NVe = Normal(NVe);
		End = Start+NVe*64;
		A = Trace(HL,HN,End,Start,True,Ex);
//Log(A @ VSize(HL-Start) @ MSHV @ (HL-Start) @ HN);
		if( A!=None )
		{
//			if( HN.Z>=AllowedZVal )
			if (VSize(Start-HL) >= 2*MSHV) // 30 degrees, almost same as AllowedZVal = 0.85, which is 31 degrees.
			{
				MSHV = HL.Z - (Location.Z - CollisionHeight) + 1;
//				MovVect = vect(0,0,1)*MSHV+NVe*VSize(Start-HL);
				Move(vect(0,0,1)*MSHV);
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
		Move(vect(0,0,1)*MSHV);
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
	HitWall(HitNormal, None);
}

simulated singular function HitWall( vector HitNormal, Actor Wall )
{
	local vector V;
	local float BMulti,VSpee;
	local vector OtherHitN;

	OtherHitN = HitNormal;

	if (!bReadyToRun && (Self.IsA('WheeledCarPhys') || Self.IsA('TreadCraftPhys')))
	{
		bReadyToRun = True;
		SetPhysics(PHYS_Projectile);
		return;
	}

	if ((GVTNormal.Z < 0 || FloorNormal.Z < 0) && HitNormal.Z > 0 && bDestroyUpsideDown)	//Upside down
	{
		TakeImpactDamage(Health*2, None);
		return;
	}

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
			TakeImpactDamage((VSpee-500)/2,None);
		else if( VSpee>600 && BMulti<0 )
			TakeImpactDamage((VSpee-600)/4,None);
		else if( VSpee>1300 && BMulti<0.3 )
			TakeImpactDamage((VSpee-1300)/5,None);
		else if (HitNormal.Z<0.45)
			TakeImpactDamage(0,None);

		MoveSmooth(-Normal(Velocity)*16);
		return;
	}

	if (!bOnGround && HitNormal.Z > 0.65)
		FellToGround();

	if (bBigVehicle)
		MoveSmooth(OtherHitN/4);


	if (bSlopedPhys && Abs(FloorNormal.Z - HitNormal.Z) > 0.45)
	{
		HitNormal.Z = 0;

		if( bOnGround && CanGetOver(MaxObstclHeight,0.85) )
			Return;
		else
			MoveSmooth(HitNormal*16);

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
			TakeImpactDamage((VSpee-500)/2,None);
		else if( VSpee>600 && BMulti<0 )
			TakeImpactDamage((VSpee-600)/4,None);
		else if( VSpee>1300 && BMulti<0.3 )
			TakeImpactDamage((VSpee-1300)/5,None);
		else if (HitNormal.Z<0.45)
			TakeImpactDamage(0,None);

		//Move(OtherHitN*3);
	}
	else
	{
		Velocity = SetUpNewMVelocity(Velocity,HitNormal,0);
		ActualFloorNormal = HitNormal;
		ActualGVTNormal = HitNormal;
		bOnGround = True;
	}
}


simulated function TakeImpactDamage( int Damage, Pawn InstigatedBy )
{
	TakeDamage(Damage,InstigatedBy,Location,vect(0,0,0),'BumpWall');
}


function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
{
	local byte i;
	local bool bHadPass;
	local byte shldset, shldtkn;

	if (!bVehicleBlewUp)
	{
		if( bDeleteMe || Level.NetMode==NM_Client )
			Return;
		if( Driver==None )
		{
			For( i=0; i<Arraycount(Passengers); i++ )
			{
				if( Passengers[i]!=None )
				{
					bHadPass = True;
					Damage = Level.Game.ReduceDamage(Damage,DamageType,Passengers[i],instigatedBy);
					Break;
				}
			}
			if( !bTakeAlwaysDamage && !bHadPass && instigatedBy!=None && instigatedBy.PlayerReplicationInfo!=None && CurrentTeam==instigatedBy.PlayerReplicationInfo.Team )
				Damage = 0;
		}
		else if( Driver.ReducedDamageType=='All' ) // God mode on!
			Damage = 0;
		else Damage = Level.Game.ReduceDamage(Damage,DamageType,Driver, instigatedBy);
		if( Driver!=None )
			Driver.damageAttitudeTo(instigatedBy);
		For( i=0; i<Arraycount(Passengers); i++ )
		{
			if( Passengers[i]!=None )
				Passengers[i].damageAttitudeTo(instigatedBy);
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
			For (i=0; i<16; i++)
			{
				if (ShieldType[i] != '')
				{
					shldset++;
	
					if (ShieldType[i] != '' && bProtectAgainst && ShieldType[i] == damageType)
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
	
		Health-=Damage;
		Velocity+=momentum/Mass;
		if( Health<=0 )
		{
			KillDriver(instigatedBy);
			GoToState('BlownUp');
		} 
		else if (Damage > 0)
			CheckForEmpty();
	}
}

State BlownUp
{
Ignores DriverEnter,Tick,ServerPackState,Bump;

	function PassengerEnter( Pawn Other, byte Seat );

Begin:
	bVehicleBlewUp = True;
	//if( Level.NetMode!=NM_DedicatedServer )
		SpawnExplosionFX();
	Sleep(0.25);
	Destroy();
}

function KillDriver( Pawn Killer )
{
	local Pawn D;
	local byte i;

	if( Driver!=None )
	{
		D = Driver;
		DriverLeft(True);
		D.Died(Killer,'Gibbed',Location);
	}
	For( i=0; i<ArrayCount(Passengers); i++ )
	{
		if( Passengers[i]!=None )
		{
			D = Passengers[i];
			PassengerLeave(i,True);
			D.Died(Killer,'Gibbed',Location);
		}
	}
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
	local byte i, rnd;
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
	For(i=0; i<16; i++)
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
	local byte i;
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
	if (!bDisableTeamSpawn)
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
	else InvPawn = Passengers[PassengerNum];
	if( PlayerPawn(InvPawn)==None || SeatNum>ArrayCount(PassengerSeats) || (SeatNum>0 && !PassengerSeats[SeatNum-1].bIsAvailable) )
		Return;
	if( SeatNum==0 )
	{
		if( !bWasPassenger )
			Return;
		if( bDriving )
		{
			if( PlayerPawn(Driver)!=None )
				Return;
			// Allow player swap places with bots!
			OthPawn = Driver;
			DriverLeft(True);
			PassengerLeave(PassengerNum,True);
			DriverEnter(InvPawn);
			PassengerEnter(OthPawn,PassengerNum);
		}
		else
		{
			PassengerLeave(PassengerNum,True);
			DriverEnter(InvPawn);
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
			if( bWasPassenger )
				PassengerLeave(PassengerNum,True);
			else DriverLeft(True);
			OthPawn = Passengers[SeatNum-1];
			PassengerLeave(SeatNum-1,True);
			PassengerEnter(InvPawn,SeatNum-1);
			if( bWasPassenger )
				PassengerEnter(OthPawn,PassengerNum);
			else DriverEnter(OthPawn);
		}
		else
		{
			if( bWasPassenger )
				PassengerLeave(PassengerNum,True);
			else DriverLeft(True);
			PassengerEnter(InvPawn,SeatNum-1);
		}
	}
}

function bool CanAddPassenger( Pawn Other, optional out byte FreeSlot )
{
	local byte i;

	if( !CanEnter(Other) || (Level.Game.bDeathMatch && !Level.Game.bTeamGame) )
		Return False;
	if( Level.Game.bTeamGame && Level.Game.bDeathMatch && Driver.PlayerReplicationInfo!=None )
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
function bool HasPassengers()
{
	local byte i;

	For( i=0; i<ArrayCount(PassengerSeats); i++ )
	{
		if( PassengerSeats[i].bIsAvailable && Passengers[i]!=None )
		{
			CurrentTeam = Passengers[i].PlayerReplicationInfo.Team;
			Return True;
		}
	}
	Return False;
}
function bool HasFreePassengerSeat( optional out byte SeatNum )
{
	local byte i;

	For( i=0; i<ArrayCount(PassengerSeats); i++ )
	{
		if( PassengerSeats[i].bIsAvailable && Passengers[i]==None )
		{
			SeatNum = i;
			Return True;
		}
	}
	Return False;
}
function bool PassengerSeatAvailable( byte SNum )
{
	if( SNum>=ArrayCount(PassengerSeats) )
		Return False;
	Return (PassengerSeats[SNum].bIsAvailable && Passengers[SNum]==None);
}
function PassengerEnter( Pawn Other, byte Seat )
{
	local rotator R, RotRollZero;

	RotRollZero = Rotation;
	RotRollZero.Roll = 0;
	Other.DrawScale = 0;
	Other.SetCollision(False,False,False);
	Other.SetCollisionSize(0,0);
	Passengers[Seat] = Other;
	if( PassengerSeats[Seat].PGun!=None )
	{
		PassengerSeats[Seat].PGun.WeaponController = Other;
		PassengerSeats[Seat].PGun.SetOwner(Other);
	}
	if( PassengerSeats[Seat].PHGun==None )
	{
		PassengerSeats[Seat].PHGun = SpawnWeapon(DriverWeaponClass,Seat + 1,Other);
		PassengerSeats[Seat].PHGun.bPassengerGun = True;
		PassengerSeats[Seat].PHGun.SeatNumber = Seat;
	}
	else PassengerSeats[Seat].PHGun.SetOwner(Other);
	PassengerSeats[Seat].PHGun.NotifyNewDriver(Other);
	if( Other.Weapon!=None )
	{
		Other.PendingWeapon = Other.Weapon;
		Other.Weapon.GoToState('');
	}
	Other.Weapon = PassengerSeats[Seat].PHGun;
	if( PlayerPawn(Other)!=None )
	{
		Other.ClientMessage(PassengerSeats[Seat].SeatName,'Pickup');
		if( PassengerSeats[Seat].PGun!=None )
			R.Yaw = PassengerSeats[Seat].PGun.TurretYaw;
		else R.Yaw = VehicleYaw;
		R.Pitch = -4000;
		PlayerPawn(Other).ClientSetRotation(R);
		if( PassengerSeats[Seat].PassengerCam==None )
		{
			PassengerSeats[Seat].PassengerCam = Spawn(Class'PassengerCameraA',Other,,,RotRollZero);
			PassengerSeats[Seat].PassengerCam.VehicleOwner = Self;
			PassengerSeats[Seat].PassengerCam.SeatNum = Seat+1;
			PassengerSeats[Seat].PassengerCam.GunAttachM = PassengerSeats[Seat].PGun;
		}
		else PassengerSeats[Seat].PassengerCam.SetOwner(Other);
		PlayerPawn(Other).ViewTarget = PassengerSeats[Seat].PassengerCam;
		PlayerPawn(Other).bBehindView = False;
		Other.GoToState('PlayerFlying');
	}
	
	CheckForEmpty();
}
function PassengerLeave( byte Seat, optional bool bForcedLeave )
{
local vector ExitVect;

	if( Passengers[Seat]!=None )
	{
		if( Passengers[Seat].bDeleteMe )
			Passengers[Seat] = None;
		else
		{
			Passengers[Seat].DrawScale = Passengers[Seat].Default.DrawScale;
			if( PlayerPawn(Passengers[Seat])!=None && Passengers[Seat].Health>0 )
				Passengers[Seat].GoToState('PlayerWalking');
			Passengers[Seat].ClientRestart();
			Passengers[Seat].SetCollision(True,False,False);
			Passengers[Seat].SetCollisionSize(Passengers[Seat].Default.CollisionRadius,Passengers[Seat].Default.CollisionHeight);

			ExitVect = ExitOffset;
			if ((Normal(Velocity) Dot Normal(ExitVect >> Rotation)) > 0.35)
				ExitVect.Y = -ExitVect.Y;
			if( !bForcedLeave && !Passengers[Seat].SetLocation(Location+(ExitVect >> Rotation)) )
			{
				ExitVect.Y = -ExitVect.Y;
				if( !bForcedLeave && !Passengers[Seat].SetLocation(Location+(ExitVect >> Rotation)) )
				{
					Passengers[Seat].SetCollision(False,False,False);
					Passengers[Seat].SetCollisionSize(0,0);
					if( PlayerPawn(Passengers[Seat])!=None )
						Passengers[Seat].GoToState('PlayerFlying');
					Return;
				}
			}
			Passengers[Seat].SetCollision(True,True,True);
			if( PlayerPawn(Passengers[Seat])!=None )
			{
				PlayerPawn(Passengers[Seat]).ViewTarget = None;
				PlayerPawn(Passengers[Seat]).EndZoom();
				Passengers[Seat].ClientSetRotation(Rotation);
			}
			Passengers[Seat].Weapon = Passengers[Seat].PendingWeapon;
			if( Passengers[Seat].Weapon!=None )
				Passengers[Seat].Weapon.BringUp();
		}
	}
	if( PassengerSeats[Seat].PGun!=None )
	{
		PassengerSeats[Seat].PGun.WeaponController = None;
		PassengerSeats[Seat].PGun.SetOwner(None);
	}
	if( PassengerSeats[Seat].PHGun!=None )
	{
		PassengerSeats[Seat].PHGun.NotifyDriverLeft(Driver);
		PassengerSeats[Seat].PHGun.SetOwner(None);
	}
	if( PassengerSeats[Seat].PassengerCam!=None && PassengerSeats[Seat].PassengerCam.Owner!=None )
		PassengerSeats[Seat].PassengerCam.SetOwner(None);
	Passengers[Seat] = None;

	CheckForEmpty();
}
function PassengerFireWeapon( bool bAltFire, byte Seat )
{
	local byte i;

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
	if( !bEmpty || HasPassengers() || MyFactory == None )
		ResetTimer = Default.ResetTimer;
	else
		ResetTimer = Level.TimeSeconds+MyFactory.VehicleResetTime;
	if (bEmpty)
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
	local byte i;

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

defaultproperties
{
      AIRating=1.000000
      VehicleGravityScale=1.000000
      WAccelRate=250.000000
      NextWaterDamageTime=0.000000
      Health=100
      InitialDamage=0
      AIClass=Class'XVehicles.VAIBehaviour'
      DriverWeaponClass=Class'XVehicles.DriverWeapon'
      bTeamLocked=False
      bShouldRepVehYaw=True
      bFPViewUseRelRot=False
      bFPRepYawUpdatesView=False
      bStationaryTurret=False
      bRenderVehicleOnFP=False
      bIsWaterResistant=False
      CurrentTeam=0
      VehicleName="Vehicle"
      TranslatorDescription=""
      MsgVehicleDesc="Press F2, to bring up your translator with vehicle description."
      ExitOffset=(X=0.000000,Y=45.000000,Z=0.000000)
      BehinViewViewOffset=(X=-650.000000,Y=0.000000,Z=120.000000)
      InsideViewOffset=(X=5.000000,Y=-15.000000,Z=0.000000)
      StartSound=None
      EndSound=None
      EngineSound=None
      IdleSound=None
      ImpactSounds(0)=Sound'XVehicles.Impacts.VehicleCollision01'
      ImpactSounds(1)=Sound'XVehicles.Impacts.VehicleCollision02'
      ImpactSounds(2)=Sound'XVehicles.Impacts.VehicleCollision03'
      ImpactSounds(3)=Sound'XVehicles.Impacts.VehicleCollision04'
      ImpactSounds(4)=Sound'XVehicles.Impacts.VehicleCollision05'
      ImpactSounds(5)=Sound'XVehicles.Impacts.VehicleCollision06'
      ImpactSounds(6)=Sound'XVehicles.Impacts.VehicleCollision07'
      ImpactSounds(7)=None
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
      bDriverWOffset=False
      bMaster=False
      bTakeAlwaysDamage=True
      bSpecialSPACEKEY=False
      DriverWeapon=(WeaponClass=None,WeaponOffset=(X=0.000000,Y=0.000000,Z=0.000000),bInvisibleGun=False)
      PassengerSeats(0)=(PassengerWeapon=None,bPassengerWInvis=False,PassengerWOffset=(X=0.000000,Y=0.000000,Z=0.000000),CameraOffset=(X=0.000000,Y=0.000000,Z=0.000000),CamBehindviewOffset=(X=-80.000000,Y=0.000000,Z=30.000000),bIsAvailable=False,SeatName="Passenger Seat",PGun=None,PHGun=None,PassengerCam=None)
      PassengerSeats(1)=(PassengerWeapon=None,bPassengerWInvis=False,PassengerWOffset=(X=0.000000,Y=0.000000,Z=0.000000),CameraOffset=(X=0.000000,Y=0.000000,Z=0.000000),CamBehindviewOffset=(X=-80.000000,Y=0.000000,Z=30.000000),bIsAvailable=False,SeatName="Passenger Seat",PGun=None,PHGun=None,PassengerCam=None)
      PassengerSeats(2)=(PassengerWeapon=None,bPassengerWInvis=False,PassengerWOffset=(X=0.000000,Y=0.000000,Z=0.000000),CameraOffset=(X=0.000000,Y=0.000000,Z=0.000000),CamBehindviewOffset=(X=-80.000000,Y=0.000000,Z=30.000000),bIsAvailable=False,SeatName="Passenger Seat",PGun=None,PHGun=None,PassengerCam=None)
      PassengerSeats(3)=(PassengerWeapon=None,bPassengerWInvis=False,PassengerWOffset=(X=0.000000,Y=0.000000,Z=0.000000),CameraOffset=(X=0.000000,Y=0.000000,Z=0.000000),CamBehindviewOffset=(X=-80.000000,Y=0.000000,Z=30.000000),bIsAvailable=False,SeatName="Passenger Seat",PGun=None,PHGun=None,PassengerCam=None)
      PassengerSeats(4)=(PassengerWeapon=None,bPassengerWInvis=False,PassengerWOffset=(X=0.000000,Y=0.000000,Z=0.000000),CameraOffset=(X=0.000000,Y=0.000000,Z=0.000000),CamBehindviewOffset=(X=-80.000000,Y=0.000000,Z=30.000000),bIsAvailable=False,SeatName="Passenger Seat",PGun=None,PHGun=None,PassengerCam=None)
      PassengerSeats(5)=(PassengerWeapon=None,bPassengerWInvis=False,PassengerWOffset=(X=0.000000,Y=0.000000,Z=0.000000),CameraOffset=(X=0.000000,Y=0.000000,Z=0.000000),CamBehindviewOffset=(X=-80.000000,Y=0.000000,Z=30.000000),bIsAvailable=False,SeatName="Passenger Seat",PGun=None,PHGun=None,PassengerCam=None)
      PassengerSeats(6)=(PassengerWeapon=None,bPassengerWInvis=False,PassengerWOffset=(X=0.000000,Y=0.000000,Z=0.000000),CameraOffset=(X=0.000000,Y=0.000000,Z=0.000000),CamBehindviewOffset=(X=-80.000000,Y=0.000000,Z=30.000000),bIsAvailable=False,SeatName="Passenger Seat",PGun=None,PHGun=None,PassengerCam=None)
      PassengerSeats(7)=(PassengerWeapon=None,bPassengerWInvis=False,PassengerWOffset=(X=0.000000,Y=0.000000,Z=0.000000),CameraOffset=(X=0.000000,Y=0.000000,Z=0.000000),CamBehindviewOffset=(X=-80.000000,Y=0.000000,Z=30.000000),bIsAvailable=False,SeatName="Passenger Seat",PGun=None,PHGun=None,PassengerCam=None)
      VehicleAI=None
      DWeapon=None
      OverlayMat=None
      OverlayTime=0.000000
      OverlayResetTime=0.000000
      bResetOLRep=False
      DriverGun=None
      PendingBump=None
      bReadyToRun=False
      Turning=0
      Rising=0
      Accel=0
      VehicleYaw=0
      ReplVehicleYaw=0
      Driver=None
      Passengers(0)=None
      Passengers(1)=None
      Passengers(2)=None
      Passengers(3)=None
      Passengers(4)=None
      Passengers(5)=None
      Passengers(6)=None
      Passengers(7)=None
      FloorNormal=(X=0.000000,Y=0.000000,Z=1.000000)
      ActualFloorNormal=(X=0.000000,Y=0.000000,Z=1.000000)
      GVTNormal=(X=0.000000,Y=0.000000,Z=1.000000)
      ActualGVTNormal=(X=0.000000,Y=0.000000,Z=1.000000)
      AttachmentList=None
      bDriving=False
      bOnGround=False
      bOldOnGround=False
      bCameraOnBehindView=True
      bVehicleBlewUp=False
      bClientBlewUp=False
      bHadADriver=False
      ResetTimer=-1.000000
      BotAttract=None
      bHasMoveTarget=False
      MoveDest=(X=0.000000,Y=0.000000,Z=0.000000)
      MoveTimer=0.000000
      VehPos=(X=0.000000,Y=0.000000,Z=0.000000)
      VehVeloc=(X=0.000000,Y=0.000000,Z=0.000000)
      SimVehVeloc=(X=0.000000,Y=0.000000,Z=0.000000)
      SimPosUpd=(X=0.000000,Y=0.000000,Z=0.000000)
      bUpdatingPos=False
      UpdTimeLeft=0
      MyCameraAct=None
      ReplicOverlayMat=(MatTexture=None,MatDispTime=0)
      MyFactory=None
      ReqPPPhysics=PHYS_None
      VehicleKeyInfoStr=""
      KeysInfo(0)=""
      KeysInfo(1)=""
      KeysInfo(2)=""
      KeysInfo(3)=""
      KeysInfo(4)=""
      KeysInfo(5)=""
      KeysInfo(6)=""
      KeysInfo(7)=""
      KeysInfo(8)=""
      KeysInfo(9)=""
      KeysInfo(10)=""
      KeysInfo(11)=""
      KeysInfo(12)=""
      KeysInfo(13)=""
      KeysInfo(14)=""
      KeysInfo(15)=""
      NumKeysInfo=0
      bHasInitKeysInfo=False
      bActorKeysInit=False
      bSlopedPhys=False
      FrontWide=(X=0.000000,Y=0.000000,Z=0.000000)
      BackWide=(X=0.000000,Y=0.000000,Z=0.000000)
      ZRange=0.000000
      MaxObstclHeight=35.000000
      bDestroyUpsideDown=False
      GVT=None
      bDisableTeamSpawn=True
      WDeAccelRate=100.000000
      OldAccelD=1
      VirtOldAccel=1
      HornSnd=None
      bDriverHorn=False
      bHornPrimaryOnly=False
      HornTimeInterval=0.000000
      NextHornTime=0.000000
      WallHitDir=0
      OldHN=(X=10.000000,Y=0.000000,Z=0.000000)
      ArcGroundTime=0.000000
      ArcInitDir(0)=(X=0.000000,Y=0.000000,Z=0.000000)
      ArcInitDir(1)=(X=0.000000,Y=0.000000,Z=0.000000)
      DriverCrosshairTex=Texture'XVehicles.HUD.CrCorrectAim'
      PassCrosshairTex(0)=Texture'XVehicles.HUD.CrCorrectAim'
      PassCrosshairTex(1)=Texture'XVehicles.HUD.CrCorrectAim'
      PassCrosshairTex(2)=Texture'XVehicles.HUD.CrCorrectAim'
      PassCrosshairTex(3)=Texture'XVehicles.HUD.CrCorrectAim'
      PassCrosshairTex(4)=Texture'XVehicles.HUD.CrCorrectAim'
      PassCrosshairTex(5)=Texture'XVehicles.HUD.CrCorrectAim'
      PassCrosshairTex(6)=Texture'XVehicles.HUD.CrCorrectAim'
      PassCrosshairTex(7)=Texture'XVehicles.HUD.CrCorrectAim'
      DriverCrossColor=(R=110,G=255,B=110,A=0)
      PassCrossColor(0)=(R=110,G=255,B=110,A=0)
      PassCrossColor(1)=(R=110,G=255,B=110,A=0)
      PassCrossColor(2)=(R=110,G=255,B=110,A=0)
      PassCrossColor(3)=(R=110,G=255,B=110,A=0)
      PassCrossColor(4)=(R=110,G=255,B=110,A=0)
      PassCrossColor(5)=(R=110,G=255,B=110,A=0)
      PassCrossColor(6)=(R=110,G=255,B=110,A=0)
      PassCrossColor(7)=(R=110,G=255,B=110,A=0)
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
      VeryOldVel(0)=(X=0.000000,Y=0.000000,Z=0.000000)
      VeryOldVel(1)=(X=0.000000,Y=0.000000,Z=0.000000)
      bHitAPawn=False
      bHitAnActor=0.000000
      NextZoneDmgTime=0.000000
      bHitASmallerVehicle=False
      ArmorType(0)=(ArmorLevel=0.000000,ProtectionType="None")
      ArmorType(1)=(ArmorLevel=0.000000,ProtectionType="None")
      ArmorType(2)=(ArmorLevel=0.000000,ProtectionType="None")
      ArmorType(3)=(ArmorLevel=0.000000,ProtectionType="None")
      ArmorType(4)=(ArmorLevel=0.000000,ProtectionType="None")
      ArmorType(5)=(ArmorLevel=0.000000,ProtectionType="None")
      ArmorType(6)=(ArmorLevel=0.000000,ProtectionType="None")
      ArmorType(7)=(ArmorLevel=0.000000,ProtectionType="None")
      bUseVehicleLights=False
      bUseSignalLights=False
      LightsOverlayer(0)=None
      LightsOverlayer(1)=None
      LightsOverlayer(2)=None
      LightsOverlayer(3)=None
      LightsOverlayer(4)=None
      LightsOverlayer(5)=None
      LightsOverlayer(6)=None
      LightsOverlayer(7)=None
      LightsOverlayer(8)=None
      StopLights(0)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      StopLights(1)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      StopLights(2)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      StopLights(3)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      StopLights(4)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      StopLights(5)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      StopLights(6)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      StopLights(7)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      BackwardsLights(0)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      BackwardsLights(1)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      BackwardsLights(2)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      BackwardsLights(3)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      BackwardsLights(4)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      BackwardsLights(5)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      BackwardsLights(6)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      BackwardsLights(7)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None)
      VLov=None
      bHeadLightInUse=False
      HeadLights(0)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None,VHeadLight=(bHaveSpotLight=False,HeadLightIntensity=0,HLightHue=0,HLightSat=0,HeadCone=0,HeadDistance=0,HSpot=None))
      HeadLights(1)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None,VHeadLight=(bHaveSpotLight=False,HeadLightIntensity=0,HLightHue=0,HLightSat=0,HeadCone=0,HeadDistance=0,HSpot=None))
      HeadLights(2)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None,VHeadLight=(bHaveSpotLight=False,HeadLightIntensity=0,HLightHue=0,HLightSat=0,HeadCone=0,HeadDistance=0,HSpot=None))
      HeadLights(3)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None,VHeadLight=(bHaveSpotLight=False,HeadLightIntensity=0,HLightHue=0,HLightSat=0,HeadCone=0,HeadDistance=0,HSpot=None))
      HeadLights(4)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None,VHeadLight=(bHaveSpotLight=False,HeadLightIntensity=0,HLightHue=0,HLightSat=0,HeadCone=0,HeadDistance=0,HSpot=None))
      HeadLights(5)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None,VHeadLight=(bHaveSpotLight=False,HeadLightIntensity=0,HLightHue=0,HLightSat=0,HeadCone=0,HeadDistance=0,HSpot=None))
      HeadLights(6)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None,VHeadLight=(bHaveSpotLight=False,HeadLightIntensity=0,HLightHue=0,HLightSat=0,HeadCone=0,HeadDistance=0,HSpot=None))
      HeadLights(7)=(VLightOffset=(X=0.000000,Y=0.000000,Z=0.000000),VLightTex=None,VSpriteProj=0.000000,VLightScale=0.000000,VLC=None,VHeadLight=(bHaveSpotLight=False,HeadLightIntensity=0,HLightHue=0,HLightSat=0,HeadCone=0,HeadDistance=0,HSpot=None))
      HeadLightOn=Sound'UnrealShare.Pickups.FSHLITE2'
      HeadLightOff=Sound'UnrealShare.Pickups.FSHLITE1'
      Specials(0)=(bSpecialAct=False,SpecialDesc="",bSpeOn=False)
      Specials(1)=(bSpecialAct=False,SpecialDesc="",bSpeOn=False)
      Specials(2)=(bSpecialAct=False,SpecialDesc="",bSpeOn=False)
      Specials(3)=(bSpecialAct=False,SpecialDesc="",bSpeOn=False)
      Specials(4)=(bSpecialAct=False,SpecialDesc="",bSpeOn=False)
      Specials(5)=(bSpecialAct=False,SpecialDesc="",bSpeOn=False)
      Specials(6)=(bSpecialAct=False,SpecialDesc="",bSpeOn=False)
      Specials(7)=(bSpecialAct=False,SpecialDesc="",bSpeOn=False)
      GroundPower=1.000000
      FallingLenghtZ=0.000000
      FirstHealth=0
      bBigVehicle=False
      RefMaxArcSpeed=550.000000
      MinArcSpeed=250.000000
      bArcMovement=False
      bHaveGroundWaterFX=True
      VehFoot=None
      FootZoneDmgDiv=20
      RefMaxWaterSpeed=3500.000000
      SecCount=0.000000
      FootVehZone(0)=None
      FootVehZone(1)=None
      FootVehZone(2)=None
      FootVehZone(3)=None
      FootVehZone(4)=None
      FootVehZone(5)=None
      FootVehZone(6)=None
      FootVehZone(7)=None
      bDamageFXInWater=False
      DamageGFX(0)=(bHaveThisGFX=False,bHaveFlames=False,DmgFXOffset=(X=0.000000,Y=0.000000,Z=0.000000),FXRange=0,DmgFlamesClass=Class'XVehicles.VehDmgFire',DmgBlackSmkClass=Class'XVehicles.VehEngBlackSmoke',DmgLightSmkClass=Class'XVehicles.VehEngLightSmoke')
      DamageGFX(1)=(bHaveThisGFX=False,bHaveFlames=False,DmgFXOffset=(X=0.000000,Y=0.000000,Z=0.000000),FXRange=0,DmgFlamesClass=Class'XVehicles.VehDmgFire',DmgBlackSmkClass=Class'XVehicles.VehEngBlackSmoke',DmgLightSmkClass=Class'XVehicles.VehEngLightSmoke')
      DamageGFX(2)=(bHaveThisGFX=False,bHaveFlames=False,DmgFXOffset=(X=0.000000,Y=0.000000,Z=0.000000),FXRange=0,DmgFlamesClass=Class'XVehicles.VehDmgFire',DmgBlackSmkClass=Class'XVehicles.VehEngBlackSmoke',DmgLightSmkClass=Class'XVehicles.VehEngLightSmoke')
      DamageGFX(3)=(bHaveThisGFX=False,bHaveFlames=False,DmgFXOffset=(X=0.000000,Y=0.000000,Z=0.000000),FXRange=0,DmgFlamesClass=Class'XVehicles.VehDmgFire',DmgBlackSmkClass=Class'XVehicles.VehEngBlackSmoke',DmgLightSmkClass=Class'XVehicles.VehEngLightSmoke')
      WreckedTex=Texture'XVehicles.Misc.WreckedVeh'
      DestroyedExplDmg=320
      ExplosionGFX(0)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
      ExplosionGFX(1)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
      ExplosionGFX(2)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
      ExplosionGFX(3)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
      ExplosionGFX(4)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
      ExplosionGFX(5)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
      ExplosionGFX(6)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
      ExplosionGFX(7)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
      ExplosionGFX(8)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
      ExplosionGFX(9)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
      ExplosionGFX(10)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
      ExplosionGFX(11)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
      ExplosionGFX(12)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
      ExplosionGFX(13)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
      ExplosionGFX(14)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
      ExplosionGFX(15)=(bHaveThisExplFX=False,ExplClass=Class'XVehicles.VehExplosionFX',ExplSize=1.000000,AttachName="None",bUseCoordOffset=False,bSymetricalCoordX=False,bSymetricalCoordY=False,ExplFXOffSet=(X=0.000000,Y=0.000000,Z=0.000000))
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
      DmgFXCount=0.000000
      WreckPartColHeight=64.000000
      WreckPartColRadius=64.000000
      bEnableShield=False
      bProtectAgainst=True
      ShieldType(0)="shot"
      ShieldType(1)="None"
      ShieldType(2)="None"
      ShieldType(3)="None"
      ShieldType(4)="None"
      ShieldType(5)="None"
      ShieldType(6)="None"
      ShieldType(7)="None"
      ShieldType(8)="None"
      ShieldType(9)="None"
      ShieldType(10)="None"
      ShieldType(11)="None"
      ShieldType(12)="None"
      ShieldType(13)="None"
      ShieldType(14)="None"
      ShieldType(15)="None"
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
}
