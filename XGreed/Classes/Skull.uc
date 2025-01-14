//=============================================================================
// Skull.
//=============================================================================
class Skull expands TournamentPickup;

/*
#forceexec MESH  MODELIMPORT MESH=Skull MODELFILE=Z:\XV\greed\Skull_118.psk LODSTYLE=10
#forceexec MESH ORIGIN MESH=Skull X=0 Y=-3 Z=4 YAW=-64 PITCH=0 ROLL=-11
#forceexec MESH  LODPARAMS MESH=Skull STRENGTH=0
#forceexec MESHMAP   SCALE MESHMAP=Skull X=0.82 Y=0.82 Z=0.82
#forceexec MESHMAP SETTEXTURE MESHMAP=Skull NUM=0 TEXTURE=Greenshield
// */

var int Amount;
var float Scale;
var(Collision) float SkullCollisionHeight, SkullCollisionRadius;
var bool bNoInventoryZone;

const AmountRed = 20;
const AmountGold = 5;
const AmountGreen = 1;

replication
{
	reliable if (Role == ROLE_Authority)
		Amount;
}

event float BotDesireability(pawn Bot)
{
	const NearZero = 0.00000001; // for prevent SmartStockBots clear MoveTarget on Fallback
	if (!Bot.bIsPlayer || Bot.PlayerReplicationInfo == None || Bot(Bot) == None || bHidden)
		return -1;
	if (Lifespan != 0 && Lifespan < 0.5 + VSize(Location - Bot.Location)/Bot.GroundSpeed)
		return NearZero;
	// always want pickup, more Amount - more want
	return MaxDesireability*Amount + 1000;
}

function bool HandlePickupQuery( Inventory Item )
{
	if (class == Item.class)
	{
		if (Item.PickupMessageClass == None)
			Pawn(Owner).ClientMessage(Item.PickupMessage, 'Pickup');
		else
			Pawn(Owner).ReceiveLocalizedMessage(Item.PickupMessageClass, 0, None, None, Item.Class);
		Item.PlaySound(Item.PickupSound, , 2.0);
		Amount += GiveBonuses(Amount, Skull(Item).Amount);
		Greed(Level.Game).SetSkulls(Pawn(Owner), self);
		Item.Destroy();
		return true;				
	}
	if (Inventory == None)
		return false;
	return Inventory.HandlePickupQuery(Item);
}

function int GiveBonuses(int Before, int Add)
{
	local ThighPads TP;
	local UDamage Amp;
	local float RespawnTimeOld;

	if (Before/(2*AmountGold) != (Before + Add)/(2*AmountGold))
	{
		Amp = UDamage(Pawn(Owner).FindInventoryType(Class'UDamage'));
		if (Amp != None)
		{
			Amp.Charge += Class'UDamage'.default.Charge;
			Amp.BeginState(); // restart counter
		}
		else
		{
			RespawnTimeOld = Class'UDamage'.default.RespawnTime;
			Class'UDamage'.default.RespawnTime = 0.0;
			Amp = Pawn(Owner).Spawn(Class'UDamage');
			Class'UDamage'.default.RespawnTime = RespawnTimeOld;
			if (Amp != None)
			{
				Amp.RespawnTime = 0.0;
				Amp.GiveTo(Pawn(Owner));
				Amp.Activate();
			}
		}
		if (Amp != None)
			Amp.PlaySound(Amp.PickupSound, , 2.0);
	}
	else if (Before/AmountGold != (Before + Add)/AmountGold)	
	{
		TP = ThighPads(Pawn(Owner).FindInventoryType(Class'ThighPads'));
		if (TP != None)
			TP.Charge = Class'ThighPads'.default.Charge;
		else
		{ // In case if it immediately oickup on respawn
			RespawnTimeOld = Class'ThighPads'.default.RespawnTime;
			Class'ThighPads'.default.RespawnTime = 0.0;
			TP = Pawn(Owner).Spawn(Class'ThighPads');
			Class'ThighPads'.default.RespawnTime = RespawnTimeOld;
			if (TP != None)
			{
				TP.RespawnTime = 0.0;
				TP.GiveTo(Pawn(Owner));
			}
		}
		if (TP != None)
			TP.PlaySound(TP.PickupSound, , 2.0);
	}
	return Add;
}

function Tick(float Delta)
{
	Super.Tick(Delta);
	
	if (LifeSpan != 0.0 && LifeSpan < 2.0)
		DrawScale = default.DrawScale*FMax(0.001, LifeSpan/2.0);

	if (bNoInventoryZone)
		TeleportSomewhere(false);
}

event FellOutOfWorld()
{
	TeleportSomewhere(false);
	if (Region.ZoneNumber == 0)
		Super.FellOutOfWorld();
}

function TeleportSomewhere(bool bRecreate)
{
	local Actor A;
	local Class<Actor> Cls;
	local int i;
	local Skull Other;
	
	bNoInventoryZone = false;
	Cls = class'PathNode';
	foreach AllActors(Cls, A)
		if (A.Region.Zone != None && !IsBadZone(A.Region.Zone, A.Region.ZoneNumber))
			i++;
	if (i == 0)		
	{
		Cls = class'InventorySpot';
		foreach AllActors(Cls, A)
			if (A.Region.Zone != None && !IsBadZone(A.Region.Zone, A.Region.ZoneNumber))
				i++;
		if (i == 0)		
		{
			Cls = class'Inventory';
			foreach AllActors(Cls, A)
				if (A.Region.Zone != None && !IsBadZone(A.Region.Zone, A.Region.ZoneNumber))
					i++;
			if (i == 0)		
			{
				Cls = class'NavigationPoint';
				foreach AllActors(Cls, A)
					if (A.Region.Zone != None && !IsBadZone(A.Region.Zone, A.Region.ZoneNumber))
						i++;
			}
		}
	}
	if (i == 0)
		return;
	i = rand(i);
	foreach AllActors(Cls, A)
		if (A.Region.Zone != None && !IsBadZone(A.Region.Zone, A.Region.ZoneNumber) && i-- == 0)
			break;
	if (A == None)
		return;
	Velocity = 40*VRand();
	if (bRecreate)
	{
		Other = SpawnSkull(A);
		if (Other != None)
		{
			Other.Amount = Amount;
			Amount = 0;
			Other = Other.Drop(A, Velocity);
		}
	}
	else if (SetLocation(A.Location))
		UpdateLook(); // Reset LifeSpan, since zone can alter it.
}

function BecomePickup()
{
	Super.BecomePickup();
	UpdateLook();
}

function BecomeItem()
{
	Super.BecomeItem();
	UpdateLook(true);
}

function PickupFunction(Pawn Other)
{
	Super.PickupFunction(Other);
	Greed(Level.Game).SetSkulls(Pawn(Owner), self);
	GiveBonuses(0, Amount);
}

event HitWall(vector HitNormal, actor Wall)
{
	local float Speed;
	Super.HitWall(HitNormal, Wall);

	// check to make sure we didn't hit a pawn
	if (Pawn(Wall) == none)
	{
		Velocity = 0.6*(( Velocity dot HitNormal ) * HitNormal * -2.0 + Velocity);   // Reflect off Wall w/damping
		Speed = VSize(Velocity);

		if (Velocity.Z > 400)
		{
			Velocity.Z = 0.5 * (400 + Velocity.Z);
		}

		// Only play the bounce sound if the skull is moving fast
		if (Speed > 40.0)
		{
			PlaySound(Sound'SkullImpact');
		}
		// If the skull is moving slowly, clear the trail effect
		else 
		{
			bBounce = false;
			Landed(HitNormal);
			SetCollisionSize(default.SkullCollisionRadius*(Scale + 1), default.SkullCollisionHeight*Scale); // Make bigger for easy pickup
		}
	}
}

simulated event Landed(vector HitNormal)
{
	local rotator newRot;
	Super.Landed(HitNormal);

	newRot.Yaw = Rotation.Yaw;
	SetRotation(newRot);
	if (Role == ROLE_Authority)
		bSimFall = false;
}

static function bool IsBadZone(ZoneInfo NewZone, byte ZoneNumber)
{
	return ZoneNumber == 0 || NewZone.bNoInventory || NewZone.bKillZone || 
		(NewZone.bPainZone && NewZone.DamagePerSec >= 20) || 
		NewZone.IsA('VacuumZone') || NewZone.IsA('CloudZone');
}

simulated function MyZoneChange(ZoneInfo NewZone)
{
	if (NewZone.bWaterZone)
		Velocity *= 0.25;
	
	if (Role == ROLE_Authority && Amount > 0 && IsBadZone(NewZone, 1))
	{
		bNoInventoryZone = true;
		Enable('Tick');		
	}
}

simulated event ZoneChange(ZoneInfo NewZone)
{
	MyZoneChange(NewZone);
	Super.ZoneChange(NewZone);
}

auto state Pickup
{
	singular function ZoneChange( ZoneInfo NewZone )
	{
		MyZoneChange(NewZone);
		Super.ZoneChange(NewZone);
	}
	
	function Landed(Vector HitNormal)
	{
		Global.Landed(HitNormal);
		Super.Landed(HitNormal);
	}
}

function UpdateLook(optional bool bReset)
{
	if (bReset)
	{
		DrawScale = default.DrawScale;
		PrePivot = default.PrePivot;
		LifeSpan = 0;
		SetCollisionSize(default.SkullCollisionRadius, default.SkullCollisionHeight);
		return;
	}	
	if (Amount >= AmountRed)
	{
		Scale = 2.5;
		Texture = Texture'RedShield';
		LifeSpan = 240;
	}
	else if (Amount >= AmountGold)
	{
		Scale = 1.5;
		Texture = Texture'N_Shield';
		LifeSpan = 120;
	}
	else
	{
		Scale = 1;
		Texture = Texture'Greenshield';
		LifeSpan = 45;
	}
	DrawScale = default.DrawScale*Scale;
	PrePivot = default.PrePivot*Scale;
	SetCollisionSize(FMin(Class'TournamentPlayer'.default.CollisionRadius, default.SkullCollisionRadius*Scale), 
		FMin(Class'TournamentPlayer'.default.CollisionHeight, default.SkullCollisionHeight*Scale));
}

// Special spawn, which ensure skull spawn in most possible cases, for not lost them.
static function Skull SpawnSkull(Actor OldHolder)
{
	local Skull Other;
	// First try not fell out from the world.
	default.bCollideWorld = true;
	Other = OldHolder.Spawn(Class'Skull');
	default.bCollideWorld = false;
	if (Other == None) // If fail - try without collision with world.
		Other = OldHolder.Spawn(Class'Skull');
	if (Other != None)
	{
		Other.SetCollisionSize(default.SkullCollisionHeight, default.SkullCollisionHeight);
		Other.SetCollision(true);
		if (IsBadZone(Other.Region.Zone, Other.Region.ZoneNumber))
		{
			Other.bNoInventoryZone = true;
			Other.Enable('Tick');
		}
	}
	return Other;
}

function Skull Drop(actor OldHolder, vector newVel)
{
	local Skull Other, Ret;
	local rotator R;
	while (Amount > AmountGreen && 
		Amount != AmountRed && 
		Amount != AmountGold)
	{
		Other = SpawnSkull(OldHolder);
		if (Other == None)
			break;
		if (Amount > AmountRed)
			Other.Amount = AmountRed;
		else if (Amount > AmountGold)
			Other.Amount = AmountGold;
		else if (Amount > AmountGreen)
			Other.Amount = AmountGreen;
		else
		{
			Other.Destroy();
			break;
		}
		Amount -= Other.Amount;
		Other = Other.Drop(OldHolder, newVel);
		if (Ret == None)
			Ret = Other; // use biggest one		
	}

	if (Amount <= 0 || bDeleteMe)
	{
		Destroy();
		return Ret;
	}
	
	UpdateLook();

	Velocity = (0.2 + FRand()) * (newVel + 400 * FRand() * VRand());
	If (Region.Zone.bWaterZone)
		Velocity *= 0.5;
	bCollideWorld = true;
	SetCollisionSize(default.SkullCollisionRadius, default.SkullCollisionHeight);
	if (bDeleteMe)
		return Ret;
 	if (!SetLocation(OldHolder.Location + (OldHolder.CollisionHeight - CollisionHeight)*vect(0, 0, 1)) 
		&& !SetLocation(OldHolder.Location) && Location != OldHolder.Location)
	{ // can't make skull, so Destroy it.
		Destroy();
		return Ret;
	}
	if (bDeleteMe)
		return Ret;

	bSimFall = true;
	SimAnim.X = 0;
	SimAnim.Y = 0;
	SimAnim.Z = 0;
	SimAnim.W = 0;
	SetPhysics(PHYS_Falling);
	SetBase(None);
	SetCollision(true, false, false);
	if (bDeleteMe)
		return Ret;
	bBounce = true;
	DropFrom(Location);
	R.Yaw = Rotation.Yaw;
	SetRotation(R);
	if (Ret == None)
		Ret = self;
	return Ret;
}

simulated event Destroyed()
{
	local Pawn P, POwner;
	local Skull Skull;
	if (Role == ROLE_Authority && Amount > 0)
	{
		POwner = Pawn(Owner);
		if (POwner != None && POwner.Base == None)
		{
			for (P = Level.PawnList; P != None; P = P.nextPawn)
				if (P == POwner)
					break;
			if (P == None)
			{
				Skull = SpawnSkull(POwner);
				if (Skull != None)
				{
					Skull.Amount = Amount;
					Skull.Drop(POwner, 0.5*POwner.Velocity);
				}
			}
		}
		if (Owner == None && bNoInventoryZone)
			TeleportSomewhere(true);
	}
	Super.Destroyed();
}

defaultproperties
{
	Scale=1.000000
	SkullCollisionHeight=15.000000
	SkullCollisionRadius=15.000000
	PickupMessage="You pickup a Skull"
	PickupViewMesh=SkeletalMesh'Skull'
	PickupViewScale=0.750000
	MaxDesireability=9999999562023526247432192.000000
	PickupSound=Sound'SkullPickup'
	Texture=FireTexture'UnrealShare.Belt_fx.ShieldBelt.Greenshield'
	Mesh=SkeletalMesh'Skull'
	DrawScale=0.750000
	bMeshEnviroMap=True
	bGameRelevant=True
	CollisionRadius=0.000000
	CollisionHeight=0.000000
	bCollideActors=False
	bFixedRotationDir=False
	RotationRate=(Yaw=0)
}
