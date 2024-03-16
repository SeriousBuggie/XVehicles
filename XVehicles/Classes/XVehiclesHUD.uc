//=============================================================================
// XVehiclesHUD.
//=============================================================================
class XVehiclesHUD expands Mutator config(User);

var ChallengeHUD MyHUD;
var ChallengeHUD OrigHUD;
var Vehicle IdentifyTarget;
var XVehiclesHUD UsedHUD;

var int FoundHuds;
var bool bGoodHud;
var float LastRender;

var config int EnterCount;
var float EnterLast;

var bool bNeedCleaner;

static function SpawnHUD(Actor A)
{	
	if (default.UsedHUD != None && !default.UsedHUD.bDeleteMe && default.UsedHUD.Level == A.Level)
		return;

	foreach A.AllActors(class'XVehiclesHUD', default.UsedHUD)
		break;
	if (default.UsedHUD != None)
		return;
	default.UsedHUD = A.Spawn(default.Class);
	if (default.UsedHUD != None)
	{
		default.UsedHUD.UsedHUD = None;
		A.Level.Game.BaseMutator.AddMutator(default.UsedHUD);
		A.Level.Game.RegisterMessageMutator(default.UsedHUD);
	}
}

function Vehicle GetVehicle(PlayerPawn Sender)
{
	if (Sender != None && DriverWeapon(Sender.Weapon) != None)
		return DriverWeapon(Sender.Weapon).VehicleOwner;
	return None;
}

function Mutate(string MutateString, PlayerPawn Sender)
{	
	local Vehicle Veh, Best;
	local float Dist, BestDist;
	local byte bDuck;
	Super.Mutate(MutateString, Sender);
	
	if (Sender == None)
		return;
	
	if (Left(MutateString, 16) ~= "VehicleEnterExit")
	{
		if (DriverWeapon(Sender.Weapon) == None)
			MutateString = "VehicleEnter";
		else
			MutateString = "VehicleExit";
	}
	
	if (Left(MutateString, 12) ~= "VehicleEnter")
	{
		foreach Sender.RadiusActors(class'Vehicle', Veh, Sender.CollisionRadius + 100)
			if (Veh.CanEnter(Sender, true))
			{
				Dist = VSize(Veh.Location - Sender.Location);
				if (Dist < BestDist || Best == None)
				{
					BestDist = Dist;
					Best = Veh;
				}
			}
		if (Best != None)
		{
			bDuck = Sender.bDuck;
			Sender.bDuck = 1;
			Best.Bump(Sender);
			Sender.bDuck = bDuck;
		}
	} 
	else if (Left(MutateString, 11) ~= "VehicleExit")
	{
		if (DriverWeapon(Sender.Weapon) != None)
			Sender.TossWeapon();
	}
	else if (Left(MutateString, 11) ~= "VehicleHonk")
	{
		Veh = GetVehicle(Sender);
		if (Veh != None)
			Veh.Honk();
	}
	else if (Left(MutateString, 13) ~= "VehicleCamera")
	{
		if (DriverWeapon(Sender.Weapon) != None)
			DriverWeapon(Sender.Weapon).ChangeCamera();
	}
	else if (Left(MutateString, 9) ~= "XVOpenGUI")
	{
		OpenGUI(Sender);
	}
}

function OpenGUI(PlayerPawn Sender)
{
	local XVGWRI XVGWRI;

	foreach AllActors(Class'XVGWRI', XVGWRI)
		if (Sender == XVGWRI.Owner)
			return;

	XVGWRI = Sender.Spawn(Class'XVGWRI', Sender);

	if (XVGWRI == None)
	{
		Log("Failed spawn XVGWRI for" @ Sender.GetHumanName(), Class.Name);
		return;
	}
}

function function bool MutatorTeamMessage(Actor Sender, Pawn Receiver, PlayerReplicationInfo PRI, 
	coerce string S, name Type, optional bool bBeep)
{
	if (Receiver != None && Sender == Receiver && !Receiver.isA('Spectator') && 
		Level.TimeSeconds - Receiver.OldMessageTime >= 2.5 &&
		(!Level.Game.bTeamGame || Type == 'TeamSay'))
	{
		if (S ~= "Taxi!")
		{
			Receiver.OldMessageTime = Level.TimeSeconds;
			SendVoiceMessage(GetGenderSound(Sound'TaxiMale', Sound'TaxiFemale', Receiver), GetTeam(Receiver));
		}
		else if (S ~= "Get in the vehicle!")
		{
			Receiver.OldMessageTime = Level.TimeSeconds;
			SendVoiceMessage(GetGenderSound(Sound'GetInVehicleMale', Sound'GetInVehicleFemale', Receiver), GetTeam(Receiver));
		}
	}
	if (PlayerPawn(Receiver) != None && Sender == Receiver && S ~= "!XV")
		OpenGUI(PlayerPawn(Receiver));

	return Super.MutatorTeamMessage(Sender, Receiver, PRI, S, Type, bBeep);
}

function bool MutatorBroadcastMessage(Actor Sender, Pawn Receiver, out coerce string Msg, optional bool bBeep, out optional name Type)
{
	local int i;
	local string S;
	if ((Type == '' || Type == 'Event') && Sender == Receiver && Spectator(Receiver) != None)
	{
		i = InStr(Msg, ":");
		S = Mid(Msg, i + 1);
		if (S ~= "!XV")
			OpenGUI(PlayerPawn(Receiver));
	}
	return Super.MutatorBroadcastMessage(Sender, Receiver, Msg, bBeep, Type);
}

function Sound GetGenderSound(Sound SoundMale, Sound SoundFemale, Pawn Sender)
{
	if (Sender.bIsFemale)
		return SoundFemale;
	return SoundMale;
}

function int GetTeam(Pawn Sender)
{
	if (Level.Game.bTeamGame && Sender.PlayerReplicationInfo != None)
		return Sender.PlayerReplicationInfo.Team;
	return -1;
}

function SendVoiceMessage(Sound Sound, int Team)
{
	local FlagAnnouncerSound SoundActor;
	local Pawn P;
	SoundActor = Spawn(class'FlagAnnouncerSound');
	if (SoundActor != None)
		SoundActor.Init(Sound, false, Team, false);
	else
		for (P = Level.PawnList; P != None; P = P.NextPawn)
			if (P.bIsPlayer && P.IsA('PlayerPawn') && 
				(Team == -1 || (P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.Team == Team)))
				PlayerPawn(P).ClientPlaySound(Sound);
}

simulated function PreBeginPlay()
{
	local ChallengeHUD HUD;
	local HUDSpawnNotify N;
	
	Super.PreBeginPlay();
	
	if (Level.NetMode == NM_Client)
		SetTimer(1, true);
		
	if (Level.NetMode == NM_DedicatedServer)
		Disable('Tick');

	if (Level.NetMode == NM_Client && (default.UsedHUD == None || default.UsedHUD.Level != Level))
		default.UsedHUD = self;
	UsedHUD = None;
		
	N = Spawn(class'HudSpawnNotify');
	N.HUDMutator = self;
	foreach AllActors(class'ChallengeHUD', HUD)
		N.SpawnNotification(HUD);
}

simulated function Timer()
{
	if (MyHUD == None || MyHUD.PlayerOwner == None)
		return;
	if (MyHUD.PlayerOwner.CollisionRadius == 0 && DriverWeapon(MyHUD.PlayerOwner.Weapon) == None)
		MyHUD.PlayerOwner.SetCollisionSize(MyHUD.PlayerOwner.default.CollisionRadius, 
			MyHUD.PlayerOwner.CollisionHeight);
}

simulated function Tick(float Delta)
{
	if (Level.NetMode != NM_DedicatedServer)
	{
		if (MyHUD == None)
			FindHUD();
		if (!bGoodHud)
			CheckHUD();
	}
}

simulated function FindHUD()
{
	local PlayerPawn P;
	local ChallengeHUD HUD;

	foreach AllActors(class'PlayerPawn', P)
		if (ChallengeHUD(P.myHUD) != None)
			break;
	if (P != None)
		MyHUD = ChallengeHUD(P.myHUD);
	else
		foreach AllActors(class'ChallengeHUD', MyHUD)
			break;
	OrigHUD = MyHUD;
}

simulated function RegisterHUDMutator()
{
	bHUDMutator = True;
}

simulated function CheckHUD()
{
	local ENetRole OldRole;
	local ChallengeHUD HUD;
	
	if (MyHUD == None)
		return;
	
	HUD = MyHUD;
	if (HUD.isA('NexgenHUDWrapper') || HUD.isA('NexgenHUDWrapperT'))
	{
		OldRole = Role;
		Role = ROLE_Authority;
		SetPropertyText("MyHUD", getVal(HUD, "originalHUD"));
		Role = OldRole;
		if (MyHUD == None)
			MyHUD = HUD;
	}
	else
		bGoodHud = true;
}

simulated function PostRender(canvas Canvas)
{
	if (NextHUDMutator != None)
		NextHUDMutator.PostRender(Canvas);
		
	if (LastRender == Level.TimeSeconds)
		return;
	LastRender = Level.TimeSeconds;
		
	if (bNeedCleaner && Canvas != None && Canvas.Viewport != None && Canvas.Viewport.Actor != None)
		bNeedCleaner = !Class'RefsCleaner'.static.Init(Canvas.Viewport.Actor);
	if (FoundHuds > 0 && Canvas != None && Canvas.Viewport != None && Canvas.Viewport.Actor != None && 
		ChallengeHUD(Canvas.Viewport.Actor.MyHUD) != None &&
		Canvas.Viewport.Actor.MyHUD != OrigHUD)
	{
		MyHUD = ChallengeHUD(Canvas.Viewport.Actor.myHUD);
		OrigHUD = MyHUD;
		bGoodHud = false;
		CheckHUD();
	}
	if (MyHUD == None || MyHUD.PawnOwner == None)
		return;
	if (MyHUD.PawnOwner == MyHUD.PlayerOwner)
		DrawIdentifyInfo(Canvas);
}

simulated function bool DrawIdentifyInfo(canvas Canvas)
{
	local float XL, YL, Y;
	local int i;
	local Font Big, Small;
	
	if (!TraceIdentify(Canvas))
		return false;

	if (IdentifyTarget != None)
	{
		Big = MyHUD.MyFonts.GetBigFont(Canvas.ClipX);		
		Small = MyHUD.MyFonts.GetSmallFont(Canvas.ClipX);
		Canvas.Font = Small;
		Canvas.StrLen("TEST", XL, YL);
		Y = Canvas.ClipY - 256 * MyHUD.Scale;
		
		if (IdentifyTarget.Driver != None)
			Y = DrawPlayer(Canvas, Big, Small, YL, Y, IdentifyTarget.Driver);

		For( i=0; i<ArrayCount(IdentifyTarget.Passengers); i++ )
			if( IdentifyTarget.Passengers[i]!=None )
				Y = DrawPlayer(Canvas, Big, Small, YL, Y, IdentifyTarget.Passengers[i]);
				
		MyHUD.IdentifyTarget = None;
	}
	return true;
}

simulated function DrawFixProgress(Canvas Canvas, Vehicle Vehicle)
{
	local float XL, YL, X, Y;
	local string Str;
	local Texture Tex;
	local Pawn PlayerOwner;
	
	const XOffset = 3;
	const YOffset = 2;
	
	PlayerOwner = MyHUD.PlayerOwner;
	if (Spectator(PlayerOwner) != None)
		PlayerOwner = Pawn(Spectator(PlayerOwner).ViewTarget);

	if (PlayerOwner != None && (FixGun(PlayerOwner.Weapon) != None ||
		(class'VehiclesConfig'.default.bPulseAltHeal && PulseGun(PlayerOwner.Weapon) != None)) &&
		//PlayerOwner.bAltFire != 0 // not work in demoplay
		PlayerOwner.Weapon.AmbientSound == PlayerOwner.Weapon.AltFireSound &&
		((MyHUD.PlayerOwner.GameReplicationInfo != None && !MyHUD.PlayerOwner.GameReplicationInfo.bTeamGame) ||
		(PlayerOwner.PlayerReplicationInfo != None && PlayerOwner.PlayerReplicationInfo.Team == Vehicle.CurrentTeam)))
	{
		Y = 100.0f*Vehicle.Health/Vehicle.FirstHealth;
		Str = string(Y);
		if (Y < 10 || Y >= 100)
			Str = Left(Str, 3);
		else
			Str = Left(Str, 4);
		Str = Str $ "%";
		Canvas.Font = MyHUD.MyFonts.GetBigFont(Canvas.ClipX);			
		Canvas.StrLen(Str, XL, YL);
		X = (Canvas.ClipX - XL)/2;
		Y = Canvas.ClipY/2 - 1.5*YL;
		
		Canvas.DrawColor = MyHUD.WhiteColor;
		
		//Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.SetPos(X - XOffset, Y - YOffset);
		Tex = Texture'AmmoLedBase';
		Canvas.DrawTile(Tex, XL + XOffset*2, YL, 0, 0, Tex.USize, Tex.VSize);
		
		//Canvas.Style = ERenderStyle.STY_Normal;		
		Canvas.SetPos(X, Y);
		Canvas.DrawText(Str);
	}
}

simulated function float DrawPlayer(canvas Canvas, font Big, font Small, float YL, float Y, Pawn Pawn)
{
	if (Pawn.PlayerReplicationInfo != None)
	{
		Canvas.Font = Big;
		MyHUD.IdentifyTarget = Pawn.PlayerReplicationInfo;
		MyHUD.DrawTwoColorID(Canvas, MyHUD.IdentifyName, Pawn.PlayerReplicationInfo.PlayerName, Y);
		if (ChallengeTeamHUD(MyHUD) != None && MyHUD.PawnOwner.PlayerReplicationInfo.Team == IdentifyTarget.CurrentTeam )
		{
			Canvas.Font = Small;
			MyHUD.DrawTwoColorID(Canvas,MyHUD.IdentifyHealth,string(Pawn.Health), Y + 1.5*YL);
			Y += 1.0*YL;
		}
		Y += 2.0*YL;
		// prevent overlap health bar
		if (DriverWeapon(MyHUD.PawnOwner.Weapon) != None && Y > Canvas.ClipY/6*5 && Y < Canvas.ClipY/6*5 + 24)
			Y = Canvas.ClipY/6*5 + 24 + 0.5*YL;
	}
	return Y;
}

simulated function string getVal(Actor actor, string prop) {
	local string ret;
	local ENetRole OldRole;

	OldRole = actor.Role;
	actor.Role = actor.ENetRole.ROLE_Authority;
	ret = actor.GetPropertyText(prop);
	actor.Role = OldRole;
	return ret;
}

simulated function bool TraceIdentify(canvas Canvas)
{
	local actor Camera, TraceActor;
	local vector HitLocation, HitNormal, StartTrace, EndTrace;
	local rotator CamRot;
	local float X;
	local Vehicle Other;
	local int i;
	
	Canvas.ViewPort.Actor.PlayerCalcView(Camera, StartTrace, CamRot);
	
	TraceActor = MyHUD.PawnOwner;
	if (DriverWeapon(MyHUD.PawnOwner.Weapon) != None && DriverWeapon(MyHUD.PawnOwner.Weapon).VehicleOwner != None)
		TraceActor = DriverWeapon(MyHUD.PawnOwner.Weapon).VehicleOwner;
	
	EndTrace = StartTrace + vector(CamRot) * 1000.0;
	foreach TraceActor.TraceActors(class'Vehicle', Other, HitLocation, HitNormal, EndTrace, StartTrace)
		// Other can be LevelInfo in v436
		if (Other.IsA('Vehicle') && Other != TraceActor && Other.Driver != MyHUD.PawnOwner)
		{
			for (i = 0; i < ArrayCount(Other.Passengers); i++)
				if (Other.Passengers[i] == MyHUD.PawnOwner)
					break;
			if (i < ArrayCount(Other.Passengers))
				continue;
			DrawFixProgress(Canvas, Other);
			if (Other.Driver != None || Other.HasPassengers())
			{
				IdentifyTarget = Other;
				MyHUD.IdentifyTarget = None;
				MyHUD.IdentifyFadeTime = 3.0;
			}
			break;
		}

	if ((MyHUD.IdentifyFadeTime == 0.0) || (IdentifyTarget == None) || MyHUD.IdentifyTarget != None)
		return false;

	return true;
}

defaultproperties
{
	bNeedCleaner=True
	bHUDMutator=True
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
}
