class ShraliProj expands xTreadVehProjectile;

#exec TEXTURE IMPORT NAME=ShraliProjCor FILE=EFFECTS\ShraliProjCor.bmp GROUP=Effects FLAGS=2

#exec AUDIO IMPORT NAME="ShraliProjLoop" FILE=SOUNDS\ShraliProjLoop.wav GROUP="Shrali"
#exec AUDIO IMPORT NAME="ShraliExpl" FILE=SOUNDS\ShraliExpl.wav GROUP="Shrali"

var float DistCount;
var bool bFirstSmk;
var ShraliProjSpirHead spsh;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		spsh;
}

simulated function PostBeginPlay()
{
	if (Level.NetMode != NM_Client)
	{
		Velocity = Speed * vector(Rotation);
		
		spsh = Spawn(Class'ShraliProjSpirHead',Self);
		spsh.PrePivotRel = vect(-40,0,0);
	}

	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	if (Level.NetMode == NM_Client)
		SetRotation(rotator(Velocity));

	Super.PostNetBeginPlay();
}

simulated function Tick(float DeltaTime)
{
local rotator r;

	DistCount += VSize(Location-OldLocation);

	if (!bFirstSmk && DistCount >= 420.0)
	{
		bFirstSmk = True;
		DistCount = 0;

		r = Rotation;
		r.Roll = Rand(16384)*2;
		Spawn(Class'EnLinesLineRed',,,, r);
		r.Roll = Rand(16384)*2;
		Spawn(Class'EnLinesLineRed',,,, r);
	}
	else if (bFirstSmk && DistCount >= 80.0)
	{
		DistCount = 0;

		r = Rotation;
		r.Roll = Rand(16384)*2;
		Spawn(Class'EnLinesLineRed',,,, r);
		r.Roll = Rand(16384)*2;
		Spawn(Class'EnLinesLineRed',,,, r);
	}
}

simulated function Destroyed()
{
	if (spsh != None)
		spsh.Destroy();

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

    HurtRadiusOwned(Damage , 1350.0, MyDamageType, MomentumTransfer, HitLocation);
	
	Spawn(Class'BigRockSpawner',,, HitLocation, rotator(HitNormal));

	Spawn(Class'ShraliFastShock',,, HitLocation, rotator(HitNormal));
	Spawn(Class'ShraliFastShockA',,, HitLocation, rotator(HitNormal));
	Spawn(Class'ShraliFastShockB',,, HitLocation, rotator(HitNormal));
	Spawn(Class'ShraliShock',,, HitLocation + HitNormal/2, rotator(HitNormal));
	Spawn(Class'ShraliShockSprt',,,HitLocation);
	Spawn(Class'ShraliSpirR',,,HitLocation,rotator(HitNormal));

	Spawn(Class'ShraliCorona',,,HitLocation);

	PlaySound(Sound'ShraliExpl',,125.0,,11500);
	ClientShakes(3125);
	ClientFlashes();
	
    MakeNoise(7.5);
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
      spsh=None
      speed=4500.000000
      MaxSpeed=9000.000000
      Damage=3800.000000
      MomentumTransfer=300000
      MyDamageType="NaliEnergy"
      ExplosionDecal=Class'XTreadVeh.ShraliProjDecal'
      bNetTemporary=False
      RemoteRole=ROLE_SimulatedProxy
      AmbientSound=Sound'XTreadVeh.Shrali.ShraliProjLoop'
      DrawType=DT_Sprite
      Style=STY_Translucent
      Texture=Texture'XTreadVeh.Effects.ShraliProjCor'
      DrawScale=0.850000
      ScaleGlow=1.600000
      SpriteProjForward=64.000000
      bUnlit=True
      SoundRadius=80
      SoundVolume=60
      LightType=LT_Steady
      LightEffect=LE_NonIncidence
      LightBrightness=100
      LightRadius=16
      bFixedRotationDir=True
      Mass=350.000000
      RotationRate=(Roll=-100000)
}
