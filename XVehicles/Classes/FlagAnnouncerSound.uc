//=============================================================================
// FlagAnnouncerSound.
//=============================================================================
class FlagAnnouncerSound expands Projectile;

var Sound PlaySound;
var bool bExcludeTournamentPlayers;
var int Team;
var bool bAnnouncer;

replication
{
	reliable if (Role == ROLE_Authority)
		PlaySound, bExcludeTournamentPlayers, Team, bAnnouncer;
}

function Init(Sound InPlaySound, bool InExcludeTournamentPlayers, int InTeam, bool InAnnouncer)
{
	PlaySound = InPlaySound;
	bExcludeTournamentPlayers = InExcludeTournamentPlayers;
	Team = InTeam;
	bAnnouncer = InAnnouncer;
}

simulated function Tick(float Delta)
{
	local PlayerPawn P;
	local bool b3DSound;
	if (Level.NetMode != NM_DedicatedServer)
		foreach AllActors(class'PlayerPawn', P)
			if (P.bIsPlayer && (!bExcludeTournamentPlayers || !P.IsA('TournamentPlayer')) && 
				(Team == -1 || (P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.Team == Team)))
			{
				if (TournamentPlayer(P) != None)
				{
					b3DSound = TournamentPlayer(P).b3DSound;
					TournamentPlayer(P).b3DSound = true; // hack for v436, for prevent play too loud
				}
				P.ClientPlaySound(PlaySound, , bAnnouncer);
				if (TournamentPlayer(P) != None)
					TournamentPlayer(P).b3DSound = b3DSound;
			}
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
