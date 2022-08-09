class xVehiclesProjectile expands Projectile;

var(Projectile) float    DamageRadius; 

function HurtRadiusOwned( float DamageAmount, float DamageRadius, name DamageName, float Momentum, vector HitLocation )
{
    local actor Victims;
    local float damageScale, dist;
    local vector dir;
    
    if( bHurtEntry )
        return;

    bHurtEntry = true;
    foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
    {
        if( Victims != self && Victims != Owner)
        {
            dir = Victims.Location - HitLocation;
            dist = FMax(1,VSize(dir));
            dir = dir/dist; 
            damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
            Victims.TakeDamage
            (
                damageScale * DamageAmount,
                Instigator, 
                Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
                (damageScale * Momentum * dir),
                DamageName
            );
        } 
    }
    bHurtEntry = false;
}


simulated function ClientShakes(float dist)
{
local Pawn P;
local float d;

	For ( P=Level.PawnList; P!=None; P=P.nextPawn )
	{
		if (PlayerPawn(P) != None && VSize(P.Location - Location) <= dist)
		{
			d = dist - VSize(P.Location - Location);
			PlayerPawn(P).ShakeView( 0.5, d*2000.0/dist , d*200.0/dist);
		}
	}
}

simulated function ClientFlashes()
{
local Vector EndFlashFog;
local float f;
local PlayerPawn p;

	//EndFlashFog.X=1;	EndFlashFog.Y=3;	EndFlashFog.Z=0;
	EndFlashFog.X=0.95;	EndFlashFog.Y=0.15;	EndFlashFog.Z=0;

	ForEach VisibleActors( class'PlayerPawn', p)
		p.ClientFlash( 2, 1000*EndFlashFog );
}

defaultproperties
{
}
