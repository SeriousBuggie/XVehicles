// redirect all damage to vehicle
class DriverShield expands Inventory;

var bool bKeysSet;

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

simulated function Tick(float delta)
{
	Super.Tick(delta);
	if (Level.NetMode != NM_DedicatedServer && !bKeysSet)
		BindKeys();
}

simulated function BindKeys()
{
	local PlayerPawn PP;
	local int i, pos;
	local string KeyName, KeyBinding, KeyBindingCaps, Cmd;
	
	if (Level.NetMode == NM_DedicatedServer || bKeysSet)
		return;
	
	PP = PlayerPawn(Owner);
	if (PP == None || PP.Player == None)
		return;
		
	bKeysSet = true;
		
	for (i = 0; i < 256; i++)
	{
		KeyName = PP.ConsoleCommand("KeyName" @ i);
		KeyBinding = PP.ConsoleCommand("KeyBinding" @ KeyName);
		KeyBindingCaps = Caps(KeyBinding);
		if (InStr(KeyBindingCaps, "JUMP") != -1 && InStr(KeyBindingCaps, "ONRELEASE XVJUMPRELEASED|") == -1)
			PP.ConsoleCommand("Set Input" @ KeyName @ "OnRelease XVJumpReleased|" $ KeyBinding);
	}
}

simulated exec function XVJumpReleased()
{
	if (PlayerPawn(Owner) != None)
		PlayerPawn(Owner).bPressedJump = false;
}

defaultproperties
{
      bKeysSet=False
      bIsAnArmor=True
      bHidden=True
      bGameRelevant=True
}
