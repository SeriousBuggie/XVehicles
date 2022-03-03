class ShrAnimRedIonExpl expands xTreadVehEffects;

#exec TEXTURE IMPORT NAME=RedIonBallFX01 FILE=Effects\RedIonBallFX01.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedIonBallFX02 FILE=Effects\RedIonBallFX02.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedIonBallFX03 FILE=Effects\RedIonBallFX03.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedIonBallFX04 FILE=Effects\RedIonBallFX04.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedIonBallFX05 FILE=Effects\RedIonBallFX05.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedIonBallFX06 FILE=Effects\RedIonBallFX06.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedIonBallFX07 FILE=Effects\RedIonBallFX07.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedIonBallFX08 FILE=Effects\RedIonBallFX08.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedIonBallFX09 FILE=Effects\RedIonBallFX09.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedIonBallFX10 FILE=Effects\RedIonBallFX10.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedIonBallFX11 FILE=Effects\RedIonBallFX11.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedIonBallFX12 FILE=Effects\RedIonBallFX12.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedIonBallFX13 FILE=Effects\RedIonBallFX13.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedIonBallFX14 FILE=Effects\RedIonBallFX14.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedIonBallFX15 FILE=Effects\RedIonBallFX15.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedIonBallFX16 FILE=Effects\RedIonBallFX16.bmp GROUP=Effects FLAGS=2

#exec AUDIO IMPORT NAME="ShrRedIonExpl" FILE=SOUNDS\ShrRedIonExpl.wav GROUP="Explosions"

var() texture AnimTex[20];
var() float TransTime;
var byte CurrentSprt;

simulated function PostBeginPlay()
{
	SetTimer(TransTime,True);
	MakeSound();
}

simulated function Timer()
{
	CurrentSprt++;
		
	if (CurrentSprt >= 20)
	{
		Destroy();
		return;
	}

	Texture = AnimTex[CurrentSprt];
}

function MakeSound()
{
	PlaySound(sound'ShrRedIonExpl',,60.0,,3000);
}

defaultproperties
{
      AnimTex(0)=Texture'XTreadVeh.Effects.RedIonBallFX01'
      AnimTex(1)=Texture'XTreadVeh.Effects.RedIonBallFX02'
      AnimTex(2)=Texture'XTreadVeh.Effects.RedIonBallFX03'
      AnimTex(3)=Texture'XTreadVeh.Effects.RedIonBallFX04'
      AnimTex(4)=Texture'XTreadVeh.Effects.RedIonBallFX05'
      AnimTex(5)=Texture'XTreadVeh.Effects.RedIonBallFX06'
      AnimTex(6)=Texture'XTreadVeh.Effects.RedIonBallFX07'
      AnimTex(7)=Texture'XTreadVeh.Effects.RedIonBallFX08'
      AnimTex(8)=Texture'XTreadVeh.Effects.RedIonBallFX09'
      AnimTex(9)=Texture'XTreadVeh.Effects.RedIonBallFX10'
      AnimTex(10)=Texture'XTreadVeh.Effects.RedIonBallFX11'
      AnimTex(11)=Texture'XTreadVeh.Effects.RedIonBallFX12'
      AnimTex(12)=Texture'XTreadVeh.Effects.RedIonBallFX13'
      AnimTex(13)=Texture'XTreadVeh.Effects.RedIonBallFX14'
      AnimTex(14)=Texture'XTreadVeh.Effects.RedIonBallFX15'
      AnimTex(15)=Texture'XTreadVeh.Effects.RedIonBallFX16'
      AnimTex(16)=Texture'XTreadVeh.Effects.RedIonBallFX04'
      AnimTex(17)=Texture'XTreadVeh.Effects.RedIonBallFX03'
      AnimTex(18)=Texture'XTreadVeh.Effects.RedIonBallFX02'
      AnimTex(19)=Texture'XTreadVeh.Effects.RedIonBallFX01'
      TransTime=0.025000
      CurrentSprt=0
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=3.000000
      DrawType=DT_Sprite
      Style=STY_Translucent
      Texture=Texture'XTreadVeh.Effects.RedIonBallFX16'
      DrawScale=1.800000
      ScaleGlow=1.500000
      SpriteProjForward=64.000000
      bUnlit=True
}
