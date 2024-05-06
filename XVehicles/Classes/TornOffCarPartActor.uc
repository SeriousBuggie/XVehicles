Class TornOffCarPartActor extends Effects;

#exec AUDIO IMPORT FILE="Sounds\HeavyPartHit01.WAV" NAME="HeavyPartHit01" GROUP="Impacts"
#exec AUDIO IMPORT FILE="Sounds\HeavyPartHit02.WAV" NAME="HeavyPartHit02" GROUP="Impacts"
#exec AUDIO IMPORT FILE="Sounds\HeavyPartHit03.WAV" NAME="HeavyPartHit03" GROUP="Impacts"

var byte Heavyness;
var rotator IniRotRate;
var float InitLifeSpan;

var() sound RndLightHitSnds[3];
var() sound RndMediumHitSnds[3];
var() sound RndHeavyHitSnds[3];

/*function PostBeginPlay()
{
	Velocity = Owner.Velocity+VRand()*400;
	Velocity.Z+=300;
	LifeSpan = 1+FRand()*4;
	RotationRate = RotRand(True);
}*/

function SetInitialSpeed(byte PartMass)
{
	Heavyness = Min(2,PartMass);

	if (Heavyness < 2)
		Velocity = Owner.Velocity+VRand()*(400 - Heavyness*175);
	else
		Velocity = Owner.Velocity+VRand()*100;

	if (Heavyness < 2)
		Velocity.Z+=300;
	else
		Velocity.Z+=600;

	LifeSpan = Default.LifeSpan + FRand()*4;
	InitLifeSpan = LifeSpan;

	if (Heavyness < 2)
	{
		if (Heavyness == 0)
			RotationRate = RotRand(True);
		else
			RotationRate = RotRand(True) / 20;
	}
	else
	{
		bBounce = False;
		RotationRate = RotRand(True) / 30;
	}

	IniRotRate = RotationRate;
}

function HitWall( vector HitNormal, actor HitWall )
{
	if (Heavyness == 0)
		Velocity = MirrorVectorByNormal(Velocity,HitNormal)*0.65;
	else if (Heavyness == 1)
		Velocity = MirrorVectorByNormal(Velocity,HitNormal)*0.45;

	//Hit sounds
	if (VSize(Velocity)>=50)
	{
	if (Heavyness == 0)
		PlaySound(RndLightHitSnds[Min(Rand(3),2)]);
	else if (Heavyness == 0)
		PlaySound(RndMediumHitSnds[Min(Rand(3),2)]);
	else
		PlaySound(RndHeavyHitSnds[Min(Rand(3),2)]);
	}
}
function Landed( vector HitNormal )
{
	if (Heavyness == 0)
		Velocity = MirrorVectorByNormal(Velocity,HitNormal)*0.7;
	else if (Heavyness == 0)
		Velocity = MirrorVectorByNormal(Velocity,HitNormal)*0.35;

	//Hit sounds
	if (VSize(Velocity)>=50)
	{
	if (Heavyness == 0)
		PlaySound(RndLightHitSnds[Min(Rand(3),2)]);
	else if (Heavyness == 0)
		PlaySound(RndMediumHitSnds[Min(Rand(3),2)]);
	else
		PlaySound(RndHeavyHitSnds[Min(Rand(3),2)]);
	}

	if( VSize(Velocity)<50 )
	{
		bMovable = False;
		SetPhysics(PHYS_None);
	}
}
function Tick( float Delta )
{
	if( LifeSpan < 1 )
	{
		Style = STY_Translucent;
		ScaleGlow = LifeSpan;
		AmbientGlow = ScaleGlow * 255;
	}

	if (VSize(Velocity)>=50)
		RotationRate = LifeSpan * IniRotRate / InitLifeSpan;
	else if (bFixedRotationDir)
		bFixedRotationDir = False;
}

function CopyDisplayFrom( Actor Other, Vehicle OwnVeh )
{
	local int i;

	Mesh = Other.Mesh;
	AnimSequence = Other.AnimSequence;
	AnimFrame = Other.AnimFrame;
	PrePivot = Other.PrePivot;
	Style = Other.Style;
	DrawType = Other.DrawType;
	DrawScale = Other.DrawScale;


	if (OwnVeh != None)
	{
		Skin = OwnVeh.WreckedTex;
		Texture = OwnVeh.WreckedTex;
		For (i=0; i<8; i++)
			MultiSkins[i] = OwnVeh.WreckedTex;
	}
	else
	{
		Skin = Other.Skin;
		Texture = Other.Texture;
		For (i=0; i<8; i++)
			MultiSkins[i] = Other.MultiSkins[i];
	}
}

defaultproperties
{
	RndLightHitSnds(0)=Sound'XVehicles.Impacts.VehicleCollision02'
	RndLightHitSnds(1)=Sound'XVehicles.Impacts.VehicleCollision04'
	RndLightHitSnds(2)=Sound'XVehicles.Impacts.VehicleCollision05'
	RndMediumHitSnds(0)=Sound'XVehicles.Impacts.VehicleCollision01'
	RndMediumHitSnds(1)=Sound'XVehicles.Impacts.VehicleCollision03'
	RndMediumHitSnds(2)=Sound'XVehicles.Impacts.VehicleCollision07'
	RndHeavyHitSnds(0)=Sound'XVehicles.Impacts.HeavyPartHit01'
	RndHeavyHitSnds(1)=Sound'XVehicles.Impacts.HeavyPartHit02'
	RndHeavyHitSnds(2)=Sound'XVehicles.Impacts.HeavyPartHit03'
	Physics=PHYS_Falling
	RemoteRole=ROLE_None
	LifeSpan=20.000000
	DrawType=DT_Mesh
	Fatness=75
	CollisionRadius=4.000000
	CollisionHeight=4.000000
	bCollideWorld=True
	bBounce=True
	bFixedRotationDir=True
}
