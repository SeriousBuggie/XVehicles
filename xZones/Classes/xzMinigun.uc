//=============================================================================
// xzMinigun.
//=============================================================================
class xzMinigun expands Minigun2;

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
    local int rndDam;

	if (Other != None)
		Spawn(class'xZoneInstantHitPoint',,, HitLocation+HitNormal);

    if (Other == Level) 
        Spawn(class'UT_LightWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
    else if ( (Other!=self) && (Other!=Owner) && (Other != None) ) 
    {
        if ( !Other.bIsPawn && !Other.IsA('Carcass') )
            spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9); 
        else
            Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);

        if ( Other.IsA('Bot') && (FRand() < 0.2) )
            Pawn(Other).WarnTarget(Pawn(Owner), 500, X);
        rndDam = 9 + Rand(6);
        if ( FRand() < 0.2 )
            X *= 2.5;
        Other.TakeDamage(rndDam, Pawn(Owner), HitLocation, rndDam*500.0*X, MyDamageType);
    }
}

defaultproperties
{
}
