//=============================================================================
// FixGunRestore.
//=============================================================================
class FixGunRestore expands Info;

var string TargetStr;

function PreBeginPlay()
{
	Target = Owner;
	TargetStr = GetPropertyText("Target");
}

function Tick(float Delta)
{
	local FixGun OrigFixGun, FixGun;
	if (Target == None)
		SetPropertyText("Target", TargetStr);
	OrigFixGun = FixGun(Target);	
	FixGun = Spawn(class'FixGun');
	if (OrigFixGun != None && FixGun != None)
	{
		// Inventory
		FixGun.Multiskins[0] = OrigFixGun.Multiskins[0];
		FixGun.Multiskins[1] = OrigFixGun.Multiskins[1];
		FixGun.Multiskins[2] = OrigFixGun.Multiskins[2];
		FixGun.Multiskins[3] = OrigFixGun.Multiskins[3];
		FixGun.Multiskins[4] = OrigFixGun.Multiskins[4];
		FixGun.Multiskins[5] = OrigFixGun.Multiskins[5];
		FixGun.Multiskins[6] = OrigFixGun.Multiskins[6];
		FixGun.Multiskins[7] = OrigFixGun.Multiskins[7];
		FixGun.Skin = OrigFixGun.Skin;
		FixGun.Style = OrigFixGun.Style;
		FixGun.bMeshEnviroMap = OrigFixGun.bMeshEnviroMap;
		FixGun.bAmbientGlow = OrigFixGun.bAmbientGlow;
		FixGun.ScaleGlow = OrigFixGun.ScaleGlow;
		FixGun.AmbientGlow = OrigFixGun.AmbientGlow;
		FixGun.PickupSound = OrigFixGun.PickupSound;
		FixGun.MaxDesireability = OrigFixGun.MaxDesireability;
		FixGun.ActivateSound = OrigFixGun.ActivateSound;
		FixGun.DeActivateSound = OrigFixGun.DeActivateSound;
		FixGun.DrawScale = OrigFixGun.DrawScale;
		FixGun.AutoSwitchPriority = OrigFixGun.AutoSwitchPriority;
		FixGun.InventoryGroup = OrigFixGun.InventoryGroup;
		FixGun.PlayerViewOffset = OrigFixGun.PlayerViewOffset;
		FixGun.PlayerViewMesh = OrigFixGun.PlayerViewMesh;
		FixGun.PlayerViewScale = OrigFixGun.PlayerViewScale;
		FixGun.BobDamping = OrigFixGun.BobDamping;
		FixGun.PickupViewMesh = OrigFixGun.PickupViewMesh;
		FixGun.PickupViewScale = OrigFixGun.PickupViewScale;
		FixGun.ThirdPersonMesh = OrigFixGun.ThirdPersonMesh;
		FixGun.ThirdPersonScale = OrigFixGun.ThirdPersonScale;
		FixGun.StatusIcon = OrigFixGun.StatusIcon;
		FixGun.Icon = OrigFixGun.Icon;
		FixGun.PickupSound = OrigFixGun.PickupSound;
		FixGun.RespawnSound = OrigFixGun.RespawnSound;
		FixGun.PickupMessageClass = OrigFixGun.PickupMessageClass;
		FixGun.ItemMessageClass = OrigFixGun.ItemMessageClass;
		FixGun.RespawnTime = OrigFixGun.RespawnTime;
		FixGun.bRotatingPickup = OrigFixGun.bRotatingPickup;
		FixGun.AttachTag = OrigFixGun.AttachTag;
		FixGun.bBounce = OrigFixGun.bBounce;
		FixGun.bFixedRotationDir = OrigFixGun.bFixedRotationDir;
		FixGun.bRotateToDesired = OrigFixGun.bRotateToDesired;
		FixGun.Buoyancy = OrigFixGun.Buoyancy;
		FixGun.DesiredRotation = OrigFixGun.DesiredRotation;
		FixGun.Mass = OrigFixGun.Mass;
		FixGun.RotationRate = OrigFixGun.RotationRate;
		FixGun.Velocity = OrigFixGun.Velocity;
		FixGun.SetPhysics(OrigFixGun.Physics);
		
		// Weapon		
		FixGun.MaxTargetRange = OrigFixGun.MaxTargetRange;
		FixGun.AmmoName = OrigFixGun.AmmoName;
		FixGun.ReloadCount = OrigFixGun.ReloadCount;
		FixGun.PickupAmmoCount = OrigFixGun.PickupAmmoCount;
		FixGun.bInstantHit = OrigFixGun.bInstantHit;
		FixGun.bAltInstantHit = OrigFixGun.bAltInstantHit;
		FixGun.bWarnTarget = OrigFixGun.bWarnTarget;
		FixGun.bAltWarnTarget = OrigFixGun.bAltWarnTarget;
		FixGun.bSplashDamage = OrigFixGun.bSplashDamage;
		FixGun.bCanThrow = OrigFixGun.bCanThrow;
		FixGun.bRecommendSplashDamage = OrigFixGun.bRecommendSplashDamage;
		FixGun.bRecommendAltSplashDamage = OrigFixGun.bRecommendAltSplashDamage;
		FixGun.bWeaponStay = OrigFixGun.bWeaponStay;
		FixGun.bOwnsCrosshair = OrigFixGun.bOwnsCrosshair;
		FixGun.bMeleeWeapon = OrigFixGun.bMeleeWeapon;
		FixGun.bRapidFire = OrigFixGun.bRapidFire;
		FixGun.FiringSpeed = OrigFixGun.FiringSpeed;
		FixGun.FireOffset = OrigFixGun.FireOffset;
		FixGun.ProjectileClass = OrigFixGun.ProjectileClass;
		FixGun.AltProjectileClass = OrigFixGun.AltProjectileClass;
		FixGun.MyDamageType = OrigFixGun.MyDamageType;
		FixGun.AltDamageType = OrigFixGun.AltDamageType;
		FixGun.ShakeMag = OrigFixGun.ShakeMag;
		FixGun.ShakeTime = OrigFixGun.ShakeTime;
		FixGun.ShakeVert = OrigFixGun.ShakeVert;
		FixGun.AIRating = OrigFixGun.AIRating;
		FixGun.RefireRate = OrigFixGun.RefireRate;
		FixGun.AltRefireRate = OrigFixGun.AltRefireRate;
		FixGun.FireSound = OrigFixGun.FireSound;
		FixGun.AltFireSound = OrigFixGun.AltFireSound;
		FixGun.CockingSound = OrigFixGun.CockingSound;
		FixGun.Misc1Sound = OrigFixGun.Misc1Sound;
		FixGun.Misc2Sound = OrigFixGun.Misc2Sound;
		FixGun.Misc3Sound = OrigFixGun.Misc3Sound;
		FixGun.MessageNoAmmo = OrigFixGun.MessageNoAmmo;
		FixGun.DeathMessage = OrigFixGun.DeathMessage;
		FixGun.NameColor = OrigFixGun.NameColor;
		FixGun.bDrawMuzzleFlash = OrigFixGun.bDrawMuzzleFlash;
		FixGun.MuzzleScale = OrigFixGun.MuzzleScale;
		FixGun.FlashY = OrigFixGun.FlashY;
		FixGun.FlashO = OrigFixGun.FlashO;
		FixGun.FlashC = OrigFixGun.FlashC;
		FixGun.FlashLength = OrigFixGun.FlashLength;
		FixGun.FlashS = OrigFixGun.FlashS;
		FixGun.MFTexture = OrigFixGun.MFTexture;
		FixGun.MuzzleFlare = OrigFixGun.MuzzleFlare;
		FixGun.FlareOffset = OrigFixGun.FlareOffset;
		
		// TournamentWeapon
		FixGun.WeaponDescription = OrigFixGun.WeaponDescription;
		FixGun.FireTime = OrigFixGun.FireTime;
		FixGun.AltFireTime = OrigFixGun.AltFireTime;
		
		// PulseGun
		FixGun.DownSound = OrigFixGun.DownSound;
	}
	Destroy();
}

defaultproperties
{
}
