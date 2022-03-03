// Corona effect, the corona effect is done by each playerpawn in the game, 
// and as it's only a visual effect for each playerpawn, it don't get called by any other pawn
// Still, this effect can be dangerously resourcefull if used too many times, 
// that's why it's only used in bigger explosions or even nukes
///////////////////////
//ATTENTION: this is not a true dynamic corona, as it doesn't blend color

class CoronaVehEffect expands Actor;

//configurable in the main corona controller

var float MaxDistance;			//Max distance where the corona is visible
var float LifeTime;			//It's basically the lifespan
var float StartScaleTime, EndScaleTime;
var float FadeInTime, FadeOutTime;
var float EndScaleCoef, StartScaleCoef;  //Scaling multiplier when appearing or dying
var texture CoronaSprite;		//Corona texture
var float MaxCoronaSize, MinCoronaSize;	//Corona scales
var float CGlow;			//Corona scaleglow


//in variables
var bool bReceivedData;
var float CountA, CountB;
var bool bVisible;
var vector OldOwnerDir, CurOwnerDir;	//Old/current owner directions
var vector OldCamLoc, NewCamLoc;	//Old/current owner cam locations

var() config bool bCoronasCollisionDetail;


replication
{
	reliable if (Role == ROLE_Authority && bNetOwner)
		MaxDistance, LifeTime, StartScaleTime, EndScaleTime, FadeInTime,
	FadeOutTime, EndScaleCoef, StartScaleCoef, CoronaSprite, MaxCoronaSize,
	MinCoronaSize, CGlow;
}

simulated function PostBeginPlay()
{
	SetTimer(0.01, False);
}


simulated function Timer()
{
local Actor A;
local vector HitLoc, HitNorm;
local vector X, Y, Z;

	if (!bReceivedData)
	{
		bReceivedData = True;
		LifeSpan = LifeTime;
		Texture = CoronaSprite;
		ScaleGlow = CGlow;
		SetTimer(0.2, True);

		//Destroy this corona if playerpawn owner is not on this side of the network
		if ((Role < ROLE_Authority && !bNetOwner) || Level.NetMode == NM_DedicatedServer)
			Destroy();
	}

	If (PlayerPawn(Owner) == None)
		Destroy();

	GetAxes(PlayerPawn(Owner).ViewRotation,X,Y,Z);

	if (PlayerPawn(Owner).ViewTarget == None)
	{
		if (!bCoronasCollisionDetail)
			bVisible = FastTrace(PlayerPawn(Owner).Location + PlayerPawn(Owner).Eyeheight * Z, Location);
		else
		{
			bVisible = True;
			ForEach TraceActors(Class'Actor', A, HitLoc, HitNorm, PlayerPawn(Owner).Location + PlayerPawn(Owner).Eyeheight * Z, Location)
			{
				if (((A == Level) || (A.bBlockActors)) && A != PlayerPawn(Owner))
				{
					bVisible = False;
					break;
				}
			}
		}
	}
	else
	{
		
		if (!bCoronasCollisionDetail)
			bVisible = FastTrace(PlayerPawn(Owner).ViewTarget.Location, Location);
		else
		{
			bVisible = True;
			ForEach TraceActors(Class'Actor', A, HitLoc, HitNorm, PlayerPawn(Owner).ViewTarget.Location, Location)
			{
				if (((A == Level) || (A.bBlockActors)) && A != PlayerPawn(Owner).ViewTarget)
				{
					bVisible = False;
					break;
				}
			}
		}
	}
}


simulated function Tick(float DeltaTime)
{
local float SizeCoef, SizeDelta, dotOld, dotNew, ProjDelta;
local vector VectorREF, VectorDELTA, VectProj;
local float VLineMax, VLine;
local vector X, Y, Z;

	if (bReceivedData)
	{
		//Distance>Size control + MaxDistance control + corona effect
		if (PlayerPawn(Owner).ViewTarget == None)
		{
			OldOwnerDir = CurOwnerDir;
			CurOwnerDir = vector(PlayerPawn(Owner).ViewRotation);

			GetAxes(PlayerPawn(Owner).ViewRotation,X,Y,Z);
			VectorREF = Normal(Location - (PlayerPawn(Owner).Location + PlayerPawn(Owner).Eyeheight * Z));
			VectorDELTA = CurOwnerDir;
			SizeCoef = VSize((PlayerPawn(Owner).Location + PlayerPawn(Owner).Eyeheight * Z) - Location);

			VectProj = PlayerPawn(Owner).Location - PlayerPawn(Owner).OldLocation;
		}
		else
		{
			OldOwnerDir = CurOwnerDir;
			CurOwnerDir = vector(PlayerPawn(Owner).ViewTarget.Rotation);

			VectorREF = Normal(Location - PlayerPawn(Owner).ViewTarget.Location);
			VectorDELTA = CurOwnerDir;
			SizeCoef = VSize(PlayerPawn(Owner).ViewTarget.Location - Location);

			//There's a native bug with OldLocation in the Info class, so it has to be handled in a special way
			if (!PlayerPawn(Owner).ViewTarget.IsA('Info'))
				VectProj = PlayerPawn(Owner).ViewTarget.Location - PlayerPawn(Owner).ViewTarget.OldLocation;
			else
			{
				OldCamLoc = NewCamloc;
				NewCamloc = PlayerPawn(Owner).ViewTarget.Location;
				VectProj = NewCamloc - OldCamLoc;		
			}
				
		}

		bHidden = !bVisible || (SizeCoef > MaxDistance);
		SizeDelta = Abs(MaxCoronaSize - MinCoronaSize);
		DrawScale = Abs(MinCoronaSize) + (SizeCoef * SizeDelta / MaxDistance);

		//New calculations using the dot product + 
		// make use of predicted movements so fix the flicker/disappearing corona bug
		dotOld = (VectorREF dot OldOwnerDir) * 0.9;
		dotNew = (VectorREF dot VectorDELTA) * 0.9;

		if (dotOld < dotNew)
			SizeCoef *= dotOld;
		else
			SizeCoef *= dotNew;

		
		if ((Normal(VectProj) dot VectorREF) > 0.0)
			ProjDelta = VSize(VectProj);
		else
			ProjDelta = 1;

		if (PlayerPawn(Owner).ViewTarget == None)
			SpriteProjForward = FMax(0, SizeCoef - ProjDelta);
		else
			SpriteProjForward = FMax(0, SizeCoef - (ProjDelta * 1.1));
			//SpriteProjForward = FMax(0, SizeCoef - (ProjDelta * 1.5));


		//Fading and scaling effects control
		if (FadeInTime > 0 && CountA < FadeInTime)
		{
			CountA += DeltaTime;
			ScaleGlow = CountA * CGlow / FadeInTime;
		}

		if (StartScaleTime > 0 && CountB < StartScaleTime)
		{
			CountB += DeltaTime;
			DrawScale *= (CountB * StartScaleCoef / StartScaleTime);
		}

		if (FadeOutTime > 0 && LifeTime > 0 && LifeSpan < FadeOutTime)
			ScaleGlow = LifeSpan * CGlow / FadeOutTime;

		if (EndScaleTime > 0 && LifeSpan < EndScaleTime)
			DrawScale *= (LifeSpan * EndScaleCoef / EndScaleTime);
	}
		
}

defaultproperties
{
      MaxDistance=0.000000
      Lifetime=0.000000
      StartScaleTime=0.000000
      EndScaleTime=0.000000
      FadeInTime=0.000000
      FadeOutTime=0.000000
      EndScaleCoef=1.000000
      StartScaleCoef=1.000000
      CoronaSprite=None
      MaxCoronaSize=0.000000
      MinCoronaSize=0.000000
      CGlow=0.000000
      bReceivedData=False
      CountA=0.000000
      CountB=0.000000
      bVisible=False
      OldOwnerDir=(X=0.000000,Y=0.000000,Z=0.000000)
      CurOwnerDir=(X=0.000000,Y=0.000000,Z=0.000000)
      OldCamLoc=(X=0.000000,Y=0.000000,Z=0.000000)
      NewCamLoc=(X=0.000000,Y=0.000000,Z=0.000000)
      bCoronasCollisionDetail=False
      RemoteRole=ROLE_SimulatedProxy
      LifeSpan=5000.000000
      Style=STY_Translucent
      Texture=None
      bUnlit=True
      CollisionRadius=0.000000
      CollisionHeight=0.000000
      Mass=0.000000
}
