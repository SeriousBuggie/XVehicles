//=============================================================================
// XVehiclesHUD.
//=============================================================================
class XVehiclesHUD expands Mutator;

var ChallengeHUD MyHUD;
var Vehicle IdentifyTarget;
var XVehiclesHUD UsedHUD;

static function SpawnHUD(Actor A)
{
	local Actor HUD;
	
	if (default.UsedHUD != None && !default.UsedHUD.bDeleteMe && default.UsedHUD.Level == A.Level)
		return;

	foreach A.AllActors(default.Class, HUD)
		break;
	if (HUD != None)
		return;
	default.UsedHUD = A.Spawn(default.Class);
	if (default.UsedHUD != None)
		A.Level.Game.BaseMutator.AddMutator(default.UsedHUD);
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
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	if (Level.NetMode == NM_Client)
		SetTimer(1, true);
		
	if (Level.NetMode == NM_DedicatedServer)
		Disable('Tick');
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
		if (!bHUDMutator)
			RegisterHUDMutator();
		CheckHUD();
	}
}

simulated function RegisterHUDMutator()
{
	local PlayerPawn P;
	
	Super.RegisterHUDMutator();

	ForEach AllActors( class'PlayerPawn', P)
		if ( ChallengeHUD(P.myHUD) != None )
			break;
	if (P != None)
		MyHUD = ChallengeHUD(P.myHUD);
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
}

simulated function PostRender(canvas Canvas)
{
	if (NextHUDMutator != None)
		NextHUDMutator.PostRender(Canvas);
		
	if (MyHUD == None)
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
	
	const XOffset = 3;
	const YOffset = 2;
	
	if (MyHUD.PlayerOwner != None && 
		(FixGun(MyHUD.PlayerOwner.Weapon) != None ||
		(class'VehiclesConfig'.default.bPulseAltHeal && PulseGun(MyHUD.PlayerOwner.Weapon) != None)) &&
		((MyHUD.PlayerOwner.GameReplicationInfo != None && !MyHUD.PlayerOwner.GameReplicationInfo.bTeamGame) ||
		(MyHUD.PlayerOwner.PlayerReplicationInfo != None && 
		MyHUD.PlayerOwner.PlayerReplicationInfo.Team == Vehicle.CurrentTeam)) &&
		MyHUD.PlayerOwner.bAltFire != 0)
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
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
}
