//=============================================================================
// FlagAnnouncer.
//=============================================================================
class FlagAnnouncer expands MessagingSpectator;

var float PrevScore[ArrayCount(class'TeamGamePlus'.default.Teams)];
var float FlagLastEventTime[ArrayCount(PrevScore)];
var CTFFlag PendingChangeProps[ArrayCount(PrevScore)];

state GameEnded
{
	function BeginState();
	function EndState();
	function Timer()
	{
		Global.Timer();
	}
}

auto state Nothing
{
	function BeginState();
	function EndState();
	function Timer()
	{
		Global.Timer();
	}
}

function PostBeginPlay() {	
	PlayerReplicationInfo.RemoteRole = ROLE_None;
	PlayerReplicationInfo.bAlwaysRelevant = false;
	Super.PostBeginPlay();

	SetTimer(1.0, true);
}

function Timer()
{
	local TeamGamePlus TeamGame;
	local int ReportTeam, Diff, OldDiff, i;
	local CTFFlag Flag;
	local float T;
	
	Super.Timer();

	TeamGame = TeamGamePlus(Level.Game);
	if (TeamGame != None && TeamGame.Class.Name == 'Domination' && TeamGame.MaxTeams == 2)
	{
		if (TeamGame.Teams[0].Score != PrevScore[0] || TeamGame.Teams[1].Score != PrevScore[1])
		{
			OldDiff = int(PrevScore[0]) - int(PrevScore[1]);
			Diff = int(TeamGame.Teams[1].Score) - int(TeamGame.Teams[0].Score);
			if (OldDiff == 0 ||
				TeamGame.Teams[0].Score >= TeamGame.GoalTeamScore ||
				TeamGame.Teams[1].Score >= TeamGame.GoalTeamScore)
				ReportTeam = Diff;
			else if (Diff == 0)
				ReportTeam = OldDiff;
			if (ReportTeam != 0)
				ReceiveLocalizedMessage(class'CTFMessage', 0, None, None, TeamGame.Teams[Clamp(ReportTeam, 0, 1)]);
		}
	}
	StorePrevScore();
	
	T = Level.TimeSeconds - 1;
	for (i = 0; i < ArrayCount(PendingChangeProps); i++)
	{
		if (PendingChangeProps[i] != None && FlagLastEventTime[i] < T)
		{
			Flag = PendingChangeProps[i];
			PendingChangeProps[i] = None;
			// reduce network usage
			if (Flag.Holder != None)
				Flag.NetUpdateFrequency = 2;
		}
	}
}

function StorePrevScore()
{
	local TeamGamePlus TeamGame;
	local int i;
	TeamGame = TeamGamePlus(Level.Game);
	if (TeamGame != None)
		for (i = 0; i < ArrayCount(TeamGame.Teams); i++)
			if (TeamGame.Teams[i] != None)
				PrevScore[i] = TeamGame.Teams[i].Score;
}

function int GetTeam(Object OptionalObject)
{	
	if (TeamInfo(OptionalObject) != None)
		return TeamInfo(OptionalObject).TeamIndex;
	else if (CTFFlag(OptionalObject) != None)
		return CTFFlag(OptionalObject).Team;
	else
		return 255;
}

event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Sw, 
	optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, 
	optional Object OptionalObject )
{
	local CTFFlag OtherFlag;
	local TeamGamePlus TeamGame;
	local Sound Sound;
	local Pawn P;
	local bool bExcludeTournamentPlayers, bPlaySound;
	local FlagAnnouncerSound SoundActor;
	local Vehicle Veh;
	local int CurrentTeam;
	
	TeamGame = TeamGamePlus(Level.Game);
	bPlaySound = !class'VehiclesConfig'.default.bDisableFlagAnnouncer && TeamGame != None && TeamGame.MaxTeams == 2;
	
	//log(Message @ Sw @ RelatedPRI_1 @ RelatedPRI_2 @ OptionalObject);
	if (Message == class'DeathMatchMessage' && Sw == 3 && RelatedPRI_1 != None && 
		PlayerPawn(RelatedPRI_1.Owner) != None && PlayerPawn(RelatedPRI_1.Owner).bIsPlayer)
	{
		CurrentTeam = GetTeam(OptionalObject);
		if (CurrentTeam == 0)
			Sound = Sound'YouAreOnRed';
		if (CurrentTeam == 1)
			Sound = Sound'YouAreOnBlue';
		if (bPlaySound && Sound != None)
			PlayerPawn(RelatedPRI_1.Owner).ClientPlaySound(Sound, , true);
		return;
	}
	if (Message != None && Message.Name == 'OneFlagMessage')
	{
		switch(Sw)
		{
			case 0:
				Message = class'CTFMessage';
				break;
			case 1:
				Message = class'CTFMessage';
				Sw = 3;
				if (OptionalObject == None)
					OptionalObject = TeamGame.Teams[0];
				else if (OptionalObject.IsA('NeutralFlag'))
					OptionalObject = TeamGame.Teams[Clamp(int(OptionalObject.GetPropertyText("LastTeam")), 0, 1)];
				break;
			case 2:
				Message = class'CTFMessage';
				OptionalObject = TeamGame.Teams[RelatedPRI_1.Team];
				break;
			case 3:
				Message = class'CTFMessage';
				Sw = 6;
				break;
		}
	}
	if (Message == class'CTFMessage')
	{
		if (RelatedPRI_1 != None && Bot(RelatedPRI_1.Owner) != None)
			foreach RelatedPRI_1.Owner.RadiusActors(class'Vehicle', Veh, 700)
				if (Veh.LastDriver == RelatedPRI_1.Owner)
					Veh.LastDriver = None;
		CurrentTeam = GetTeam(OptionalObject);
		switch(Sw)
		{
			case 0:
				if (CTFFlag(OptionalObject) != None)
					CurrentTeam = 1 - CurrentTeam;
				if (CurrentTeam == 1)
				{
					Sound = Sound'Blue_Team_Scores';
					if (TeamGame != None && 
						TeamGame.Teams[0] != None &&
						TeamGame.Teams[1] != None)
					{
						if (int(TeamGame.Teams[1].Score) == int(TeamGame.Teams[0].Score))
							Sound = Sound'Blue_Team_tied_for_the_lead';
						else if (int(TeamGame.Teams[1].Score) > int(TeamGame.Teams[0].Score))
						{
							if (int(PrevScore[1]) <= int(PrevScore[0]))
								Sound = Sound'Blue_Team_takes_the_lead';
							else
								Sound = Sound'Blue_Team_increases_their_lead';
						}
						if (TeamGame.GoalTeamScore > 0 && 
							TeamGame.Teams[1].Score >= TeamGame.GoalTeamScore &&
							TeamGame.Teams[1].Score > TeamGame.Teams[0].Score)
						{
							Sound = Sound'blue_team_is_the_winner';
							bExcludeTournamentPlayers = true;
						}
					}
				}
				if (CurrentTeam == 0)
				{
					Sound = Sound'Red_Team_Scores';
					if (TeamGame != None && 
						TeamGame.Teams[0] != None &&
						TeamGame.Teams[1] != None)
					{
						if (int(TeamGame.Teams[0].Score) == int(TeamGame.Teams[1].Score))
							Sound = Sound'Red_Team_tied_for_the_lead';
						else if (int(TeamGame.Teams[0].Score) > int(TeamGame.Teams[1].Score))
						{
							if (int(PrevScore[0]) <= int(PrevScore[1]))
								Sound = Sound'Red_Team_takes_the_lead';
							else
								Sound = Sound'Red_Team_increases_their_lead';
						}
						if (TeamGame.GoalTeamScore > 0 && 
							TeamGame.Teams[0].Score >= TeamGame.GoalTeamScore &&
							TeamGame.Teams[0].Score > TeamGame.Teams[1].Score)
						{
							Sound = Sound'red_team_is_the_winner';
							bExcludeTournamentPlayers = true;
						}
					}
				}
				break;
			case 1:
			case 3:
			case 5:
				if (CurrentTeam == 0)
					Sound = Sound'Red_Flag_Returned';
				if (CurrentTeam == 1)
					Sound = Sound'Blue_Flag_Returned';
				break;
			case 2:
				if (CurrentTeam == 0)
					Sound = Sound'Red_Flag_Dropped';
				if (CurrentTeam == 1)
					Sound = Sound'Blue_Flag_Dropped';
				if (Sound != None && RelatedPRI_1 != None && CTFFlag(RelatedPRI_1.HasFlag) != None &&
					CTFFlag(RelatedPRI_1.HasFlag).Holder != None)
					ForEach AllActors(class'CTFFlag', OtherFlag)
						if (OtherFlag.Team == 1 - CurrentTeam)
						{
							if (OtherFlag.bHome && VSize(OtherFlag.HomeBase.Location - 
								CTFFlag(RelatedPRI_1.HasFlag).Holder.Location) < 1000)
								Sound = Sound'Denied';
							break;
						}
				break;
			case 4:
			case 6:
				if (CurrentTeam == 0)
					Sound = Sound'Red_Flag_Taken';
				if (CurrentTeam == 1)
					Sound = Sound'Blue_Flag_Taken';
				if (RelatedPRI_1 != None && Bot(RelatedPRI_1.Owner) != None)
					class'XVehiclesCTF'.static.FixBot(Bot(RelatedPRI_1.Owner), -1);
				break;
		}
		OtherFlag = CTFFlag(OptionalObject);
		if (OtherFlag != None)
		{
			OtherFlag.NetUpdateFrequency = OtherFlag.default.NetUpdateFrequency;
			if (OtherFlag.Team < ArrayCount(FlagLastEventTime))
			{
				FlagLastEventTime[OtherFlag.Team] = Level.TimeSeconds;
				PendingChangeProps[OtherFlag.Team] = OtherFlag;
			}
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
	StorePrevScore();
	if (class'BotSpawnNotify'.default.XVehiclesCTF != None)
		class'BotSpawnNotify'.default.XVehiclesCTF.KillCredit(self);
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID);

function TeamMessage(PlayerReplicationInfo PRI, coerce string S, name Type, optional bool bBeep);

defaultproperties
{
}
