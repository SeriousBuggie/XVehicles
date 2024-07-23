//=============================================================================
// HoverBadger.
//=============================================================================
class HoverBadger expands HoverCraftPhys;

var byte CurrentTeamColor;
var() vector SmokeOffset;
var VehicleWheel MyWheels[4];

simulated function Tick(float delta)
{
	Super.Tick(delta);
	if (CurrentTeamColor != CurrentTeam)
		ChangeColor();
	if (DriverGun != None)
		DriverGun.TurretYaw = Rotation.Yaw;
}

simulated function ChangeColor()
{
	local int i;
	CurrentTeamColor = CurrentTeam;
	switch (CurrentTeamColor)
	{
		case 1:
			Skin = Texture'BadgerBlue';
			break;
		case 0:
		default: 
			Skin = Texture'BadgerRed';
			break;
	}
	MultiSkins[0] = Skin;
	if (GVT != None)
	{
		GVT.MultiSkins[0] = Skin;
	}
	if (DriverGun != None)
	{
		DriverGun.MultiSkins[0] = Skin;
		if (DriverGun.PitchPart != None)
			DriverGun.PitchPart.MultiSkins[0] = Skin;
	}
	if (PassengerSeats[0].PGun != None)
	{
		PassengerSeats[0].PGun.MultiSkins[0] = Skin;
		if (PassengerSeats[0].PGun.PitchPart != None)
			PassengerSeats[0].PGun.PitchPart.MultiSkins[0] = Skin;
	}
	if (Level.NetMode != NM_DedicatedServer)
		for (i = 0; i < ArrayCount(MyWheels); i++)
			if (MyWheels[i] != None)
				MyWheels[i].MultiSkins[0] = Skin;
}

simulated function PostBeginPlay()
{
	local bool bMirWheel;
	local int i;
	Super.PostBeginPlay();
	if (Level.NetMode != NM_DedicatedServer)
	{
		for (i = 0; i < ArrayCount(MyWheels); i++)
		{
			MyWheels[i] = VehicleWheel(AddAttachment(Class'BadgerWheel'));
			if (MyWheels[i] == None)
				Continue;
			MyWheels[i].WheelOffset = Repulsor[i];
			MyWheels[i].WheelRot.Roll = 16384;
			bMirWheel = i % 2 == 1;
			MyWheels[i].bMirroredWheel = bMirWheel;
			if (bMirWheel)
			{
				MyWheels[i].Mesh = Mesh'BadgerWheelMir';
				MyWheels[i].WheelRot.Roll *= -1;
			}
		}
		if (MyWheels[0] != None)
			MyWheels[0].bMasterPart = True;
	}
}

simulated function AttachmentsTick( float Delta )
{
	local int i;
	local Quat VehQ;
	local VehicleWheel MyWheel;

	Super.AttachmentsTick(Delta);

	// Update wheels
	if (Level.NetMode != NM_DedicatedServer)
	{
		VehQ = RtoQ(Rotation);
		For (i = 0; i < ArrayCount(MyWheels); i++)
		{
			MyWheel = MyWheels[i];
			MyWheel.SetLocation(Location + (MyWheel.WheelOffset >> Rotation)*DrawScale);
			
			MyWheel.SetRotation(QtoR(RtoQ(MyWheel.WheelRot) Qmulti VehQ));
		}
	}
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	SetTimer(0.5, true);
}

simulated function Timer()
{
	local Effects E;
	Super.Timer();
	if (Level.NetMode != NM_DedicatedServer && Driver != None)
	{
		E = spawn(class'UT_SpriteSmokePuff',,,Location + (SmokeOffset >> Rotation));
		E.RemoteRole = ROLE_None;
		E.DrawScale = 0.5;
	}
}

defaultproperties
{
	CurrentTeamColor=42
	SmokeOffset=(X=-93.000000,Y=11.000000,Z=18.500000)
	MaxHoverSpeed=2500.000000
	VehicleTurnSpeed=16000.000000
	HoveringHeight=102.000000
	JumpingHeight=970.000000
	MaxPushUpDiff=3.000000
	Repulsor(0)=(X=44.000000,Y=-51.500000,Z=-43.500000)
	Repulsor(1)=(X=44.000000,Y=51.500000,Z=-43.500000)
	Repulsor(2)=(X=-44.000000,Y=-51.500000,Z=-43.500000)
	Repulsor(3)=(X=-44.000000,Y=51.500000,Z=-43.500000)
	RepulsorCount=4
	JumpSound=Sound'XXMP.HoverBadger.HoverBikeJump03'
	AIRating=3.000000
	WAccelRate=1000.000000
	Health=700
	VehicleName="HoverBadger"
	TranslatorDescription="This is a HoverBadger, press [Fire] or [AltFire] to fire the different firemodes. Use your Strafe keys and Move Forward/Backward keys to strafe/accelerate/deaccelerate. To leave this vehicle, press your [ThrowWeapon] key."
	ExitOffset=(X=0.000000,Y=140.000000)
	BehinViewViewOffset=(X=-250.000000,Y=0.000000,Z=100.000000)
	StartSound=Sound'XXMP.HoverBadger.HoverBadgerStart'
	EndSound=Sound'XXMP.HoverBadger.HoverBadgerStop'
	EngineSound=Sound'XXMP.HoverBadger.HoverBadgerEngine'
	bEngDynSndPitch=True
	MinEngPitch=64
	MaxEngPitch=128
	bDriverWOffset=True
	DriverWeapon=(WeaponClass=Class'HoverBadgerTurret',WeaponOffset=(X=-20.000000,Z=44.000000))
	VehicleKeyInfoStr="HoverBadger keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|%mutate VehicleCamera% to change camera|%ThrowWeapon% to exit the vehicle"
	MaxObstclHeight=0.000000
	WDeAccelRate=1500.000000
	DriverCrosshairTex=Texture'XTreadVeh.Icons.TankGKOneMainCross'
	bUseVehicleLights=True
	bUseSignalLights=True
	StopLights(0)=(VLightOffset=(X=-57.750000,Y=54.000000,Z=5.000000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	StopLights(1)=(VLightOffset=(X=-57.750000,Y=-56.000000,Z=5.000000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(0)=(VLightOffset=(X=-56.750000,Y=48.000000,Z=7.500000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(1)=(VLightOffset=(X=-56.750000,Y=-50.000000,Z=7.500000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	HeadLights(0)=(VLightOffset=(X=82.000000,Y=13.500000,Z=-12.000000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(1)=(VLightOffset=(X=82.000000,Y=-15.000000,Z=-12.000000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	GroundPower=2.500000
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=52.000000,Y=5.000000),FXRange=12)
	DestroyedExplDmg=420
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=8.125000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=3.440000,AttachName="HoverBadgerTurret")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=103.750000,Y=98.125000,Z=-10.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-138.750000,Y=98.125000,Z=-10.000000))
	ExplosionGFX(4)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(Y=98.125000,Z=-10.000000))
	WreckPartColHeight=45.000000
	WreckPartColRadius=71.000000
	bEnableShield=True
	ShieldLevel=0.650000
	Mesh=SkeletalMesh'Badger'
	SoundRadius=70
	SoundVolume=100
	CollisionRadius=71.000000
	CollisionHeight=62.000000
}
