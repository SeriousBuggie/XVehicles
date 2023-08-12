class KrahtTurret expands xTreadVehWeapon;

//Mesh import
#exec MESH IMPORT MESH=KrahtTurret ANIVFILE=MODELS\KrahtTurret_a.3d DATAFILE=MODELS\KrahtTurret_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=KrahtTurret STRENGTH=0.85
#exec MESH ORIGIN MESH=KrahtTurret X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=KrahtTurret SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=KrahtTurret SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=KrahtTurret MESH=KrahtTurret
#exec MESHMAP SCALE MESHMAP=KrahtTurret X=0.3 Y=0.3 Z=0.6

//Skinning
#exec TEXTURE IMPORT NAME=KrahtTurretSk FILE=SKINS\KrahtTurretSk.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=KrahtTurret NUM=1 TEXTURE=KrahtTurretSk

#exec AUDIO IMPORT NAME="KrahtChargeUp" FILE=SOUNDS\KrahtChargeUp.wav GROUP="Kraht"
#exec AUDIO IMPORT NAME="KrahtFire" FILE=SOUNDS\KrahtFire.wav GROUP="Kraht"

var KrahtFXSpirR KSpirR, KSpirL;
var KrahtFFX KFFX;

function SpawnFireEffects(byte Mode)
{
	if (PitchPart != None)
	{
		KFFX = Spawn(Class'KrahtFireFX',PitchPart,,PitchPart.Location + (vect(148,0,-2.5) >> PitchPart.Rotation));
		KFFX.PrePivotRel = vect(148,0,-2.5);
	}
}

simulated function Destroyed()
{
	if (KSpirR != None)
		KSpirR.Destroy();
	if (KSpirL != None)
		KSpirL.Destroy();
	if (KFFX != None)
		KFFX.Destroy();

	Super.Destroyed();
}

simulated function DelayFX(byte Mode)
{
	if (Mode == 0 && PitchPart != None)
	{
		KSpirR = Spawn(Class'KrahtFXSpirR',PitchPart,,PitchPart.Location + (vect(146,22,-2.5) >> PitchPart.Rotation));
		KSpirR.PrePivotRel = vect(146,22,-2.5);

		KSpirL = Spawn(Class'KrahtFXSpirL',PitchPart,,PitchPart.Location + (vect(146,-22,-2.5) >> PitchPart.Rotation));
		KSpirL.PrePivotRel = vect(146,-22,-2.5);

		KFFX = Spawn(Class'KrahtFFX',PitchPart,,PitchPart.Location + (vect(148,0,-2.5) >> PitchPart.Rotation));
		KFFX.PrePivotRel = vect(148,0,-2.5);
	}
}

defaultproperties
{
	RotatingSpeed=20000.000000
	PitchRange=(Max=6500,Min=-2500)
	bAltFireZooms=True
	TurretPitchActor=Class'KrahtCannon'
	PitchActorOffset=(X=37.000000,Y=0.000000,Z=9.500000)
	WeapSettings(0)=(ProjectileClass=Class'KrahtProj',FireStartOffset=(X=20.000000,Z=-2.500000),RefireRate=1.500000,FireSound=Sound'XTreadVeh.Kraht.KrahtFire',FireSndRange=60,FireSndVolume=255,FireDelay=1.000000,FireDelaySnd=Sound'XTreadVeh.Kraht.KrahtChargeUp',FireDelaySndRange=48,FireDelaySndVolume=235)
	bPhysicalGunAimOnly=True
	FiringShaking(0)=(bShakeEnabled=True,ShakeRadius=425.000000,shaketime=0.250000,ShakeVertMag=325.000000,ShakeRollMag=1500.000000)
	PartMass=1
	Mesh=LodMesh'KrahtTurret'
	SoundRadius=150
	SoundVolume=255
	CollisionRadius=68.000000
	CollisionHeight=16.000000
}
