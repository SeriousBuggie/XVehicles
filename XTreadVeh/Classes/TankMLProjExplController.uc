class TankMLProjExplController expands xTreadVehEffects;

#exec AUDIO IMPORT NAME="TankMLProjExplSnd01" FILE=SOUNDS\TankMLProjExplSnd01.wav GROUP="TankML"
#exec AUDIO IMPORT NAME="TankMLProjExplSnd02" FILE=SOUNDS\TankMLProjExplSnd02.wav GROUP="TankML"

var() float AscendSpeed;
var float TimeCount;

var(Particles) class<Effects> PartSpawnClass;
var(Particles) name PartSeq;
var(Particles) float PartSeqMin, PartSeqMax, MaxScale, MinScale;
var(Particles) float TimeSpan;
var(Particles) byte Amount;
var float TimeCntSpan;

simulated function PostBeginPlay()
{
	MakeSound();
	Velocity = AscendSpeed * vector(Rotation);
}

function MakeSound()
{
	if (Rand(50) > 25)
		PlaySound(EffectSound1,,150.0,,9500);
	else
		PlaySound(EffectSound2,,150.0,,9500);
}

function Tick(float Delta)
{
local Actor A;
local float SprtScale;
local byte i;
local Effects s;

	TimeCount += Delta;
	TimeCntSpan += Delta;
	
	if (TimeCount >= 0.025)
	{
		SprtScale = ((Default.LifeSpan - LifeSpan) * 15)**2 + 3;
		A = Spawn(Class'TankMLProjExplFX');
		A.DrawScale = SprtScale;
		A = Spawn(Class'TankMLSmoke');
		A.DrawScale = SprtScale * 1.65;
		A.LifeSpan -= (FRand() * 1.5);
		TimeCount = 0;
	}
	
	if (TimeCntSpan >= TimeSpan)
	{
		for( i = 0; i < Amount; i++)
		{
			s = Spawn(PartSpawnClass);
			s.DrawScale = MinScale + ((Default.LifeSpan-LifeSpan) * (MaxScale-MinScale) / Default.LifeSpan);

			if (PartSeqMin < PartSeqMax && PartSeq != '')
			{
				s.AnimSequence = PartSeq;
				s.AnimFrame = PartSeqMin + ((Default.LifeSpan-LifeSpan) * (PartSeqMax-PartSeqMin) / Default.LifeSpan);
				if (IncadescentPart(s) != None)
					IncadescentPart(s).FrameScale = Byte((Default.LifeSpan-LifeSpan) * 3 / Default.LifeSpan);
			}
		}
		TimeCntSpan = 0;
	}
}

defaultproperties
{
	AscendSpeed=4000.000000
	PartSpawnClass=Class'XTreadVeh.IncadescentPart'
	PartSeq="Grow"
	PartSeqMin=0.100000
	PartSeqMax=0.500000
	MaxScale=0.250000
	MinScale=0.062500
	TimeSpan=0.080000
	Amount=1
	EffectSound1=Sound'XTreadVeh.TankML.TankMLProjExplSnd01'
	EffectSound2=Sound'XTreadVeh.TankML.TankMLProjExplSnd02'
	Physics=PHYS_Projectile
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.325000
}
