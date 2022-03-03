class BigRockSpawner expands xTreadVehEffects;

var() class<Effects> PartSpawnClass;
var() name PartSeq;
var() float PartSeqMin, PartSeqMax;
var() float TimeSpan;
var() byte Amount;

function PostBeginPlay()
{
local byte i;
local Effects s;

	For( i = 0; i < Amount; i++)
	{
		s = Spawn(PartSpawnClass);

		if (PartSeqMin < PartSeqMax && PartSeq != '')
		{
			s.AnimSequence = PartSeq;
			s.AnimFrame = PartSeqMin;
		}
	}

	SetTimer(TimeSpan, True);
}


function Timer()
{
local byte i;
local Effects s;

	For( i = 0; i < Amount; i++)
	{
		s = Spawn(PartSpawnClass);

		if (PartSeqMin < PartSeqMax && PartSeq != '')
		{
			s.AnimSequence = PartSeq;
			s.AnimFrame = PartSeqMin + ((Default.LifeSpan-LifeSpan) * (PartSeqMax-PartSeqMin) / Default.LifeSpan);
		}
	}
}

defaultproperties
{
      PartSpawnClass=Class'XTreadVeh.BigStonesPart'
      PartSeq="Grow"
      PartSeqMin=0.100000
      PartSeqMax=0.500000
      TimeSpan=0.100000
      Amount=1
      bHidden=True
      LifeSpan=0.400000
}
