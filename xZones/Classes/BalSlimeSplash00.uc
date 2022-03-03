class BalSlimeSplash00 expands BalWaterSplash00;

#exec AUDIO IMPORT NAME="SlimeSnd1" FILE=SOUNDS\SlimeSnd1.wav GROUP="Slime"
#exec AUDIO IMPORT NAME="SlimeSnd2" FILE=SOUNDS\SlimeSnd2.wav GROUP="Slime"

defaultproperties
{
      SplashSnd(0)=Sound'UnrealShare.Generic.LavaEn'
      SplashSnd(1)=Sound'UnrealShare.Generic.LavaEx'
      SplashSnd(2)=Sound'xZones.Slime.SlimeSnd1'
      SplashSnd(3)=Sound'xZones.Slime.SlimeSnd2'
      Texture=Texture'xZones.Particles.SplshSlime'
}
