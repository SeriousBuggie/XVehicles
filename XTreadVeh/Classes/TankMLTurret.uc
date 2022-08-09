class TankMLTurret expands xTreadVehWeapon;

//Mesh import
#exec MESH IMPORT MESH=TankMLTurret ANIVFILE=MODELS\TankMLTurret_a.3d DATAFILE=MODELS\TankMLTurret_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=TankMLTurret STRENGTH=0.85
#exec MESH ORIGIN MESH=TankMLTurret X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=TankMLTurret SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankMLTurret SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=TankMLTurret MESH=TankMLTurret
#exec MESHMAP SCALE MESHMAP=TankMLTurret X=0.5 Y=0.5 Z=1.0

//Skinning
#exec TEXTURE IMPORT NAME=TankTurretSk_I FILE=SKINS\TankTurretSk_I.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=TankMLTurret NUM=1 TEXTURE=TankTurretSk_I

//Sound
#exec AUDIO IMPORT NAME="TankMLFire" FILE=SOUNDS\TankMLFire.wav GROUP="TankML"
#exec AUDIO IMPORT NAME="TankMLDelay" FILE=SOUNDS\TankMLDelay.wav GROUP="TankML"

var() rotator MuzzleFXRotation[4];

function SpawnFireEffects(byte Mode)
{
local byte i;

	if (Mode == 0 && PitchPart != None)
	{
		PitchPart.PlayAnim('Fire', 10.0, 0.05);
		
		for (i = 0; i < 4; i++)
			Spawn(Class'TankMLMuzzFX',,, PitchPart.Location + ((WeapSettings[0].FireStartOffset + vect(64,0,0)) >> PitchPart.Rotation), PitchPart.Rotation + MuzzleFXRotation[i]);
	}
}

simulated function DelayFX(byte Mode)
{
	if (Mode == 0 && TankML(OwnerVehicle) != None)
			TankML(OwnerVehicle).SpawnShotOverlayer();
}

defaultproperties
{
	MuzzleFXRotation(0)=(Roll=20576)
	MuzzleFXRotation(1)=(Roll=-20576)
	MuzzleFXRotation(2)=(Roll=12192)
	MuzzleFXRotation(3)=(Roll=-12192)
	RotatingSpeed=27000.000000
	PitchRange=(Max=4600,Min=-1100)
	bAltFireZooms=True
	TurretPitchActor=Class'XTreadVeh.TankMLCannon'
	PitchActorOffset=(X=79.000000,Y=0.000000,Z=-4.000000)
	WeapSettings(0)=(ProjectileClass=Class'XTreadVeh.TankMLProj',FireStartOffset=(X=272.000000),RefireRate=3.500000,FireSound=Sound'XTreadVeh.TankML.TankMLFire',FireSndRange=64,FireSndVolume=180,FireDelay=1.000000,FireDelaySnd=Sound'XTreadVeh.TankML.TankMLDelay',FireDelaySndRange=48,FireDelaySndVolume=235)
	bPhysicalGunAimOnly=True
	FiringShaking(0)=(bShakeEnabled=True,ShakeRadius=750.000000,shaketime=0.350000,ShakeVertMag=2400.000000,ShakeRollMag=3250.000000)
	PartMass=1
	Mesh=LodMesh'XTreadVeh.TankMLTurret'
	SoundRadius=150
	SoundVolume=255
	CollisionRadius=80.000000
	CollisionHeight=32.000000
}
