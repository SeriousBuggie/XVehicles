//=============================================================================
// FlagAnnouncerSound.
//=============================================================================
class FlagAnnouncerSound expands Projectile;

var Sound PlaySound;
var bool bExcludeTournamentPlayers;
var int Team;

replication
{
	reliable if (Role == ROLE_Authority)
		PlaySound, bExcludeTournamentPlayers, Team;
}

function Init(Sound InPlaySound, bool InExcludeTournamentPlayers, int InTeam)
{
	PlaySound = InPlaySound;
	bExcludeTournamentPlayers = InExcludeTournamentPlayers;
	Team = InTeam;
}

simulated function Tick(float Delta)
{
	local PlayerPawn P;
	if (Level.NetMode != NM_DedicatedServer)
		foreach AllActors(class'PlayerPawn', P)
			if (P.bIsPlayer && (!bExcludeTournamentPlayers || !P.IsA('TournamentPlayer')) && 
				(Team == -1 || (P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.Team == Team)))
				P.ClientPlaySound(PlaySound);
	Disable('Tick');
}

defaultproperties
{
	bAlwaysRelevant=True
	Physics=PHYS_None
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=5.000000
	bCollideActors=False
	bCollideWorld=False
}
