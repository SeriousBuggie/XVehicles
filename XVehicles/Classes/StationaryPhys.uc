// A stationary Turret. (Created by .:..: 11.1.2008)
Class StationaryPhys extends Vehicle;

const MaxZoomInRate = 10.8; // Hardcoded in PlayerPawn as (90.0 - 88.0*0.9)

simulated singular function HitWall( vector HitNormal, Actor Wall );
simulated function vector GetAccelDir( int InTurn, int InRise, int InAccel )
{
	return vect(0,0,0);
}
simulated function ReadDriverInput( PlayerPawn Other, float DeltaTime )
{
	if( Other.bWasForward )
	{
		if( Other.DesiredFOV > MaxZoomInRate )
		{
			Other.DesiredFOV -= DeltaTime*60;
			if( Other.DesiredFOV < MaxZoomInRate )
				Other.DesiredFOV = MaxZoomInRate;
		}
	}
	else if( Other.bWasBack )
	{
		if( Other.DesiredFOV < Other.DefaultFOV )
		{
			Other.DesiredFOV += DeltaTime*60;
			if( Other.DesiredFOV > Other.DefaultFOV )
				Other.DesiredFOV = Other.DefaultFOV;
		}
	}
}
simulated function UpdateDriverInput( float Delta );
simulated function ServerPerformMove( int InRise, int InTurn, int InAccel );

// Nothing here to constantly replicate.
simulated function ClientUpdateState( float Delta );
function ServerPackState( float Delta);

simulated function bool CheckOnGround()
{
	Return True;
}

// No inputs for bots!
function ReadBotInput( float Delta );
simulated function Bump( Actor Other );

defaultproperties
{
      Health=300
      bShouldRepVehYaw=False
      bStationaryTurret=True
      VehicleName="Stationary Turret"
      TranslatorDescription="This is a stationary turret. You can fire using [Fire] and [AltFire] and zoom in and out using movement keys. To leave this vehicle press [ThrowWeapon] key."
      VehicleKeyInfoStr="Turret keys:|%Fire% to fire, %AltFire% to alt fire|%ThrowWeapon% to exit the vehicle"
      Physics=PHYS_None
      Mesh=LodMesh'UnrealShare.WoodenBoxM'
}
