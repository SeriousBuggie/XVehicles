//=============================================================================
// VehicleState.
//=============================================================================
class VehicleState expands Effects;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if (Level.NetMode != NM_DedicatedServer)
		FixOffset();
	else
		Disable('Tick');
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	
	if (Level.NetMode != NM_DedicatedServer)
		FixOffset();
}

simulated function FixOffset()
{
	if (Owner != None)
	{
		if (Vehicle(Owner) != None)
			PrePivot = Vehicle(Owner).GetStateOffset();
		else
			PrePivot.Z = Owner.CollisionHeight;
		PrePivot.Z += 30;
		
		PrePivot = PrePivot >> Owner.Rotation;
		
		if (Vehicle(Owner) != None && Vehicle(Owner).bSlopedPhys && Vehicle(Owner).GVT!=None)
			PrePivot += Vehicle(Owner).GVT.PrePivot;
	}
}

simulated function Tick(float Delta)
{	
	if (Level.NetMode != NM_DedicatedServer)
		FixOffset();
}

function SetState(byte CurrentTeam, bool bTeamLocked, bool bUsed)
{
	local Texture Icon;
	
	if (bUsed)
		switch (CurrentTeam) {			
			case 0: Icon = Texture'I_TeamR'; break;
			case 1: Icon = Texture'I_TeamB'; break;
			case 2: Icon = Texture'I_TeamG'; break;
			case 3: Icon = Texture'I_TeamY'; break;
			default: Icon = Texture'I_TeamN'; break;
		}
	else
	{
		if (bTeamLocked)
			switch (CurrentTeam) {			
				case 0: Icon = Texture'I_TeamXR'; break;
				case 1: Icon = Texture'I_TeamXB'; break;
				case 2: Icon = Texture'I_TeamXG'; break;
				case 3: Icon = Texture'I_TeamXY'; break;
				default: Icon = Texture'Iconnoenter'; break;
			}
		else 
		{
			switch (CurrentTeam) {			
				case 0: Icon = Texture'Tranglow'; break;
				case 1: Icon = Texture'TranglowB'; break;
				case 2: Icon = Texture'TranglowG'; break;
				case 3: Icon = Texture'TranglowY'; break;
				default: Icon = Texture'Healthbar'; break;
			}
		}
	}
	
	Sprite = Icon;
	Skin = Icon;
	Texture = Icon;
}

defaultproperties
{
	bOwnerNoSee=True
	bNetTemporary=False
	bTrailerPrePivot=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Sprite
	Style=STY_Translucent
	Sprite=Texture'Botpack.Translocator.Tranglow'
	Texture=Texture'Botpack.Translocator.Tranglow'
	Skin=Texture'Botpack.Translocator.Tranglow'
	DrawScale=0.500000
	PrePivot=(X=0.000000,Y=0.000000,Z=70.000000)
	Mass=0.000000
}
