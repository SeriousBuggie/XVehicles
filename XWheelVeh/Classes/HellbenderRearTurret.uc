//=============================================================================
// HellbenderRearTurret.
//=============================================================================
class HellbenderRearTurret expands xWheelVehWeapon;

var float StartHoldTime, ClientStartHoldTime;
var float MaxHoldTime; //wait this long between shots for full damage
var float DamageScale, MinDamageScale;
var float FireSoundPitch;
var bool bHoldingFire;
var sound ChargingSound, ChargedLoop;

var() Class<Actor> TraceActor;

var byte CurrentTeamColor;
var Texture Beam;

var HellbenderChargeFX ChargeFX[2];

const MaxZoomInRate = 10.8; // Hardcoded in PlayerPawn as (90.0 - 88.0*0.9)

replication
{
	reliable if (Role == ROLE_Authority)
		StartHoldTime;
}

function FireTurret(byte Mode, optional bool bForceFire)
{
	if (Bot(WeaponController) != None)
	{
		if (bHoldingFire && !bFireRestrict)
			EndFireTurret();
		if (!bHoldingFire)
			StsrtFireTurret();
		return;
	}
	if (bAltFireZooms && Mode == 1 && PlayerPawn(WeaponController) != None)
		return;
	StsrtFireTurret();
}

function StsrtFireTurret()
{
	local int i;
	if (!bHoldingFire)
	{
		bHoldingFire = true;
		StartHoldTime = Level.TimeSeconds;
		AmbientSound = ChargingSound;
		
		if (PitchPart != None)
			for (i = 0; i < 2; i++)
			{
				if (ChargeFX[i] == None)
					ChargeFX[i] = PitchPart.Spawn(class'HellbenderChargeFX', PitchPart);
				if (ChargeFX[i] != None)
				{
					ChargeFX[i].PrePivotRel = WeapSettings[i].FireStartOffset;
					ChargeFX[i].LifeSpan = ChargeFX[i].default.LifeSpan;
				}
			}
	}
}

function MakeFireFX(byte Mode)
{
	PlaySound(WeapSettings[Mode].FireSound, SLOT_Misc, 
		WeapSettings[Mode].FireSndVolume, , 
		WeapSettings[Mode].FireSndRange*62.5, FireSoundPitch);
}

function EndFireTurret()
{
	local int i;
	AmbientSound = None;
	
	DamageScale = FClamp((Level.TimeSeconds - StartHoldTime) / MaxHoldTime, MinDamageScale, 1.0);
	WeapSettings[0].hitdamage = default.WeapSettings[0].hitdamage * DamageScale;
	WeapSettings[0].HitMomentum = default.WeapSettings[0].HitMomentum * DamageScale;
	FireSoundPitch = 2.0 - DamageScale;
	
	Super.FireTurret(0);
	bHoldingFire = false;
	StartHoldTime = 0;
	
	for (i = 0; i < 2; i++)
		if (ChargeFX[i] != None)
		{
			ChargeFX[i].Destroy();
			ChargeFX[i] = None;
		}
}

simulated function Tick(float delta)
{
	Super.Tick(delta);
	if (OwnerVehicle != None && (Beam == None || CurrentTeamColor != OwnerVehicle.CurrentTeam))
		ChangeColor();

	if (Role == ROLE_Authority)
	{
		if (!bHoldingFire && Bot(WeaponController) != None) // AI
			StsrtFireTurret();
		
		if (bHoldingFire && AmbientSound == ChargingSound && 
			Level.TimeSeconds - StartHoldTime >= MaxHoldTime)
			AmbientSound = ChargedLoop;
		if ((!bHoldingFire && AmbientSound != None) || 
			(bHoldingFire && (WeaponController == None || WeaponController.bFire == 0) &&
			Bot(WeaponController) == None))
			EndFireTurret();
	}
}

simulated function ChangeColor()
{
	CurrentTeamColor = OwnerVehicle.CurrentTeam;
	switch (CurrentTeamColor)
	{
		case 1:
			Beam = Texture'XVehicles.Coronas.CybProjCorBlue';
			break;
		case 2:
			Beam = Texture'XVehicles.Coronas.CybProjCorGreen';
			break;
		case 3:
			Beam = Texture'XVehicles.Coronas.CybProjCorYellow';
			break;
		case 0: 
		default:
			Beam = Texture'XVehicles.Coronas.CybProjCorRed';
			break;
	}
}

function SpawnTraceEffects(vector Dir)
{
	local vector ROffset, Start;
	local Actor Tracer;

	if (PitchPart != None)
	{
		ROffset = WeapSettings[0].FireStartOffset;
		
		Tracer = Spawn(TraceActor, self, , PitchPart.Location + (ROffset >> PitchPart.Rotation), rotator(Dir));
		if (Tracer != None)
			Tracer.Texture = Beam;
			
		ROffset = WeapSettings[1].FireStartOffset;
				
		Start = ROffset >> PitchPart.Rotation;
		Tracer = Spawn(TraceActor, self, , PitchPart.Location + Start, rotator(Dir*80000 - Start));
		if (Tracer != None)
			Tracer.Texture = Beam;
	}
}

simulated function WRenderOverlay(Canvas C)
{
	Super.WRenderOverlay(C);
	
	if (StartHoldTime == 0)
	{
		ClientStartHoldTime = 0;
		return;
	}
	if (StartHoldTime > 0 && ClientStartHoldTime == 0)
		ClientStartHoldTime = Level.TimeSeconds;

	DrawChargeBar(C, C.ClipX/2, C.ClipY/2 + 24, 64, 6);
}

simulated function DrawChargeBar(Canvas C, int X, int Y, float Width, float Height)
{
	local float Pct;
	
	Pct = Fmin(1.0, (Level.TimeSeconds - ClientStartHoldTime)/MaxHoldTime);
	if (Pct <= 0 || (Pct == 1.0 && (int(Level.TimeSeconds*4) & 1) == 0))
		return;

	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 64;
	
	C.Style = ERenderStyle.STY_Normal;
	C.SetPos(X + (0.5 - Pct)*Width, Y);
	C.DrawTile(Texture'Misc', Width*Pct, Height, 60, 60, 64, 64);
}

defaultproperties
{
	MaxHoldTime=2.500000
	MinDamageScale=0.150000
	ChargingSound=Sound'XWheelVeh.Hellbender.PRVChargeUp'
	ChargedLoop=Sound'XWheelVeh.Hellbender.PRVChargeLoop'
	TraceActor=Class'HellbenderBeam'
	RotatingSpeed=22000.000000
	PitchRange=(Max=16400,Min=-6000)
	bAltFireZooms=True
	TurretPitchActor=Class'HellbenderRearGun'
	PitchActorOffset=(X=12.000000,Z=55.500000)
	WeapSettings(0)=(FireStartOffset=(X=53.500000,Y=7.000000,Z=20.500000),RefireRate=0.750000,FireSound=Sound'XWheelVeh.Hellbender.PRVFire04',bInstantHit=True,hitdamage=200,HitType="Energy",HitError=0.000000,HitMomentum=150000.000000)
	WeapSettings(1)=(ProjectileClass=Class'JSDXLPlasma',FireStartOffset=(X=53.500000,Y=-8.000000,Z=20.500000),RefireRate=0.675000,FireSound=Sound'XWheelVeh.Fire.JSDXLDualFire',DualMode=2,HitError=0.000000)
	bLimitPitchByCarTop=True
	CarTopRange=0.500000
	CarTopAllowedPitch=(Max=16400,Min=-2000)
	bPhysicalGunAimOnly=True
	Mesh=SkeletalMesh'HellbenderRearTurret'
	SoundRadius=150
	SoundVolume=255
	CollisionRadius=18.000000
	CollisionHeight=4.000000
	NetPriority=3.000000
}
