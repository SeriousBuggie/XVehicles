//////////////////////////////////////////////////////////////
//				Feralidragon (15-01-2011)
//
// NW3 CYBOT LAUNCHER BUILD 1.00
//////////////////////////////////////////////////////////////

class CybProjExplRed expands UT_FlameExplosion;

#exec TEXTURE IMPORT NAME=RedCybPallete FILE=PALLETES\RedCybPallete.bmp GROUP=Palletes
#exec TEXTURE IMPORT NAME=BlueCybPallete FILE=PALLETES\BlueCybPallete.bmp GROUP=Palletes
#exec TEXTURE IMPORT NAME=GreenCybPallete FILE=PALLETES\GreenCybPallete.bmp GROUP=Palletes
#exec TEXTURE IMPORT NAME=YellowCybPallete FILE=PALLETES\YellowCybPallete.bmp GROUP=Palletes

#exec OBJ LOAD FILE=Textures\CybProjExplosions.utx PACKAGE=NWCybotLauncherVIII.CybProjExplosions

#exec AUDIO IMPORT NAME="CybProjExplSnd" FILE=SOUNDS\CybProjExplSnd.wav GROUP="Explosion"

simulated function PostBeginPlay()
{
	MakeSound();
}

function MakeSound()
{
	if (EffectSound1 != None)
		PlaySound(EffectSound1,,8.0,,1200.0);
}

defaultproperties
{
      EffectSound1=Sound'XChopVeh.Explosion.CybProjExplSnd'
      Texture=Texture'XChopVeh.CybProjExplosions.CybRExpl01'
      Skin=Texture'XChopVeh.Palletes.RedCybPallete'
      DrawScale=1.000000
      ScaleGlow=1.650000
      LightBrightness=35
      LightRadius=3
}
