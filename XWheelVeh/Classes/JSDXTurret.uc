class JSDXTurret expands xWheelVehWeapon;

//Mesh import
#exec MESH IMPORT MESH=JSDXTurret ANIVFILE=MODELS\JSDXTurret_a.3d DATAFILE=MODELS\JSDXTurret_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=JSDXTurret STRENGTH=0.85
#exec MESH ORIGIN MESH=JSDXTurret X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=JSDXTurret SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=JSDXTurret SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=JSDXTurret MESH=JSDXTurret
#exec MESHMAP SCALE MESHMAP=JSDXTurret X=0.25 Y=0.25 Z=0.5

//Skinning
#exec TEXTURE IMPORT NAME=JeepHTurretSk FILE=SKINS\JeepHTurretSk.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=JSDXTurret NUM=1 TEXTURE=JeepHTurretSk

//Sounds
#exec AUDIO IMPORT NAME="JSDXLFire" FILE=SOUNDS\JSDXLFire.wav GROUP="Fire"
#exec AUDIO IMPORT NAME="JSDXLDualFire" FILE=SOUNDS\JSDXLDualFire.wav GROUP="Fire"
#exec AUDIO IMPORT NAME="JeepTurretH" FILE=SOUNDS\JeepTurretH.wav GROUP="JeepSDX"

function SpawnFireEffects(byte Mode)
{
local vector ROffset;
local LPlasmaFireFX LPl;

	if (PitchPart != None)
	{
		ROffset = WeapSettings[Mode].FireStartOffset;
	
		if (Mode == 0)
		{
			if (bTurnFire)
				ROffset.Y = -ROffset.Y;
			LPl = Spawn(Class'LPlasmaFireFX',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation));
			LPl.PrePivotRel = ROffSet;
		}
		else
		{
			LPl = Spawn(Class'LPlasmaFireFX',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation));
			LPl.PrePivotRel = ROffSet;
			ROffset.Y = -ROffset.Y;
			LPl = Spawn(Class'LPlasmaFireFX',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation));
			LPl.PrePivotRel = ROffSet;
		}
	}
}

function FireTurret( byte Mode, optional bool bForceFire )
{
	local Vehicle EnemyVehicle;
	local float Dist;
	if (PLayerPawn(WeaponController) == None)
	{ // bot select proper mode for shoot, 1 = dual mode, which fire more often, but together
		Mode = 0; // single mode, which fire more rare, but one-by-one
		if (Vehicle(WeaponController.Target) != None) // empty vehicle
			Mode = 1;
		else if (Pawn(WeaponController.Target) != None)
		{
			Dist = VSize(WeaponController.Target.Location - Location);			
			if (DriverWeapon(Pawn(WeaponController.Target).Weapon) != None)
				EnemyVehicle = DriverWeapon(Pawn(WeaponController.Target).Weapon).VehicleOwner;
			if (EnemyVehicle == None) // enemy on foot
			{
				if (Dist < WeapSettings[1].ProjectileClass.default.Speed*
					(0.25 + 0.5*Min(WeaponController.Target.CollisionHeight, 
					WeaponController.Target.CollisionRadius)/Pawn(WeaponController.Target).GroundSpeed))
					Mode = 1;
			}
			else if (StationaryPhys(EnemyVehicle) != None) // enemy in turret
				Mode = 1;
			else if (Dist < WeapSettings[1].ProjectileClass.default.Speed/2) // close to vehicle
				Mode = 1;
		}
	}
	Super.FireTurret(Mode);
}

defaultproperties
{
	RotatingSpeed=22000.000000
	PitchRange=(Max=14000,Min=-6500)
	TurretPitchActor=Class'JSDXGun'
	PitchActorOffset=(X=-1.875000,Z=28.750000)
	WeapSettings(0)=(ProjectileClass=Class'JSDXLPlasma',FireStartOffset=(X=87.500000,Y=12.500000,Z=24.000000),RefireRate=2.750000,FireAnim1="LeftLightFire",FireAnim2="RightLightFire",FireSound=Sound'XWheelVeh.Fire.JSDXLFire',DualMode=1)
	WeapSettings(1)=(ProjectileClass=Class'JSDXLPlasma',FireStartOffset=(X=87.500000,Y=12.500000,Z=24.000000),RefireRate=1.200000,FireAnim1="DualLightFire",FireSound=Sound'XWheelVeh.Fire.JSDXLDualFire',DualMode=2)
	bFireRateByAnim=True
	bLimitPitchByCarTop=True
	CarTopRange=0.500000
	CarTopAllowedPitch=(Max=14000,Min=-600)
	bPhysicalGunAimOnly=True
	Mesh=LodMesh'JSDXTurret'
	SoundRadius=150
	SoundVolume=255
	CollisionRadius=18.000000
	CollisionHeight=4.000000
	NetPriority=3.000000
}
