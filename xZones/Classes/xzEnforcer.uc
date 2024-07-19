//=============================================================================
// xzEnforcer.
//=============================================================================
class xzEnforcer expands Enforcer;

function SetSwitchPriority(pawn Other)
{
    local int i;

    if ( PlayerPawn(Other) != None )
    {
        Super(TournamentWeapon).SetSwitchPriority(Other);

        // also set double switch priority

        for ( i=0; i<20; i++)
            if ( PlayerPawn(Other).WeaponPriority[i] == 'xzDoubleEnforcer' )
            {
                DoubleSwitchPriority = i;
                return;
            }
    }       
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
    local UT_Shellcase s;
    local vector realLoc;

	if (Other != None)
		Spawn(class'xZoneInstantHitPoint',,, HitLocation+HitNormal);

    realLoc = Owner.Location + CalcDrawOffset();
    s = Spawn(class'UT_ShellCase',, '', realLoc + 20 * X + FireOffset.Y * Y + Z);
    if ( s != None )
        s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);              
    if (Other == Level) 
    {
        if ( bIsSlave || (SlaveEnforcer != None) )
            Spawn(class'UT_LightWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
        else
            Spawn(class'UT_WallHit',,, HitLocation+HitNormal, Rotator(HitNormal));
    }
    else if ((Other != self) && (Other != Owner) && (Other != None) ) 
    {
        if ( FRand() < 0.2 )
            X *= 5;
        Other.TakeDamage(HitDamage, Pawn(Owner), HitLocation, 3000.0*X, MyDamageType);
        if ( !Other.bIsPawn && !Other.IsA('Carcass') )
            spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
        else
            Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);

    }       
}

defaultproperties
{
}
