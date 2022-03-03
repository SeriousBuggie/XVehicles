class JTDXLPlasma expands JSDXLPlasma;

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if (Other != Owner && (!Other.IsA('Projectile') || Other.CollisionRadius > 0))
	{
		Explode(HitLocation, vect(0,0,1));
		Other.TakeDamage(Damage, Instigator, HitLocation, Normal(Other.Location - Location)*MomentumTransfer, MyDamageType);
	}
}

    function BlowUp(vector HitLocation)
    {
        //HurtRadius(Damage , 62.5, MyDamageType, MomentumTransfer, HitLocation);
	Spawn(Class'JTDXPlasmaExpl');
        MakeNoise(1.0);
    }

defaultproperties
{
      Damage=70.000000
      MomentumTransfer=9000
      ExplosionDecal=Class'Botpack.BoltScorch'
      MultiSkins(0)=FireTexture'UnrealShare.Effect1.FireEffect1pb'
      MultiSkins(1)=FireTexture'UnrealShare.Effect1.FireEffect1o'
      SoundPitch=32
      LightHue=0
      LightSaturation=0
}
