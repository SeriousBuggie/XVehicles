class TankCBullet expands xTreadVehProjectile;

#exec MESH IMPORT MESH=TankCBullet ANIVFILE=MODELS\TankCBullet_a.3d DATAFILE=MODELS\TankCBullet_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=TankCBullet STRENGTH=0.35
#exec MESH ORIGIN MESH=TankCBullet X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=TankCBullet SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankCBullet SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=TankCBullet MESH=TankCBullet
#exec MESHMAP SCALE MESHMAP=TankCBullet X=0.15 Y=0.15 Z=0.5

#exec TEXTURE IMPORT NAME=TankCBullet FILE=SKINS\TankCBullet.bmp GROUP=Skins LODSET=2

#exec MESHMAP SETTEXTURE MESHMAP=TankCBullet NUM=1 TEXTURE=TankCBullet

#exec AUDIO IMPORT NAME="TCBulletFly" FILE=SOUNDS\TCBulletFly.wav GROUP="TankGKOne"

var float DistCount;
var bool bFirstSmk;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	Velocity = Speed * vector(Rotation);
}

simulated function Tick(float DeltaTime)
{
	if (!Region.Zone.bWaterZone)
	{
		DistCount += VSize(Location-OldLocation);

		if (!bFirstSmk && DistCount >= 127.5)
		{
			bFirstSmk = True;
			DistCount = 0;
			Spawn(Class'SmkTrace');
		}
		else if (DistCount >= 255)
		{
			DistCount = 0;
			Spawn(Class'SmkTrace');
		}
	}
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if (Other != Owner && (!Other.IsA('Projectile') || Other.CollisionRadius > 0))
		Explode(HitLocation, vect(0,0,1));
}

    function BlowTheHellUp(vector HitLocation, vector HitNormal)
    {
	local byte i;

        HurtRadiusOwned(Damage , 710.0, MyDamageType, MomentumTransfer, HitLocation);

	Spawn(Class'TCBulExpl');
	Spawn(Class'DustAirBurst');
	
	For(i=0; i<7; i++)
		Spawn(Class'DustParticles',,, HitLocation, rotator(HitNormal));

	ClientShakes(750);
	
        MakeNoise(3.75);
    }

simulated function Explode(vector HitLocation, vector HitNormal)
{
	BlowTheHellUp(HitLocation, HitNormal);
	Destroy();
}

defaultproperties
{
      DistCount=0.000000
      bFirstSmk=False
      speed=4500.000000
      MaxSpeed=9000.000000
      Damage=600.000000
      MomentumTransfer=100000
      MyDamageType="TankBlast"
      ExplosionDecal=Class'XTreadVeh.TankCBlastMark'
      RemoteRole=ROLE_SimulatedProxy
      AmbientSound=Sound'XTreadVeh.TankGKOne.TCBulletFly'
      Mesh=LodMesh'XTreadVeh.TankCBullet'
      DrawScale=0.500000
      SoundRadius=80
      SoundVolume=60
      Mass=150.000000
}
