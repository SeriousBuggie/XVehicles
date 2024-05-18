//=============================================================================
// GreedReplicationInfo.
//=============================================================================
class GreedReplicationInfo expands ReplicationInfo;

var Skull Skull;
var int Skulls;

replication
{
	reliable if (Role == ROLE_Authority)
		Skulls;
}

simulated event PostBeginPlay()
{
	SetTimer(1.0, true);
	LinkToOwner();
}

simulated event PostNetBeginPlay()
{
	SetTimer(1.0, true);
	LinkToOwner();
}

simulated function LinkToOwner()
{
	if (Pawn(Owner) != None && Pawn(Owner).PlayerReplicationInfo != None)
	{
		Pawn(Owner).PlayerReplicationInfo.Target = self;
		SetTimer(0, false);
	}
}

simulated event Timer()
{
	LinkToOwner();
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bGameRelevant=True
}
