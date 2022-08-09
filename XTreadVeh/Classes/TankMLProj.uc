class TankMLProj expands xTreadVehProjectile;

#exec MESH IMPORT MESH=TankMLProj ANIVFILE=MODELS\TankMLProj_a.3d DATAFILE=MODELS\TankMLProj_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=TankMLProj STRENGTH=0.75
#exec MESH ORIGIN MESH=TankMLProj X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=TankMLProj SEQ=All STARTFRAME=0 NUMFRAMES=8
#exec MESH SEQUENCE MESH=TankMLProj SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankMLProj SEQ=Revolve STARTFRAME=0 NUMFRAMES=8 RATE=8.0
#exec MESH SEQUENCE MESH=TankMLProj SEQ=RevolveLoop STARTFRAME=0 NUMFRAMES=7 RATE=7.0

#exec MESHMAP NEW MESHMAP=TankMLProj MESH=TankMLProj
#exec MESHMAP SCALE MESHMAP=TankMLProj X=2.5 Y=0.35 Z=0.7

#exec obj load file=..\Textures\UExplosionsSet01.utx package=UExplosionsSet01

#exec AUDIO IMPORT NAME="TankMLProjAmb" FILE=SOUNDS\TankMLProjAmb.wav GROUP="TankMLLoop"

var texture RandTexFX[8];
var TankMLProjFX TProjTrail;
var() const float ProjLength;
var TankMLProjCor TMLTrail;
var() vector TMLTrailOffset;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		RandTexFX, TProjTrail, TMLTrail;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if (Level.NetMode != NM_Client)
	{
		TProjTrail = Spawn(Class'TankMLProjFX', Self);
		TProjTrail.DrawScale = DrawScale;
		TProjTrail.ScaleGlow = ScaleGlow;
		
		ApplyRandomParticles(Self);
		ApplyRandomParticles(TProjTrail);
		
		Velocity = Speed * vector(Rotation);
		LoopAnim('RevolveLoop', Speed/ProjLength/10);
		
		TMLTrail = Spawn(Class'TankMLProjCor', Self,, Location + (TMLTrailOffset >> Rotation));
		TMLTrail.PrePivot = TMLTrailOffset >> Rotation;
	}
	
	SetTimer(0.1, True);
}

simulated function Timer()
{
	if (TMLTrail != None)
		TMLTrail.PrePivot = TMLTrailOffset >> Rotation;
}

simulated function ApplyRandomParticles(Actor A)
{
local byte i;

	if (A != None)
	{
		for (i = 0; i < ArrayCount(RandTexFX); i++)
			A.MultiSkins[i] = RandTexFX[Rand(ArrayCount(RandTexFX))];
	}
}

simulated function Destroyed()
{
	if (TProjTrail != None)
		TProjTrail.Destroy();
	if (TMLTrail != None)
		TMLTrail.Destroy();

	Super.Destroyed();
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if (Other != Owner && (!Other.IsA('Projectile') || Other.CollisionRadius > 0))
		Explode(HitLocation, vect(0,0,1));
}

function BlowTheHellUp(vector HitLocation, vector HitNormal)
{
	local byte i;

	HurtRadiusOwned(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
   
	Spawn(Class'TankMLProjExplController',,, HitLocation, rotator(HitNormal));
	Spawn(Class'TankMLSmkRing',,, HitLocation, rotator(HitNormal));
	Spawn(Class'TankMLSmkRing',,, HitLocation, rotator(HitNormal) + rot(0,0,2731));
	Spawn(Class'TankMLShockRing',,, HitLocation + HitNormal, rotator(HitNormal));

	ClientShakes(DamageRadius*1.07);

    MakeNoise(3.75);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	BlowTheHellUp(HitLocation, HitNormal);
	Destroy();
}

defaultproperties
{
	RandTexFX(0)=Texture'UExplosionsSet01.ExplF04'
	RandTexFX(1)=Texture'UExplosionsSet01.ExplF05'
	RandTexFX(2)=Texture'UExplosionsSet01.ExplF06'
	RandTexFX(3)=Texture'UExplosionsSet01.ExplF07'
	RandTexFX(4)=Texture'UExplosionsSet01.ExplF08'
	RandTexFX(5)=Texture'UExplosionsSet01.ExplF09'
	RandTexFX(6)=Texture'UExplosionsSet01.ExplF10'
	RandTexFX(7)=Texture'UExplosionsSet01.ExplF11'
	ProjLength=320.000000
	TMLTrailOffset=(X=96.000000)
	DamageRadius=1400.000000
	speed=6000.000000
	MaxSpeed=12000.000000
	Damage=1500.000000
	MomentumTransfer=100000
	MyDamageType="MegaBurned"
	ExplosionDecal=Class'XTreadVeh.TankMLMark'
	RemoteRole=ROLE_SimulatedProxy
	AmbientSound=Sound'XTreadVeh.TankMLLoop.TankMLProjAmb'
	Style=STY_Translucent
	Texture=Texture'XVehicles.Misc.TransInvis'
	Mesh=LodMesh'XTreadVeh.TankMLProj'
	DrawScale=0.750000
	ScaleGlow=1.500000
	bUnlit=True
	bParticles=True
	bRandomFrame=True
	MultiSkins(0)=Texture'UExplosionsSet01.ExplF01'
	MultiSkins(1)=Texture'UExplosionsSet01.ExplF02'
	MultiSkins(2)=Texture'UExplosionsSet01.ExplF03'
	MultiSkins(3)=Texture'UExplosionsSet01.ExplF04'
	MultiSkins(4)=Texture'UExplosionsSet01.ExplF05'
	MultiSkins(5)=Texture'UExplosionsSet01.ExplF06'
	MultiSkins(6)=Texture'UExplosionsSet01.ExplF07'
	MultiSkins(7)=Texture'UExplosionsSet01.ExplF08'
	SoundRadius=128
	SoundVolume=200
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=80
	LightRadius=8
	Mass=500.000000
}
