//=============================================================================
// xzSniperRifle.
//=============================================================================
class xzSniperRifle expands SniperRifle;

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
    local UT_Shellcase s;

	if (Other != None)
		Spawn(class'xZoneInstantHitPoint',,, HitLocation+HitNormal);

    s = Spawn(class'UT_ShellCase',, '', Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * FireOffset.Y+5.0) * Y - Z * 1);
    if ( s != None ) 
    {
        s.DrawScale = 2.0;
        s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);              
    }
    if (Other == Level) 
        Spawn(class'UT_HeavyWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
    else if ( (Other != self) && (Other != Owner) && (Other != None) ) 
    {
        if ( Other.bIsPawn )
            Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);
        if ( Other.bIsPawn && (HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight) 
            && (instigator.IsA('PlayerPawn') || (instigator.IsA('Bot') && !Bot(Instigator).bNovice)) )
            Other.TakeDamage(100, Pawn(Owner), HitLocation, 35000 * X, AltDamageType);
        else
            Other.TakeDamage(45,  Pawn(Owner), HitLocation, 30000.0*X, MyDamageType);   
        if ( !Other.bIsPawn && !Other.IsA('Carcass') )
            spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9); 
    }
}

defaultproperties
{
}
