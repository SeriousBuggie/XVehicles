class xSlimeZone expands xZoneInfo;

#exec AUDIO IMPORT NAME="BubbleSlimeLoop" FILE=SOUNDS\BubbleSlimeLoop.wav GROUP="Slime"
#exec AUDIO IMPORT NAME="SlimeTrailFXLoop" FILE=SOUNDS\SlimeTrailFXLoop.wav GROUP="SlimeTrailFX"

#exec TEXTURE IMPORT NAME=SlimeTrail FILE=PARTICLES\SlimeTrail.bmp GROUP=Particles FLAGS=2

defaultproperties
{
	isWaterFX=True
	DistortionAmount=9
	ZoneAmbSound=Sound'xZones.Slime.BubbleSlimeLoop'
	ZoneAmbVolume=255
	SplashClass(0)=Class'SlimeVertSplashA00'
	SplashClass(1)=Class'SlimeVertSplashA01'
	SplashClass(2)=Class'SlimeVertSplashA02'
	SplashClass(3)=Class'SlimeVertSplashA03'
	SplashClass(4)=Class'SlimeVertSplashA04'
	SplashClass(5)=Class'SlimeVertSplashA05'
	SplashClass(6)=Class'SlimeVertSplashA06'
	SplashClass(7)=Class'SlimeVertSplashA07'
	BallisticSplashClass(0)=Class'BalSlimeSplash00'
	BallisticSplashClass(1)=Class'BalSlimeSplash01'
	BallisticSplashClass(2)=Class'BalSlimeSplash02'
	BallisticSplashClass(3)=Class'BalSlimeSplash03'
	WaterRingClass=Class'SlimeSplashRing'
	SplashDamage=15
	DamagePerSec=50
	DamageType="Corroded"
	ZoneName="SLIME"
	EntrySound=Sound'UnrealShare.Generic.LavaEn'
	ExitSound=Sound'UnrealShare.Generic.LavaEx'
	EntryActor=Class'UnrealShare.GreenSmokePuff'
	ExitActor=Class'UnrealShare.GreenSmokePuff'
	bWaterZone=True
	bPainZone=True
	bDestructive=True
	bNoInventory=True
	ViewFlash=(X=-0.117200,Y=-0.117200,Z=-0.117200)
	ViewFog=(X=0.187500,Y=0.281250,Z=0.093750)
	AmbientSound=Sound'xZones.SlimeTrailFX.SlimeTrailFXLoop'
	Skin=Texture'xZones.Particles.SlimeTrail'
}
