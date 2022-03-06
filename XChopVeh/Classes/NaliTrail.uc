//////////////////////////////////////////////////////////////
//	Nali Weapons III Trail base class
//				Feralidragon (27-04-2010)
//
// NW3 CORE BUILD 1.00
//////////////////////////////////////////////////////////////

class NaliTrail expands Effects 
abstract;

var() vector PrePivotRel;
var() bool bReplicatePrePivotRel;
var() bool UpdateInClientOnly;

replication
{
	reliable if (Role == ROLE_Authority && bReplicatePrePivotRel)
		PrePivotRel;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (Role == ROLE_Authority || !bReplicatePrePivotRel)
		bTrailerPrePivot = (VSize(PrePivotRel) > 0);
}

simulated function SetPrePivot(vector PrePivotOffset)
{
	if ((Role == ROLE_Authority || !bReplicatePrePivotRel) && VSize(PrePivotOffset) > 0)
		PrePivotRel = PrePivotOffset;
}

simulated function Tick(float Delta)
{
	if ((Level.NetMode != NM_DedicatedServer || !UpdateInClientOnly) && VSize(PrePivotRel) > 0 && Owner != None)
	{
		bTrailerPrePivot = True;
		PrePivot = (PrePivotRel >> Owner.Rotation);
	}
}

defaultproperties
{
      PrePivotRel=(X=0.000000,Y=0.000000,Z=0.000000)
      bReplicatePrePivotRel=False
      UpdateInClientOnly=True
      bNetTemporary=False
      bTrailerSameRotation=True
      Physics=PHYS_Trailer
      RemoteRole=ROLE_SimulatedProxy
      Mass=0.000000
}
