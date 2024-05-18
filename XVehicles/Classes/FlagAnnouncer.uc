//=============================================================================
// FlagAnnouncer.
//=============================================================================
class FlagAnnouncer expands MessagingSpectator;

function PostBeginPlay() {	
	PlayerReplicationInfo.RemoteRole = ROLE_None;
	PlayerReplicationInfo.bAlwaysRelevant = false;
	Super.PostBeginPlay();
}

event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	local TeamInfo TeamInfo;
	local CTFFlag CTFFlag, OtherFlag;
	local CTFGame CTFGame;
	local Sound Sound;
	local Pawn P;
	local bool bExcludeTournamentPlayers, bPlaySound;
	local FlagAnnouncerSound SoundActor;
	local Vehicle Veh;
	
	CTFGame = CTFGame(Level.Game);
	bPlaySound = !class'VehiclesConfig'.default.bDisableFlagAnnouncer && CTFGame != None && CTFGame.MaxTeams == 2;
	
	if (Message == class'DeathMatchMessage' && Switch == 3 && RelatedPRI_1 != None && 
		PlayerPawn(RelatedPRI_1.Owner) != None && PlayerPawn(RelatedPRI_1.Owner).bIsPlayer)
	{
		TeamInfo = TeamInfo(OptionalObject);
		if (TeamInfo != None)
		{
			if (TeamInfo.TeamIndex == 0)
				Sound = Sound'YouAreOnRed';
			if (TeamInfo.TeamIndex == 1)
				Sound = Sound'YouAreOnBlue';
			if (bPlaySound && Sound != None)
				PlayerPawn(RelatedPRI_1.Owner).ClientPlaySound(Sound, , true);
			return;
		}
	}
	
	if (Message == class'CTFMessage')
	{
		if (RelatedPRI_1 != None && Bot(RelatedPRI_1.Owner) != None)
			foreach RelatedPRI_1.Owner.RadiusActors(class'Vehicle', Veh, 700)
				if (Veh.LastDriver == RelatedPRI_1.Owner)
					Veh.LastDriver = None;
		TeamInfo = TeamInfo(OptionalObject);
		if (TeamInfo != None)		
			switch(Switch)
			{
				case 2:
					if (TeamInfo.TeamIndex == 0)
						Sound = Sound'Red_Flag_Dropped';
					if (TeamInfo.TeamIndex == 1)
						Sound = Sound'Blue_Flag_Dropped';
					if (Sound != None && RelatedPRI_1 != None && CTFFlag(RelatedPRI_1.HasFlag) != None &&
						CTFFlag(RelatedPRI_1.HasFlag).Holder != None)
						ForEach AllActors(class'CTFFlag', OtherFlag)
							if (OtherFlag.Team == 1 - TeamInfo.TeamIndex)
							{
								if (OtherFlag.bHome && VSize(OtherFlag.HomeBase.Location - 
									CTFFlag(RelatedPRI_1.HasFlag).Holder.Location) < 1000)
									Sound = Sound'Denied';
								break;
							}
					break;
				case 3:
				case 5:
					if (TeamInfo.TeamIndex == 0)
						Sound = Sound'Red_Flag_Returned';
					if (TeamInfo.TeamIndex == 1)
						Sound = Sound'Blue_Flag_Returned';
					break;
				case 4:
				case 6:
					if (TeamInfo.TeamIndex == 0)
						Sound = Sound'Red_Flag_Taken';
					if (TeamInfo.TeamIndex == 1)
						Sound = Sound'Blue_Flag_Taken';
					if (RelatedPRI_1 != None && Bot(RelatedPRI_1.Owner) != None)
						class'XVehiclesCTF'.static.FixBot(Bot(RelatedPRI_1.Owner), -1);
					break;
			}
		CTFFlag = CTFFlag(OptionalObject);
		if (CTFFlag != None)
			switch(Switch)
			{
				case 0:
					if (CTFFlag.Team == 0)
					{
						Sound = Sound'Blue_Team_Scores';
						if (CTFGame != None && 
							CTFGame.Teams[0] != None &&
							CTFGame.Teams[1] != None)
						{
							if (CTFGame.Teams[1].Score == CTFGame.Teams[0].Score)
								Sound = Sound'Blue_Team_tied_for_the_lead';
							else if (CTFGame.Teams[1].Score == CTFGame.Teams[0].Score + 1)
								Sound = Sound'Blue_Team_takes_the_lead';
							else if (CTFGame.Teams[1].Score > CTFGame.Teams[0].Score)
								Sound = Sound'Blue_Team_increases_their_lead';
							if (CTFGame.GoalTeamScore > 0 && 
								CTFGame.Teams[1].Score >= CTFGame.GoalTeamScore &&
								CTFGame.Teams[1].Score > CTFGame.Teams[0].Score)
							{
								Sound = Sound'blue_team_is_the_winner';
								bExcludeTournamentPlayers = true;
							}
						}
					}
					if (CTFFlag.Team == 1)
					{
						Sound = Sound'Red_Team_Scores';
						if (CTFGame != None && 
							CTFGame.Teams[0] != None &&
							CTFGame.Teams[1] != None)
						{
							if (CTFGame.Teams[0].Score == CTFGame.Teams[1].Score)
								Sound = Sound'Red_Team_tied_for_the_lead';
							else if (CTFGame.Teams[0].Score == CTFGame.Teams[1].Score + 1)
								Sound = Sound'Red_Team_takes_the_lead';
							else if (CTFGame.Teams[0].Score > CTFGame.Teams[1].Score)
								Sound = Sound'Red_Team_increases_their_lead';
							if (CTFGame.GoalTeamScore > 0 && 
								CTFGame.Teams[0].Score >= CTFGame.GoalTeamScore &&
								CTFGame.Teams[0].Score > CTFGame.Teams[1].Score)
							{
								Sound = Sound'red_team_is_the_winner';
								bExcludeTournamentPlayers = true;
							}
						}
					}
					break;
				case 1:
					if (CTFFlag.Team == 0)
						Sound = Sound'Red_Flag_Returned';
					if (CTFFlag.Team == 1)
						Sound = Sound'Blue_Flag_Returned';
					break;
			}
	}
	if (bPlaySound && Sound != None)
	{
		SoundActor = Spawn(class'FlagAnnouncerSound');
		if (SoundActor != None)
			SoundActor.Init(Sound, bExcludeTournamentPlayers, -1, true);
		else
			for (P = Level.PawnList; P != None; P = P.NextPawn)
				if (P.bIsPlayer && P.IsA('PlayerPawn') && 
					(!bExcludeTournamentPlayers || !P.IsA('TournamentPlayer')))
					PlayerPawn(P).ClientPlaySound(Sound, , true);
	}
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID);

function TeamMessage(PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep);

defaultproperties
{
}
