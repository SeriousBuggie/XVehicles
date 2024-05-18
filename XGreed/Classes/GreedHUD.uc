//=============================================================================
// GreedHUD.
//=============================================================================
class GreedHUD expands Mutator;

var float LastRender;
var int LastSkulls;
var float LastSkullsTime;

var Font FirstFont;
var Font BigFont;
var float LastFontX;

var() color RedColor, BlueColor, GreenColor, YellowColor, WhiteColor, BlackColor;

simulated event PreBeginPlay()
{
	local ChallengeHUD HUD;
	local GreedHUDSpawnNotify N;
	
	Super.PreBeginPlay();
	
	if (Level.NetMode == NM_DedicatedServer)
		return;
	
	N = Spawn(class'GreedHUDSpawnNotify');
	N.HUDMutator = self;
	foreach AllActors(class'ChallengeHUD', HUD)
		N.SpawnNotification(HUD);
}

simulated event PostRender(canvas Canvas) {
	if (NextHUDMutator != None)
		NextHUDMutator.PostRender(Canvas);

	if (LastRender != Level.TimeSeconds) {
		LastRender = Level.TimeSeconds;
		MyPostRender(Canvas);
	}
}

simulated function MyPostRender(canvas C) {
	local PlayerPawn me;
	local int cnt;
	local Pawn p, player[144];

	me = C.ViewPort.Actor;
	
	if (FirstFont == None || LastFontX != C.ClipX) {
		FirstFont = class'FontInfo'.Static.GetStaticSmallFont(C.ClipX);
		BigFont = class'FontInfo'.Static.GetStaticBigFont(C.ClipX);
		LastFontX = C.ClipX;
	}
	
	cnt = 0;
	ForEach me.AllActors(class'Pawn', p) {
		if (!p.bIsPlayer || p.health <= 0 || p == me) continue;
		player[cnt++] = p;
	}
	
	DrawLabel(C, me, player, cnt);
	
	DrawSkulls(C, me);
}

simulated function DrawSkulls(Canvas Canvas, PlayerPawn me)
{
	local float X, Y, Scale, Whiten;
	local int Skulls;
	local ChallengeHUD HUD;
		
	HUD = ChallengeHUD(me.myHUD);
	if (me.PlayerReplicationInfo  == None || me.PlayerReplicationInfo.bIsSpectator || HUD.bHideHUD)
		return;
	
	Skulls = Class'Greed'.static.getSkulls(me);
	Scale = HUD.Scale;
	
	X = Canvas.ClipX - 140 * Scale;
	Y = 4 * 64 * Scale;
	
	Canvas.Style = HUD.Style;
	Canvas.CurX = X;
	Canvas.CurY = Y;
	Canvas.DrawColor = HUD.HUDColor; 
	if (Skulls != 0 && LastSkulls <= Skulls)
	{
		Whiten = Level.TimeSeconds - LastSkullsTime;	
		if (Whiten < 3.0)
		{
			if (HUD.HudColor == HUD.GoldColor )
				Canvas.DrawColor = HUD.WhiteColor;
			else
				Canvas.DrawColor = HUD.GoldColor;
			Canvas.CurX = X - 64 * Scale;
			Canvas.CurY = Y - 32 * Scale;
			Canvas.Style = ERenderStyle.STY_Translucent;
			Canvas.DrawTile(Texture'BotPack.HUDWeapons', 256 * Scale, 128 * Scale, 0, 128, 256.0, 128.0);
			
			Canvas.CurX = X;
			Canvas.CurY = Y;
			Whiten = 4 * Whiten - int(4 * Whiten);
			Canvas.DrawColor = Canvas.DrawColor + (HUD.HUDColor - Canvas.DrawColor) * Whiten;
		}
	}

	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 0, 128, 128.0, 64.0);
	Canvas.DrawColor = WhiteColor;
	HUD.DrawBigNum(Canvas, Skulls, X + 40 * Scale, Y + 16 * Scale);
	
	if (LastSkulls != Skulls)
	{
		LastSkulls = Skulls;
		LastSkullsTime = Level.TimeSeconds;
	}
}

simulated function DrawLabel(Canvas C, PlayerPawn me, Pawn actor[144], int cnt) {
	local Pawn thisPawn, Other;
	local vector X, Y, Z, CamLoc, TargetDir, Dir, XY;
	local rotator CamRot;
	local Actor Camera;
	local float Dist, DistScale;
	local float TanFOVx, TanFOVy;
	local float f, dx, dy, TextHeight, dummy, PenX, PenY;
	local string StrHealth, StrMonstername, StrSkulls;
	local int i, j, k, Team, MyTeam;
	local color outline;

	//outline.R = 0; outline.G = 0; outline.B = 0;
	Team = -1;

	C.Font = FirstFont;

	me.PlayerCalcView(Camera, CamLoc, CamRot);

	TanFOVx = Tan(me.FOVAngle / 114.591559); // 360/Pi = 114.5915590...
	TanFOVy = (C.ClipY / C.ClipX) * TanFOVx;
	GetAxes(CamRot, X, Y, Z);

	C.bNoSmooth = False;
	C.Style = me.ERenderStyle.STY_Normal;
	for (i = 0; i < cnt; i++) {
		thisPawn = actor[i];
		
		TargetDir = thisPawn.Location - CamLoc;
		Dist = VSize(TargetDir) * FMin(TanFOVx, 1.0);
		PenY = thisPawn.CollisionHeight;
		TargetDir = Normal(TargetDir + vect(0,0,1) * PenY);
		if (TargetDir dot X <= 0) continue;
		PenX = thisPawn.CollisionRadius;
		if (PenX == 0) PenX = thisPawn.default.CollisionRadius;
		if (PenX == 0) PenX = 1;
		DistScale = FMin(100.0 * PenX / Dist, 1.0);
		if (DistScale == 1.0 && (me.FastTrace(thisPawn.Location, CamLoc) || 
			me.FastTrace(thisPawn.Location + vect(0,0,0.8) * PenY, CamLoc)))
		{
			Dir = X * (X dot TargetDir);
			XY = TargetDir - Dir;

			dx = C.ClipX * 0.5 * (1.0 + (XY dot Y) / (VSize(Dir) * TanFOVx));
			dy = C.ClipY * 0.5 * (1.0 - (XY dot Z) / (VSize(Dir) * TanFOVy));

			StrHealth = string(thisPawn.Health);
			if (thisPawn.PlayerReplicationInfo != None && thisPawn.PlayerReplicationInfo.PlayerName != "")
				StrMonstername = thisPawn.PlayerReplicationInfo.PlayerName;
			else
				StrMonstername = string(thisPawn.class.name);
			j = Class'Greed'.static.getSkulls(thisPawn);
			if (j != 0)
				StrSkulls = string(j);
			else
				StrSkulls = "";
	
			PenX = dx;
			C.TextSize(StrHealth, dx, TextHeight);
			PenY = dy - 1.75 * TextHeight;
			
			k = 0;
			for (j = 0; j < i; j++)
			{
				Other = actor[j];
				if (Other.Location == thisPawn.Location) 
				{
					if (Class'Greed'.static.getSkulls(Other) != 0)
						k += 4;
					else
						k += 2;
				}
			}
			
			PenY -= k*TextHeight;
			
			// draw it centered above
			PenX -= dx/2;
			
			if (thisPawn.PlayerReplicationInfo != None)
				MyTeam = thisPawn.PlayerReplicationInfo.Team;
			else
				MyTeam = 255;
				
			//MyTeam = (int(Level.TimeSeconds) % 20) / 4;
			
			if (Team != MyTeam) {
				Team = MyTeam;				
				switch (Team) {
					case 0: C.DrawColor = YellowColor; break;
					case 1: C.DrawColor = BlueColor; break;
					case 2: C.DrawColor = GreenColor; break;
					case 3: C.DrawColor = YellowColor; break;
					case 255:
					default: C.DrawColor = YellowColor; break;
				}
			}
			
			DrawTextClipped(C, PenX, PenY, StrHealth, outline);

			C.TextSize(StrMonstername, f, dummy);
			PenX += dx/2 - f/2;
			PenY -= TextHeight;
			DrawTextClipped(C, PenX, PenY, StrMonstername, outline);
			
			if (StrSkulls != "")
			{
				C.Font = BigFont;
				C.TextSize(StrSkulls, dx, dummy);
				PenX += f/2 - dx/2;
				PenY -= TextHeight;
				DrawTextClipped(C, PenX, PenY, StrSkulls, outline);
				C.Font = FirstFont;
			}
		}
	}
}

simulated function DrawTextClipped(Canvas C, int X, int Y, string text, Color outline) {
	local Color old;

	old = C.DrawColor;
	C.DrawColor = outline;

	C.SetPos(X - 1, Y - 1);
	C.DrawTextClipped(text, False);
	C.SetPos(X + 1, Y + 1);
	C.DrawTextClipped(text, False);
	C.SetPos(X - 1, Y + 1);
	C.DrawTextClipped(text, False);
	C.SetPos(X + 1, Y - 1);
	C.DrawTextClipped(text, False);

	C.DrawColor = old;
	C.SetPos(X, Y);
	C.DrawTextClipped(text, False);
}

defaultproperties
{
	RedColor=(R=255,G=210,B=255)
	BlueColor=(G=255,B=255)
	GreenColor=(G=255)
	YellowColor=(R=255,G=255)
	WhiteColor=(R=255,G=255,B=255)
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	bGameRelevant=True
}
