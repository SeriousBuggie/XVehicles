// crappy mutator which replace any (!) subclasses of minigun, enforcer and sniperrifle to modified version
// for make water splash on hitscan shoots. Better avoid to use.
class XZonesMut expands Mutator;

var() string ZonesPackName;
var bool bReady;

function PostBeginPlay()
{
local TournamentWeapon TW, Other;

	ForEach AllActors(Class'TournamentWeapon', Other)
	{
		if (Other.IsA('Enforcer') && !Other.IsA('xzEnforcer'))
		{
			TW = Spawn(Class'xzEnforcer',,, Other.Location, Other.Rotation);
			TW.bFixedRotationDir = Other.bFixedRotationDir;
			TW.bRotatingPickup = Other.bRotatingPickup;
			TW.rotationRate = Other.rotationRate;
			Other.Destroy();
		}
		else if (Other.IsA('Minigun2') && !Other.IsA('xzMinigun'))
		{
			TW = Spawn(Class'xzMinigun',,, Other.Location, Other.Rotation);
			TW.bFixedRotationDir = Other.bFixedRotationDir;
			TW.bRotatingPickup = Other.bRotatingPickup;
			TW.rotationRate = Other.rotationRate;
			Other.Destroy();		
		}	
		else if (Other.IsA('SniperRifle') && !Other.IsA('xzSniperRifle'))
		{
			TW = Spawn(Class'xzSniperRifle',,, Other.Location, Other.Rotation);
			TW.bFixedRotationDir = Other.bFixedRotationDir;
			TW.bRotatingPickup = Other.bRotatingPickup;
			TW.rotationRate = Other.rotationRate;
			Other.Destroy();
		}
	}

	SetTimer(0.3, False);
}

function Timer()
{
	bReady = True;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (bReady)
	{
	if (Other.IsA('Enforcer') && !Other.IsA('xzEnforcer'))
	{
		replaceWith(Other, ZonesPackName $ ".xzEnforcer");
		return false;
	}
	else if (Other.IsA('Minigun2') && !Other.IsA('xzMinigun'))
	{
		replaceWith(Other, ZonesPackName $ ".xzMinigun");
		return false;
	}
	else if (Other.IsA('SniperRifle') && !Other.IsA('xzSniperRifle'))
	{
		replaceWith(Other, ZonesPackName $ ".xzSniperRifle");
		return false;
	}
	}

	return true;
}

function ModifyPlayer(Pawn P)
{
local Weapon newWeapon;

	if (Level.Game.IsA('TournamentGameInfo'))
	{
		newWeapon = Spawn(Class'xzEnforcer');

		if (newWeapon != None)
		{
			newWeapon.bTossedOut = false;
			newWeapon.Instigator = P;
			newWeapon.RespawnTime = 0.0;
			newWeapon.bHeldItem = true;
			newWeapon.BecomeItem();
			P.AddInventory(newWeapon);
			newWeapon.GiveAmmo(P);
			newWeapon.SetSwitchPriority(P);
			newWeapon.WeaponSet(P);
		}
	}

    if ( NextMutator != None )
        NextMutator.ModifyPlayer(P);
}


function bool ReplaceWith(actor Other, string aClassName) {
	 local Actor A;
	 local class<Actor> aClass;

	 if ( Other.IsA('Inventory') && (Other.Location == vect(0,0,0)) )
		  return false;

	 aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	 if ( aClass != None )
		  A = Spawn(aClass,,Other.tag,Other.Location, Other.Rotation);

	if (Inventory(A) != None && Inventory(Other) != None)
	{
		  Inventory(A).bRotatingPickup = Inventory(Other).bRotatingPickup;
		  A.SetPhysics(Other.Physics);
		  A.bFixedRotationDir = Other.bFixedRotationDir;
	}

	 if ( Other.IsA('Inventory') )
	 {
		  if ( Inventory(Other).MyMarker != None )
		  {
			   Inventory(Other).MyMarker.markedItem = Inventory(A);
			   if ( Inventory(A) != None )
			   {
					Inventory(A).MyMarker = Inventory(Other).MyMarker;
					A.SetLocation(A.Location
						 + (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
			   }
			   Inventory(Other).MyMarker = None;
		  }
		  else if ( A.IsA('Inventory') )
		  {
			   Inventory(A).bHeldItem = true;
			   Inventory(A).Respawntime = 0.0;
		  }
	 }

	 if ( A != None )
	 {
		  A.event = Other.event;
		  A.tag = Other.tag;

		  // All that for this!
		  A.rotationRate = Other.rotationRate;
		  A.SetRotation(Other.Rotation);

		  return true;
	 }

	 return false;
}

defaultproperties
{
	ZonesPackName="xZones"
}
