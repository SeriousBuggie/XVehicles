//=============================================================================
// PreventEnter.
//=============================================================================
class PreventEnter expands Info;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	Instigator = PlayerPawn(Owner);
}

function Tick(float Delta)
{
	Super.Tick(Delta);
	if (Instigator == None || Instigator.bDuck == 0)
		Destroy();
}

function Destroyed()
{
	Instigator = None;
	Super.Destroyed();
}

defaultproperties
{
	RemoteRole=ROLE_None
	LifeSpan=3.000000
}
