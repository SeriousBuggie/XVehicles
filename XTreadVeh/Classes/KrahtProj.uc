class KrahtProj expands xTreadVehProjectile;

#exec MESH IMPORT MESH=KrahtProj ANIVFILE=MODELS\KrahtProj_a.3d DATAFILE=MODELS\KrahtProj_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH LODPARAMS MESH=KrahtProj STRENGTH=0.35
#exec MESH ORIGIN MESH=KrahtProj X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=KrahtProj SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=KrahtProj SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=KrahtProj MESH=KrahtProj
#exec MESHMAP SCALE MESHMAP=KrahtProj X=0.15 Y=0.1 Z=0.1

#exec TEXTURE IMPORT NAME=KrahProjTex FILE=SKINS\KrahProjTex.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=KrahtProj NUM=1 TEXTURE=KrahProjTex

#exec TEXTURE IMPORT NAME=KrahProjCor FILE=CORONAS\KrahProjCor.bmp GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=KrahtProj NUM=2 TEXTURE=KrahProjCor

#exec AUDIO IMPORT NAME="KrahtProjAmb" FILE=SOUNDS\KrahtProjAmb.wav GROUP="Kraht"

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	Velocity = Speed * vector(Rotation);
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

	Spawn(Class'KrahtProjExpl');
	Spawn(Class'KrahtCorona',,, HitLocation);
	Spawn(Class'KrahtShock',,, HitLocation + HitNormal/2, rotator(HitNormal));

	ClientShakes(DamageRadius*1.14);
	
    MakeNoise(2.5);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	BlowTheHellUp(HitLocation, HitNormal);
	Destroy();
}

defaultproperties
{
	DamageRadius=550.000000
	speed=4500.000000
	MaxSpeed=9000.000000
	Damage=750.000000
	MomentumTransfer=50000
	MyDamageType="KrahtEnergy"
	ExplosionDecal=Class'KrahtBlastMark'
	RemoteRole=ROLE_SimulatedProxy
	AmbientSound=Sound'XTreadVeh.Kraht.KrahtProjAmb'
	Style=STY_Translucent
	Mesh=LodMesh'KrahtProj'
	DrawScale=6.500000
	ScaleGlow=1.750000
	bUnlit=True
	SoundRadius=150
	SoundVolume=150
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=80
	LightHue=40
	LightSaturation=240
	LightRadius=10
	Mass=150.000000
}
