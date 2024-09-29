//=============================================================================
// Ghost.
//=============================================================================
class Ghost expands HoverCraftPhys;

/*
#forceexec MESH  MODELIMPORT MESH=Ghost MODELFILE=Z:\XV\halo\Ghost_.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=Ghost X=-20 Y=0 Z=10
#forceexec MESH  LODPARAMS MESH=Ghost STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=Ghost X=1.6 Y=1.6 Z=1.6

#forceexec MESHMAP SETTEXTURE MESHMAP=Ghost NUM=0 TEXTURE=Ghost1
// */


var float InvisTime;
var bool bInvis;

var byte CurrentTeamColor;

simulated function Tick(float delta)
{
	Super.Tick(delta);
	if (Role == ROLE_Authority)
	{
		if (CurrentTeamColor != CurrentTeam)
			ChangeColor();
		if (bInvis && Level.TimeSeconds - InvisTime >= 13.0)
			InvisOff();
	}
}

singular function DriverLeft( optional bool bForcedLeave, optional coerce string Reason )
{
	Super.DriverLeft(bForcedLeave, Reason);
	if (Driver == None)
		InvisOff();
}

simulated function ChangeColor()
{
	CurrentTeamColor = CurrentTeam;
	switch (CurrentTeamColor)
	{
		case 0:
			MultiSkins[0] = Texture'ghostred';
			break;
		case 1:
			MultiSkins[0] = Texture'ghostblue';
			break;
		default: 
			MultiSkins[0] = Texture'ghost1';
			break;
	}
	Style = STY_Normal;
}

function InvisOn()
{
	if (bInvis)
		return;
	if (Level.TimeSeconds - InvisTime >= 25.0)
	{
		bInvis = true;
		InvisTime = Level.TimeSeconds;
		MultiSkins[0] = Texture'unrealshare.Belt_fx.Invis';
		Style = STY_Translucent;
		PlaySound(Sound'PwrNodeBuild01', SLOT_None);
	}
}

function InvisOff()
{
	if (!bInvis)
		return;
	bInvis = false;
	InvisTime = Level.TimeSeconds;
	ChangeColor();
	PlaySound(Sound'PwrNodeBuild01', SLOT_None);
}

defaultproperties
{
	InvisTime=-1000.000000
	CurrentTeamColor=42
	MaxHoverSpeed=2500.000000
	VehicleTurnSpeed=16000.000000
	HoveringHeight=160.000000
	JumpingHeight=730.000000
	MaxPushUpDiff=3.000000
	bCanDuck=True
	Repulsor(0)=(X=95.000000,Z=-7.000000)
	Repulsor(1)=(X=-10.000000,Y=80.000000,Z=-7.000000)
	Repulsor(2)=(X=-10.000000,Y=-80.000000,Z=-7.000000)
	RepulsorCount=3
	JumpSound=Sound'XHoverVeh.Manta.HoverBikeJump05'
	DuckSound=Sound'XHoverVeh.Manta.HoverBikeTurbo01'
	AIRating=6.000000
	WAccelRate=1000.000000
	VehicleName="Ghost"
	TranslatorDescription="This is a Ghost, press [Fire] or [AltFire] to fire the different firemodes. Use your Strafe keys and Move Forward/Backward keys to strafe/accelerate/deaccelerate. To leave this vehicle, press your [ThrowWeapon] key."
	ExitOffset=(X=0.000000,Y=130.000000)
	BehinViewViewOffset=(X=-500.000000,Y=0.000000,Z=100.000000)
	StartSound=Sound'XHoverVeh.Ghost.ghost_in'
	EndSound=Sound'XHoverVeh.Ghost.ghost_out'
	EngineSound=Sound'XHoverVeh.Ghost.ghost_hover'
	bEngDynSndPitch=True
	MinEngPitch=65
	MaxEngPitch=100
	DriverWeapon=(WeaponClass=Class'GhostGun',WeaponOffset=(X=0.000000))
	WDeAccelRate=1500.000000
	HeadLights(0)=(VLightOffset=(X=85.000000,Y=11.000000,Z=-2.000000),VLightTex=Texture'XHoverVeh.pics.FlashFlare1',VLightScale=0.500000)
	HeadLights(1)=(VLightOffset=(X=85.000000,Y=-11.000000,Z=-2.000000),VLightTex=Texture'XHoverVeh.pics.FlashFlare1',VLightScale=0.500000)
	HeadLightOn=None
	HeadLightOff=None
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=2.000000,Y=-43.000000,Z=-16.000000))
	DestroyedExplDmg=70
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=6.750000)
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=100.000000,Y=80.000000,Z=-5.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-64.000000,Y=80.000000,Z=-5.000000))
	bEnableShield=True
	ShieldLevel=0.650000
	LODBias=1.000000
	Texture=Texture'XHoverVeh.pics.fan1'
	Mesh=SkeletalMesh'Ghost'
	SoundRadius=255
	SoundVolume=255
	CollisionRadius=92.000000
	CollisionHeight=46.000000
}
