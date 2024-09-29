//=============================================================================
// GhostMuzzle.
//=============================================================================
class GhostMuzzle expands VehicleLightsCor;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (Vehicle(Owner) != None)
	{
		switch (Vehicle(Owner).CurrentTeam)
		{
			case 1: Texture = Texture'Tranglowb'; break;
			case 2: Texture = Texture'Tranglowg'; break;
			case 3: Texture = Texture'Tranglowy'; break;
			default: Texture = Texture'Tranglow'; break;
		}
	}
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	DrawScale = LifeSpan * Mass / Default.LifeSpan;
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
}

defaultproperties
{
	bHidden=False
	LifeSpan=0.500000
	SpriteProjForward=0.000000
}
