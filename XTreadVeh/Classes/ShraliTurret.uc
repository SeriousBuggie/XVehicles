class ShraliTurret expands xTreadVehWeapon;

//Mesh import
#exec MESH IMPORT MESH=ShraliTurret ANIVFILE=MODELS\ShraliTurret_a.3d DATAFILE=MODELS\ShraliTurret_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=ShraliTurret STRENGTH=0.85
#exec MESH ORIGIN MESH=ShraliTurret X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=ShraliTurret SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ShraliTurret SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=ShraliTurret MESH=ShraliTurret
#exec MESHMAP SCALE MESHMAP=ShraliTurret X=1.0 Y=1.0 Z=2.0

//Skinning
#exec TEXTURE IMPORT NAME=ShraliTurretSk FILE=SKINS\ShraliTurretSk.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=ShraliTurret NUM=1 TEXTURE=ShraliTurretSk

#exec AUDIO IMPORT NAME="ShraliLoading" FILE=SOUNDS\ShraliLoading.wav GROUP="Shrali"
#exec AUDIO IMPORT NAME="ShraliFire" FILE=SOUNDS\ShraliFire.wav GROUP="Shrali"

var ShraliEnergyDot sed;

function SpawnFireEffects(byte Mode)
{
local vector ROffset;

	if (PitchPart != None)
	{
		ROffset = WeapSettings[Mode].FireStartOffset;
		Spawn(Class'ShraliCanMuzA',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation), PitchPart.Rotation);
		Spawn(Class'ShraliMuzBCor',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation));

		Spawn(Class'ShrAfterBlast',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation), PitchPart.Rotation);
		Spawn(Class'ShrSecAfterBlast',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation), PitchPart.Rotation);
		Spawn(Class'ShrThrAfterBlast',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation), PitchPart.Rotation);
	}
}

simulated function Destroyed()
{
	if (sed != None)
		sed.Destroy();

	Super.Destroyed();
}

simulated function DelayFX(byte Mode)
{
	if (Mode == 0 && PitchPart != None)
	{
		sed = Spawn(Class'ShraliEnergyDot',PitchPart,,PitchPart.Location + (vect(507.5,0,0) >> PitchPart.Rotation));
		sed.PrePivotRel = vect(507.5,0,0);
	}
}

defaultproperties
{
	RotatingSpeed=20000.000000
	PitchRange=(Max=4500,Min=-1700)
	bAltFireZooms=True
	TurretPitchActor=Class'XTreadVeh.ShraliCannon'
	PitchActorOffset=(X=30.625000,Y=0.000000,Z=40.625000)
	WeapSettings(0)=(ProjectileClass=Class'XTreadVeh.ShraliProj',FireStartOffset=(X=510.000000),RefireRate=1.000000,FireSound=Sound'XTreadVeh.Shrali.ShraliFire',FireSndRange=68,FireSndVolume=200,FireDelay=6.000000,FireDelaySnd=Sound'XTreadVeh.Shrali.ShraliLoading',FireDelaySndRange=56,FireDelaySndVolume=200)
	bPhysicalGunAimOnly=True
	bUseEnergyFX=True
	EnergyPartsA(0)=(bHaveThisEnPartc=True,EnLnClass=Class'XTreadVeh.EnLnPartRedA',EnLnLocOffSet=(X=510.000000),RepeatDelay=0.200000,RepeatTimes=120,bProgressive=True)
	EnergyPartsA(1)=(bHaveThisEnPartc=True,EnLnClass=Class'XTreadVeh.EnLnPartRedB',EnLnLocOffSet=(X=510.000000),RepeatDelay=0.200000,RepeatTimes=120,bProgressive=True)
	EnergyPartsA(2)=(bHaveThisEnPartc=True,EnLnClass=Class'XTreadVeh.EnLnPartRedC',EnLnLocOffSet=(X=510.000000),RepeatDelay=0.200000,RepeatTimes=120,bProgressive=True)
	EnergyPartsA(3)=(bHaveThisEnPartc=True,EnLnClass=Class'XTreadVeh.EnLnPartRedD',EnLnLocOffSet=(X=510.000000),RepeatDelay=0.200000,RepeatTimes=120,bProgressive=True)
	FiringShaking(0)=(bShakeEnabled=True,bShakeByStep=True,ShakeStart=SHK_DuringFire,ShakeRadius=780.000000,shaketime=5.800000,ShakeVertMag=100.000000,ShakeRollMag=75.000000,StepInterval=0.200000)
	FiringShaking(1)=(bShakeEnabled=True,ShakeStart=SHK_OnFire,ShakeRadius=1000.000000,shaketime=0.300000,ShakeVertMag=475.000000,ShakeRollMag=2050.000000)
	PartMass=1
	Mesh=LodMesh'XTreadVeh.ShraliTurret'
	SoundRadius=150
	SoundVolume=255
	CollisionRadius=128.000000
	CollisionHeight=64.000000
}
