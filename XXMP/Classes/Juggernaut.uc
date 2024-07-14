//=============================================================================
// Juggernaut.
//=============================================================================
class Juggernaut expands WheeledCarPhys;

/*
#forceexec MESH  MODELIMPORT MESH=Juggernaut MODELFILE=Z:\XV\XMP\Juggernaut_chasis.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=Juggernaut X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=Juggernaut STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=Juggernaut X=0.55 Y=0.55 Z=0.55
#forceexec MESHMAP SETTEXTURE MESHMAP=Juggernaut NUM=0 TEXTURE=JuggernautNone
// */

/*
#forceexec MESH  MODELIMPORT MESH=JuggernautWheel MODELFILE=Z:\XV\XMP\Juggernaut_Wheel.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=JuggernautWheel X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=JuggernautWheel STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=JuggernautWheel X=0.55 Y=0.55 Z=0.55
#forceexec MESHMAP SETTEXTURE MESHMAP=JuggernautWheel NUM=0 TEXTURE=JuggernautNone
// */

/*
#forceexec MESH  MODELIMPORT MESH=JuggernautGun MODELFILE=Z:\XV\XMP\JuggernautGun.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=JuggernautGun X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=JuggernautGun STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=JuggernautGun X=0.55 Y=0.55 Z=0.55
#forceexec MESHMAP SETTEXTURE MESHMAP=JuggernautGun NUM=0 TEXTURE=JuggernautNone
// */

/*
#forceexec MESH  MODELIMPORT MESH=JuggernautTurret MODELFILE=Z:\XV\XMP\JuggernautTurret_.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=JuggernautTurret X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=JuggernautTurret STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=JuggernautTurret X=0.55 Y=0.55 Z=0.55
#forceexec MESHMAP SETTEXTURE MESHMAP=JuggernautTurret NUM=0 TEXTURE=JuggernautNone
// */

/*
#forceexec MESH  MODELIMPORT MESH=JuggernautFrontGun MODELFILE=Z:\XV\XMP\JuggernautFrontGun.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=JuggernautFrontGun X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=JuggernautFrontGun STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=JuggernautFrontGun X=0.55 Y=0.55 Z=0.55
#forceexec MESHMAP SETTEXTURE MESHMAP=JuggernautFrontGun NUM=0 TEXTURE=JuggernautNone
// */

/*
#forceexec MESH  MODELIMPORT MESH=JuggernautFrontTurret MODELFILE=Z:\XV\XMP\JuggernautFrontTurret_.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=JuggernautFrontTurret X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=JuggernautFrontTurret STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=JuggernautFrontTurret X=0.55 Y=0.55 Z=0.55
#forceexec MESHMAP SETTEXTURE MESHMAP=JuggernautFrontTurret NUM=0 TEXTURE=JuggernautNone
// */

var byte CurrentTeamColor;

simulated function Tick(float delta)
{
	Super.Tick(delta);
	if (CurrentTeamColor != CurrentTeam)
		ChangeColor();
}

simulated function ChangeColor()
{
	local int i;
	CurrentTeamColor = CurrentTeam;
	switch (CurrentTeamColor)
	{
		case 0:
			Skin = Texture'JuggernautRed';
			break;
		case 1:
			Skin = Texture'JuggernautBlue';
			break;
		default: 
			Skin = Texture'JuggernautNone';
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
	for (i = 0; i < NumWheels; i++)
		MyWheels[i].MultiSkins[0] = Skin;
}

defaultproperties
{
	CurrentTeamColor=42
	Wheels(0)=(WheelOffset=(X=78.000000,Y=-90.500000,Z=-47.000000),WheelClass=Class'JuggernautWheel',WheelMesh=SkeletalMesh'JuggernautWheel')
	Wheels(1)=(WheelOffset=(X=78.000000,Y=90.500000,Z=-47.000000),WheelRot=(Yaw=32768),WheelClass=Class'JuggernautWheel',WheelMesh=SkeletalMesh'JuggernautWheel',bMirroredWheel=True)
	Wheels(2)=(WheelOffset=(X=-87.000000,Y=-78.500000,Z=-47.000000),WheelClass=Class'JuggernautWheel',WheelMesh=SkeletalMesh'JuggernautWheel')
	Wheels(3)=(WheelOffset=(X=-87.000000,Y=78.500000,Z=-47.000000),WheelRot=(Yaw=32768),WheelClass=Class'JuggernautWheel',WheelMesh=SkeletalMesh'JuggernautWheel',bMirroredWheel=True)
	MaxGroundSpeed=500.000000
	WheelsRadius=80.000000
	TractionWheelsPosition=-78.000000
	AIRating=3.000000
	VehicleGravityScale=3.000000
	WAccelRate=350.000000
	Health=1350
	VehicleName="Juggernaut"
	ExitOffset=(X=0.000000,Y=203.000000)
	BehinViewViewOffset=(X=-250.000000,Y=0.000000,Z=150.000000)
	StartSound=Sound'JuggernautStartup'
	EndSound=Sound'XWheelVeh.JeepSDX.JeepStop'
	EngineSound=Sound'JuggernautIdle'
	bEngDynSndPitch=True
	MinEngPitch=32
	MaxEngPitch=96
	DriverWeapon=(WeaponClass=Class'JuggernautFrontTurret',WeaponOffset=(X=95.250000,Y=-54.000000,Z=5.200000))
	PassengerSeats(0)=(PassengerWeapon=Class'JuggernautTurret',PassengerWOffset=(X=0.750000,Z=62.000000),CameraOffset=(Z=50.000000),CamBehindviewOffset=(X=-250.000000,Z=50.000000),bIsAvailable=True,SeatName="Juggernaut Canon")
	VehicleKeyInfoStr="Juggernaut keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%mutate VehicleCamera% to change camera|%ThrowWeapon% to exit the vehicle"
	bSlopedPhys=True
	FrontWide=(X=103.750000,Y=98.125000,Z=-10.000000)
	BackWide=(X=-138.750000,Y=98.125000,Z=-10.000000)
	ZRange=260.000000
	MaxObstclHeight=44.000000
	DriverCrosshairTex=Texture'XTreadVeh.Icons.TankGKOnePassCross'
	PassCrosshairTex(0)=Texture'XTreadVeh.Icons.TankGKOneMainCross'
	ArmorType(7)=(ArmorLevel=0.950000,ProtectionType="Burned")
	GroundPower=2.500000
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=86.000000,Y=5.000000),FXRange=12)
	DestroyedExplDmg=420
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=8.125000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=3.440000,AttachName="JuggernautTurret")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=103.750000,Y=98.125000,Z=-10.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-138.750000,Y=98.125000,Z=-10.000000))
	ExplosionGFX(4)=(bHaveThisExplFX=True,ExplSize=2.250000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(Y=98.125000,Z=-10.000000))
	WreckPartColHeight=45.000000
	WreckPartColRadius=130.000000
	bEnableShield=True
	ShieldLevel=0.650000
	Mesh=SkeletalMesh'Juggernaut'
	SoundRadius=70
	SoundVolume=100
	CollisionRadius=132.500000
	CollisionHeight=85.000000
	Mass=4800.000000
}
