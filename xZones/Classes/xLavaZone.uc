class xLavaZone expands xZoneInfo;

#exec AUDIO IMPORT NAME="BubbleLavaLoop" FILE=SOUNDS\BubbleLavaLoop.wav GROUP="Lava"
#exec AUDIO IMPORT NAME="LavaTrailFXLoop" FILE=SOUNDS\LavaTrailFXLoop.wav GROUP="LavaTrailFX"

#exec TEXTURE IMPORT NAME=LavaTrail FILE=PARTICLES\LavaTrail.bmp GROUP=Particles FLAGS=2

defaultproperties
{
      isWaterFX=True
      DistortionAmount=9
      ZoneAmbSound=Sound'xZones.Lava.BubbleLavaLoop'
      ZoneAmbVolume=255
      SplashClass(0)=Class'xZones.LavaVertSplashA00'
      SplashClass(1)=Class'xZones.LavaVertSplashA01'
      SplashClass(2)=Class'xZones.LavaVertSplashA02'
      SplashClass(3)=Class'xZones.LavaVertSplashA03'
      SplashClass(4)=Class'xZones.LavaVertSplashA04'
      SplashClass(5)=Class'xZones.LavaVertSplashA05'
      SplashClass(6)=Class'xZones.LavaVertSplashA06'
      SplashClass(7)=Class'xZones.LavaVertSplashA07'
      BallisticSplashClass(0)=Class'xZones.BalLavaSplash00'
      BallisticSplashClass(1)=Class'xZones.BalLavaSplash01'
      BallisticSplashClass(2)=Class'xZones.BalLavaSplash02'
      BallisticSplashClass(3)=Class'xZones.BalLavaSplash03'
      WaterRingClass=Class'xZones.LavaSplashRing'
      SplashDamage=50
      DamagePerSec=2500
      DamageType="Burned"
      ZoneName="LAVA"
      EntrySound=Sound'UnrealShare.Generic.LavaEn'
      ExitSound=Sound'UnrealShare.Generic.LavaEx'
      EntryActor=Class'xZones.xFlameExplosion'
      ExitActor=Class'xZones.xFlameExplosion'
      bWaterZone=True
      bPainZone=True
      bDestructive=True
      bNoInventory=True
      ViewFog=(X=0.585938,Y=0.195313,Z=0.078125)
      AmbientSound=Sound'xZones.LavaTrailFX.LavaTrailFXLoop'
      Skin=Texture'xZones.Particles.LavaTrail'
}
