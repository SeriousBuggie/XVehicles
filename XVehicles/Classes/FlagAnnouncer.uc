//=============================================================================
// FlagAnnouncer.
//=============================================================================
class FlagAnnouncer expands MessagingSpectator;

event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	local TeamInfo TeamInfo;
	local CTFFlag CTFFlag, OtherFlag;
	local Sound Sound;
	local Pawn P;
	local bool bExcludeTournamentPlayers;
	
	if (Message == class'DeathMatchMessage' && Switch == 3 && RelatedPRI_1 != None && 
		PlayerPawn(RelatedPRI_1.Owner) != None && PlayerPawn(RelatedPRI_1.Owner).bIsPlayer)
	{
		TeamInfo = TeamInfo(OptionalObject);
		if (TeamInfo != None)
		{
			if (TeamInfo.TeamIndex == 0)
			if (Sound != None)
				PlayerPawn(RelatedPRI_1.Owner).ClientPlaySound(Sound);
			return;
		}
	}
	
	if (Message == class'CTFMessage')
	{
		TeamInfo = TeamInfo(OptionalObject);
		if (TeamInfo != None)		
			switch(Switch)
					if (Sound != None && RelatedPRI_1 != None && CTFFlag(RelatedPRI_1.HasFlag) != None &&
						CTFFlag(RelatedPRI_1.HasFlag).Holder != None)
						ForEach AllActors(class'CTFFlag', OtherFlag)
							{
								if (OtherFlag.bHome && VSize(OtherFlag.HomeBase.Location - 
									CTFFlag(RelatedPRI_1.HasFlag).Holder.Location) < 1000)
									Sound = Sound'Denied';
								break;
							}
				case 5:
				case 6:
		CTFFlag = CTFFlag(OptionalObject);
		if (CTFFlag != None)		
			switch(Switch)
					{
						if (CTFGame(Level.Game) != None && 
							CTFGame(Level.Game).Teams[0] != None &&
							CTFGame(Level.Game).Teams[1] != None)
						{
							if (CTFGame(Level.Game).Teams[1].Score == CTFGame(Level.Game).Teams[0].Score + 1)
								Sound = Sound'Blue_Team_takes_the_lead';
							else if (CTFGame(Level.Game).Teams[1].Score > CTFGame(Level.Game).Teams[0].Score)
								Sound = Sound'Blue_Team_increases_their_lead';
							if (CTFGame(Level.Game).GoalTeamScore > 0 && 
								CTFGame(Level.Game).Teams[1].Score >= CTFGame(Level.Game).GoalTeamScore &&
								CTFGame(Level.Game).Teams[1].Score > CTFGame(Level.Game).Teams[0].Score)
							{
								bExcludeTournamentPlayers = true;
							}
						}
					}
					{
						if (CTFGame(Level.Game) != None && 
							CTFGame(Level.Game).Teams[0] != None &&
							CTFGame(Level.Game).Teams[1] != None)
						{
							if (CTFGame(Level.Game).Teams[0].Score == CTFGame(Level.Game).Teams[1].Score + 1)
								Sound = Sound'Red_Team_takes_the_lead';
							else if (CTFGame(Level.Game).Teams[0].Score > CTFGame(Level.Game).Teams[1].Score)
								Sound = Sound'Red_Team_increases_their_lead';
							if (CTFGame(Level.Game).GoalTeamScore > 0 && 
								CTFGame(Level.Game).Teams[0].Score >= CTFGame(Level.Game).GoalTeamScore &&
								CTFGame(Level.Game).Teams[0].Score > CTFGame(Level.Game).Teams[1].Score)
							{
								bExcludeTournamentPlayers = true;
							}
						}
					}
	}
	if (Sound != None)
		for (P = Level.PawnList; P != None; P = P.NextPawn)
			if (P.bIsPlayer && P.IsA('PlayerPawn') && 
			(!bExcludeTournamentPlayers || !P.IsA('TournamentPlayer')))
				PlayerPawn(P).ClientPlaySound(Sound);
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID);

defaultproperties
{
}