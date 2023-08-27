class JTDXLPlasma expands JSDXLPlasma;

function BlowUp(vector HitLocation)
{
    //HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
	Spawn(Class'JTDXPlasmaExpl');
    MakeNoise(1.0);
}

defaultproperties
{
	DamageRadius=62.500000
	Damage=70.000000
	MomentumTransfer=9000
	ExplosionDecal=Class'Botpack.BoltScorch'
	MultiSkins(0)=FireTexture'UnrealShare.Effect1.FireEffect1pb'
	MultiSkins(1)=FireTexture'UnrealShare.Effect1.FireEffect1o'
	SoundPitch=32
	LightHue=0
	LightSaturation=0
}
