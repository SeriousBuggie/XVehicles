//=============================================================================
// Skull.
//=============================================================================
class Skull expands TournamentPickup;

var int Amount;
var float Scale;
var(Collision) float SkullCollisionHeight, SkullCollisionRadius;

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

/** Slow down skulls that enter water */
simulated event ZoneChange(ZoneInfo NewZone)
{
	if (NewZone.bWaterZone)
	{
		Velocity *= 0.25;
	}

	Super.ZoneChange(NewZone);
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
function Skull SpawnSkull(pawn OldHolder)
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
	}
	return Other;
}

function Skull Drop(pawn OldHolder, vector newVel)
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

defaultproperties
{
	Scale=1.000000
	SkullCollisionHeight=15.000000
	SkullCollisionRadius=15.000000
	PickupMessage="You pickup a Skull"
	PickupViewMesh=Mesh'Relics.RelicSkull'
	PickupViewScale=0.750000
	MaxDesireability=9999999562023526247432192.000000
	PickupSound=Sound'SkullPickup'
	AnimSequence="Bob"
	AnimFrame=0.500000
	Texture=FireTexture'UnrealShare.Belt_fx.ShieldBelt.Greenshield'
	Mesh=Mesh'Relics.RelicSkull'
	DrawScale=0.750000
	PrePivot=(X=0.000000,Y=0.000000,Z=-2.000000)
	bMeshEnviroMap=True
	bGameRelevant=True
	CollisionRadius=0.000000
	CollisionHeight=0.000000
	bCollideActors=False
	bFixedRotationDir=False
	RotationRate=(Pitch=0,Yaw=0)
}
