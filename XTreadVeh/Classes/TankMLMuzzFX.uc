class TankMLMuzzFX expands xTreadVehEffects;

#exec MESH IMPORT MESH=TankMLMuzzFX ANIVFILE=MODELS\TankMLMuzzFX_a.3d DATAFILE=MODELS\TankMLMuzzFX_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TankMLMuzzFX X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=TankMLMuzzFX SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TankMLMuzzFX SEQ=Still STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW MESHMAP=TankMLMuzzFX MESH=TankMLMuzzFX
#exec MESHMAP SCALE MESHMAP=TankMLMuzzFX X=1.25 Y=0.01 Z=5.0

var() texture FireTexFX[15];
var() int FireN[8];
var() float FireAnimRate;

simulated function PostBeginPlay()
{
	SetTimer(1/FireAnimRate, True);
}

simulated function Timer()
{
local byte i;

	for (i = 0; i < 8; i++)
	{
		if (FireN[i] < ArrayCount(FireTexFX) && FireN[i] >= 0)
			MultiSkins[i] = FireTexFX[FireN[i]];
		
		FireN[i]++;
	}
	
	if (FireN[0] >= ArrayCount(FireTexFX))
		Destroy();
}

defaultproperties
{
	FireTexFX(0)=Texture'UExplosionsSet01.ExplF01'
	FireTexFX(1)=Texture'UExplosionsSet01.ExplF02'
	FireTexFX(2)=Texture'UExplosionsSet01.ExplF03'
	FireTexFX(3)=Texture'UExplosionsSet01.ExplF04'
	FireTexFX(4)=Texture'UExplosionsSet01.ExplF05'
	FireTexFX(5)=Texture'UExplosionsSet01.ExplF06'
	FireTexFX(6)=Texture'UExplosionsSet01.ExplF07'
	FireTexFX(7)=Texture'UExplosionsSet01.ExplF08'
	FireTexFX(8)=Texture'UExplosionsSet01.ExplF09'
	FireTexFX(9)=Texture'UExplosionsSet01.ExplF10'
	FireTexFX(10)=Texture'UExplosionsSet01.ExplF11'
	FireTexFX(11)=Texture'UExplosionsSet01.ExplF12'
	FireTexFX(12)=Texture'UExplosionsSet01.ExplF13'
	FireTexFX(13)=Texture'UExplosionsSet01.ExplF14'
	FireTexFX(14)=Texture'XVehicles.Misc.TransInvis'
	FireN(0)=-7
	FireN(1)=-6
	FireN(2)=-5
	FireN(3)=-4
	FireN(4)=-3
	FireN(5)=-2
	FireN(6)=-1
	FireAnimRate=37.500000
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Mesh
	Style=STY_Translucent
	Texture=Texture'XVehicles.Misc.TransInvis'
	Mesh=LodMesh'XTreadVeh.TankMLMuzzFX'
	DrawScale=1.500000
	ScaleGlow=1.500000
	bUnlit=True
	bParticles=True
	bRandomFrame=True
	MultiSkins(0)=Texture'XVehicles.Misc.TransInvis'
	MultiSkins(1)=Texture'XVehicles.Misc.TransInvis'
	MultiSkins(2)=Texture'XVehicles.Misc.TransInvis'
	MultiSkins(3)=Texture'XVehicles.Misc.TransInvis'
	MultiSkins(4)=Texture'XVehicles.Misc.TransInvis'
	MultiSkins(5)=Texture'XVehicles.Misc.TransInvis'
	MultiSkins(6)=Texture'XVehicles.Misc.TransInvis'
	MultiSkins(7)=Texture'XVehicles.Misc.TransInvis'
}
