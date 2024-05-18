//=============================================================================
// Skull.
//=============================================================================
class Skull expands TournamentPickup;

const AmountRed = 20;
const AmountYellow = 5;
const AmountGreen = 1;

event float BotDesireability(pawn Bot)
{
	if (!Bot.bIsPlayer || Bot.PlayerReplicationInfo == None || Bot(Bot) == None || 
		Bot(Bot).Orders == 'Defend') // Defenders not want collect it, since not goes for register
		return -1;
	// always want pickup, more charge - more want
	return MaxDesireability*Charge + 1000;
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
		Charge += GiveBonuses(Charge, Skull(Item).Charge);
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
	local int AmpCount;
	local ThighPads TP;
	local UDamage Amp;
	
	if (Add >= 10 || (Before % 10 < 5 && (Before + Add) % 10 >= 5))
	{
		TP = Pawn(Owner).Spawn(Class'ThighPads');
		TP.GiveTo(Pawn(Owner));
		TP.PlaySound(TP.PickupSound, , 2.0);
	}
	AmpCount = Add/10;
	if (Before % 10 > (Before + (Add % 10)) % 10)
		AmpCount++;
	if (AmpCount > 0)
	{
		Amp = UDamage(Pawn(Owner).FindInventoryType(Class'UDamage'));
		if (Amp != None)
		{
			Amp.Charge += AmpCount*Class'UDamage'.default.Charge;
			Amp.BeginState(); // restart counter
		}
		else
		{
			Amp = Pawn(Owner).Spawn(Class'UDamage');
			Amp.GiveTo(Pawn(Owner));
			Amp.Activate();
		}
		Amp.PlaySound(Amp.PickupSound, , 2.0);
	}
	return Add;
}

function BecomePickup()
{
	Super.BecomePickup();
	if (Charge >= AmountRed)
		LifeSpan = 240;
	else if (Charge >= AmountYellow)
		LifeSpan = 120;
	else
		LifeSpan = 45;
}

function BecomeItem()
{
	Super.BecomeItem();
	LifeSpan = 0;
	SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
}

function PickupFunction(Pawn Other)
{
	Super.PickupFunction(Other);
	Greed(Level.Game).SetSkulls(Pawn(Owner), self);
	GiveBonuses(0, Charge);
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
			SetCollisionSize(default.CollisionRadius*2, default.CollisionHeight); // Make bigger for easy pickup
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

function Drop(pawn OldHolder, vector newVel)
{
	local Skull Other;
	local rotator R;
	while (Charge > 0 && 
		Charge != AmountRed && 
		Charge != AmountYellow && 
		Charge != AmountGreen)
	{
		Other = OldHolder.Spawn(Class'Skull');
		if (Other == None)
			break;
		if (Charge > AmountRed)
			Other.Charge = AmountRed;
		else if (Charge > AmountYellow)
			Other.Charge = AmountYellow;
		else if (Charge > AmountGreen)
			Other.Charge = AmountGreen;
		Charge -= Other.Charge;
		Other.Drop(OldHolder, newVel);
	}

	if (Charge <= 0)
	{
		Destroy();
		return;
	}
	
	if (Charge == AmountRed)
		Texture = Texture'RedShield';
	else if (Charge == AmountYellow)
		Texture = Texture'N_Shield';
	else if (Charge == AmountGreen)
		Texture = Texture'Greenshield';
	else
		Texture = Texture'BlueShield'; // must not happen

	Velocity = (0.2 + FRand()) * (newVel + 400 * FRand() * VRand());
	If (Region.Zone.bWaterZone)
		Velocity *= 0.5;
	bCollideWorld = true;
	SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
 	if (!SetLocation(OldHolder.Location + (OldHolder.CollisionHeight - CollisionHeight)*vect(0, 0, 1)) 
		&& !SetLocation(OldHolder.Location) && Location != OldHolder.Location)
	{ // can't make skull, so Destroy it.
		Destroy();
		return;
	}

	bSimFall = true;
	SimAnim.X = 0;
	SimAnim.Y = 0;
	SimAnim.Z = 0;
	SimAnim.W = 0;
	SetPhysics(PHYS_Falling);
	SetBase(None);
	SetCollision(true, false, false);
	bBounce = true;
	DropFrom(Location);
	R.Yaw = Rotation.Yaw;
	SetRotation(R);
}

defaultproperties
{
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
	CollisionRadius=15.000000
	CollisionHeight=15.000000
	bFixedRotationDir=False
	RotationRate=(Pitch=0,Yaw=0)
}
