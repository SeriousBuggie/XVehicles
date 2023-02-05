//=============================================================================
// FlagAnnouncerSound.
//=============================================================================
class FlagAnnouncerSound expands Projectile;

var Sound PlaySound;
var bool bExcludeTournamentPlayers;

replication
{
	reliable if (Role == ROLE_Authority)
		PlaySound, bExcludeTournamentPlayers;
}

function Init(Sound InPlaySound, bool InExcludeTournamentPlayers)
{
	PlaySound = InPlaySound;
	bExcludeTournamentPlayers = InExcludeTournamentPlayers;
}

simulated function Tick(float Delta)
{
	local PlayerPawn P;
	if (Level.NetMode != NM_DedicatedServer)
		foreach AllActors(class'PlayerPawn', P)
			if (P.bIsPlayer && (!bExcludeTournamentPlayers || !P.IsA('TournamentPlayer')))
				P.ClientPlaySound(PlaySound);
	Disable('Tick');
}

defaultproperties
{
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=5.000000
}
