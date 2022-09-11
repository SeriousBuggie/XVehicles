//=============================================================================
// XManta.
//=============================================================================
class XManta expands HoverCraftPhys;

/*
#forceexec MESH IMPORT MESH=Manta ANIVFILE=Z:\XV\Manta_a.3d DATAFILE=Z:\XV\Manta_d.3d X=0 Y=0 Z=0 mlod=0 
#forceexec MESH ORIGIN MESH=Manta X=-2 Y=0 Z=0

#forceexec MESH SEQUENCE MESH=Manta SEQ=All STARTFRAME=0 NUMFRAMES=1

#forceexec MESHMAP NEW MESHMAP=Manta MESH=Manta
#forceexec MESHMAP SCALE MESHMAP=Manta X=0.1185 Y=0.1185 Z=0.237

#forceexec MESHMAP SETTEXTURE MESHMAP=Manta NUM=0 TEXTURE=MantaYellow
#forceexec MESHMAP SETTEXTURE MESHMAP=Manta NUM=1 TEXTURE=fan1
#forceexec MESHMAP SETTEXTURE MESHMAP=Manta NUM=2 TEXTURE=fan1
// */

/*
#forceexec MESH  MODELIMPORT MESH=Manta2 MODELFILE=Z:\XV\HoverBike.psk LODSTYLE=10
//#forceexec ANIM  IMPORT ANIM=Manta2Anims ANIMFILE=Z:\XV\HoverBike.psa COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#forceexec MESH ORIGIN MESH=Manta2 X=-11.63 Y=0 Z=16.75
#forceexec MESH  LODPARAMS MESH=Manta2 STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=Manta2 X=1 Y=1 Z=1
//#forceexec MESH  DEFAULTANIM MESH=Manta2 ANIM=Manta2Anims

//#forceexec ANIM  SEQUENCE ANIM=Manta2Anims SEQ=All STARTFRAME=0 NUMFRAMES=1 RATE=30.0000 COMPRESS=1.00
//#forceexec ANIM  SEQUENCE ANIM=Manta2Anims SEQ=Still STARTFRAME=0 NUMFRAMES=1 RATE=30.0000 COMPRESS=1.00

//#forceexec ANIM DIGEST ANIM=Manta2Anims  VERBOSE
#forceexec MESHMAP SETTEXTURE MESHMAP=Manta2 NUM=0 TEXTURE=MantaYellow
#forceexec MESHMAP SETTEXTURE MESHMAP=Manta2 NUM=1 TEXTURE=fan1
#forceexec MESHMAP SETTEXTURE MESHMAP=Manta2 NUM=2 TEXTURE=fan1
// */

var byte CurrentTeamColor;

simulated function Tick(float delta)
{
	Super.Tick(delta);
	if (CurrentTeamColor != CurrentTeam)
		ChangeColor();
	if (bHeadLightInUse != bDriving)
	{
		bUseVehicleLights = true;
		SwitchVehicleLights();
		bUseVehicleLights = false;
	}
}

simulated function ChangeColor()
{
	CurrentTeamColor = CurrentTeam;
	switch (CurrentTeamColor)
	{
		case 1:
		case 2:
			MultiSkins[0] = Texture'MantaGreen';
			break;
		default: 
			MultiSkins[0] = Texture'MantaYellow';
			break;
	}
}

defaultproperties
{
	MaxHoverSpeed=2500.000000
	VehicleTurnSpeed=16000.000000
	HoveringHeight=160.000000
	JumpingHeight=730.000000
	MaxPushUpDiff=3.000000
	Repulsor(0)=(X=95.000000,Z=-7.000000)
	Repulsor(1)=(X=-10.000000,Y=80.000000,Z=-7.000000)
	Repulsor(2)=(X=-10.000000,Y=-80.000000,Z=-7.000000)
	JumpSound=Sound'XHoverVeh.Manta.HoverBikeJump05'
	DuckSound=Sound'XHoverVeh.Manta.HoverBikeTurbo01'
	bEngDynSndPitch=True
	MinEngPitch=64
	MaxEngPitch=128
	AIRating=6.000000
	WAccelRate=1000.000000
	VehicleName="Manta"
	TranslatorDescription="This is a Manta, press [Fire] or [AltFire] to fire the different firemodes. Use your Strafe keys and Move Forward/Backward keys to strafe/accelerate/deaccelerate. To leave this vehicle, press your [ThrowWeapon] key."
	ExitOffset=(X=0.000000,Y=130.000000)
	BehinViewViewOffset=(X=-500.000000,Y=0.000000,Z=100.000000)
	StartSound=Sound'XHoverVeh.Manta.HoverBikeStart01'
	EndSound=Sound'XHoverVeh.Manta.HoverBikeStop01'
	EngineSound=Sound'XHoverVeh.Manta.HoverBikeEng02'
	DriverWeapon=(WeaponClass=Class'XHoverVeh.MantaGun',WeaponOffset=(X=0.000000))
	WDeAccelRate=1500.000000
	HeadLights(0)=(VLightOffset=(X=85.000000,Y=11.000000,Z=-2.000000),VLightTex=Texture'XHoverVeh.pics.FlashFlare1',VLightScale=0.500000)
	HeadLights(1)=(VLightOffset=(X=85.000000,Y=-11.000000,Z=-2.000000),VLightTex=Texture'XHoverVeh.pics.FlashFlare1',VLightScale=0.500000)
	HeadLightOn=None
	HeadLightOff=None
	DropFlag=DF_All
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=50.000000,Y=-25.000000,Z=-7.000000))
	DestroyedExplDmg=70
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=6.750000)
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=100.000000,Y=80.000000,Z=-5.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-64.000000,Y=80.000000,Z=-5.000000))
	bEnableShield=True
	ShieldLevel=0.650000
	LODBias=1.000000
	Texture=Texture'XHoverVeh.pics.fan1'
	Mesh=Mesh'XHoverVeh.Manta'
	MultiSkins(1)=Texture'XHoverVeh.pics.fan1'
	MultiSkins(2)=Texture'XHoverVeh.pics.fan1'
	SoundRadius=255
	SoundVolume=255
	CollisionRadius=92.000000
	CollisionHeight=46.000000
}
