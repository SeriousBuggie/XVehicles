//=============================================================================
// Viper.
//=============================================================================
class Viper expands HoverCraftPhys;

/*
#forceexec MESH  MODELIMPORT MESH=Viper MODELFILE=Z:\XV\ut3\VH_NecrisManta.psk LODSTYLE=10
#forceexec ANIM  IMPORT ANIM=ViperAnims ANIMFILE=Z:\XV\ut3\NecrisManta_anims.psa COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#forceexec MESH ORIGIN MESH=Viper X=0 Y=0 Z=50
#forceexec MESH  LODPARAMS MESH=Viper STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=Viper X=1 Y=1 Z=1
#forceexec MESH  DEFAULTANIM MESH=Viper ANIM=ViperAnims

//#forceexec ANIM  SEQUENCE ANIM=ViperAnims SEQ=All STARTFRAME=0 NUMFRAMES=1 RATE=30.0000 COMPRESS=1.00
//#forceexec ANIM  SEQUENCE ANIM=ViperAnims SEQ=Still STARTFRAME=0 NUMFRAMES=1 RATE=30.0000 COMPRESS=1.00

#forceexec ANIM DIGEST ANIM=ViperAnims  VERBOSE
#forceexec MESHMAP SETTEXTURE MESHMAP=Viper NUM=0 TEXTURE=ViperSkinRed
// */

var byte CurrentTeamColor;

simulated function Tick(float delta)
{
	Super.Tick(delta);
	if (CurrentTeamColor != CurrentTeam)
		ChangeColor();
	Animate();
}

simulated function ChangeColor()
{
	CurrentTeamColor = CurrentTeam;
	switch (CurrentTeamColor)
	{
		case 1:
		case 2:
			MultiSkins[0] = Texture'ViperSkinBlue';
			break;
		default: 
			MultiSkins[0] = Texture'ViperSkinRed';
			break;
	}
}

simulated function Animate()
{
	if (Rising > 0 && AnimSequence != 'JumpIdle')
		LoopAnim('JumpIdle', 1, 0.5);
	else if (Rising <= 0 && AnimSequence == 'JumpIdle')
		PlayAnim('JumpEnd', 0.8, 0.1);
	else if (AnimSequence == 'JumpStart' && !IsAnimating())
		PlayAnim('JumpEnd', 0.5, 0);
	else if (AnimSequence == 'JumpEnd' && !IsAnimating())
		LoopAnim('SlowIdle', 1, 0.2);
	else if (bOnGround && Turning > 0 && AnimSequence != 'FastIdle_lf')
		LoopAnim('FastIdle_lf', 0.8, 0.7);
	else if (bOnGround && Turning < 0 && AnimSequence != 'FastIdle_rt')
		LoopAnim('FastIdle_rt', 0.8, 0.7);
	else if (bOnGround && Turning == 0 && Accel == 0 && AnimSequence != 'SlowIdle')
		LoopAnim('SlowIdle', 1, 0.5);
	else if (bOnGround && Turning == 0 && Accel > 0 && AnimSequence == 'SlowIdle')
		PlayAnim('SpeedUp', 1.2, 0.2);
	else if (bOnGround && Turning == 0 && Accel > 0 && AnimSequence == 'SpeedUp' && !IsAnimating())
		LoopAnim('FastIdle_fw', 1, 0.1);
	else if (bOnGround && Turning == 0 && Accel < 0 && AnimSequence == 'SlowIdle')
		PlayAnim('FastIdle_bw', 1, 0.3);
	else if (bOnGround && Turning == 0 && Accel < 0 && AnimSequence == 'FastIdle_fw')
		PlayAnim('SlowDown', 1, 0.2);
	else if (bOnGround && Turning == 0 && Accel < 0 && AnimSequence == 'SlowDown' && !IsAnimating())
		LoopAnim('FastIdle_bw', 1, 0.1);
	else if (bOnGround && Turning == 0 && Accel > 0 && (AnimSequence == 'FastIdle_rt' || AnimSequence == 'FastIdle_lf'))
		LoopAnim('FastIdle_fw', 1, 0.5);
	else if (bOnGround && Turning == 0 && Accel < 0 && (AnimSequence == 'FastIdle_rt' || AnimSequence == 'FastIdle_lf'))
		LoopAnim('FastIdle_bw', 1, 0.5);
	else if (Turning == 0 && (AnimSequence == 'FastIdle_rt' || AnimSequence == 'FastIdle_lf'))
		LoopAnim('SlowIdle', 1, 0.6);
}

defaultproperties
{
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
	JumpSound=Sound'XHoverVeh.Viper.Jump'
	DuckSound=Sound'XHoverVeh.Manta.HoverBikeTurbo01'
	AIRating=6.000000
	WAccelRate=1000.000000
	VehicleName="Viper"
	TranslatorDescription="This is a Viper, press [Fire] or [AltFire] to fire the different firemodes. Use your Strafe keys and Move Forward/Backward keys to strafe/accelerate/deaccelerate. To leave this vehicle, press your [ThrowWeapon] key."
	ExitOffset=(X=0.000000,Y=130.000000)
	BehinViewViewOffset=(X=-500.000000,Y=0.000000,Z=100.000000)
	StartSound=Sound'XHoverVeh.Viper.EnterVehicle'
	EndSound=Sound'XHoverVeh.Viper.ExitVehicle'
	EngineSound=Sound'XHoverVeh.Viper.Engine'
	ImpactSounds(0)=Sound'XHoverVeh.Viper.impact'
	ImpactSounds(1)=Sound'XHoverVeh.Viper.impact'
	ImpactSounds(2)=Sound'XHoverVeh.Viper.impact'
	ImpactSounds(3)=Sound'XHoverVeh.Viper.impact'
	ImpactSounds(4)=Sound'XHoverVeh.Viper.impact'
	ImpactSounds(5)=Sound'XHoverVeh.Viper.impact'
	ImpactSounds(6)=Sound'XHoverVeh.Viper.impact'
	bEngDynSndPitch=True
	MinEngPitch=32
	MaxEngPitch=128
	DriverWeapon=(WeaponClass=Class'ViperGun',WeaponOffset=(X=0.000000))
	WDeAccelRate=1500.000000
	HeadLights(0)=(VLightOffset=(X=85.000000,Y=11.000000,Z=-2.000000),VLightTex=Texture'XHoverVeh.pics.FlashFlare1',VLightScale=0.500000)
	HeadLights(1)=(VLightOffset=(X=85.000000,Y=-11.000000,Z=-2.000000),VLightTex=Texture'XHoverVeh.pics.FlashFlare1',VLightScale=0.500000)
	HeadLightOn=None
	HeadLightOff=None
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=-49.000000,Y=-16.000000,Z=18.000000))
	DestroyedExplDmg=70
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=6.750000)
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=100.000000,Y=80.000000,Z=-5.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-64.000000,Y=80.000000,Z=-5.000000))
	bEnableShield=True
	ShieldLevel=0.650000
	AnimSequence="SlowIdle"
	LODBias=1.000000
	Texture=Texture'XHoverVeh.pics.fan1'
	Mesh=SkeletalMesh'Viper'
	SoundRadius=255
	SoundVolume=255
	CollisionRadius=92.000000
	CollisionHeight=46.000000
}
