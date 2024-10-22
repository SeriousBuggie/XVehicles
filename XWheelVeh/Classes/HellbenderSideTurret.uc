//=============================================================================
// HellbenderSideTurret.
//=============================================================================
class HellbenderSideTurret expands xWheelVehWeapon;

var() Class<Actor> TraceActor;
var Actor LastTracer;

var byte CurrentTeamColor;
var Texture Beam;

var Projectile Projectiles[1024];
var int ProjectilesCount;

var() float MaxChainReactionDist;

var() float MinAim;

var bool bAdjustAim;
var rotator AdjustedAim;

function FireTurret(byte Mode, optional bool bForceFire)
{
	local float CurAim, BestAim;
	local int i;
	local Projectile BestMine;
	local rotator OldRot;	
	local Bot B;
	local HellbenderSkyMine NearMine;
	
	B = Bot(WeaponController);
	
	bAdjustAim = false;
	if (B != None)
	{
		if (HellbenderSkyMine(B.Target) != None)
		{
			Mode = 1;
			bAdjustAim = true;
			AdjustedAim = rotator(B.Target.Location - PitchPart.Location);
		}
		else
		{
			if (B.Target != None)
			{
				foreach B.Target.VisibleCollidingActors(Class'HellbenderSkyMine', NearMine, 
					Class'HellbenderSkyMine'.default.ComboRadius)
				{
					if (NearMine.OwnerGun == self && NearMine.ComboTarget == B.Target)
						continue;
					CurAim = VSize(B.Target.Location - NearMine.Location);
					if ((BestMine == None || BestAim < CurAim) && 
						Normal(NearMine.Location - PitchPart.Location) dot vector(PitchPart.Rotation) >= MinAim &&
						OwnerVehicle.FastTrace(NearMine.Location, PitchPart.Location))
					{
						BestMine = NearMine;
						BestAim = CurAim;
					}
				}
				
				if (BestMine == None && Pawn(B.Target) != None) // Destroy enemy SkyMines
					foreach B.Target.VisibleCollidingActors(Class'HellbenderSkyMine', NearMine, 
						Class'HellbenderSkyMine'.default.ComboRadius*4,
						(B.Target.Location - Location)/2)
					{
						if (NearMine.Instigator != B.Target)
							continue;
						CurAim = VSize(B.Target.Location - NearMine.Location);
						if ((BestMine == None || BestAim < CurAim) && 
							Normal(NearMine.Location - PitchPart.Location) dot vector(PitchPart.Rotation) >= MinAim &&
							OwnerVehicle.FastTrace(NearMine.Location, PitchPart.Location))
						{
							BestMine = NearMine;
							BestAim = CurAim;
						}
					}
			}
			if (BestMine != None)
			{
				Mode = 1;
				bAdjustAim = true;
				AdjustedAim = rotator(BestMine.Location - PitchPart.Location);
			}
			else if (Pawn(B.Target) != None && OwnerVehicle.FastTrace(B.Target.Location, PitchPart.Location))
			{
				CurAim = VSize(B.Target.Location - Location);
				if (DriverWeapon(Pawn(B.Target).Weapon) != None)
					Mode = int(CurAim >= 5000 || FRand() < 0.4);
				else
				{
					BestAim = Normal(B.Target.Velocity) dot Normal(B.Target.Location - Location);
					if (BestAim > 0.7)
						Mode = int(CurAim >= 2000);
					else if (BestAim > -0.7)
						Mode = int(CurAim >= 4000);
					else
						Mode = int(CurAim >= 6000);
				}
			}
			else
				Mode = 0;
		}
	}
	if (B == None && Mode == 1 && PitchPart != None && !bAdjustAim)
	{
		OldRot = PitchPart.Rotation;
		//aiming help for hitting skymines
		BestAim = MinAim;
		for (i = ProjectilesCount - 1; i >= 0; i--)
		{
			if (Projectiles[i] == None)
				continue;
			if (Projectiles[i].bDeleteMe || Projectiles[i].bHidden)
			{
				Projectiles[i] = None;
				continue;
			}
			CurAim = Normal(Projectiles[i].Location - PitchPart.Location) dot vector(PitchPart.Rotation);
			if (CurAim > BestAim)
			{
				BestMine = Projectiles[i];
				BestAim = CurAim;
			}
		}
		for (i = ProjectilesCount - 1; i >= 0 && Projectiles[i] == None; i--)
			ProjectilesCount--;
		if (BestMine != None)
		{
			bAdjustAim = true;
			AdjustedAim = rotator(BestMine.Location - PitchPart.Location);
		}
	}

	Super.FireTurret(Mode, bForceFire);
	
	bAdjustAim = false;
}

simulated function GetTurretCoords( optional out vector Pos, optional out rotator TurRot, optional out rotator PitchPartRot )
{
	Super.GetTurretCoords(Pos, TurRot, PitchPartRot);
	if (bAdjustAim)
		PitchPartRot = AdjustedAim;
}

function bool CanDoCombo(HellbenderSkyMine ComboTarget)
{
	local vector HL, HN;
	return OwnerVehicle.FastTrace(PitchPart.Location, ComboTarget.Location) &&
		HellbenderSkyMine(OwnerVehicle.Trace(HL, HN, ComboTarget.Location, PitchPart.Location, true)) != None;
}

function bool DoCombo(HellbenderSkyMine ComboTarget)
{
	local Bot B;
	B = Bot(WeaponController);
	if (B != None && ComboTarget != None && OwnerVehicle != None && PitchPart != None && CanDoCombo(ComboTarget))
	{
		RangedAttack(B, ComboTarget, WeapSettings[1].RefireRate + 0.1);
		return true;
	}
	return false;
}

function AddProjectile(Projectile Projectile)
{
	local int i;	
	local Bot B;
	local HellbenderSkyMine SkyMine;
	B = Bot(WeaponController);
	if (B != None)
	{
		SkyMine = HellbenderSkyMine(Projectile);
		if (SkyMine != None)
		{
			if (B.Enemy != None)
				SkyMine.ComboTarget = B.Enemy;
			else if (B.Target != None)
				SkyMine.ComboTarget = B.Target;
		}
	}
	
	for (i = 0; i < ProjectilesCount; i++)
		if (Projectiles[i] == None || Projectiles[i].bDeleteMe || Projectiles[i].bHidden)
			break;
	if (i >= ArrayCount(Projectiles))
		return;
	Projectiles[i] = Projectile;
	if (i == ProjectilesCount)
		ProjectilesCount++;
}

function ChainReaction(Projectile Source)
{
	local float BestDist, Dist;
	local int i;
	local Actor Tracer;
	local Projectile ChainTarget;
	
	BestDist = MaxChainReactionDist;
	for (i = ProjectilesCount - 1; i >= 0; i--)
	{
		if (Projectiles[i] == None)
			continue;
		if (Projectiles[i] == self || Projectiles[i].bDeleteMe || Projectiles[i].bHidden)
		{
			Projectiles[i] = None;
			continue;
		}
		Dist = VSize(Source.Location - Projectiles[i].Location);
		if (Dist < BestDist)
		{
			ChainTarget = Projectiles[i];
			BestDist = Dist;
		}
	}
	for (i = ProjectilesCount - 1; i >= 0 && Projectiles[i] == None; i--)
		ProjectilesCount--;
	
	if (HellbenderSkyMine(ChainTarget) != None)
	{
		Tracer = Source.Spawn(TraceActor, self,, Source.Location, rotator(ChainTarget.Location - Source.Location));
		if (Tracer != None)
		{
			Tracer.Texture = Beam;
			if (HellbenderBeam(Tracer) != None)
				HellbenderBeam(Tracer).Destination = ChainTarget.Location;
		}
		HellbenderSkyMine(ChainTarget).ChainedSuperExplosion();
	}
}

function TraceProcess(actor A, vector HitLocation, vector HitNormal, byte Mode)
{
	if (HellbenderBeam(LastTracer) != None)
	{
		HellbenderBeam(LastTracer).Destination = HitLocation;
		LastTracer = None;
	}
	if (HellbenderSkyMine(A) != None)
	{
		HellbenderSkyMine(A).ChainedSuperExplosion();
		return;
	}
	if (ShockProj(A) != None)
	{
		ShockProj(A).SuperExplosion();
		return;
	}
	Super.TraceProcess(A, HitLocation, HitNormal, Mode);
}

simulated function Tick(float delta)
{
	Super.Tick(delta);
	if (OwnerVehicle != None && (Beam == None || CurrentTeamColor != OwnerVehicle.CurrentTeam))
		ChangeColor();
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
	local vector ROffset;
	local Actor Tracer;

	if (PitchPart != None)
	{
		ROffset = WeapSettings[1].FireStartOffset;
		
		Tracer = Spawn(TraceActor, self, , PitchPart.Location + (ROffset >> PitchPart.Rotation), rotator(Dir));
		if (Tracer != None)
		{
			Tracer.Texture = Beam;
			LastTracer = Tracer;
		}
	}
}

defaultproperties
{
	TraceActor=Class'HellbenderBeam'
	MaxChainReactionDist=2500.000000
	MinAim=0.925000
	RotatingSpeed=22000.000000
	PitchRange=(Max=8400,Min=-2000)
	TurretPitchActor=Class'HellbenderSideGun'
	PitchActorOffset=(X=3.600000,Y=0.000000,Z=0.920000)
	WeapSettings(0)=(ProjectileClass=Class'HellbenderSkyMine',FireStartOffset=(X=30.000000,Y=-2.000000,Z=1.500000),RefireRate=0.400000,FireSound=Sound'XWheelVeh.Hellbender.PRVFire01')
	WeapSettings(1)=(FireStartOffset=(X=30.000000,Y=-2.000000,Z=1.500000),RefireRate=0.750000,FireSound=Sound'XWheelVeh.Hellbender.PRVFire02',bInstantHit=True,hitdamage=25,HitType="ChainReaction",HitError=0.000000)
	CarTopRange=0.500000
	CarTopAllowedPitch=(Max=8400,Min=-2000)
	bPhysicalGunAimOnly=True
	Mesh=SkeletalMesh'HellbenderSideTurret'
	SoundRadius=150
	SoundVolume=255
	CollisionRadius=18.000000
	CollisionHeight=4.000000
	NetPriority=3.000000
}
