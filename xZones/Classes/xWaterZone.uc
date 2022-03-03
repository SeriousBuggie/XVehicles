class xWaterZone expands xZoneInfo;

#exec AUDIO IMPORT NAME="Underwater01" FILE=SOUNDS\Underwater01.wav GROUP="UnderWater"
#exec AUDIO IMPORT NAME="Underwater02" FILE=SOUNDS\Underwater02.wav GROUP="UnderWater"
#exec AUDIO IMPORT NAME="Underwater03" FILE=SOUNDS\Underwater03.wav GROUP="UnderWater"
#exec AUDIO IMPORT NAME="Underwater04" FILE=SOUNDS\Underwater04.wav GROUP="UnderWater"
#exec AUDIO IMPORT NAME="Underwater05" FILE=SOUNDS\Underwater05.wav GROUP="UnderWater"
#exec AUDIO IMPORT NAME="Underwater06" FILE=SOUNDS\Underwater06.wav GROUP="UnderWater"

#exec AUDIO IMPORT NAME="WaterTrailFXLoop" FILE=SOUNDS\WaterTrailFXLoop.wav GROUP="WaterTrailFX"

#exec TEXTURE IMPORT NAME=WaterTrail FILE=PARTICLES\WaterTrail.bmp GROUP=Particles FLAGS=2

defaultproperties
{
      isWaterFX=True
      DistortionAmount=4
      ZoneAmbSound=Sound'xZones.UnderWater.Underwater04'
      ZoneAmbVolume=190
      ZoneName="Underwater"
      EntrySound=Sound'UnrealShare.Generic.DSplash'
      ExitSound=Sound'UnrealShare.Generic.WtrExit1'
      EntryActor=Class'UnrealShare.WaterImpact'
      ExitActor=Class'UnrealShare.WaterImpact'
      bWaterZone=True
      ViewFlash=(X=-0.075000,Y=-0.075000,Z=-0.075000)
      ViewFog=(X=0.100000,Y=0.200000,Z=0.325000)
      AmbientSound=Sound'xZones.WaterTrailFX.WaterTrailFXLoop'
      Skin=Texture'xZones.Particles.WaterTrail'
}
