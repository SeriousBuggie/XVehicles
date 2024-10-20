//=============================================================================
// Scorpion.
//=============================================================================
class Scorpion expands WheeledCarPhys;

/*
#forceexec MESH  MODELIMPORT MESH=Scorpion MODELFILE=Z:\XV\RV_3.psk LODSTYLE=10
#forceexec ANIM  IMPORT ANIM=ScorpionAnims ANIMFILE=Z:\XV\RV_.psa COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#forceexec MESH ORIGIN MESH=Scorpion X=-8 Y=0 Z=7 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=Scorpion STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=Scorpion X=1 Y=1 Z=1
#forceexec MESH  DEFAULTANIM MESH=Scorpion ANIM=ScorpionAnims
#forceexec MESHMAP SETTEXTURE MESHMAP=Scorpion NUM=0 TEXTURE=RvGreen
#forceexec MESHMAP SETTEXTURE MESHMAP=Scorpion NUM=1 TEXTURE=RvBlades
#forceexec MESHMAP SETTEXTURE MESHMAP=Scorpion NUM=2 TEXTURE=RvGreen
#forceexec MESHMAP SETTEXTURE MESHMAP=Scorpion NUM=3 TEXTURE=RainFX.SGlass
#forceexec MESHMAP SETTEXTURE MESHMAP=Scorpion NUM=4 TEXTURE=RvGun

#forceexec ANIM DIGEST ANIM=ScorpionAnims  VERBOSE
// */

/*
#forceexec MESH  MODELIMPORT MESH=ScorpionWheel MODELFILE=Z:\XV\RV_4.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=ScorpionWheel X=60.35 Y=45.9 Z=-27 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=ScorpionWheel STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=ScorpionWheel X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=ScorpionWheel NUM=2 TEXTURE=RvGreen
// */

/*
#forceexec MESH  MODELIMPORT MESH=ScorpionWheelMir MODELFILE=Z:\XV\RV_4.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=ScorpionWheelMir X=60.35 Y=64.9 Z=-27 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=ScorpionWheelMir STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=ScorpionWheelMir X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=ScorpionWheelMir NUM=2 TEXTURE=RvGreen
// */

/*
#forceexec MESH  MODELIMPORT MESH=ScorpionGun MODELFILE=Z:\XV\RVGun.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=ScorpionGun X=0 Y=-5 Z=14 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=ScorpionGun STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=ScorpionGun X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=ScorpionGun NUM=0 TEXTURE=RvGun
// */

/*
#forceexec MESH  MODELIMPORT MESH=ScorpionTurret MODELFILE=Z:\XV\RVTurret.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=ScorpionTurret X=0 Y=-5 Z=10 YAW=0 PITCH=0 ROLL=0
#forceexec MESH  LODPARAMS MESH=ScorpionTurret STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=ScorpionTurret X=1 Y=1 Z=1
#forceexec MESHMAP SETTEXTURE MESHMAP=ScorpionTurret NUM=0 TEXTURE=RvGun
// */

var byte CurrentTeamColor;
var bool BladesNotBroken;
var bool BladesPrev;
var float AnimFrameRep;

replication
{
	unreliable if (Role == ROLE_Authority)
		AnimFrameRep;
}

simulated function Tick(float delta)
{
	Super.Tick(delta);
	if (CurrentTeamColor != CurrentTeam)
		ChangeColor();
	if (Role == ROLE_Authority && (BladesNotBroken || AnimFrame > 0.0))
		TickBlades(delta);
	else if (Role < ROLE_Authority)
	{
		AnimFrame = AnimFrameRep;
		if (GVT != None)
		{
			GVT.AnimFrame = AnimFrameRep;
			GVT.AnimSequence = AnimSequence;
		}
	}
}

function TickBlades(float delta)
{
	local vector HitLocation, HitNormal, X, Y, Z, Start, End;
	local actor Victim;
	local float Dir, NewAnimFrame, Angle;
	local int i;
	
	Dir = -2.0;
	if (BladesNotBroken && Driver != None)
	{
		if (PlayerPawn(Driver) == None)
		{ // AI logic for use Blades
			if (Driver.Enemy != None && Driver.Enemy.bBlockActors)
			{
				HitLocation = Driver.Enemy.Location - Location;
				if (VSize(HitLocation) <= 800.0 && HitLocation dot Velocity > 0.0)
				{
					GetAxes(Rotation, X, Y, Z);
					if (Abs(HitLocation dot Y) < 200.0)
					{
						End = Location + 200.0*Y + 11.5*Z;
						if (FastTrace(End) && FastTrace(End - 400.0*Y))
						{
							Victim = Trace(HitLocation, HitNormal, End - 100.0*Y, Location, true, vect(100, 100, 0));
							if (Victim == None || Pawn(Victim) != None)
							{
								Victim = Trace(HitLocation, HitNormal, End - 300.0*Y, Location, true, vect(100, 100, 0));
								if (Victim == None || Pawn(Victim) != None)
									Dir = 2.0;
							}
						}
					}
				}
			}	
		}
		else if (Driver.bAltFire != 0)
			Dir = 2.0;
		if (!BladesPrev && Dir > 0.0)
			AnimFrame = 0.0;
	}
	NewAnimFrame = FClamp(AnimFrame + Dir*delta, 0.0, 0.94); // 16/17
	if (BladesNotBroken && AnimFrame != NewAnimFrame)
	{
		if (AnimFrame == 0.0)
			PlaySound(Sound'Shing1', SLOT_Misc, 2);
		else if (Dir < 0.0 && BladesPrev)
			PlaySound(Sound'Shing2', SLOT_Misc, 2);
	}
	BladesPrev = Dir > 0.0;
	AnimFrameRep = NewAnimFrame;
	AnimFrame = NewAnimFrame;
	if (GVT != None)
	{
		GVT.AnimFrame = NewAnimFrame;
		GVT.AnimSequence = AnimSequence;
	}
	if (BladesNotBroken && AnimFrame >= 0.33)
	{
		GetAxes(Rotation, X, Y, Z);
		Angle = (FMin(0.106, AnimFrame - 0.354))*19.634954; // 204800.0*PI/32768;
		Dir = 105.5 + 80.0*Sin(Angle);
		End = Location - (59.5 - 80.0*Cos(Angle))*X - Dir*Y + 11.5*Z;
		
		Start = Location - 53.0*X - 64.5*Y + 11.5*Z;
		for (i = 0; i < 2; i++)
		{
			Victim = Trace(HitLocation, HitNormal, End, Start);
			if (Victim != None && (Victim.bBlockActors || Mover(Victim) != None || LevelInfo(Victim) != None))
			{
				if (Pawn(Victim) != None || Carcass(Victim) != None)
				{
					Angle = 1000; // Damage
					if (IsSameTeam(Pawn(Victim)))
						Angle = 0;
					Victim.TakeDamage(Angle, Instigator, HitLocation, Velocity * 100, 'Crushed');
				}
				else
				{
					BladesNotBroken = false;
					PlaySound(Sound'RVBladeBreakOff', SLOT_Misc, 2);
				}
			}
			if (i == 0)
			{
				End += 2*Dir*Y;
				Start += 129*Y;
			}
		}
	}
}

simulated function ChangeColor()
{
	CurrentTeamColor = CurrentTeam;
	switch (CurrentTeamColor)
	{
		case 1:
		case 2:
			Texture = Texture'RvGreen';
			break;
		case 0:
		case 3:
		default:
			Texture = Texture'RvYellow';
			break;
	}
	MultiSkins[0] = Texture;
	MultiSkins[2] = Texture;
	if (GVT != None)
	{
		GVT.MultiSkins[0] = MultiSkins[0];
		GVT.MultiSkins[2] = MultiSkins[2];
	}
}

defaultproperties
{
	CurrentTeamColor=42
	BladesNotBroken=True
	Wheels(0)=(WheelOffset=(X=68.500000,Y=-46.000000,Z=-34.000000),WheelClass=Class'ScorpionWheel',WheelMesh=SkeletalMesh'ScorpionWheel')
	Wheels(1)=(WheelOffset=(X=68.500000,Y=48.500000,Z=-34.000000),WheelClass=Class'ScorpionWheel',WheelMesh=SkeletalMesh'ScorpionWheelMir',bMirroredWheel=True)
	Wheels(2)=(WheelOffset=(X=-67.000000,Y=-46.000000,Z=-34.000000),WheelClass=Class'ScorpionWheel',WheelMesh=SkeletalMesh'ScorpionWheel')
	Wheels(3)=(WheelOffset=(X=-67.000000,Y=48.500000,Z=-34.000000),WheelClass=Class'ScorpionWheel',WheelMesh=SkeletalMesh'ScorpionWheelMir',bMirroredWheel=True)
	MaxGroundSpeed=875.000000
	WheelTurnSpeed=16000.000000
	WheelsRadius=25.000000
	TractionWheelsPosition=-68.000000
	VehicleGravityScale=2.000000
	WAccelRate=515.000000
	Health=600
	VehicleName="Scorpion"
	ExitOffset=(X=0.000000,Y=150.000000)
	BehinViewViewOffset=(X=-300.000000,Y=0.000000,Z=100.000000)
	StartSound=Sound'XWheelVeh.Scorpion.RVStart01'
	EndSound=Sound'XWheelVeh.Scorpion.RVStop01'
	EngineSound=Sound'XWheelVeh.Scorpion.RVEng01'
	bEngDynSndPitch=True
	MinEngPitch=32
	MaxEngPitch=96
	PassengerSeats(0)=(PassengerWeapon=Class'ScorpionTurret',PassengerWOffset=(X=-73.000000,Z=28.500000),CameraOffset=(Z=37.500000),CamBehindviewOffset=(X=-75.000000,Z=17.500000),bIsAvailable=True,SeatName="Light Plasma Cannon")
	VehicleKeyInfoStr="Scorpion keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|1, 2 to switch seats|9 to toggle winter tires|0 to toggle light|%mutate VehicleCamera% to change camera|%ThrowWeapon% to exit the vehicle"
	bSlopedPhys=True
	FrontWide=(X=68.500000,Y=57.000000,Z=-7.500000)
	BackWide=(X=-67.000000,Y=57.000000,Z=-7.500000)
	ZRange=220.000000
	MaxObstclHeight=25.000000
	HornSnd=Sound'XWheelVeh.JeepSDX.JeepHorn'
	bDriverHorn=True
	HornTimeInterval=2.000000
	PassCrosshairTex(0)=Texture'XWheelVeh.Icons.JeepSDXTurretCross'
	PassCrossColor(0)=(R=0,B=0)
	bUseVehicleLights=True
	bUseSignalLights=True
	StopLights(0)=(VLightOffset=(X=-92.000000,Y=22.500000,Z=1.000000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	StopLights(1)=(VLightOffset=(X=-92.000000,Y=-21.000000,Z=1.000000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(0)=(VLightOffset=(X=-90.000000,Y=18.500000,Z=13.000000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	BackwardsLights(1)=(VLightOffset=(X=-90.000000,Y=-16.000000,Z=13.000000),VLightTex=Texture'XVehicles.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
	HeadLights(0)=(VLightOffset=(X=92.000000,Y=34.000000,Z=0.500000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(1)=(VLightOffset=(X=92.000000,Y=-31.000000,Z=0.500000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
	HeadLights(2)=(VLightOffset=(X=94.000000,Y=28.000000,Z=0.500000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000)
	HeadLights(3)=(VLightOffset=(X=94.000000,Y=-24.000000,Z=0.500000),VLightTex=Texture'XVehicles.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000)
	GroundPower=1.750000
	VehicleFlagOffset=(X=0.000000,Y=0.000000,Z=-20.000000)
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=63.000000,Y=-5.500000,Z=5.500000),FXRange=13)
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=5.550000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="ScorpionWheel")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="ScorpionTurret")
	UseExplosionSnd2=False
	WreckPartColHeight=48.000000
	bEnableShield=True
	ShieldLevel=0.600000
	AnimSequence="RVarmEXTEND"
	Texture=Texture'XVehicles.Skins.CybotMetal'
	Mesh=SkeletalMesh'Scorpion'
	SoundRadius=70
	SoundVolume=255
	CollisionRadius=70.000000
	CollisionHeight=58.000000
	Mass=2200.000000
}
