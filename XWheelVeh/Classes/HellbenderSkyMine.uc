//=============================================================================
// SkyMine.
//=============================================================================
class HellbenderSkyMine expands ShockProj;

var bool bDoChainReaction;
var() float ChainReactionDelay, ComboRadius, ComboMomentum, ComboDamage;
var HellbenderSideTurret OwnerGun;
var Actor ComboTarget;       // for AI use

function SuperExplosion()
{
	HurtRadius(ComboDamage, ComboRadius, MyDamageType, ComboMomentum, Location);
	
	Spawn(Class'ut_ComboRing',,'',Location, Instigator.ViewRotation);
	PlaySound(ExploSound,,20.0,,2000,0.6);	

	if (bDoChainReaction)
	{
		SetPhysics(PHYS_None);
		SetCollision(false);
		bHidden = true;
		SetTimer(ChainReactionDelay, false);
	}
	else
		Destroy();
}

simulated function PostBeginPlay()
{
	local Vehicle VehicleOwner;
	local VehicleAttachment vat;
	Super.PostBeginPlay();

	VehicleOwner = Vehicle(Owner);
	if (VehicleOwner != None)
		for (vat = VehicleOwner.AttachmentList; vat != None; vat = vat.NextAttachment)
			if (HellbenderSideTurret(vat) != None)
			{
				OwnerGun = HellbenderSideTurret(vat);
				OwnerGun.AddProjectile(self);
				break;
			}
}

function ChainedSuperExplosion()
{
	bDoChainReaction = true;
	SuperExplosion();
}

function Timer()
{	
	if (OwnerGun != None)
		OwnerGun.ChainReaction(self);
	
	Destroy();
}

auto state Flying
{
	function ProcessTouch(Actor Other, vector HitLocation)
	{
		if (Other == Owner || (Other != None && Other.class == Class && Other.Owner == Owner) ||
			!Other.bCollideActors)
			return;
		Super.ProcessTouch(Other, HitLocation);
	}
	
	function BeginState()
	{
		if (VSize(Velocity) < 0.5*speed)
			Super.BeginState();
		if (ComboTarget != None)
			GotoState('WaitForCombo');
	}
}

function float GetDist()
{
	local Actor Vehicle;
	local float Dist;
	Vehicle = OwnerGun.GetVehicle(ComboTarget);
	Dist = ComboRadius;
	if (Vehicle.IsInState('EmptyVehicle') && VSize(Vehicle.Velocity) < 50)
		Dist *= 0.15;
	else
		Dist *= 0.5;
	return Dist + Vehicle.CollisionRadius;
}

State WaitForCombo extends Flying
{
	function Tick(float DeltaTime)
	{
		if (ComboTarget == None || ComboTarget.bDeleteMe || OwnerGun == None || 
			OwnerGun.WeaponController != Instigator)
		{
			ComboTarget = None;
			GotoState('Flying');
		}
		else if ((Velocity Dot (ComboTarget.Location - Location)) <= 0)
		{
			if (VSize(ComboTarget.Location - Location) <= ComboRadius + 
				OwnerGun.GetVehicle(ComboTarget).CollisionRadius)
			{
				if (!OwnerGun.DoCombo(self))
					return;
			}
			ComboTarget = None;
			GotoState('Flying');
		}
		else if ((VSize(ComboTarget.Location - Location) <= GetDist()) &&
			OwnerGun.DoCombo(self))
		{
			ComboTarget = None;
			GotoState('Flying');
		}
	}
}

defaultproperties
{
	ChainReactionDelay=0.250000
	ComboRadius=525.000000
	ComboMomentum=150000.000000
	ComboDamage=200.000000
	speed=950.000000
	MaxSpeed=950.000000
	Damage=25.000000
	MomentumTransfer=25000
	DrawScale=0.600000
	CollisionRadius=20.000000
	CollisionHeight=20.000000
}
