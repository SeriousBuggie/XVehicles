class BalLavaSplash00 expands BalWaterSplash00;

#exec AUDIO IMPORT NAME="LavaExpl01" FILE=SOUNDS\LavaExpl01.wav GROUP="Lava"
#exec AUDIO IMPORT NAME="LavaExpl02" FILE=SOUNDS\LavaExpl02.wav GROUP="Lava"
#exec AUDIO IMPORT NAME="LavaExpl03" FILE=SOUNDS\LavaExpl03.wav GROUP="Lava"

defaultproperties
{
	SplashSnd(0)=Sound'UnrealShare.General.Expl04'
	SplashSnd(1)=Sound'xZones.lava.LavaExpl01'
	SplashSnd(2)=Sound'xZones.lava.LavaExpl02'
	SplashSnd(3)=Sound'xZones.lava.LavaExpl03'
	Texture=Texture'xZones.Particles.SplshLava'
}
