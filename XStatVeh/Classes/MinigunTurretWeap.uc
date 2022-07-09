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
	if (OwnerVehicle != None)
		ChangeColor();
	PlaySound(Sound'CybTransformSnd',,12.0,,1200.0);
	PlayAnim('Transform', 5.0);
	Sleep(0.1);
	FinishAnim();
}

simulated function Tick(float delta)
{
	local bool bInside;
	Super.Tick(delta);
	if (OwnerVehicle != None && CurrentTeamColor != OwnerVehicle.CurrentTeam)
		ChangeColor();
	if (Level.NetMode != NM_DedicatedServer)
	{
		bInside = WeaponController != None && (bNetOwner || Level.NetMode == NM_Standalone);		if (bInside != (MultiSkins[2] == Texture'FlakAmmoLED'))		{			if (bInside)				MultiSkins[2] = Texture'FlakAmmoLED';			else				MultiSkins[2] = Core;		}
	}
}

simulated function ChangeColor()
{
	local Texture Laser;
	CurrentTeamColor = OwnerVehicle.CurrentTeam;
	switch (CurrentTeamColor)
	{
		case 1: 
			Core = Texture'CybotCoreBlue'; 
			Laser = Texture'SentinelLaserFXBlue';
			Beam = Texture'CybProjCorBlue';
			break;
		case 2: 
			Core = Texture'CybotCoreGreen'; 
			Laser = Texture'SentinelLaserFXGreen'; 
			Beam = Texture'CybProjCorGreen';
			break;
		case 3: 
			Core = Texture'CybotCoreYellow'; 
			Laser = Texture'SentinelLaserFXYellow'; 
			Beam = Texture'CybProjCorYellow';
			break;
		case 0: 
		default: 
			Core = Texture'CybotCoreRed'; 
			Laser = Texture'SentinelLaserFXRed'; 
			Beam = Texture'CybProjCorRed';
			break;
	}
	MultiSkins[2] = Core;
	if (PitchPart != None)
	{
		PitchPart.MultiSkins[LaserTexture] = Laser;
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
      HitMark=Class'Botpack.UT_LightWallHitEffect'
      AnimSequence="Still"
      Texture=Texture'XStatVeh.Skins.CybotMetal'
      Mesh=LodMesh'XStatVeh.CybSentinelTurret'
      DrawScale=5.000000
      MultiSkins(1)=Texture'XStatVeh.Skins.CybotSk'
      MultiSkins(2)=Texture'XStatVeh.Skins.CybotCoreRed'
      CollisionRadius=70.000000
      CollisionHeight=45.000000
}
