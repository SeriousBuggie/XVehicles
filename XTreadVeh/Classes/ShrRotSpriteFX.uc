class ShrRotSpriteFX expands xTreadVehEffects;

#exec TEXTURE IMPORT NAME=RedKCoron01 FILE=Effects\RedKCoron01.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedKCoron02 FILE=Effects\RedKCoron02.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedKCoron03 FILE=Effects\RedKCoron03.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedKCoron04 FILE=Effects\RedKCoron04.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedKCoron05 FILE=Effects\RedKCoron05.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedKCoron06 FILE=Effects\RedKCoron06.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedKCoron07 FILE=Effects\RedKCoron07.bmp GROUP=Effects FLAGS=2
#exec TEXTURE IMPORT NAME=RedKCoron08 FILE=Effects\RedKCoron08.bmp GROUP=Effects FLAGS=2

var() texture RotTex[8];
var() float TransTime;
var byte CurrentSprt;
var bool bRotateBackwards;

simulated function PostBeginPlay()
{
	SetTimer(TransTime,True);
}

simulated function Timer()
{
	if (!bRotateBackwards)
	{
		CurrentSprt++;
		
		if (CurrentSprt >= 8)
			CurrentSprt = 0;
	}
	else
	{
		CurrentSprt--;
		
		if (CurrentSprt >= 8)
			CurrentSprt = 7;
	}

	Texture = RotTex[CurrentSprt];
}

simulated function Tick( float DeltaTime)
{
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
	DrawScale = LifeSpan * Default.DrawScale / Default.LifeSpan;
}

defaultproperties
{
	RotTex(0)=Texture'XTreadVeh.Effects.RedKCoron01'
	RotTex(1)=Texture'XTreadVeh.Effects.RedKCoron02'
	RotTex(2)=Texture'XTreadVeh.Effects.RedKCoron03'
	RotTex(3)=Texture'XTreadVeh.Effects.RedKCoron04'
	RotTex(4)=Texture'XTreadVeh.Effects.RedKCoron05'
	RotTex(5)=Texture'XTreadVeh.Effects.RedKCoron06'
	RotTex(6)=Texture'XTreadVeh.Effects.RedKCoron07'
	RotTex(7)=Texture'XTreadVeh.Effects.RedKCoron08'
	TransTime=0.010000
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.500000
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'XTreadVeh.Effects.RedKCoron01'
	DrawScale=0.200000
	ScaleGlow=2.000000
	SpriteProjForward=22.000000
	bUnlit=True
}
