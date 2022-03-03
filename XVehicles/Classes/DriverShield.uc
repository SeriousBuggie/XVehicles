// redirect all damage to vehicle
class DriverShield expands Inventory;

function Vehicle GetVehicle()
{
	if (Pawn(Owner) != None && DriverWeapon(Pawn(Owner).Weapon) != None)
		return DriverWeapon(Pawn(Owner).Weapon).VehicleOwner;
	return None;
}

// UT_Shield destroy all armor on pickup, and bots able pickup stuff inside vehicle
// so we make another copy
function Destroyed()
{
	local Pawn OldOwner;
	if (GetVehicle() != None)
		OldOwner = Pawn(Owner);
	
	Super.Destroyed();
	
	if (OldOwner != None)
		OldOwner.AddInventory( OldOwner.Spawn(Class)); 
}

function int ReduceDamage( int Damage, name DamageType, vector HitLocation )
{
	if (HandleDamage(Damage, DamageType, HitLocation))
		return 0;
	else
		return Super.ReduceDamage(Damage, DamageType, HitLocation);
}

function int ArmorPriority(name DamageType)
{
	return 2147483647; // max int = always first
}

function bool HandleDamage( int Damage, name DamageType, vector HitLocation )
{
	local Vehicle veh;
	veh = GetVehicle();
	if (veh == None)
		return false;
		
	veh.TakeDamage(Damage, None, HitLocation, vect(0,0,0), DamageType);
	return true;
}

function int ArmorAbsorbDamage(int Damage, name DamageType, vector HitLocation)
{
	if (HandleDamage(Damage, DamageType, HitLocation))
		return 0;
	else
		return Damage;
}

defaultproperties
{
      bIsAnArmor=True
      bHidden=True
      bGameRelevant=True
}
