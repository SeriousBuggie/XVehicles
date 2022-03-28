class TankMGRot expands xTreadVehWeapon;

//Mesh import
#exec MESH IMPORT MESH=TankMGRot ANIVFILE=MODELS\TankMGRot_a.3d DATAFILE=MODELS\TankMGRot_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=TankMGRot STRENGTH=0.85
#exec MESH ORIGIN MESH=TankMGRot X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=TankMGRot SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankMGRot SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=TankMGRot MESH=TankMGRot
#exec MESHMAP SCALE MESHMAP=TankMGRot X=0.125 Y=0.125 Z=0.25

//Skinning
#exec TEXTURE IMPORT NAME=TankRusty FILE=SKINS\TankRusty.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=TankMGRot NUM=1 TEXTURE=TankRusty

#exec AUDIO IMPORT NAME="TankGKMGunFire" FILE=SOUNDS\TankGKMGunFire.wav GROUP="TankGKOne"

var TankMGMuz TMGMz;
var byte TracerCount;

function SpawnFireEffects( byte Mode )
{
local vector ROffset;

	if (TMGMz == None && PitchPart != None)
	{
		ROffset = WeapSettings[Mode].FireStartOffset + vect(-10,0,-5);
		TMGMz = Spawn(Class'TankMGMuz',PitchPart,,PitchPart.Location + (ROffset >> PitchPart.Rotation), PitchPart.Rotation);
		TMGMz.PrePivotRel = ROffset;
	}
}

function SpawnTraceEffects(vector Dir)
{
local vector ROffset;

	if (PitchPart != None && TracerCount > 1)
	{
		ROffset = WeapSettings[0].FireStartOffset + vect(-20,0,0);
		Spawn(Class'TMGunTracer',,,PitchPart.Location + (ROffset >> PitchPart.Rotation), rotator(Dir));
		TracerCount = 0;
	}
	else
		TracerCount++;
}

function Timer()
{
	bFireRestrict = False;
	if( WeaponController==None )
	{
		if (TMGMz != None)
		{
			TMGMz.Destroy();
			TMGMz = None;
		}
		Return;
	}
	if( WeaponController.bFire!=0 )
		FireTurret(0);
	else if( WeaponController.bAltFire!=0 )
	{
		if (TMGMz != None)
		{
			TMGMz.Destroy();
			TMGMz = None;
		}

		FireTurret(1);
	}
	else if (TMGMz != None)
	{
		TMGMz.Destroy();
		TMGMz = None;
	}
}

simulated function Destroyed()
{
	if (TMGMz != None)
		TMGMz.Destroy();

	Super.Destroyed();
}

defaultproperties
{
      TMGMz=None
      TracerCount=0
      RotatingSpeed=80000.000000
      PitchRange=(Max=15000,Min=-3000)
      bAltFireZooms=True
      TurretPitchActor=Class'XTreadVeh.TankMGun'
      PitchActorOffset=(Z=17.500000)
      WeapSettings(0)=(FireStartOffset=(X=32.500000),RefireRate=0.100000,FireSound=Sound'XTreadVeh.TankGKOne.TankGKMGunFire',bInstantHit=True,hitdamage=17,HitType="Ballistic",HitError=0.010000,HitMomentum=10000.000000,HitHeavyness=2)
      bPhysicalGunAimOnly=True
      bRotWithOtherWeap=True
      Mesh=LodMesh'XTreadVeh.TankMGRot'
      SoundRadius=150
      SoundVolume=255
      CollisionRadius=16.000000
      CollisionHeight=4.000000
}
