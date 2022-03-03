class LavaSplashRing expands WaterSplashRing;

#exec TEXTURE IMPORT NAME=LavaSplashRing FILE=PARTICLES\LavaSplashRing.bmp GROUP=Particles FLAGS=2
#exec TEXTURE IMPORT NAME=SplshLava FILE=PARTICLES\SplshLava.bmp GROUP=Particles FLAGS=2

defaultproperties
{
      MultiSkins(1)=Texture'xZones.Particles.LavaSplashRing'
}
