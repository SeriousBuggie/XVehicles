// XFXVehCorona, the corona effect is done by each playerpawn in the game, 
// and as it's only a visual effect for each playerpawn, it don't get called by any other pawn
// Still, this effect can be dangerously resourcefull if used too many times, 
// that's why it's only used in bigger explosions or even nukes
///////////////////////
//ATTENTION: this is not a true dynamic corona, as it doesn't blend color, use it only in main flash events like nuclear explosions

class XFXVehCorona expands Actor;

var() float MaxDistance;			//Max distance where the corona is visible
var() float LifeTime;				//It's basically the lifespan
var() float StartScaleTime, EndScaleTime;	//Time to scale up and down effect
var() float FadeInTime, FadeOutTime;		//Time to fade in and out effect
var() float EndScaleCoef, StartScaleCoef; 	//Scaling multiplier when appearing or dying
var() texture CoronaSprite;			//Corona texture
var() float MaxCoronaSize, MinCoronaSize;	//Corona scales
var() float CGlow;				//Corona scaleglow


replication
{
	reliable if (Role == ROLE_Authority)
		MaxDistance, LifeTime, StartScaleTime, EndScaleTime, FadeInTime,
	FadeOutTime, EndScaleCoef, StartScaleCoef, CoronaSprite, MaxCoronaSize,
	MinCoronaSize, CGlow;
}

simulated function PostBeginPlay()
{
local PlayerPawn PP;
local CoronaVehEffect ce;

	ForEach AllActors(Class'PlayerPawn', PP)
	{
		ce = Spawn(Class'CoronaVehEffect', PP);
		ce.MaxDistance = MaxDistance;
		ce.LifeTime = LifeTime;
		ce.StartScaleTime = StartScaleTime;
		ce.EndScaleTime = EndScaleTime;
		ce.FadeInTime = FadeInTime;
		ce.FadeOutTime = FadeOutTime;
		ce.EndScaleCoef = EndScaleCoef;
		ce.StartScaleCoef = StartScaleCoef;
		ce.CoronaSprite = CoronaSprite;
		ce.MaxCoronaSize = MaxCoronaSize;
		ce.MinCoronaSize = MinCoronaSize;
		ce.CGlow = CGlow;
		ce.RemoteRole = ROLE_None;
	}

	Destroy();
}

defaultproperties
{
	MaxDistance=4000.000000
	LifeTime=8.000000
	FadeInTime=1.000000
	FadeOutTime=1.000000
	EndScaleCoef=1.000000
	StartScaleCoef=1.000000
	MaxCoronaSize=5.000000
	MinCoronaSize=1.000000
	CGlow=1.500000
	bHidden=True
	RemoteRole=ROLE_SimulatedProxy
	Style=STY_Translucent
	Texture=None
	bUnlit=True
	CollisionRadius=0.000000
	CollisionHeight=0.000000
	Mass=0.000000
}
