//=============================================================================
// WeaponLocker.
//=============================================================================
class WeaponLocker expands TournamentWeapon config(XWeaponLocker);

//Model Import
#exec mesh import mesh=WeaponLocker anivfile=Models\WeaponLocker_a.3d datafile=Models\WeaponLocker_d.3d x=0 y=0 z=0 mlod=0
#exec mesh origin mesh=WeaponLocker x=0 y=0 z=0
#exec mesh sequence mesh=WeaponLocker seq=All startframe=0 numframes=1

#exec meshmap new meshmap=WeaponLocker mesh=WeaponLocker
#exec meshmap scale meshmap=WeaponLocker x=0.18359 y=0.18359 z=0.36719

//Skins import
#exec TEXTURE IMPORT NAME=WLockerskin1 FILE=SKINS\WLockerskin1.pcx GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=WLockerskin1 FILE=SKINS\WLockerskin1.pcx GROUP=Skins PALETTE=WLockerskin1
#exec MESHMAP SETTEXTURE MESHMAP=WeaponLocker NUM=0 TEXTURE=WLockerskin1

#exec TEXTURE IMPORT NAME=WLockerskin2 FILE=SKINS\WLockerskin2.pcx GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=WLockerskin2 FILE=SKINS\WLockerskin2.pcx GROUP=Skins PALETTE=WLockerskin2
#exec MESHMAP SETTEXTURE MESHMAP=WeaponLocker NUM=1 TEXTURE=WLockerskin2

//Sound import
#exec AUDIO IMPORT NAME="WeaponLocker" FILE=SOUNDS\WeaponLocker.wav GROUP="WeaponLocker"


//-----------------------------------------------------------------------

struct WeaponEntry
{
	var() class<Weapon> WeaponClass;
	var() int ExtraAmmo;
};

var() bool bSentinelProtected;
var() WeaponEntry Weapons[16];

var() byte LockerTeam;

struct MeshRotFix
{
	var() Mesh Mesh;
	var() rotator RotFix;
};

var() config MeshRotFix RotFix[64];

// internal stuff
var WDumbMeshes WMesh[8];
var WRI WRI;
var bool bNW3hack;
var Inventory TempInv;

// overide some parent functions
function Inventory SpawnCopy( pawn P )
{
	local int i;
	local Weapon InvK, wep;
	local bool bChanged;
	local Actor NWRepObj;
	local string InvStr;
	local Class<Weapon> WeaponClass;
	
	If (LockerTeam != 255 && Level.Game.IsA('TeamGamePlus') && 
		(P.PlayerReplicationInfo == None || P.PlayerReplicationInfo.Team != LockerTeam))
		return None;

	For (i=0; i<ArrayCount(Weapons); i++)
	{
		if (Weapons[i].WeaponClass != None)
		{
			If (!RefillAmmo(P, Weapons[i].WeaponClass, Weapons[i].ExtraAmmo))
			{
				InvK = P.Spawn(Weapons[i].WeaponClass,,Name);
				
				if (bNW3hack && InvK != None)
				{ // hack for support NW3
					TempInv = InvK;
					InvStr = GetPropertyText("TempInv");
					foreach InvK.RadiusActors(class'Actor', NWRepObj, 1)
						if (NWRepObj.isA('NWRepObj') && NWRepObj.GetPropertyText("Inv") == InvStr)
							break;
					if (NWRepObj != None)
					{
						InvStr = NWRepObj.GetPropertyText("NewInvClass");
						if (InvStr != "")
						{
							WeaponClass = class<Weapon>(DynamicLoadObject(InvStr, class'Class'));
							if (WeaponClass != None)
							{ // emulate instant replace
								wep = InvK.Spawn(WeaponClass,,Weapons[i].WeaponClass.Name);
								if (wep != None)
								{
									InvK.Destroy();
									InvK = None;
								}
							}
						}
					}
				}
				
				if (InvK == None) // smth replace it
				{
					foreach P.RadiusActors(class'Weapon', wep, 10)
						if (wep.Class.name != Weapons[i].WeaponClass.Name && 
							wep.Tag == Weapons[i].WeaponClass.Name)
							InvK = wep;
					if (InvK != None)
					{
						if (Weapons[i].WeaponClass != InvK.Class) // for next time
						{
							Weapons[i].WeaponClass = InvK.Class; // this prevent attract bots
							if (i < ArrayCount(WMesh))
							{
								if (WRI == None)
									WRI = Spawn(class'WRI', self);
								else
									WRI.WeaponClass[i] = Weapons[i].WeaponClass;
							}
						}
						if (RefillAmmo(P, InvK.Class, Weapons[i].ExtraAmmo)) 
						{		
							InvK.Destroy();
							continue;
						}
					}
				}
				if (InvK != None)
				{
					InvK.RespawnTime = 0.0;
					InvK.bHeldItem = true;
					InvK.bTossedOut = false;
					InvK.GiveTo( P );
					InvK.Instigator = P;
					InvK.GiveAmmo(P);
					InvK.SetSwitchPriority(P);
					if (InvK.AmmoType != None)
						InvK.AmmoType.AmmoAmount += Weapons[i].ExtraAmmo;
					if ( !P.bNeverSwitchOnPickup )
						InvK.WeaponSet(P);
					InvK.AmbientGlow = 0;
				}
			}		
		}
	}
}

function bool RefillAmmo(Pawn P, class<Weapon> WeaponClass, int ExtraAmmo)
{
	local Weapon InvK;
	InvK = Weapon(P.FindInventoryType(WeaponClass));
	If (InvK != None)
	{
		If( InvK.AmmoType != None && InvK.AmmoType.AmmoAmount < InvK.PickupAmmoCount + ExtraAmmo)
			InvK.AmmoType.AmmoAmount = InvK.PickupAmmoCount + ExtraAmmo;
		return true;
	}
	return false;
}

simulated function PostBeginPlay()
{
	local int i;
	local Mutator Mutator;
	
	foreach AllActors(class'Mutator', Mutator)
		if (Mutator.isA('NWReplacer'))
			break;
	bNW3hack = Mutator != None;

	for (i=0; i<ArrayCount(Weapons); i++)
		if (Weapons[i].WeaponClass != None && AIRating < Weapons[i].WeaponClass.default.AIRating)
			AIRating = Weapons[i].WeaponClass.default.AIRating;
	
	Super.PostBeginPlay();
	
	if (Level.NetMode != NM_DedicatedServer)
		SetPickups();
}

// tell the bot how much it wants this weapon pickup
// called when the bot is trying to decide which inventory pickup to go after next
function float BotDesireability(Pawn Bot)
{
	local Weapon AlreadyHas;
	local float desire;
	local int i;

	if ( bHidden )
		return 0;

	if ( bSentinelProtected && (Bot.Weapon == None || Bot.Weapon.AIRating < 0.5) )
		return 0;

	// see if bot already has a weapon of this type
	for ( i=0; i<ArrayCount(Weapons); i++ )
		if ( Weapons[i].WeaponClass != None )
		{
			AlreadyHas = Weapon(Bot.FindInventoryType(Weapons[i].WeaponClass));
			if ( AlreadyHas == None )
				desire += Weapons[i].WeaponClass.Default.AIRating;
			else if ( AlreadyHas.AmmoType != None && AlreadyHas.AmmoType.AmmoAmount < AlreadyHas.PickupAmmoCount + Weapons[i].ExtraAmmo)
				desire += 0.15;
		}
	if ( PlayerPawn(Bot(Bot).RoamTarget) != None /* hunt player */ && (desire * 0.833 < Bot.Weapon.AIRating - 0.1) )
		return 0;

	// incentivize bot to get this weapon if it doesn't have a good weapon already
	if ( (Bot.Weapon == None) || (Bot.Weapon.AIRating < 0.5) )
		return 2*desire;

	return desire;
}

static final operator(22) rotator >>    ( rotator A, rotator B )
{
	local vector X, Y, Z;
	GetAxes(A, X, Y, Z);
	X = X >> B;
	Y = Y >> B;
	Z = Z >> B;
	return OrthoRotation(X, Y, Z);
}

simulated function SetPickups()
{
	local vector X, Y, Z, SpawnOffset;
	local int i, j, count;
	local float Interval;
	local WDumbMeshes TeamLight;
	local rotator r, dir, up;
	local Mesh Mesh;
	local bool bUpdate;
	
	bUpdate = WMesh[0] != None;
	if (bUpdate)
		for (i=0; i < ArrayCount(WMesh); i++)
			if (WMesh[i] != None)
				WMesh[i].Destroy();
	
	for (i=0; i < ArrayCount(WMesh); i++)
		if (Weapons[i].WeaponClass != None)
			count++;		
			
	if (count == 0)
		return;
		
	Interval = 65536.0/count;
	up = rot(16384,0,0) >> Rotation;
	For (i=0; i<count; i++)
	{
		Mesh = Weapons[i].WeaponClass.Default.PickupViewMesh;
		r.Yaw = Interval*i;
		SpawnOffset = vect(32,0,0)*DrawScale >> r;
		
		dir = up;
		dir.Roll -= r.Yaw;
		For (j = 0; j < ArrayCount(default.RotFix); j++)
			if (default.RotFix[j].Mesh == None)
				break;
			else if (default.RotFix[j].Mesh == Mesh)
			{
				dir = default.RotFix[j].RotFix >> dir;
				break;
			}
		WMesh[i] = Spawn(Class'WDumbMeshes',self,, Location + (SpawnOffset >> Rotation), dir);
		WMesh[i].Mesh = Mesh;
		WMesh[i].DrawScale = Weapons[i].WeaponClass.Default.PickupViewScale;
		WMesh[i].WeaponClass = Weapons[i].WeaponClass;
		WMesh[i].SetBase(self);
	}
	
	if (bUpdate)
		return;

	TeamLight = Spawn(Class'WDumbMeshes',,, Location + (vect(0,0,36)*DrawScale >> Rotation));
	TeamLight.Style = STY_Translucent;
	TeamLight.DrawType = DT_Sprite;
	TeamLight.DrawScale = 0.20;
	TeamLight.ScaleGlow = 0.75;
	TeamLight.AmbientGlow = 255;

	If (LockerTeam != 255 && Level.Game.IsA('TeamGamePlus'))
	{
		If (Level.Game.IsA('Assault'))
		{
			If (Assault(Level.Game).Attacker.TeamIndex != 0)
			{
				If (LockerTeam == 0)
					LockerTeam = 1;
				else
					LockerTeam = 0;
			}
		}

		If (LockerTeam == 0)
			TeamLight.Texture = Texture'BotPack.Translocator.TranGlow';
		else if (LockerTeam == 1)
			TeamLight.Texture = Texture'BotPack.Translocator.TranGlowB';
		else if (LockerTeam == 3)
			TeamLight.Texture = Texture'BotPack.Translocator.TranGlowY';
		else
			TeamLight.Texture = Texture'BotPack.Translocator.TranGlowG';
	}
	else
		TeamLight.Texture = Texture'BotPack.Translocator.TranGlowG';
}

auto state Pickup
{
	// Validate touch, and if valid trigger event.
	function bool ValidTouch( actor Other )
	{
		// make sure not touching through wall
		if ( !FastTrace(Other.Location, Location) )
			return false;
		
		return Super.ValidTouch(Other);
	}
}

//---------------------------------------------------------------
//Cancel several inventory functions
//---------------------------------------------------------------

function BecomePickup();

function BecomeItem();

function GiveTo( pawn Other );

function SetRespawn();

function Activate();

event TravelPreAccept();

function bool HandlePickupQuery( inventory Item );

function Inventory SelectNext();

function DropFrom(vector StartLocation);

function ActivateTranslator(bool bHint);

defaultproperties
{
      bSentinelProtected=False
      Weapons(0)=(WeaponClass=None,ExtraAmmo=0)
      Weapons(1)=(WeaponClass=None,ExtraAmmo=0)
      Weapons(2)=(WeaponClass=None,ExtraAmmo=0)
      Weapons(3)=(WeaponClass=None,ExtraAmmo=0)
      Weapons(4)=(WeaponClass=None,ExtraAmmo=0)
      Weapons(5)=(WeaponClass=None,ExtraAmmo=0)
      Weapons(6)=(WeaponClass=None,ExtraAmmo=0)
      Weapons(7)=(WeaponClass=None,ExtraAmmo=0)
      Weapons(8)=(WeaponClass=None,ExtraAmmo=0)
      Weapons(9)=(WeaponClass=None,ExtraAmmo=0)
      Weapons(10)=(WeaponClass=None,ExtraAmmo=0)
      Weapons(11)=(WeaponClass=None,ExtraAmmo=0)
      Weapons(12)=(WeaponClass=None,ExtraAmmo=0)
      Weapons(13)=(WeaponClass=None,ExtraAmmo=0)
      Weapons(14)=(WeaponClass=None,ExtraAmmo=0)
      Weapons(15)=(WeaponClass=None,ExtraAmmo=0)
      LockerTeam=255
      RotFix(0)=(Mesh=LodMesh'Botpack.PulsePickup',RotFix=(Pitch=0,Yaw=16384,Roll=0))
      RotFix(1)=(Mesh=LodMesh'Botpack.RazPick2',RotFix=(Pitch=0,Yaw=16384,Roll=0))
      RotFix(2)=(Mesh=LodMesh'Botpack.ImpPick',RotFix=(Pitch=0,Yaw=16384,Roll=0))
      RotFix(3)=(Mesh=LodMesh'Botpack.Flak2Pick',RotFix=(Pitch=0,Yaw=32768,Roll=0))
      RotFix(4)=(Mesh=LodMesh'Botpack.Eight2Pick',RotFix=(Pitch=0,Yaw=32768,Roll=0))
      RotFix(5)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(6)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(7)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(8)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(9)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(10)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(11)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(12)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(13)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(14)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(15)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(16)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(17)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(18)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(19)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(20)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(21)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(22)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(23)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(24)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(25)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(26)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(27)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(28)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(29)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(30)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(31)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(32)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(33)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(34)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(35)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(36)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(37)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(38)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(39)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(40)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(41)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(42)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(43)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(44)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(45)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(46)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(47)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(48)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(49)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(50)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(51)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(52)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(53)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(54)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(55)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(56)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(57)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(58)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(59)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(60)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(61)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(62)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      RotFix(63)=(Mesh=None,RotFix=(Pitch=0,Yaw=0,Roll=0))
      WMesh(0)=None
      WMesh(1)=None
      WMesh(2)=None
      WMesh(3)=None
      WMesh(4)=None
      WMesh(5)=None
      WMesh(6)=None
      WMesh(7)=None
      WRI=None
      bNW3hack=False
      TempInv=None
      bWeaponStay=True
      bAmbientGlow=False
      bRotatingPickup=False
      PickupMessage="You loaded up at a weapon locker"
      ItemName="Weapon Locker"
      PickupSound=Sound'XWeaponLocker.WeaponLocker.WeaponLocker'
      bNoDelete=True
      RemoteRole=ROLE_DumbProxy
      Mesh=Mesh'XWeaponLocker.WeaponLocker'
      AmbientGlow=127
      bGameRelevant=True
      bTravel=False
      CollisionRadius=50.000000
      CollisionHeight=47.000000
}
