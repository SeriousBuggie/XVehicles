class xZonePlayerObj expands Effects;

var int DistortRollPerSec;

var bool bReady;
var byte DistortionAmount;

var float TimeSec;

var ZoneInfo OldOwnerZone, NewOwnerZone;

function PostBeginPlay()
{
	SetTimer(0.1, True);
}

function Timer()
{
	if (!bReady && PlayerPawn(Owner) != None)
	{
		bReady = True;
		OldOwnerZone = PlayerPawn(Owner).HeadRegion.Zone;
		NewOwnerZone = PlayerPawn(Owner).HeadRegion.Zone;
	}
	else if (PlayerPawn(Owner) != None)
	{
		NewOwnerZone = PlayerPawn(Owner).HeadRegion.Zone;
		if (NewOwnerZone != OldOwnerZone)
			xZoneChange(NewOwnerZone);
	}
}

function xZoneChange( ZoneInfo NewZone )
{
	if (xZoneInfo(NewZone) != None)
	{
		AmbientSound = xZoneInfo(NewZone).ZoneAmbSound;
		SoundVolume = xZoneInfo(NewZone).ZoneAmbVolume;
		SoundPitch = xZoneInfo(NewZone).ZoneAmbPitch;
		DistortionAmount = xZoneInfo(NewZone).DistortionAmount;
		DistortRollPerSec = xZoneInfo(NewZone).DistortRollPerSec;
	}
	else
		ResetZoneObj();

	OldOwnerZone = NewZone;
}

function Tick(float Delta)
{
local rotator r;

	if (PlayerPawn(Owner) == None)
		return;

	if (Class'xZoneInfo'.default.hasDistortion && DistortionAmount > 0)
	{
		TimeSec += Delta;
		if (TimeSec >= 1.0)
			TimeSec = -1;
	}
	
	if (PlayerPawn(Owner).ViewTarget != None)
	{
		PrePivot = PlayerPawn(Owner).ViewTarget.Location - PlayerPawn(Owner).Location;

		if (Class'xZoneInfo'.default.hasDistortion && DistortionAmount > 0)
		{
			r = PlayerPawn(Owner).ViewTarget.Rotation;
			r.Roll = (DistortRollPerSec * DistortionAmount * Cos(TimeSec*PI));
			PlayerPawn(Owner).ViewTarget.SetRotation(r);
			PlayerPawn(Owner).SetFOVAngle(DistortionAmount*Cos(TimeSec*PI) + PlayerPawn(Owner).default.FOVAngle + (PlayerPawn(Owner).DesiredFOV - PlayerPawn(Owner).default.FOVAngle));
		}
	}
	else
	{
		if (Class'xZoneInfo'.default.hasDistortion && DistortionAmount > 0)
		{
			PlayerPawn(Owner).ViewRotation.Roll = (DistortRollPerSec * DistortionAmount * Cos(TimeSec*PI));
			PlayerPawn(Owner).SetFOVAngle(DistortionAmount*Cos(TimeSec*PI) + PlayerPawn(Owner).default.FOVAngle + (PlayerPawn(Owner).DesiredFOV - PlayerPawn(Owner).default.FOVAngle));
		}

		if (PrePivot != vect(0,0,0))
			PrePivot = vect(0,0,0);
	}
}

function ResetZoneObj()
{
local rotator r;

	AmbientSound = None;
	DistortionAmount = 0;

	if (PlayerPawn(Owner) != None)
	{
		if (PlayerPawn(Owner).ViewTarget != None)
		{
			r = PlayerPawn(Owner).ViewTarget.Rotation;
			r.Roll = 0;
			PlayerPawn(Owner).ViewTarget.SetRotation(r);
		}

		PlayerPawn(Owner).SetFOVAngle( PlayerPawn(Owner).Default.FOVAngle);
		PlayerPawn(Owner).ViewRotation.Roll = 0;
	}
}

function Destroyed()
{
	ResetZoneObj();
	Super.Destroyed();
}

defaultproperties
{
	bHidden=True
	bNetTemporary=False
	bTrailerPrePivot=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_SimulatedProxy
	SoundRadius=20
	SoundVolume=255
}
