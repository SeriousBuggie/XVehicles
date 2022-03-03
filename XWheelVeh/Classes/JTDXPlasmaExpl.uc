class JTDXPlasmaExpl expands UT_FlameExplosion;

#exec AUDIO IMPORT NAME="JTDXLPlasmaHit" FILE=SOUNDS\JTDXLPlasmaHit.wav GROUP="Plasma"
#exec OBJ LOAD FILE=Textures\HPlasma.utx PACKAGE=XWheelVeh.PlasmaExpl

defaultproperties
{
      EffectSound1=Sound'XWheelVeh.Plasma.JTDXLPlasmaHit'
      Texture=Texture'XWheelVeh.PlasmaExpl.HeavyPlasmExpl01'
      DrawScale=1.000000
      SpriteProjForward=47.500000
      LightBrightness=40
      LightHue=0
      LightSaturation=0
}
