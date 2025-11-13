class JPadEmitPrtc expands Effects;

#exec MESH IMPORT MESH=JPadEmitPrtc ANIVFILE=MODELS\JPadEmitPrtc_a.3d DATAFILE=MODELS\JPadEmitPrtc_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=JPadEmitPrtc X=0 Y=0 Z=0 PITCH=-64

#exec MESH SEQUENCE MESH=JPadEmitPrtc SEQ=All STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=JPadEmitPrtc MESH=JPadEmitPrtc
#exec MESHMAP SCALE MESHMAP=JPadEmitPrtc X=0.02 Y=0.02 Z=0.2

#exec TEXTURE IMPORT NAME=YellowStreak FILE=JParticles\YellowStreak.bmp GROUP=Particles FLAGS=2
#exec MESHMAP SETTEXTURE MESHMAP=JPadEmitPrtc NUM=1 TEXTURE=YellowStreak

var float Count, Ratio1, Ratio2;
var JPadEmitPrtc Next;

simulated function PostBeginPlay()
{
local rotator RRo;

	RRo = Rotation;
	RRo.Roll = 2 * Rand(16384);
	SetRotation(RRo);
	LifeSpan = 1.5 + FRand();
	
	Ratio1 = Default.ScaleGlow / 0.1;
}

simulated function Tick( float DeltaTime)
{
	local UTJumpPad Host;
	if (LifeSpan <= 1.0)
	{
		bHidden = true;
		Disable('Tick');
		Host = UTJumpPad(Owner);
		if (Host != None)
		{
			Next = Host.Streaks;
			Host.Streaks = self;
		}
		return;
	}
	if (Count < 0.1)
	{
		Count += DeltaTime;
		ScaleGlow = Count * Ratio1;
	}
	else
	{
		if (Ratio2 <= 0)
			Ratio2 = Default.ScaleGlow / (LifeSpan - 1.0);
		else
			ScaleGlow = (LifeSpan - 1.0) * Ratio2;
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
