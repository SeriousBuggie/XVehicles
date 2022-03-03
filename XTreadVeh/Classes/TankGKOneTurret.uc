class TankGKOneTurret expands xTreadVehWeapon;

//Mesh import
#exec MESH IMPORT MESH=TankGKOneTurret ANIVFILE=MODELS\TankGKOneTurret_a.3d DATAFILE=MODELS\TankGKOneTurret_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=TankGKOneTurret STRENGTH=0.85
#exec MESH ORIGIN MESH=TankGKOneTurret X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=TankGKOneTurret SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankGKOneTurret SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=TankGKOneTurret MESH=TankGKOneTurret
#exec MESHMAP SCALE MESHMAP=TankGKOneTurret X=0.25 Y=0.25 Z=0.5

//Skinning
#exec TEXTURE IMPORT NAME=TankTurretSk_II FILE=SKINS\TankTurretSk_II.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=TankGKOneTurret NUM=1 TEXTURE=TankTurretSk_II

#exec AUDIO IMPORT NAME="TankGKFire01" FILE=SOUNDS\TankGKFire01.wav GROUP="TankGKOne"

function SpawnFireEffects(byte Mode)
{
local vector ROffset;
local TCBulOutFX LPl;

	if (PitchPart != None)
	{
		ROffset = WeapSettings[Mode].FireStartOffset;
		LPl = Spawn(Class'TCBulOutFX',,,PitchPart.Location + (ROffset >> PitchPart.Rotation), PitchPart.Rotation);
	}
}

defaultproperties
{
      RotatingSpeed=22000.000000
      PitchRange=(Max=4500,Min=-1700)
      bAltFireZooms=True
      TurretPitchActor=Class'XTreadVeh.TankGKOneCannon'
      PitchActorOffset=(X=51.250000,Z=4.375000)
      WeapSettings(0)=(ProjectileClass=Class'XTreadVeh.TankCBullet',FireStartOffset=(X=225.000000),RefireRate=3.000000,FireSound=Sound'XTreadVeh.TankGKOne.TankGKFire01',FireSndRange=64,FireSndVolume=40)
      bPhysicalGunAimOnly=True
      FiringShaking(0)=(bShakeEnabled=True,ShakeRadius=365.000000,shaketime=0.350000,ShakeVertMag=1200.000000,ShakeRollMag=1850.000000)
      PartMass=1
      Mesh=LodMesh'XTreadVeh.TankGKOneTurret'
      SoundRadius=150
      SoundVolume=255
      CollisionRadius=80.000000
      CollisionHeight=18.000000
}
