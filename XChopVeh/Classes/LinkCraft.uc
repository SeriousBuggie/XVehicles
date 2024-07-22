//=============================================================================
// LinkCraft.
//=============================================================================
class LinkCraft expands ChopperPhys;

/*
#forceexec MESH  MODELIMPORT MESH=LinkCraft MODELFILE=Z:\XV\AS\LinkBody_.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=LinkCraft X=0 Y=0 Z=0
#forceexec MESH  LODPARAMS MESH=LinkCraft STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=LinkCraft X=1 Y=1 Z=1

#forceexec MESHMAP SETTEXTURE MESHMAP=LinkCraft NUM=0 TEXTURE=LinkTurret_skin2
#forceexec MESHMAP SETTEXTURE MESHMAP=LinkCraft NUM=1 TEXTURE=LinkTurret_skin1
#forceexec MESHMAP SETTEXTURE MESHMAP=LinkCraft NUM=2 TEXTURE=Greenshield
// */

/*
#forceexec ANIM IMPORT ANIM=LinkCraftAnim ANIMFILE=Z:\XV\AS\LinkBody_.psa IMPORTSEQS=1
#forceexec MESH DEFAULTANIM MESH=LinkCraft ANIM=LinkCraftAnim
#forceexec ANIM DIGEST ANIM=LinkCraftAnim VERBOSE
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
	local Class<Projectile> Proj;
	CurrentTeamColor = CurrentTeam;
	switch (CurrentTeamColor)
	{
		case 1:
			Proj = Class'CybProjB';
			MultiSkins[2] = Texture'BlueShield';
			break;
		case 2:
			Proj = Class'CybProjG';
			MultiSkins[2] = Texture'Greenshield';
			break;
		case 3:
			Proj = Class'CybProjY';
			MultiSkins[2] = Texture'N_Shield';
			break;
		case 0:
		default: 
			MultiSkins[2] = Texture'RedShield';
			Proj = Class'CybProj';
			break;
	}
	if (DriverGun != None)
		DriverGun.WeapSettings[0].ProjectileClass = Proj;
}

defaultproperties
{
	CurrentTeamColor=42
	MaxAirSpeed=2000.000000
	YawTurnSpeed=36000.000000
	AIRating=5.000000
	WAccelRate=1000.000000
	Health=360
	VehicleName="LinkCraft"
	TranslatorDescription="This is a LinkCraft, you can fire different firemodes using [Fire] and [AltFire] buttons. To move higher or lover use [Jump] and [Crouch] buttons and to move around use movement keys. To leave this vehicle press [ThrowWeapon] key."
	ExitOffset=(X=0.000000,Y=140.000000)
	BehinViewViewOffset=(X=-400.000000,Y=0.000000,Z=208.000000)
	StartSound=Sound'AttackCraftStartUp'
	EndSound=Sound'AttackCraftShutDown'
	EngineSound=Sound'AttackCraftIdle'
	ImpactSounds(0)=Sound'XChopVeh.Damage.CybSndArmorDmg1'
	ImpactSounds(1)=Sound'XChopVeh.Damage.CybSndArmorDmg2'
	ImpactSounds(2)=Sound'XChopVeh.Damage.CybSndArmorDmg3'
	ImpactSounds(3)=Sound'XChopVeh.Hit.CybWreckMetalHit'
	ImpactSounds(4)=Sound'XChopVeh.Damage.CybSndArmorDmg1'
	ImpactSounds(5)=Sound'XChopVeh.Damage.CybSndArmorDmg2'
	ImpactSounds(6)=Sound'XChopVeh.Hit.CybWreckMetalHit'
	ImpactSounds(7)=Sound'XChopVeh.Fragments.FragSound01'
	BulletHitSounds(0)=Sound'XChopVeh.Damage.CybSndArmorDmg1'
	BulletHitSounds(1)=Sound'XChopVeh.Damage.CybSndArmorDmg2'
	BulletHitSounds(2)=Sound'XChopVeh.Damage.CybSndArmorDmg3'
	BulletHitSounds(3)=Sound'XChopVeh.Hit.CybWreckMetalHit'
	BulletHitSounds(4)=Sound'XChopVeh.Damage.CybSndArmorDmg1'
	BulletHitSounds(5)=Sound'XChopVeh.Damage.CybSndArmorDmg2'
	bEngDynSndPitch=True
	MinEngPitch=64
	MaxEngPitch=96
	DriverWeapon=(WeaponClass=Class'LinkCraftGun',WeaponOffset=(X=0.000000))
	VehicleKeyInfoStr="LinkCraft keys:|%MoveForward%,%MoveBackward% to accelerate/deaccelerate|%StrafeLeft%, %StrafeRight% to strafe|%Jump%, %Duck% to move up/down|%Fire% to fire, %AltFire% to alt fire|Number keys to switch seats|%ThrowWeapon% to exit the vehicle"
	WDeAccelRate=200.000000
	HeadLights(0)=(VLightOffset=(X=100.000000,Y=14.000000,Z=-43.000000),VLightTex=Texture'XHoverVeh.pics.FlashFlare1',VLightScale=0.500000)
	HeadLights(1)=(VLightOffset=(X=100.000000,Y=-14.000000,Z=-43.000000),VLightTex=Texture'XHoverVeh.pics.FlashFlare1',VLightScale=0.500000)
	HeadLightOn=None
	HeadLightOff=None
	DamageGFX(0)=(bHaveThisGFX=True,bHaveFlames=True,DmgFXOffset=(X=110.000000,Z=-5.000000),FXRange=15)
	DestroyedExplDmg=70
	ExplosionGFX(0)=(bHaveThisExplFX=True,ExplSize=6.750000)
	ExplosionGFX(1)=(bHaveThisExplFX=True,ExplSize=2.000000,AttachName="LinkCraftGun")
	ExplosionGFX(2)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=100.000000,Y=80.000000,Z=-5.000000))
	ExplosionGFX(3)=(bHaveThisExplFX=True,ExplSize=1.750000,bUseCoordOffset=True,bSymetricalCoordY=True,ExplFXOffSet=(X=-64.000000,Y=80.000000,Z=-5.000000))
	bEnableShield=True
	ShieldLevel=0.600000
	Mesh=SkeletalMesh'LinkCraft'
	AmbientGlow=17
	SoundRadius=255
	SoundVolume=160
	CollisionRadius=112.000000
	CollisionHeight=88.000000
}
