//=============================================================================
// XVehiclesHUD.
//=============================================================================
class XVehiclesHUD expands Mutator;

var ChallengeHUD MyHUD;
var Vehicle IdentifyTarget;

static function SpawnHUD(Actor A)
{
	local Actor HUD;

	foreach A.AllActors(default.Class, HUD)
		break;
	if (HUD == None)
		A.Spawn(default.class);
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
	if ( MyHUD.PawnOwner == MyHUD.PlayerOwner )
		DrawIdentifyInfo(Canvas);
}

simulated function bool DrawIdentifyInfo(canvas Canvas)
{
	local float XL, YL, Y;
	local int i;
	local font Big, Small;
	
	if ( !TraceIdentify(Canvas))
		return false;

	if (IdentifyTarget != None)
	{
		Y = Canvas.ClipY - 256 * MyHUD.Scale;
	
		Big = MyHUD.MyFonts.GetBigFont(Canvas.ClipX);
		Small = MyHUD.MyFonts.GetSmallFont(Canvas.ClipX);
		Canvas.Font = Small;
		Canvas.StrLen("TEST", XL, YL);
		
		if (IdentifyTarget.Driver != None)
			Y = DrawPlayer(Canvas, Big, Small, YL, Y, IdentifyTarget.Driver);

		For( i=0; i<ArrayCount(IdentifyTarget.Passengers); i++ )
			if( IdentifyTarget.Passengers[i]!=None )
				Y = DrawPlayer(Canvas, Big, Small, YL, Y, IdentifyTarget.Passengers[i]);
				
		MyHUD.IdentifyTarget = None;
	}
	return true;
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
	local actor Other, Camera, TraceActor;
	local vector HitLocation, HitNormal, StartTrace, EndTrace;
	local rotator CamRot;
	local float X;
	local Vehicle MyVehicle;
	
	Canvas.ViewPort.Actor.PlayerCalcView(Camera, StartTrace, CamRot);
	
	TraceActor = MyHUD.PawnOwner;
	if (DriverWeapon(MyHUD.PawnOwner.Weapon) != None && DriverWeapon(MyHUD.PawnOwner.Weapon).VehicleOwner != None)
		TraceActor = DriverWeapon(MyHUD.PawnOwner.Weapon).VehicleOwner;
	
	EndTrace = StartTrace + vector(CamRot) * 1000.0;
	Other = TraceActor.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	
	if (Vehicle(Other) != None && DriverWeapon(MyHUD.PawnOwner.Weapon) != None && 
		VSize(Other.Location - MyHUD.PawnOwner.Location) < FMin(Other.CollisionRadius, Other.CollisionHeight))
		MyVehicle = Vehicle(Other);
	
	if (MyVehicle != None && Other == MyVehicle)
	{
		X = (vector(CamRot) dot (MyVehicle.Location - StartTrace));
		StartTrace += vector(CamRot)*2*Abs(X);
		Other = TraceActor.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	}

	if ( Vehicle(Other) != None && (Vehicle(Other).Driver != None || Vehicle(Other).HasPassengers()) )
	{
		IdentifyTarget = Vehicle(Other);
		MyHUD.IdentifyTarget = None;
		MyHUD.IdentifyFadeTime = 3.0;
	}

	if ( (MyHUD.IdentifyFadeTime == 0.0) || (IdentifyTarget == None) || MyHUD.IdentifyTarget != None )
		return false;

	return true;
}

defaultproperties
{
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
}
