//////////////////////////////////////////////////////////////
//	Nali Weapons III Cybots projectile
//				Feralidragon (15-01-2011)
//
// NW3 CYBOT LAUNCHER BUILD 1.00
//////////////////////////////////////////////////////////////

class CybProj expands NaliProjectile;

#exec MESH IMPORT MESH=CybProj ANIVFILE=MODELS\CybProj_a.3d DATAFILE=MODELS\CybProj_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=CybProj STRENGTH=0.25
#exec MESH ORIGIN MESH=CybProj X=0 Y=0 Z=0 YAW=128

#exec MESH SEQUENCE MESH=CybProj SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=CybProj SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=CybProj MESH=CybProj
#exec MESHMAP SCALE MESHMAP=CybProj X=0.1 Y=0.05 Z=0.1

#exec TEXTURE IMPORT NAME=CybProjTrailRed FILE=Coronas\CybProjTrailRed.bmp GROUP=Coronas FLAGS=2
#exec TEXTURE IMPORT NAME=CybProjTrailBlue FILE=Coronas\CybProjTrailBlue.bmp GROUP=Coronas FLAGS=2
#exec TEXTURE IMPORT NAME=CybProjTrailGreen FILE=Coronas\CybProjTrailGreen.bmp GROUP=Coronas FLAGS=2
#exec TEXTURE IMPORT NAME=CybProjTrailYellow FILE=Coronas\CybProjTrailYellow.bmp GROUP=Coronas FLAGS=2
#exec MESHMAP SETTEXTURE MESHMAP=CybProj NUM=1 TEXTURE=CybProjTrailRed


var() class<Effects> TeamExplFX;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	RotationRate.Roll = -90000;
}

simulated function ExplodeX(vector HitLocation, vector HitNormal, optional actor A)
{
	SpawnExplosionFX( HitLocation, HitNormal, A);
	Super.ExplodeX(HitLocation, HitNormal, A);
}

function SpawnExplosionFX(vector HitLocation, vector HitNormal, optional actor A)
{
	Spawn(TeamExplFX);
}

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
	if (Other == Owner || Other == Instigator)
		return;
	
	Super.ProcessTouch(Other, HitLocation);
}

defaultproperties
{
      TeamExplFX=Class'XChopVeh.CybProjExplRed'
      TrailClass1=Class'XChopVeh.CybProjCor'
      bWaterHitFX=True
      WaterSpeedScale=1.000000
      WaterSplashType=2
      bDirectHit=True
      ExplosionNoise=1.000000
      DmgRadius=64.000000
      bNeverHurtInstigator=True
      bNoHurtTeam=True
      bDirectionalBlow=True
      speed=10000.000000
      MaxSpeed=22500.000000
      Damage=30.000000
      MomentumTransfer=25500
      MyDamageType="CybotLaser"
      ExplosionDecal=Class'XChopVeh.CybProjDecal'
      Style=STY_Translucent
      Mesh=LodMesh'XChopVeh.CybProj'
      DrawScale=8.000000
      ScaleGlow=2.500000
      bUnlit=True
      MultiSkins(1)=Texture'XChopVeh.Coronas.CybProjTrailRed'
      LightType=LT_Steady
      LightEffect=LE_NonIncidence
      LightBrightness=50
      LightRadius=5
      bFixedRotationDir=True
}
