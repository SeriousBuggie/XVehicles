//Water Trail FX
class VehWaterTrail expands Effects;

#exec MESH IMPORT MESH=WaterTrail ANIVFILE=MODELS\WaterTrail_a.3d DATAFILE=MODELS\WaterTrail_d.3d X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH ORIGIN MESH=WaterTrail X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=WaterTrail SEQ=All STARTFRAME=0 NUMFRAMES=2
#exec MESH SEQUENCE MESH=WaterTrail SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterTrail SEQ=MaxExpand STARTFRAME=1 NUMFRAMES=1
#exec MESH SEQUENCE MESH=WaterTrail SEQ=Expand STARTFRAME=0 NUMFRAMES=2 RATE=1.0

#exec MESHMAP NEW MESHMAP=WaterTrail MESH=WaterTrail
#exec MESHMAP SCALE MESHMAP=WaterTrail X=2.0 Y=2.0 Z=4.0

#exec TEXTURE IMPORT NAME=WaterTrailDef FILE=EFFECTS\WaterTrailDef.bmp GROUP=Skins FLAGS=2
#exec MESHMAP SETTEXTURE MESHMAP=WaterTrail NUM=1 TEXTURE=WaterTrailDef

var float InitDrawScale, FinalScale;
var bool inWater;

simulated function PostBeginPlay()
{
	Velocity = vect(0,0,-250);
}

simulated function Tick(float DeltaTime)
{
	ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
	DrawScale = InitDrawScale + (Default.LifeSpan - LifeSpan) * FinalScale * InitDrawScale / Default.LifeSpan;
}

simulated function ZoneChange( ZoneInfo newZone)
{
	if (!inWater && newZone.bWaterZone)
	{
		Move(vect(0,0,2));
		Velocity = 0.1*Velocity;
		SetPhysics(PHYS_None);
		Buoyancy = 0.0;

		if (VSize(newZone.ZoneVelocity) > 30)
		{
			SetPhysics(PHYS_Projectile);
			Velocity += newZone.ZoneVelocity;
			SetRotation(rotator(AnimFrame*InitDrawScale*256*vector(Rotation) + newZone.ZoneVelocity));
		}

		inWater = True;
	}
}

defaultproperties
{
	InitDrawScale=1.000000
	FinalScale=3.000000
	Physics=PHYS_Falling
	RemoteRole=ROLE_None
	LifeSpan=1.000000
	AnimSequence="Expand"
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=LodMesh'WaterTrail'
	ScaleGlow=1.750000
	bUnlit=True
	bBounce=True
	Buoyancy=10.000000
}
