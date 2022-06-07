//**************************************************************
// Jeep SDX - Human military jeep type vehicle.
// * 2 Seats
// * Regular energy double cannon (passenger only)
// * Ice surfaces support
// * Head Lights
//**************************************************************
class JeepSDX expands WheeledCarPhys;

//Mesh import
#exec MESH IMPORT MESH=JeepSDX ANIVFILE=MODELS\JeepSDX_a.3d DATAFILE=MODELS\JeepSDX_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=JeepSDX STRENGTH=0.85
#exec MESH ORIGIN MESH=JeepSDX X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=JeepSDX SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=JeepSDX SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=JeepSDX MESH=JeepSDX
#exec MESHMAP SCALE MESHMAP=JeepSDX X=0.5 Y=0.5 Z=1.0

//Skinning
#exec TEXTURE IMPORT NAME=JeepHBodySk01 FILE=SKINS\JeepHBodySk01.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=JeepSDX NUM=1 TEXTURE=JeepHBodySk01

#exec TEXTURE IMPORT NAME=JeepHBodySk02 FILE=SKINS\JeepHBodySk02.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=JeepSDX NUM=2 TEXTURE=JeepHBodySk02

#exec TEXTURE IMPORT NAME=JeepHBodySk03 FILE=SKINS\JeepHBodySk03.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=JeepSDX NUM=3 TEXTURE=JeepHBodySk03

//Sounds
#exec AUDIO IMPORT NAME="JeepEng" FILE=SOUNDS\JeepEng.wav GROUP="JeepSDX"
#exec AUDIO IMPORT NAME="JeepStart" FILE=SOUNDS\JeepStart.wav GROUP="JeepSDX"
#exec AUDIO IMPORT NAME="JeepStop" FILE=SOUNDS\JeepStop.wav GROUP="JeepSDX"
#exec AUDIO IMPORT NAME="JeepHorn" FILE=SOUNDS\JeepHorn.wav GROUP="JeepSDX"
#exec AUDIO IMPORT NAME="JeepIceIronOn" FILE=SOUNDS\JeepIceIronOn.wav GROUP="JeepSDX"
#exec AUDIO IMPORT NAME="JeepIceIronOff" FILE=SOUNDS\JeepIceIronOff.wav GROUP="JeepSDX"

//Misc tex
#exec TEXTURE IMPORT NAME=JeepSDXLightsOv FILE=Overlayers\JeepSDXLightsOv.bmp GROUP=Misc FLAGS=2 LODSET=2
#exec TEXTURE IMPORT NAME=JeepHeadL FILE=LightTex\JeepHeadL.bmp GROUP=Misc FLAGS=2 LODSET=2
#exec TEXTURE IMPORT NAME=JeepBackL FILE=LightTex\JeepBackL.bmp GROUP=Misc FLAGS=2 LODSET=2

//Crosshair
#exec TEXTURE IMPORT NAME=JeepSDXTurretCross FILE=ICONS\JeepSDXTurretCross.bmp GROUP=Icons MIPS=OFF

var JSDXIceWheelSup IronBars[4];
var() sound IronOn, IronOff;

simulated function Tick(float Delta)
{
	Super.Tick(Delta);
	
	SetIronBars();
}

simulated function SetIronBars()
{
	local int i;

	if (Specials[7].bSpeOn && IronBars[0] == None)
	{
		For( i=0; i<4; i++ )
		{
			IronBars[i] = Spawn(Class'JSDXIceWheelSup',MyWheels[i]);
			if (MyWheels[i] != None && MyWheels[i].bMirroredWheel)
				IronBars[i].Mesh = Mesh'JSDXIceWheelSupMir';
		}

		Velocity = VelFriction;
		WheelsTraction = 8.0;
	}
	else if (!Specials[7].bSpeOn && IronBars[0] != None)
	{
		For( i=0; i<4; i++ )
		{
			if (IronBars[i] != None)
				IronBars[i].Destroy();
			IronBars[i] = None;
		}
	
		VelFriction = Velocity;
		WheelsTraction = 0.1;
	}
}

function ActivateSpecial( byte SpecialN)
{
	if (SpecialN == 7 && !Specials[7].bSpeOn)	//Iron wheels for icy/snowy surfaces
	{
		Specials[7].bSpeOn = True;
	
		if (IronOn != None)
			PlaySound(IronOn);
	}
	else if (SpecialN == 7 && Specials[7].bSpeOn)
	{
		Specials[7].bSpeOn = False;

		if (IronOff != None)
			PlaySound(IronOff);
	}
}

defaultproperties
{
      IronBars(0)=None
      IronBars(1)=None
      IronBars(2)=None
      IronBars(3)=None
      IronOn=Sound'XWheelVeh.JeepSDX.JeepIceIronOn'
      IronOff=Sound'XWheelVeh.JeepSDX.JeepIceIronOff'
      Wheels(0)=(WheelOffset=(X=80.000000,Y=-60.000000,Z=-35.000000),WheelClass=Class'XWheelVeh.JSDXWheel',WheelMesh=LodMesh'XWheelVeh.JSDXWheel')
      Wheels(1)=(WheelOffset=(X=80.000000,Y=60.000000,Z=-35.000000),WheelClass=Class'XWheelVeh.JSDXWheel',WheelMesh=LodMesh'XWheelVeh.JSDXWheelMir',bMirroredWheel=True)
      Wheels(2)=(WheelOffset=(X=-80.000000,Y=-60.000000,Z=-35.000000),WheelClass=Class'XWheelVeh.JSDXWheel',WheelMesh=LodMesh'XWheelVeh.JSDXWheel')
      Wheels(3)=(WheelOffset=(X=-80.000000,Y=60.000000,Z=-35.000000),WheelClass=Class'XWheelVeh.JSDXWheel',WheelMesh=LodMesh'XWheelVeh.JSDXWheelMir',bMirroredWheel=True)
      MaxGroundSpeed=875.000000
      WheelTurnSpeed=16000.000000
      bEngDynSndPitch=True
      MinEngPitch=32
      MaxEngPitch=96
      WheelsRadius=27.500000
      TractionWheelsPosition=-80.000000
      VehicleGravityScale=2.000000
      WAccelRate=515.000000
      Health=600
      VehicleName="Jeep SDX"
      ExitOffset=(Y=150.000000)
      BehinViewViewOffset=(X=-220.000000,Z=112.500000)
      StartSound=Sound'XWheelVeh.JeepSDX.JeepStart'
      EndSound=Sound'XWheelVeh.JeepSDX.JeepStop'
      EngineSound=Sound'XWheelVeh.JeepSDX.JeepEng'
      PassengerSeats(0)=(PassengerWeapon=Class'XWheelVeh.JSDXTurret',PassengerWOffset=(X=-78.125000,Z=8.062500),CameraOffset=(Z=37.500000),CamBehindviewOffset=(X=-75.000000,Z=57.500000),bIsAvailable=True,SeatName="Light Plasma Dual Cannon")
      VehicleKeyInfoStr="Jeep SDX keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|1, 2 to switch seats|9 to toggle winter tires|0 to toggle light|%PrevWeapon%, %NextWeapon%, %SwitchToBestWeapon% to change camera|%ThrowWeapon% to exit the vehicle"
      bSlopedPhys=True
      FrontWide=(X=80.000000,Y=60.000000,Z=-7.500000)
      BackWide=(X=-80.000000,Y=60.000000,Z=-7.500000)
      ZRange=220.000000
      MaxObstclHeight=25.000000
      HornSnd=Sound'XWheelVeh.JeepSDX.JeepHorn'
      bDriverHorn=True
      HornTimeInterval=2.000000
      PassCrosshairTex(0)=Texture'XWheelVeh.Icons.JeepSDXTurretCross'
      PassCrossColor(0)=(R=0,B=0)
      bUseVehicleLights=True
      bUseSignalLights=True
      LightsOverlayer(1)=Texture'XWheelVeh.Misc.JeepSDXLightsOv'
      StopLights(0)=(VLightOffset=(X=-122.500000,Y=56.250000,Z=-6.250000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
      StopLights(1)=(VLightOffset=(X=-122.500000,Y=65.000000,Z=-6.250000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
      StopLights(2)=(VLightOffset=(X=-122.500000,Y=-56.250000,Z=-6.250000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
      StopLights(3)=(VLightOffset=(X=-122.500000,Y=-65.000000,Z=-6.250000),VLightTex=Texture'Botpack.Translocator.Tranglow',VSpriteProj=2.500000,VLightScale=0.250000)
      BackwardsLights(0)=(VLightOffset=(X=-122.500000,Y=56.250000,Z=-18.750000),VLightTex=Texture'XWheelVeh.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
      BackwardsLights(1)=(VLightOffset=(X=-122.500000,Y=-56.250000,Z=-18.750000),VLightTex=Texture'XWheelVeh.Misc.JeepBackL',VSpriteProj=2.500000,VLightScale=0.250000)
      HeadLights(0)=(VLightOffset=(X=118.750000,Y=61.250000),VLightTex=Texture'XWheelVeh.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000)
      HeadLights(1)=(VLightOffset=(X=118.750000,Y=-61.250000),VLightTex=Texture'XWheelVeh.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000)
      HeadLights(2)=(VLightOffset=(X=125.000000,Y=45.000000,Z=-6.250000),VLightTex=Texture'XWheelVeh.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
      HeadLights(3)=(VLightOffset=(X=125.000000,Y=-45.000000,Z=-6.250000),VLightTex=Texture'XWheelVeh.Misc.JeepHeadL',VSpriteProj=1.250000,VLightScale=0.440000,VHeadLight=(bHaveSpotLight=True,HeadLightIntensity=80,HLightSat=255,HeadCone=64,HeadDistance=192))
      Specials(7)=(bSpecialAct=True,SpecialDesc="Wheels Iron bars [to use in ice for better traction]")
      GroundPower=1.750000
      DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=103.750000,Z=17.500000),FXRange=13)
      ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=5.550000)
      ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="JSDXWheel")
      ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="JSDXTurret")
      UseExplosionSnd2=False
      WreckPartColHeight=48.000000
      bEnableShield=True
      ShieldLevel=0.600000
      Mesh=LodMesh'XWheelVeh.JeepSDX'
      SoundRadius=70
      SoundVolume=100
      CollisionRadius=80.000000
      CollisionHeight=60.000000
      Mass=2200.000000
}
