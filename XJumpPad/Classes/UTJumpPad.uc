// ============================================================================
//  swJumpPad.
//
//  Improved JumpPad/Kicker Actor that calculates jump force automatically.
//  Does not require additional Trigger/LiftExit/LiftCenter actors.
//  Familiar placing procedure - just like Teleporters.
//  Path links visible in UnrealEd.
//  Bot support.
//  Can be disabled/enabled with Triggers.
//  Support for on-jump special effects.
//  Allows jump angle and destination randomisation.
//  Supports custom vertical gravity, ie: LowGrav mutator.
// 
// ============================================================================
//  Copyright 2005 Roman Switch` Dzieciol, neai o2.pl
//  http://wiki.beyondunreal.com/wiki/Switch
// ============================================================================
//  One-way JumpPad Tutorial:
//  - swJumpPads are placed like Teleporters:
//  - TWO swJumpPad actors are required: Source and Destination.
//  - In Source swJumpPad set "URL" to some name.
//  - In Destination swJumpPad set "Tag" to that name.
//  - Adjust JumpAngle if neccessary.
//  - Congratulations, you have set up a one-way bot-friendly JumpPad.
//
// ============================================================================
//  Tips:
//
//  - JumpAngle will be limited to 1-89 degrees.
//
//  - If the JumpAngle is too low, a theoretically valid one will be calculated 
//    ingame and warning message will be broadcasted every time someone jumps.
//
//  - For testing precision, doublejump into JumpPad from distance, this way
//    you won't accidentially disrupt your jump with movement keys.
//
//  - Ignore other Teleporter properties other than URL, it's not a teleporter.
//
//  - If you want to change jump parameters, change them in the Source JumpPad,
//    not the Destination one.
//
//  - bTraceGround requires that there are no holes under the center of
//    Destination JumpPad. If there is one, ie if the JumpPad is placed on edge
//    of a cliff, players will be launched at the ground level in the hole, ie
//    bottom of the cliff. To fix this move Destination JumpPad away from the 
//    edge or disable bTraceGround.
//    
// ============================================================================
//  Angle random modes:
//  
//  AM_Random   
//      Uses random value from range ( JumpAngle, JumpAngle+AngleRand )
//      
//  AM_Extremes
//      Uses JumpAngle then JumpAngle+AngleRand then repeat. Lets suppose that
//      two players walk into JumpPad one after another. Player who jumped 
//      first may arrive at target location *later* than player who jumped 
//      second if the jump angle of second player was significatly flatter.
//      
//  AM_Owned        
//      Team==TeamNumber uses JumpAngle, other teams use JumpAngle+AngleRand
//
// ============================================================================
//  bLogParams acronyms:
//  
//  A   = Angle
//  IV  = Impact velocity in Z plane
//  IS  = Impact velocity in XY plane
//  IH  = Impact height
//  T   = Time in ms
//  P   = Peak height
//  V   = Jump velocity
//  G   = Gravity
//  U   = URL
//  PN  = Player Name
//  N   = Source JumpPad name
//  D   = Destination JumpPad name
//
// ============================================================================
class UTJumpPad expands Teleporter;

//Model import
#exec mesh import mesh=XJumpPad anivfile=Models\WildCardBaseM_a.3d datafile=Models\WildCardBaseM_d.3d x=0 y=0 z=0 MLOD=1 LODSTYLE=0
#exec mesh origin mesh=XJumpPad x=0 y=0 z=0 PITCH=0
#exec mesh sequence mesh=XJumpPad seq=All startframe=0 numframes=1

#exec meshmap new meshmap=XJumpPad mesh=XJumpPad
#exec meshmap scale meshmap=XJumpPad x=0.15 y=0.15 z=0.3

//Skins import
#exec TEXTURE IMPORT NAME=XJumpPad FILE=SKINS\WildCardBaseT.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SETTEXTURE MESHMAP=XJumpPad NUM=0 TEXTURE=WildCardBaseT

//Additional textures import
#exec TEXTURE IMPORT NAME=RedStreak FILE=JParticles\RedStreak.bmp GROUP=Particles FLAGS=2
#exec TEXTURE IMPORT NAME=RedGrid FILE=JParticles\RedGrid.bmp GROUP=Particles FLAGS=2
#exec TEXTURE IMPORT NAME=BlueStreak FILE=JParticles\BlueStreak.bmp GROUP=Particles FLAGS=2
#exec TEXTURE IMPORT NAME=BlueGrid FILE=JParticles\BlueGrid.bmp GROUP=Particles FLAGS=2
#exec TEXTURE IMPORT NAME=GreenStreak FILE=JParticles\GreenStreak.bmp GROUP=Particles FLAGS=2
#exec TEXTURE IMPORT NAME=GreenGrid FILE=JParticles\GreenGrid.bmp GROUP=Particles FLAGS=2
#exec TEXTURE IMPORT NAME=PurpleStreak FILE=JParticles\PurpleStreak.bmp GROUP=Particles FLAGS=2
#exec TEXTURE IMPORT NAME=PurpleGrid FILE=JParticles\PurpleGrid.bmp GROUP=Particles FLAGS=2
#exec TEXTURE IMPORT NAME=OrangeStreak FILE=JParticles\OrangeStreak.bmp GROUP=Particles FLAGS=2
#exec TEXTURE IMPORT NAME=OrangeGrid FILE=JParticles\OrangeGrid.bmp GROUP=Particles FLAGS=2
#exec TEXTURE IMPORT NAME=WhiteStreak FILE=JParticles\WhiteStreak.bmp GROUP=Particles FLAGS=2
#exec TEXTURE IMPORT NAME=WhiteGrid FILE=JParticles\WhiteGrid.bmp GROUP=Particles FLAGS=2

var float TCountA, TCountB;

var enum EParticleColor
{
	PCLR_Red,
	PCLR_Blue,
	PCLR_Green,
	PCLR_Yellow,
	PCLR_Purple,
	PCLR_Orange,
	PCLR_White
} PT;

var() EParticleColor ParticlesColor;
var() EParticleColor GridsColor;

var() float ParticlesSpeed;
var() float GridsSpeed;

var() bool bAutoSize;

var vector Velocity;

// ---------------- swJumpPad source --------------------------------

enum EAngleMode
{
    AM_Random,      
    AM_Extremes,    
    AM_Owned        
};


// ============================================================================
// Source JumpPad Properties
// ============================================================================

var(JumpPad) float          JumpAngle;          // Jump angle

var(JumpPad) byte           TeamNumber;         // Team number
var(JumpPad) bool           bTeamOnly;          // Other teams can't use it

var(JumpPad) float          TargetZOffset;      // Target location height offset
var(JumpPad) vector         TargetRand;         // Target location random range
var(JumpPad) bool           bTraceGround;       // Find ground below JumpPad and use it as target location

var(JumpPad) float          AngleRand;          // Jump angle random range
var(JumpPad) EAngleMode     AngleRandMode;      // Jump angle random range mode

var(JumpPad) bool           bDisabled;          // Disable, triggering JumpPad toggles this

var(JumpPadFX) class<Actor> JumpEffect;         // Spawn this actor at JumpPad when someone jumps
var(JumpPadFX) class<Actor> JumpPlayerEffect;   // Spawn this actor at jumping player
var(JumpPadFX) name         JumpEvent;          // Trigger this event when someone jumps
var(JumpPadFX) sound        JumpSound;          // Play this sound when someone jumps
var(JumpPadFX) bool         bClientSideEffects; // Spawn effects only on clients

var(JumpPadDebug) float     JumpWait;           // Disable JumpPad for JumpWait seconds after jump
var(JumpPadDebug) bool      bLogParams;         // Display jump parameters in log and ingame


// ============================================================================
// Internal
// ============================================================================

var Actor JumpTarget;
var Actor JumpActor;
var bool bSwitchAngle;
var float MinAngleCurve;
var float MinAngleFinder;
var float MinAngle;
var float MaxAngle;

Const RadianToDegree    = 57.2957795131;
Const DegreeToRadian    = 0.01745329252;
Const RadianToURot      = 10430.3783505;
Const URotToRadian      = 0.000095873799;
Const DegreeToURot      = 182.04444444;
Const URotToDegree      = 0.00549316;

replication
{
	reliable if( Role==ROLE_Authority )
		Velocity;
}

simulated function PostBeginPlay()
{
	local Actor A;
	local vector V, S;
    Super(NavigationPoint).PostBeginPlay();
    
    if( Role!=ROLE_Authority )
    	return;
    	
    if( URL == "" )
    {
        ExtraCost = 0;
        bHidden = true;
	}
	else
	{
		// Find JumpTarget
        foreach AllActors( class 'Actor', A )
            if( string(A.tag) ~= URL && A != Self ) 
                JumpTarget = A;

		Velocity = CalcVelocity(self);
	}
	
	if (!bHidden && bAutoSize)
	{
		if (DrawScale != default.DrawScale && Mesh == default.Mesh &&
			CollisionRadius == default.CollisionRadius && CollisionHeight == default.CollisionHeight)
		{
			SetCollisionSize(CollisionRadius*DrawScale/default.DrawScale, CollisionHeight*DrawScale/default.DrawScale);
		}
		if (Rotation != rot(0,0,0))
		{
			V.X = default.CollisionRadius*DrawScale/default.DrawScale;
			V.Y = V.X;
			S = V >> Rotation;
			
			if (S.Z < 0)
				S.Z = -S.Z;
			
			V.X = 0;
			V.Y = 0;
			V.Z = default.CollisionHeight*DrawScale/default.DrawScale;
			V = V >> Rotation;
			
			if (V.Z < 0)
				V.Z = -V.Z;

			if (CollisionHeight < S.Z + V.Z)
				 SetCollisionSize(CollisionRadius, S.Z + V.Z);
		}
	}
}

simulated function bool Accept( actor Incoming, Actor Source )
{
    return false;
}

simulated function Trigger( Actor Other, Pawn EventInstigator )
{
    local int i;

    bEnabled = !bEnabled;
    if( bEnabled ) // launch any pawns already in my radius
        for( i=0; i<4; i++)
            if( Touching[i] != None )
                Touch(Touching[i]);
}

simulated function ShowMessage( coerce string s, optional Actor A, optional bool bID )
{
    if( bID )
        s = s $ GetIdentifier(A);
    
    if( Role == ROLE_Authority )
        BroadcastMessage( s, true );
    
    Log( s, name );
}

simulated function float GetAngle( Actor Other )
{
    switch( AngleRandMode )
    {
        case AM_Random: 
            return RandRange( JumpAngle, JumpAngle+AngleRand );
            
        case AM_Extremes: 
            bSwitchAngle = !bSwitchAngle;
            return JumpAngle + AngleRand*float(bSwitchAngle);
            
        case AM_Owned: 
            if( Pawn(Other) != None && Pawn(Other).PlayerReplicationInfo.Team != TeamNumber )
                    return JumpAngle+AngleRand;
            else    return JumpAngle;
    }   
}

simulated function string GetIdentifier( Actor A )
{
    local string S;
    local Pawn P;

    S = S @ "U=[" $URL$ "]";

    P = Pawn(A);
    if( P != None )
    {
        S = S @ "PN=[";
        if( P.PlayerReplicationInfo != None
        &&  P.PlayerReplicationInfo.PlayerName != "" )
                S = S $P.PlayerReplicationInfo.PlayerName; 
        else    S = S $P.Name;  
        S = S $ "]";
    }
    S = S @ "N=[" $Name$ "]"; 
    S = S @ "D=[" $JumpTarget.GetPropertyText("Name")$ "]"; 

    return S; 
}

simulated function vector TraceGround( vector Origin )
{
    local Actor A;
    local vector HL,HN;
    
    A = Trace( HL, HN, Origin+vect(0,0,-32768), Origin, false );
    if( A != None )
    {
        return HL;
    }
        
    ShowMessage( "ERROR: Ground level not found below destination",, true );
    return JumpTarget.Location + vect(0,0,-1)*JumpTarget.CollisionHeight;
}

simulated function vector CalcVelocity( Actor Other )
{
    local vector vel;
    local vector origin;
    local vector targetloc, targetdelta, targetrange;
    local rotator jumpdir, targetdir;
    local float targetdist, targetz;
    local float grav;
    local float angler, angled, pitch, angledmin, minalpha, angledtry;
    local float tanr, sinr, cosr;
    local float speed, speedxy, speedz;
    local float peak;
    local float time;
    local float impactheight, impactspeedz;
    local vector impactspeedxy;
    local Bot B;
    
    
    // Player location
    origin = Other.Location + vect(0,0,-1)*Other.CollisionHeight;
    
    // Target Location
    if( bTraceGround )
    {
        targetloc = TraceGround(JumpTarget.Location);
    }
    else
    {
        targetloc = JumpTarget.Location + vect(0,0,-1)*JumpTarget.CollisionHeight;
    }
    targetloc += VRand()*TargetRand;
    targetloc.Z += TargetZOffset;
    
    // Target vars
    targetdelta = targetloc - origin;
    targetrange = targetdelta * vect(1,1,0);
    targetdist = VSize(targetrange);
    targetz = targetdelta.Z;
    targetdir = rotator(targetdelta);
    
    // Get gravity
    grav = -Region.Zone.ZoneGravity.Z;
    
    // Get Angle
    //JumpAngle=10;
    angled = FClamp(GetAngle(Other),MinAngle,MaxAngle);

    // Check minimum angle
    angledmin = FClamp(int(targetdir.Pitch * URotToDegree)+1,MinAngle,MaxAngle);
    if( angledmin > angled )
    {
        minalpha = (1-(1-(angledmin / MaxAngle))**MinAngleCurve);
        angledtry = FClamp(angledmin+(MaxAngle-angledmin)*MinAngleFinder*minalpha,MinAngle,MaxAngle);
        ShowMessage( "WARNING: Minimum theoretical jump angle is" @int(angledmin)$ ". JumpAngle=" $int(angled)$ ". Trying angle=" $int(angledtry), Other, true );
        angled = angledtry;
    }

    // Convert angle
    angler = angled * DegreeToRadian; // radians
    pitch = angled * DegreeToURot; // ru
    
    // Target direction
    jumpdir = targetdir;
    jumpdir.Pitch = pitch;
    
    // Speed
    tanr = tan(angler);
    speed = targetdist * Sqrt( (grav*((tanr*tanr) + 1)) / (2*(targetdist*tanr-targetz)) );
    if( speed == 0 )
    {
        ShowMessage( "ERROR: Could not calculate JumpSpeed", Other, true );
        if (Pawn(Other) != None)
	        speed = Pawn(Other).JumpZ;
	    else
	    	speed = class'Pawn'.default.JumpZ;
    }
    
    // Velocity
    vel = speed * vector(jumpdir);

    // Velocity components
    speedxy = VSize(vel*vect(1,1,0));
    speedz = vel.Z;
        
    // Flight time
    time = (speedz / grav) + sqrt((speedz*speedz)/(grav*grav)-(2*targetz)/grav);     
    
    if( bLogParams )
    {
        sinr = sin(angler);
        cosr = cos(angler);
        
        peak = ( (speed*speed*sinr*sinr) / (2*grav));
        
        impactheight = peak - targetz;
        impactspeedxy = Normal(targetrange) * speedxy;
        impactspeedz = ( speedz ) - ( grav * time );
        
        ShowMessage(
         "A=" $int(angled)
        @"IV=" $int(impactspeedz)
        @"IS=" $int(VSize(impactspeedxy))
        @"IH=" $int(impactheight)
        @"T=" $int(time*1000)
        @"P=" $int(peak)
        @"V=" $int(speed)
        @"G=" $int(grav)
        , Other, true );
    }

    // AI hints
    B = Bot(Other);
    if( B != None )
    {
        B.Focus = JumpTarget.Location;
        B.MoveTarget = JumpTarget;
        B.MoveTimer = time-0.1;
        B.Destination = JumpTarget.Location;
    } 

	if (Other != self)
	{
	    // Update player's physics
	    if( Other.Physics == PHYS_Walking )
	    {
	        Other.SetPhysics(PHYS_Falling);
	    }        
	    Other.Velocity = vel;    
	    Other.Acceleration = vect(0,0,0);  
	}
    
    // AI hints
    if( B != None )
    {
        B.bJumpOffPawn = true;
        B.SetFall();
        B.DesiredRotation = rotator(targetrange);
    }        
    
    return vel;
}

simulated event Touch( Actor Other )
{
    // Accept only pawns
    if( !bEnabled || Pawn(Other) == None || Other.Physics == PHYS_None  )
        return;

    // Setup PostTouch
    PendingTouch = Other.PendingTouch;
    Other.PendingTouch = self;
}

simulated event PostTouch( Actor Other )
{
    local Pawn P;
    local Actor A;

    // Accept only pawns
    P = Pawn(Other);
    if( !bEnabled || P == None || P.Physics == PHYS_None )
        return;

    if( Role == ROLE_Authority )
    {
        // Find JumpTarget
        foreach AllActors( class 'Actor', A )
            if( string(A.tag) ~= URL && A != Self ) 
                JumpTarget = A;
                
        if( JumpTarget == None )
        {
            if( URL != "" )
                ShowMessage( "ERROR: Could not find destination", Other, true );
            return;
        }           
            
        // If team only, enforce it
        if( bTeamOnly && P.PlayerReplicationInfo.Team != TeamNumber )
            return;
        
        // Do not launch again a launched player.
        if( Other != JumpActor || Level.TimeSeconds-JumpWait > default.JumpWait )
        {
            JumpActor = Other;
            JumpWait = Level.TimeSeconds;   
        }
        else return;  
        
        // Launch player
        CalcVelocity( P );
                
        // Broadcast event
        Instigator = P;
        if( JumpEvent != '' )
            foreach AllActors( class'Actor', A, JumpEvent )
                A.Trigger( self, Instigator );
            
        // Play Sounds
        JumpSounds(P);
    }
    
    // Show effects
    JumpEffects(P); 
}

simulated function JumpEffects( Pawn Other )
{
    if((bClientSideEffects && Level.NetMode != NM_DedicatedServer)
    ||(!bClientSideEffects && Role == ROLE_Authority))
    {
        // Spawn JumpPad effect
        if( JumpEffect != None )
            Spawn( JumpEffect, self,, Location, rotator(Other.Velocity) );  
            
        // Spawn Player effect
        if( JumpPlayerEffect != None )
            Spawn( JumpPlayerEffect, Other,, Other.Location, rotator(Other.Velocity) ); 
    }
}

function JumpSounds( Pawn Other )
{
    // Make noise
    if( JumpSound != None )
    {
        PlaySound(JumpSound);     
        MakeNoise(1.0);
    }
}

/* SpecialHandling is called by the navigation code when the next path has been found.  
It gives that path an opportunity to modify the result based on any special considerations
*/

function Actor SpecialHandling( Pawn Other )
{
    //ShowMessage( "FOUND!",, true );
    return self;
}

    
// ============================================================================
//  Copyright 2005 Roman Switch` Dzieciol, neai o2.pl
//  http://wiki.beyondunreal.com/wiki/Switch
// ============================================================================


// ---------------- swJumpPad source --------------------------------


simulated function Tick(float DeltaTime)
{
local vector X, Y, Z;
local int rX, rY;
local JPadEmitPrtc JStreak;
local JPadEmitGrid JGrid;
local byte j;
local rotator R;

	Super.Tick(DeltaTime);

	if (bDisabled || Level.NetMode == NM_DedicatedServer || bHidden)
		return;
		
	R = Rotation + rot(16384,0,0);

	TCountA += DeltaTime;
	TCountB += DeltaTime;

	if (TCountA >= 0.15)
	{
		TCountA = 0;

		GetAxes(R, X, Y, Z);
		
		For (j=0; j<4; j++)
		{
			rX = (Rand(57) - 28) * DrawScale;
			rY = (Rand(57) - 28) * DrawScale;
	
			JStreak = Spawn(Class'JPadEmitPrtc',,, Location + rX*Z + rY*Y + 4*X, rotator(Velocity));
			JStreak.Velocity = Normal(Velocity) * FRand() * ParticlesSpeed * DrawScale;
	
			JStreak.DrawScale = DrawScale;
	
			if (ParticlesColor == PCLR_Red)
				JStreak.MultiSkins[1] = Texture'RedStreak';
			else if (ParticlesColor == PCLR_Blue)
				JStreak.MultiSkins[1] = Texture'BlueStreak';
			else if (ParticlesColor == PCLR_Green)
				JStreak.MultiSkins[1] = Texture'GreenStreak';
			else if (ParticlesColor == PCLR_Purple)
				JStreak.MultiSkins[1] = Texture'PurpleStreak';
			else if (ParticlesColor == PCLR_Orange)
				JStreak.MultiSkins[1] = Texture'OrangeStreak';
			else if (ParticlesColor == PCLR_White)
				JStreak.MultiSkins[1] = Texture'WhiteStreak';
		}
	}

	if (TCountB >= 0.25)
	{
		TCountB = 0;

		GetAxes(R, X, Y, Z);
		JGrid = Spawn(Class'JPadEmitGrid',,, Location + 4*X);
		
		JGrid.Velocity = Normal(Velocity) * GridsSpeed * DrawScale;

		JGrid.DrawScale = DrawScale;

		if (GridsColor == PCLR_Red)
			JGrid.MultiSkins[1] = Texture'RedGrid';
		else if (GridsColor == PCLR_Blue)
			JGrid.MultiSkins[1] = Texture'BlueGrid';
		else if (GridsColor == PCLR_Green)
			JGrid.MultiSkins[1] = Texture'GreenGrid';
		else if (GridsColor == PCLR_Purple)
			JGrid.MultiSkins[1] = Texture'PurpleGrid';
		else if (GridsColor == PCLR_Orange)
			JGrid.MultiSkins[1] = Texture'OrangeGrid';
		else if (GridsColor == PCLR_White)
			JGrid.MultiSkins[1] = Texture'WhiteGrid';
	}
}

event int SpecialCost(Pawn Seeker)
{
	if (!bHidden && !bDisabled && Seeker != None && Seeker.Weapon != None && Seeker.Weapon.isA('DriverWeapon'))
		return 100000;
		
	return ExtraCost;
}

defaultproperties
{
      TCountA=0.000000
      TCountB=0.000000
      PT=PCLR_Red
      ParticlesColor=PCLR_Yellow
      GridsColor=PCLR_Yellow
      ParticlesSpeed=160.000000
      GridsSpeed=50.000000
      bAutoSize=True
      Velocity=(X=0.000000,Y=0.000000,Z=0.000000)
      JumpAngle=45.000000
      TeamNumber=0
      bTeamOnly=False
      TargetZOffset=0.000000
      TargetRand=(X=0.000000,Y=0.000000,Z=0.000000)
      bTraceGround=True
      AngleRand=0.000000
      AngleRandMode=AM_Random
      bDisabled=False
      JumpEffect=None
      JumpPlayerEffect=None
      JumpEvent="JumpPad"
      JumpSound=Sound'UnrealI.Pickups.BootJmp'
      bClientSideEffects=False
      JumpWait=1.000000
      bLogParams=False
      JumpTarget=None
      JumpActor=None
      bSwitchAngle=False
      MinAngleCurve=3.000000
      MinAngleFinder=0.750000
      MinAngle=1.000000
      MaxAngle=89.000000
      ExtraCost=400
      bSpecialCost=True
      bStatic=False
      bHidden=False
      bNoDelete=True
      bDirectional=False
      DrawType=DT_Mesh
      Mesh=LodMesh'XJumpPad.XJumpPad'
      CollisionRadius=48.000000
      CollisionHeight=8.000000
}
