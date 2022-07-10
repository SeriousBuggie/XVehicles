//=============================================================================
// MinigunTurretWeap.
//=============================================================================
class MinigunTurretWeap expands xStatVehWeapon;

var() Class<Actor> TraceActor;

var byte CurrentTeamColor;
var byte LaserTexture;
var Texture Core, Beam;
var byte TracerCount, PuffSide;

auto state StartingUp
{
Begin:
	PlaySound(Sound'CybTransformSnd',,12.0,,1200.0);
	PlayAnim('Transform', 5.0);
	Sleep(0.1);
	FinishAnim();
}

simulated function Tick(float delta)
{
	local bool bInside;
	Super.Tick(delta);
	if (OwnerVehicle != None && (Core == None || CurrentTeamColor != OwnerVehicle.CurrentTeam))
		ChangeColor();
	if (Level.NetMode != NM_DedicatedServer)
	{
		bInside = PlayerPawn(WeaponController) != None && 
			(PlayerPawn(WeaponController).Player != None || Level.NetMode == NM_Standalone || 
			(OwnerVehicle != None && OwnerVehicle.VehicleState != None && OwnerVehicle.VehicleState.bHidden));		if (bInside != (MultiSkins[2] == Texture'FlakAmmoLED'))		{			if (bInside)				MultiSkins[2] = Texture'FlakAmmoLED';			else				MultiSkins[2] = Core;		}
	}
}

simulated function ChangeColor()
{
	local Texture Laser;
	CurrentTeamColor = OwnerVehicle.CurrentTeam;
	switch (CurrentTeamColor)
	{
		case 1: 
			Core = Texture'XVehicles.Skins.CybotCoreBlue'; 
			Laser = Texture'XVehicles.LaserFX.SentinelLaserFXBlue';
			Beam = Texture'XVehicles.Coronas.CybProjCorBlue';
			break;
		case 2: 
			Core = Texture'XVehicles.Skins.CybotCoreGreen'; 
			Laser = Texture'XVehicles.LaserFX.SentinelLaserFXGreen'; 
			Beam = Texture'XVehicles.Coronas.CybProjCorGreen';
			break;
		case 3: 
			Core = Texture'XVehicles.Skins.CybotCoreYellow'; 
			Laser = Texture'XVehicles.LaserFX.SentinelLaserFXYellow'; 
			Beam = Texture'XVehicles.Coronas.CybProjCorYellow';
			break;
		case 0: 
		default: 
			Core = Texture'XVehicles.Skins.CybotCoreRed'; 
			Laser = Texture'XVehicles.LaserFX.SentinelLaserFXRed'; 
			Beam = Texture'XVehicles.Coronas.CybProjCorRed';
			break;
	}
	MultiSkins[2] = Core;
	if (PitchPart != None)
	{
		PitchPart.MultiSkins[LaserTexture] = Core;
		PitchPart.MultiSkins[LaserTexture + 1] = Laser;
	}
}

function SpawnFireEffects(byte Mode)
{
	local name Anim;
	local vector ROffset;
	Super.SpawnFireEffects(Mode);
	
	if (PitchPart == None)
		return;
	if (WeapSettings[0].DualMode == 0)
		Anim = 'Fire';
	else if (bTurnFire)
		Anim = 'LeftFire';
	else
		Anim = 'RightFire';
	PitchPart.PlayAnim(Anim, 9.0);
	
	PuffSide = 1 - PuffSide;
	ROffset = WeapSettings[0].FireStartOffset;
	if (WeapSettings[0].DualMode == 1 && PuffSide != 0)
		ROffset.Y = -ROffset.Y;
	spawn(class'UT_SpriteSmokePuff',,,PitchPart.Location + (ROffset >> PitchPart.Rotation));
}

function SpawnTraceEffects(vector Dir)
{
	local vector ROffset;
	local bool bDual;
	local Actor Tracer;

	bDual = WeapSettings[0].DualMode != 0;
	if (PitchPart != None && (bDual || TracerCount > 1))
	{
		ROffset = WeapSettings[0].FireStartOffset;
		if (bTurnFire)
			ROffset.Y = -ROffset.Y;
		Tracer = Spawn(TraceActor,self,,PitchPart.Location + (ROffset >> PitchPart.Rotation), rotator(Dir));
		if (Tracer != None)
			Tracer.Texture = Beam;
		
		TracerCount = 0;
	}
	else
		TracerCount++;
}

simulated function rotator GetDriverInput( float Delta )
{
	local rotator Ret;
	local bool bOld;
	bOld = bAltFireZooms;
	bAltFireZooms = false;
	Ret = Super.GetDriverInput(Delta);
	bAltFireZooms = bOld;
	if( bAltFireZooms && NetConnection(PlayerPawn(WeaponController).Player)==None )
	{
		if( !bPressingAltZoom && WeaponController.bAltFire!=0 )
		{
			bPressingAltZoom = True;
			if (PlayerPawn(WeaponController).DesiredFOV != StationaryPhys(OwnerVehicle).MaxZoomInRate)
				PlayerPawn(WeaponController).DesiredFOV = StationaryPhys(OwnerVehicle).MaxZoomInRate;
			else
				PlayerPawn(WeaponController).DesiredFOV = PlayerPawn(WeaponController).DefaultFOV;
		}
		else if( bPressingAltZoom && WeaponController.bAltFire==0 )
		{
			bPressingAltZoom = False;
		}
	}
	RepAimPos = OwnerVehicle.CalcPlayerAimPos(PassengerNum);
	Return Ret;
}

defaultproperties
{
      TraceActor=Class'Botpack.MTracer'
      CurrentTeamColor=0
      LaserTexture=2
      Core=None
      beam=None
      TracerCount=0
      PuffSide=0
      RotatingSpeed=65000.000000
      PitchRange=(Max=17000,Min=-8500)
      bAltFireZooms=True
      TurretPitchActor=Class'XStatVeh.MinigunTurretGun'
      WeapSettings(0)=(FireStartOffset=(X=120.000000,Z=45.000000),RefireRate=0.150000,FireSound=Sound'XStatVeh.Attack.CybFire',bInstantHit=True,hitdamage=20,HitType="Ballistic",HitMomentum=10000.000000,HitHeavyness=2)
      bPhysicalGunAimOnly=True
      AnimSequence="Still"
      Texture=Texture'XStatVeh.Skins.CybotMetal'
      Mesh=LodMesh'XStatVeh.CybSentinelTurret'
      DrawScale=5.000000
      MultiSkins(1)=Texture'XVehicles.Skins.CybotSk'
      MultiSkins(2)=Texture'XVehicles.Skins.CybotCoreRed'
      CollisionRadius=70.000000
      CollisionHeight=45.000000
}
