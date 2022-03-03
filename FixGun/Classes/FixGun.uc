//=============================================================================
// FixGun.
//=============================================================================
class FixGun expands PulseGun;

simulated event RenderOverlays( canvas Canvas )
{
	MultiSkins[1] = Texture'Ammoled';
	Texture'Ammoled'.NotifyActor = Self;
	Super.RenderOverlays(Canvas);
	Texture'Ammoled'.NotifyActor = None;
	MultiSkins[1] = Default.MultiSkins[1];
}

function float RateSelf( out int bUseAltMode )
{
	local int Ignored;
	
	bUseAltMode = 0; // never use for Bot.
	return Super.RateSelf(Ignored);
}

defaultproperties
{
      WeaponDescription="Classification: Fix RiflenPrimary Fire: Medium sized, fast moving plasma balls are fired at a fast rate of fire.nSecondary Fire: A bolt of blue lightning is expelled for 100 meters, which will fix vehicles.nTechniques: Firing and keeping the secondary fire's beam on a vehicle will fix them in seconds."
      AmmoName=Class'FixGun.FixAmmo'
      PickupAmmoCount=200
      ProjectileClass=Class'FixGun.FixSphere'
      AltProjectileClass=Class'FixGun.StarterFixBolt'
      AIRating=1.000000
      MessageNoAmmo=" has no ammo."
      NameColor=(R=0,G=0,B=255)
      PickupMessage="You got a Fixing Gun"
      ItemName="Fixing Gun"
      StatusIcon=Texture'FixGun.Icons.UseFix'
      MuzzleFlashScale=1.000000
      MuzzleFlashTexture=Texture'UnrealShare.DispExpl.dseb_A01'
      Icon=Texture'FixGun.Icons.UseFix'
      bGameRelevant=True
      MultiSkins(0)=Texture'Botpack.Ammocount.AmmoCountBar'
      MultiSkins(1)=Texture'FixGun.Skins.JFixPickup_01'
      MultiSkins(2)=Texture'FixGun.Skins.JFixGun_02'
      MultiSkins(3)=Texture'FixGun.Skins.JFixGun_03'
      MultiSkins(7)=ScriptedTexture'Botpack.Ammocount.AmmoLed'
      CollisionHeight=16.000000
}
