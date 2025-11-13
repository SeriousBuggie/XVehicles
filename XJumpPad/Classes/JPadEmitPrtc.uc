class JPadEmitPrtc expands Effects;

#exec MESH IMPORT MESH=JPadEmitPrtc ANIVFILE=MODELS\JPadEmitPrtc_a.3d DATAFILE=MODELS\JPadEmitPrtc_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=JPadEmitPrtc X=0 Y=0 Z=0 PITCH=-64

#exec MESH SEQUENCE MESH=JPadEmitPrtc SEQ=All STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=JPadEmitPrtc MESH=JPadEmitPrtc
#exec MESHMAP SCALE MESHMAP=JPadEmitPrtc X=0.02 Y=0.02 Z=0.2

#exec TEXTURE IMPORT NAME=YellowStreak FILE=JParticles\YellowStreak.bmp GROUP=Particles FLAGS=2
#exec MESHMAP SETTEXTURE MESHMAP=JPadEmitPrtc NUM=1 TEXTURE=YellowStreak

var float Count, Ratio1, Ratio2;

simulated function PostBeginPlay()
{
local rotator RRo;

	RRo.Roll = 2 * Rand(16384);
	RRo.Yaw = Rotation.Yaw;
	RRo.Pitch = Rotation.Pitch;
	SetRotation(RRo);
	LifeSpan = 0.5 + FRand();
	
	Ratio1 = Default.ScaleGlow / 0.1;
}

simulated function Tick( float DeltaTime)
{
	if (Count < 0.1)
	{
		Count += DeltaTime;
		ScaleGlow = Count * Ratio1;
	}
	else
	{
		if (Ratio2 <= 0)
			Ratio2 = Default.ScaleGlow / LifeSpan;
		else
			ScaleGlow = LifeSpan * Ratio2;
	}
}

defaultproperties
{
	Physics=PHYS_Projectile
	RemoteRole=ROLE_None
	LifeSpan=5.000000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=LodMesh'JPadEmitPrtc'
	ScaleGlow=1.750000
	bUnlit=True
}
