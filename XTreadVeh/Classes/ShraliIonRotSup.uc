class ShraliIonRotSup expands xTreadVehWeapon;

//Mesh import
#exec MESH IMPORT MESH=ShraliIonRotSup ANIVFILE=MODELS\ShraliIonRotSup_a.3d DATAFILE=MODELS\ShraliIonRotSup_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=ShraliIonRotSup STRENGTH=0.85
#exec MESH ORIGIN MESH=ShraliIonRotSup X=0 Y=0 Z=0

//Mesh anim
#exec MESH SEQUENCE MESH=ShraliIonRotSup SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ShraliIonRotSup SEQ=Still STARTFRAME=0 NUMFRAMES=1

//Mesh scale
#exec MESHMAP NEW MESHMAP=ShraliIonRotSup MESH=ShraliIonRotSup
#exec MESHMAP SCALE MESHMAP=ShraliIonRotSup X=0.25 Y=0.25 Z=0.5

//Skinning
#exec TEXTURE IMPORT NAME=ShraliIonRotSupSk FILE=SKINS\ShraliIonRotSupSk.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=ShraliIonRotSup NUM=1 TEXTURE=ShraliIonRotSupSk

//Sounds
#exec AUDIO IMPORT NAME="ShraliIonFire" FILE=SOUNDS\ShraliIonFire.wav GROUP="Shrali"

function SpawnFireEffects( byte Mode )
{
local vector ROffset;
local ShrRotSpriteFX srsfx;

	if (PitchPart != None)
	{
		ROffset = vect( 88, 24, 0);
		Spawn(Class'ShrRotSpriteFX',,,PitchPart.Location + (ROffset >> PitchPart.Rotation));
	
		ROffset = vect( 88, -24, 0);		
		srsfx = Spawn(Class'ShrRotSpriteFX',,,PitchPart.Location + (ROffset >> PitchPart.Rotation));
		srsfx.bRotateBackwards = True;
	}
}


function TraceProcess( actor A, vector HitLocation, vector HitNormal, byte Mode)
{
local vector ROffset1, ROffset2, Dir1, Dir2;
local float VectDist;
local int NumPoints, PointN;
local ShrSpiralBeam ssb;
local ShrRedIonExplSparksA sries;
local xVehProjDummy xWFX;

	if( A!=None )
	{
		if (A != Level && PitchPart != None)
			HitNormal = Normal(PitchPart.Location - HitLocation);
		else
			Spawn(Class'ShrIonHitMark',,, HitLocation, rotator(HitNormal));

		Spawn(Class'ShrRedIonExplSparksA',,, HitLocation, rotator(HitNormal) + Rand(16384)*rot(0,0,1));
		Spawn(Class'ShrRedIonExplSparksB',,, HitLocation, rotator(HitNormal) + Rand(16384)*rot(0,0,1));
		Spawn(Class'ShrRedIonExplSparksC',,, HitLocation, rotator(HitNormal) + Rand(16384)*rot(0,0,1));
		sries = Spawn(Class'ShrRedIonExplSparksA',,, HitLocation, rotator(HitNormal) + Rand(16384)*rot(0,0,1));
		sries.DrawScale = 1.0;
		sries = Spawn(Class'ShrRedIonExplSparksC',,, HitLocation, rotator(HitNormal) + Rand(16384)*rot(0,0,1));
		sries.DrawScale = 1.0;

		A.TakeDamage(WeapSettings[Mode].HitDamage,WeaponController,HitLocation,WeapSettings[Mode].HitMomentum*Normal(HitLocation-Location), WeapSettings[Mode].HitType);
	}
	else
		HitLocation = PitchPart.Location + vector(PitchPart.Rotation)*30000;

	//Trace effect
	if (PitchPart != None)
	{
		ROffset1 = PitchPart.Location + (vect( 88, 24, 0) >> PitchPart.Rotation);
		ROffset2 = PitchPart.Location + (vect( 88, -24, 0) >> PitchPart.Rotation);

		VectDist = VSize(HitLocation - ROffset1);
		Dir1 = Normal(HitLocation - ROffset1);
		Dir2 = Normal(HitLocation - ROffset2);
		NumPoints = VectDist / 640;

		xWFX = Spawn(Class'xVehProjDummy', OwnerVehicle,, ROffset1, rotator(Dir1));
		xWFX.Mass = 6;
		xWFX = Spawn(Class'xVehProjDummy', OwnerVehicle,, ROffset2, rotator(Dir2));
		xWFX.Mass = 6;
		
		For (PointN = 0; PointN < (NumPoints + 1); PointN++)
		{
			ssb = Spawn(Class'ShrSpiralBeam',,, ROffset1 + Dir1*PointN*640, rotator(Dir1));

			if (PointN == NumPoints && ssb != None)
			{
				ssb.AnimSequence = 'Adjust';
				ssb.AnimFrame = (640 - (VectDist - NumPoints*640)) * 21/22 / 640;
			}

			ssb = Spawn(Class'ShrSpiralBeam',,, ROffset2 + Dir2*PointN*640, rotator(Dir2));

			if (PointN == NumPoints && ssb != None)
			{
				ssb.AnimSequence = 'Adjust';
				ssb.AnimFrame = (640 - (VectDist - NumPoints*640)) * 21/22 / 640;
			}
		}
	}

	Spawn(Class'ShrAnimRedIonExpl',,, HitLocation);
}

defaultproperties
{
      RotatingSpeed=32000.000000
      PitchRange=(Max=14000,Min=2000)
      bAltFireZooms=True
      TurretPitchActor=Class'XTreadVeh.ShraliIonGun'
      PitchActorOffset=(X=-7.500000,Z=32.500000)
      WeapSettings(0)=(FireStartOffset=(X=88.000000),RefireRate=1.000000,FireSound=Sound'XTreadVeh.Shrali.ShraliIonFire',bInstantHit=True,hitdamage=225,HitType="RedIonize",HitError=0.000000,HitMomentum=170000.000000,HitHeavyness=0)
      bLimitPitchByCarTop=True
      CarTopRange=0.150000
      CarTopAllowedPitch=(Max=14000,Min=-1550)
      bPhysicalGunAimOnly=True
      Mesh=LodMesh'XTreadVeh.ShraliIonRotSup'
      SoundRadius=150
      SoundVolume=255
      CollisionRadius=42.000000
      CollisionHeight=16.000000
}
