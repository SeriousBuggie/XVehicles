//**************************************************************
// Jeep SDX - Human military jeep type vehicle.
// * 2 Seats
// * Regular energy double cannon (passenger only)
// * Head Lights
//**************************************************************
class JeepTDX expands WheeledCarPhys;

//Skinning
#exec TEXTURE IMPORT NAME=JeepTDXHBodySk01 FILE=SKINS\JeepTDXHBodySk01.bmp GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=JeepTDXHBodySk02 FILE=SKINS\JeepTDXHBodySk02.bmp GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=JeepTDXHBodySk03 FILE=SKINS\JeepTDXHBodySk03.bmp GROUP=Skins LODSET=2

defaultproperties
{
      Wheels(0)=(WheelOffset=(X=80.000000,Y=-60.000000,Z=-35.000000),WheelClass=Class'XWheelVeh.JTDXWheel',WheelMesh=LodMesh'XWheelVeh.JSDXWheel')
      Wheels(1)=(WheelOffset=(X=80.000000,Y=60.000000,Z=-35.000000),WheelClass=Class'XWheelVeh.JTDXWheel',WheelMesh=LodMesh'XWheelVeh.JSDXWheelMir',bMirroredWheel=True)
      Wheels(2)=(WheelOffset=(X=-80.000000,Y=-60.000000,Z=-35.000000),WheelClass=Class'XWheelVeh.JTDXWheel',WheelMesh=LodMesh'XWheelVeh.JSDXWheel')
      Wheels(3)=(WheelOffset=(X=-80.000000,Y=60.000000,Z=-35.000000),WheelClass=Class'XWheelVeh.JTDXWheel',WheelMesh=LodMesh'XWheelVeh.JSDXWheelMir',bMirroredWheel=True)
      MaxGroundSpeed=750.000000
      WheelTurnSpeed=16000.000000
      bEngDynSndPitch=True
      MinEngPitch=16
      MaxEngPitch=75
      WheelsRadius=27.500000
      TractionWheelsPosition=-80.000000
      VehicleGravityScale=2.350000
      WAccelRate=480.000000
      Health=900
      VehicleName="Jeep TDX"
      ExitOffset=(Y=150.000000)
      BehinViewViewOffset=(X=-220.000000,Z=112.500000)
      StartSound=Sound'XWheelVeh.JeepSDX.JeepStart'
      EndSound=Sound'XWheelVeh.JeepSDX.JeepStop'
      EngineSound=Sound'XWheelVeh.JeepSDX.JeepEng'
      PassengerSeats(0)=(PassengerWeapon=Class'XWheelVeh.JTDXTurret',PassengerWOffset=(X=-78.125000,Z=8.062500),CameraOffset=(Z=37.500000),CamBehindviewOffset=(X=-75.000000,Z=57.500000),bIsAvailable=True,SeatName="Heavy Plasma Dual Cannon")
      VehicleKeyInfoStr="Jeep TDX keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to turn|%Fire% to fire, %AltFire% to alt fire|1, 2 to switch seats|0 to toggle light|%PrevWeapon%, %NextWeapon%, %SwitchToBestWeapon% to change camera|%ThrowWeapon% to exit the vehicle"
      bSlopedPhys=True
      FrontWide=(X=80.000000,Y=60.000000,Z=-7.500000)
      BackWide=(X=-80.000000,Y=60.000000,Z=-7.500000)
      ZRange=220.000000
      MaxObstclHeight=25.000000
      HornSnd=Sound'XWheelVeh.JeepSDX.JeepHorn'
      bDriverHorn=True
      HornTimeInterval=2.000000
      PassCrosshairTex(0)=Texture'XWheelVeh.Icons.JeepSDXTurretCross'
      PassCrossColor(0)=(R=255,G=0,B=0)
      ArmorType(0)=(ArmorLevel=0.300000,ProtectionType="Burned")
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
      GroundPower=2.100000
      DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=103.750000,Z=17.500000),FXRange=13)
      ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=5.550000)
      ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="JSDXWheel")
      ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.875000,AttachName="JSDXTurret")
      UseExplosionSnd2=False
      WreckPartColHeight=48.000000
      Mesh=LodMesh'XWheelVeh.JeepSDX'
      MultiSkins(1)=Texture'XWheelVeh.Skins.JeepTDXHBodySk01'
      MultiSkins(2)=Texture'XWheelVeh.Skins.JeepTDXHBodySk02'
      MultiSkins(3)=Texture'XWheelVeh.Skins.JeepTDXHBodySk03'
      SoundRadius=70
      SoundVolume=100
      CollisionRadius=80.000000
      CollisionHeight=60.000000
      Mass=2700.000000
}
