//=============================================================================
// FixBolt.
//=============================================================================
class FixBolt expands PBolt;

var float LastFix;
var() Sound FixSounds[4];

var string LastLevel;

simulated function CheckBeam(vector X, float DeltaTime)
{
	local Actor HitActor;
	local vector HitLocation, HitNormal, Momentum;
	local bool OldColActors;

	// [Higor] Fix for firing through walls (check between player eye and bolt start first)
	if ( (Position == 0) && (Instigator != None) )
	{
		OldColActors = Instigator.bCollideActors;
		if (OldColActors)
			Instigator.SetCollision(false);
		HitActor = Trace( HitLocation, HitNormal, Location, Instigator.Location + vect(0,0,1)*Instigator.BaseEyeHeight, true);
	}
	
	// check to see if hits something, else spawn or orient child
	if ( (HitActor == None) || (HitActor == Instigator) )
		HitActor = Trace(HitLocation, HitNormal, Location + BeamSize * X, Location, true);
	if (OldColActors)
		Instigator.SetCollision(true);

	if ( (HitActor != None)	&& (HitActor != Instigator)
		&& (HitActor.bProjTarget || (HitActor == Level) || (HitActor.bBlockActors && HitActor.bBlockPlayers)) 
		&& ((Pawn(HitActor) == None) || Pawn(HitActor).AdjustHitLocation(HitLocation, Velocity)) )
	{
		if ( Level.Netmode != NM_Client )
		{			
			if ( DamagedActor == None )
			{
				AccumulatedDamage = FMin(0.5 * (Level.TimeSeconds - LastHitTime), 0.1);
				if (int(Level.Game.GetPropertyText("NoLockdown")) == 1)
				    Momentum = vect(0,0,0);
				else
				    Momentum = MomentumTransfer * X * AccumulatedDamage;
				FixDamage(HitActor, damage * AccumulatedDamage, instigator, HitLocation,
					Momentum, MyDamageType);
				AccumulatedDamage = 0;
			}				
			else if ( DamagedActor != HitActor )
			{
   				if (int(Level.Game.GetPropertyText("NoLockdown")) == 1)
				    Momentum = vect(0,0,0);
				else
				    Momentum = MomentumTransfer * X * AccumulatedDamage;
				FixDamage(DamagedActor, damage * AccumulatedDamage, instigator, HitLocation,
					Momentum, MyDamageType);
				AccumulatedDamage = 0;
			}				
			LastHitTime = Level.TimeSeconds;
			DamagedActor = HitActor;
			AccumulatedDamage += DeltaTime;
			if ( AccumulatedDamage > 0.22 )
			{
				// repeated hits to the same actor
				if ( DamagedActor.IsA('Carcass') && (FRand() < 0.09) )
					AccumulatedDamage = 35/damage;
   				if (int(Level.Game.GetPropertyText("NoLockdown")) > 0)
				    Momentum = vect(0,0,0);
				else
				    Momentum = MomentumTransfer * X * AccumulatedDamage;
				FixDamage(DamagedActor, damage * AccumulatedDamage, instigator, HitLocation,
					Momentum, MyDamageType);
				AccumulatedDamage = 0;
			}
		}
		if ( HitActor.bIsPawn && Pawn(HitActor).bIsPlayer )
		{
			if ( WallEffect != None )
				WallEffect.Destroy();
		}
		else if ( (WallEffect == None) || WallEffect.bDeleteMe )
			WallEffect = Spawn(class'FixHit',,, HitLocation - 5 * X);
		else if ( !WallEffect.IsA('FixHit') )
		{
			WallEffect.Destroy();	
			WallEffect = Spawn(class'FixHit',,, HitLocation - 5 * X);
		}
		else
			WallEffect.SetLocation(HitLocation - 5 * X);

		if ( (WallEffect != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,,,HitLocation,rotator(HitNormal));

		if ( PlasmaBeam != None )
		{
			AccumulatedDamage += PlasmaBeam.AccumulatedDamage;
			PlasmaBeam.Destroy();
			PlasmaBeam = None;
		}

		return;
	}
	else if ( (Level.Netmode != NM_Client) && (DamagedActor != None) )
	{
		if (int(Level.Game.GetPropertyText("NoLockdown")) == 1)
		    Momentum = vect(0,0,0);
		else
		    Momentum = MomentumTransfer * X * AccumulatedDamage;

		FixDamage(DamagedActor, damage * AccumulatedDamage, instigator, DamagedActor.Location - X * 1.2 * DamagedActor.CollisionRadius,
			Momentum, MyDamageType);
		AccumulatedDamage = 0;
		DamagedActor = None;
	}			


	if ( Position >= 9 )
	{	
		if ( (WallEffect == None) || WallEffect.bDeleteMe )
			WallEffect = Spawn(class'FixCap',,, Location + (BeamSize - 4) * X);
		else if ( WallEffect.IsA('FixHit') )
		{
			WallEffect.Destroy();	
			WallEffect = Spawn(class'FixCap',,, Location + (BeamSize - 4) * X);
		}
		else
			WallEffect.SetLocation(Location + (BeamSize - 4) * X);
	}
	else
	{
		if ( WallEffect != None )
		{
			WallEffect.Destroy();
			WallEffect = None;
		}
		if ( PlasmaBeam == None )
		{
			PlasmaBeam = Spawn(class'FixBolt',,, Location + BeamSize * X); 
			PlasmaBeam.Position = Position + 1;
		}
		else
			PlasmaBeam.UpdateBeam(self, X, DeltaTime);
	}
}

function FixDamage(Actor Target, int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	local int Health, FirstHealth;
	local string str;
	local Actor A;
	
	if (Target == None || (!Target.isA('Vehicle') && !Target.isA('mantacar')))
		return;
	
	if (!Target.isA('mantacar'))
		str = "Health";
	else
		str = "MHealth";
	Health = int(Target.GetPropertyText(str));
	FirstHealth = int(Target.GetPropertyText("FirstHealth"));
	if (Health > 0 && FirstHealth == 0) // old vehicle
	{
//		FirstHealth = int(Target.Default.GetPropertyText("Health")); // not work
		if (!Target.isA('mantacar'))
		{
			if (Target.isA('Juggernaut'))
				FirstHealth = 2000;
			else if (Target.isA('Harbinger'))
				FirstHealth = 1600;
			else if (Target.isA('raptor'))
				FirstHealth = 1000;
			else if (Target.isA('bulldog'))
				FirstHealth = 1600;
			else if (Target.isA('WheeledCarPhys'))
				FirstHealth = 500;
			else
				FirstHealth = 250; // fallback
		}
		else
		{
			if (Target.isA('cicada'))
				FirstHealth = 900;
			else if (Target.isA('Leviathan'))
				FirstHealth = 5000;
			else if (Target.isA('Paladin'))
				FirstHealth = 700;
			else if (Target.isA('raptorcar'))
				FirstHealth = 300;
			else if (Target.isA('Ronin_Goliath'))
				FirstHealth = 8000;
			else if (Target.isA('tankcar'))
				FirstHealth = 1000;
			else if (Target.isA('turret2'))
				FirstHealth = 600;
			else if (Target.isA('wheeledcar'))
				FirstHealth = 400;
			else
				FirstHealth = 250; // fallback
		}
	}
	
	if (Health <= 0 || Health >= FirstHealth)
		return;
	Health += Damage;
	if (Health > FirstHealth)
		Health = FirstHealth;
		
	Target.SetPropertyText(str, string(Health));
	
	A = spawn(class'UT_SpriteSmokePuff', , , HitLocation);
	
	if (Health == FirstHealth || Level.TimeSeconds - LastFix > 1)
	{
		if (A != None && int(Level.TimeSeconds) % 3 == 0)
			A.PlaySound(FixSounds[Rand(ArrayCount(FixSounds))]);
		if (EventInstigator != None)
		{
			str = Target.GetPropertyText("VehicleName");
			if (str == "")
				str = Target.GetHumanName();
			EventInstigator.ClientMessage("You fix" @ str @ "damage up to" @ Health @ "out of" @ FirstHealth);
		}
		if (Pawn(Target.Owner) != None && Target.Owner != Instigator)
			Pawn(Target.Owner).ClientMessage("Your vehicle is being fixed!", 'CriticalEvent');
	
		LastFix = Level.TimeSeconds;
		Target.SetPropertyText("LastFix", string(LastFix));
	}
	
	str = Level @ int(Level.TimeSeconds / 100);
	if (Instigator != None && !isA('StarterFixBolt') && default.LastLevel != str)
	{
		default.LastLevel = str;
		Instigator.ClientMessage("Tip: Get very close to fix much faster.", 'CriticalEvent');
	}
}

defaultproperties
{
      LastFix=0.000000
      FixSounds(0)=Sound'UnrealShare.Dispersion.number1'
      FixSounds(1)=Sound'UnrealShare.Dispersion.number2'
      FixSounds(2)=Sound'UnrealShare.Dispersion.number3'
      FixSounds(3)=Sound'UnrealShare.Dispersion.number4'
      LastLevel=""
      SpriteAnim(0)=FireTexture'UnrealShare.EffectASMD.fireeffectASMD'
      SpriteAnim(1)=FireTexture'UnrealShare.EffectASMD.fireeffectASMD'
      SpriteAnim(2)=FireTexture'UnrealShare.EffectASMD.fireeffectASMD'
      SpriteAnim(3)=FireTexture'UnrealShare.EffectASMD.fireeffectASMD'
      SpriteAnim(4)=FireTexture'UnrealShare.EffectASMD.fireeffectASMD'
      BeamSize=80.000000
      Damage=100.000000
      ExplosionDecal=Class'FixGun.FixScorch'
      LifeSpan=0.000000
      Texture=FireTexture'UnrealShare.EffectASMD.fireeffectASMD'
      Skin=FireTexture'UnrealShare.EffectASMD.fireeffectASMD'
}
