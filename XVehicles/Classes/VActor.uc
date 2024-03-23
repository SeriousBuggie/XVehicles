// VActor - Base of all vehicle classes, contains only some useful math functions.
// Special thanks to people @ UnrealWiki for quaternion functions.
Class VActor extends Actor
	Abstract
	Config(XVehicles);

/*
struct Quat // Quaternion
{
	var float X,Y,Z,W;
};
*/
struct Quat extends Vector // Quaternion
{
	var float W;
};

const URotToRadian=0.000095873799;
const URotToRadianHalf=0.0000479368995;
const RADIANS_TO_UU = 10430.37835047045272f;
const UU_90_DEGREES = 16384.0f;
const UU_360_DEGREES = 65536.0f;
const UU_360_NEGDEGREES = -65536.0f;
var MatOverlayFX OverlayMActor;
var Player StaticPP;

// arrays access too slow, so there dupliacte of fields
var int PrevCurrentYawA;
var vector PrevGroundNormalA;
var int PrevCurrentPitchA;
var rotator PrevTransformForGroundRotA;

var int PrevCurrentYawB;
var vector PrevGroundNormalB;
var int PrevCurrentPitchB;
var rotator PrevTransformForGroundRotB;

var() globalconfig float DistDetail;

struct IntRange
{
	var() int Max,Min;
};

// for debug
/*
var vector TmpLocA, TmpLocB;
var float DbgTmr, DbgTmr2;
var ENetRole DbgRole;
var string DbgMsg;
*/

// simulated event BaseChange() { Log(self @ "BaseChange" @ Base); }
// simulated event Attach( Actor Other ) { Log(self @ "Attach" @ Other); }
// simulated event Detach( Actor Other ) { Log(self @ "Detach" @ Other); }

simulated function PostBeginPlay()
{
	LODBias = DistDetail;
	Super.PostBeginPlay();
}

simulated function Destroyed()
{
	if( OverlayMActor!=None )
	{
		OverlayMActor.Destroy();
		OverlayMActor = None;
	}
}
Static function PlayerPawn FindNetOwner( Actor ChkAct )
{
	local PlayerPawn P;

	if (class'VActor'.Default.StaticPP != None)
		Return class'VActor'.Default.StaticPP.Actor;
	ForEach ChkAct.AllActors(Class'PlayerPawn',P)
		if (Viewport(P.Player) != None)
		{
			class'VActor'.Default.StaticPP = P.Player;
			Return P.Player.Actor;
		}
}
simulated function bool IsNetOwner( Actor Other )
{
	Return (Other!=None && Other==Class'VActor'.Static.FindNetOwner(Other));
}
simulated static function bool StIsNetOwner( Actor Other )
{
	Return (Other!=None && Other==Class'VActor'.Static.FindNetOwner(Other));
}

//==============================================================================
// Quaternion math functions:
simulated static final function Quat RtoQ( rotator Rot )
{
	local Quat Q, Z;
//	local Quat Y;
	local float Angle, YW, YY, QW, QX;
	
	Angle = Rot.Roll*URotToRadianHalf;
	QW = cos(Angle);
	QX = sin(Angle);
	
	Angle = Rot.Pitch*URotToRadianHalf;
	/*
	Y.W = cos(Angle);
	Y.Y = sin(Angle);	
	Q = Q Qmulti Y;
	*/
	YW = cos(Angle);
	YY = sin(Angle);
	Q.Y = YY*QW;
	Q.Z = -QX*YY;
	Q.W = QW*YW;
	Q.X = QX*YW;
	
	Angle = Rot.Yaw*URotToRadianHalf;
	Z.W = cos(Angle);
	Z.Z = sin(Angle);	
	Q = Q Qmulti Z;
	
	return Q;
}
simulated static final function rotator QtoR( quat Q )
{
	local float x, y, z, w, s;
	local rotator result;

	x = Q.x;
	y = Q.y;
	z = Q.z;
	w = Q.w;
	s = 2.0f * ( w * y - x * z );
        
	// It is invalid to pass values outside
	// of the range -1,1 to asin()... so don't.
	if ( s >= 1.0f )
	{
		result.yaw      = 0;
		result.pitch    = UU_90_DEGREES;
		result.roll     = atan2( 2.0f*(x*y-w*z), 1.0f-2.0f*(Square(x) + Square(z)) ) * RADIANS_TO_UU;
	}
	else if ( -1.0f < s )
	{
		result.yaw      = atan2( 2.0f*(x*y+w*z), 1.0f-2.0f*(Square(y) + Square(z)) ) * RADIANS_TO_UU;
		result.pitch    = asin( s ) * RADIANS_TO_UU;
		result.roll     = atan2( 2.0f*(y*z+w*x), 1.0f-2.0f*(Square(x) + Square(y)) ) * RADIANS_TO_UU;
	}
	else
	{
		result.yaw      = 0;
		result.pitch    = -UU_90_DEGREES;
		result.roll     = -atan2( 2.0f*(x*y-w*z), 1.0f-2.0f*(Square(x) + Square(z)) ) * RADIANS_TO_UU;
	}
	return Normalize( result );
}
static final function quat QuatSlerp( quat u, quat v, float f )
{
	local float alpha,beta,theta,sin_t,cos_t;
	local bool flip;
	local quat  result;

	// Force the input within range.
	f = fmin( f, 1.0f );
	f = fmax( f, 0.0f );

	cos_t = u.x*v.x+u.y*v.y+u.z*v.z+u.w*v.w;

	if ( cos_t < 0.0f )
	{
		cos_t = -cos_t;
		flip = True;
	}

	if ( ( 1.0f - cos_t ) < 0.000001f )
	{
		beta    = 1.0f - f;
		alpha   = f;
	}
	else
	{
		theta   = acos( cos_t );
		sin_t   = sin( theta );
		beta    = sin( theta - f * theta ) / sin_t;
		alpha   = sin( f * theta ) / sin_t;
	}

	if ( flip )
		alpha = -alpha;

	result.x = beta * u.x + alpha * v.x;
	result.y = beta * u.y + alpha * v.y;
	result.z = beta * u.z + alpha * v.z;
	result.w = beta * u.w + alpha * v.w;

	return result;
}
static final function float ASin  ( float A )
{
	if (A>1||A<-1) //outside domain!
		return 0;
	if (A==1)  //div by 0 checks
		return Pi/2.0;
	if (A==-1)
		return Pi/-2.0;
	return ATan(A/Sqrt(1-Square(A)));
}
static final function float ACos  ( float A )
{
	if (A>1||A<-1) //outside domain!
		return 0;
	if (A==0) //div by 0 check
		return (Pi/2.0);
	A=ATan(Sqrt(1.0-Square(A))/A);
	if (A<0)
		A+=Pi;
	Return A;
}
final static function float ATan2(float Y,float X)
{
	local float tempang;
  
	if(X==0) //div by 0 checks.
	{
		if(Y<0)
			return -pi/2.0;
		else if(Y>0)
			return pi/2.0;
		else return 0; //technically impossible (nothing exists)
	}
	tempang=ATan(Y/X);
  
	if (X<0)
		tempang+=pi;  //1st/3rd quad
  
	//normalize (from -pi to pi)
	if(tempang>pi) 
		tempang-=pi*2.0;
  
	if(tempang<-pi)
		tempang+=pi*2.0;
  
	return tempang;
}
simulated static final operator(16) quat Qmulti ( quat Q1 , quat Q2 )
{
	local vector V1,V2,Vp;
	local quat Qp;

	V1 = Q1;
	V2 = Q2;
	Qp.W = Q1.W * Q2.W - (V1 dot V2);
	Vp = (Q1.W * V2) + (Q2.W * V1) - (V1 cross V2);
	Qp.X = Vp.X;
	Qp.Y = Vp.Y;
	Qp.Z = Vp.Z;
	return Qp;
}
//==============================================================================
// Vector math functions:
final simulated function rotator TransformForGroundRot( int CurrentYaw, vector GroundNormal, optional int CurrentPitch, optional bool bReverse )
{
	local vector CrossDir,FwdDir,OldFwdDir,X,Y,Z,A,B;
	local rotator R;

	R.Yaw = CurrentYaw;
	R.Pitch = CurrentPitch;
	//Log(Abs(GroundNormal.Z - 1)*1000000 @ Abs(GroundNormal.Z - 1) < 0.0000001);
	if( Abs(GroundNormal.Z - 1) < 0.0000001 )
		Return R;
		
	if (bReverse)
	{	
		if (CurrentYaw == PrevCurrentYawA &&
			GroundNormal == PrevGroundNormalA &&
			CurrentPitch == PrevCurrentPitchA)
			return PrevTransformForGroundRotA;
	}
	else	
		if (CurrentYaw == PrevCurrentYawB &&
			GroundNormal == PrevGroundNormalB &&
			CurrentPitch == PrevCurrentPitchB)
			return PrevTransformForGroundRotB;

	GetAxes(R,X,Y,Z);

	if (bReverse)
	{
		A = vect(0,0,1);
		B = GroundNormal;		
	}
	else
	{
		A = GroundNormal;
		B = vect(0,0,1);
	}

	// translate view direction
	CrossDir = Normal(A Cross B);
	FwdDir = CrossDir Cross A;
	OldFwdDir = CrossDir Cross B;
	X = A * (B Dot X) + 
		CrossDir * (CrossDir Dot X) + 
		FwdDir * (OldFwdDir Dot X);
	X = Normal(X);
	Z = Normal(A);
	Y = Z Cross X;
	R = OrthoRotation(X,Y,Z);
	
	if (bReverse)
	{	
		PrevCurrentYawA = CurrentYaw;
		PrevGroundNormalA = GroundNormal;
		PrevCurrentPitchA = CurrentPitch;
		PrevTransformForGroundRotA = R;
	}
	else	
	{
		PrevCurrentYawB = CurrentYaw;
		PrevGroundNormalB = GroundNormal;
		PrevCurrentPitchB = CurrentPitch;
		PrevTransformForGroundRotB = R;
	}

	return R;
}
// Vel = vector value to bouch off a "surface"
// GNormal = The surface normal
// Bounchyness 0-1, 0 = no bounching, 1 = full bounch off
simulated function vector SetUpNewMVelocity( vector Vel, vector GNormal, float Bounchyness )
{
	Return Vel-(1.f+Bounchyness)*(Vel dot GNormal) * GNormal;
}
simulated function bool CanGetOver( float MSHV, float AllowedZVal ) // Check if maxstepheight value allows to get over this
{
	local vector Start,End,Ex,NVe,HL,HN;
	local Actor A;
	
	if( MSHV<=0 )
		Return False;
	Ex.X = CollisionRadius;
	Ex.Y = Ex.X;
	Ex.Z = CollisionHeight;
	Start = Location;
	Start.Z += MSHV;
	NVe = Velocity;
	NVe.Z = 0;
	NVe = Normal(NVe);
	End = Start + NVe*12;
	A = Trace(HL, HN, End, Start, True, Ex);
	if (A != None)
	{
		if (HN.Z >= AllowedZVal)
		{
			if (!Move(vect(0,0,1)*MSHV))
			{
				Move(-12*NVe);
				Move(vect(0,0,1)*MSHV);
				Move(12*NVe);
			}
			Move(NVe*VSize(Start - HL));
			HitWall(HN,A);
			Return True;
		}
		Return False;
	}
	Start = End;
	End.Z -= MSHV;
	A = Trace(HL, HN, End, Start, True, Ex);
	if (A != None && HN.Z >= AllowedZVal)
	{
		if (!Move(vect(0,0,1)*MSHV))
		{
			Move(-12*NVe);
			Move(vect(0,0,1)*MSHV);
			Move(12*NVe);
		}
		Move(NVe*12);
		HitWall(HN,A);
		Return True;
	}
	Return False;
}
simulated function vector GetZFrom( rotator R )
{
	local vector X,Y,Z;

	GetAxes(R,X,Y,Z);
	Return Z;
}

//==============================================================================
// Rotation:
// Rotate it to closest component
simulated function int CalcTurnSpeed( int CurTurnSpeed, int CurTurn, int DestTurn )
{
	if( CurTurnSpeed==0 )
		Return CurTurn;
	CurTurnSpeed = CurTurnSpeed & 65535;
	CurTurn = CurTurn & 65535;
	DestTurn = DestTurn & 65535;
	if( (CurTurn+32768)>DestTurn && CurTurn<=DestTurn )
	{
		CurTurn+=CurTurnSpeed;
		if( CurTurn>=DestTurn )
			CurTurn = DestTurn;
	}
	else if( (CurTurn-32768)<DestTurn && CurTurn>=DestTurn )
	{
		CurTurn-=CurTurnSpeed;
		if( CurTurn<=DestTurn )
			CurTurn = DestTurn;
	}
	else if( CurTurn>DestTurn )
	{
		DestTurn+=UU_360_DEGREES;
		if( (CurTurn+32768)>=DestTurn && CurTurn<DestTurn )
		{
			CurTurn+=CurTurnSpeed;
			if( CurTurn>=DestTurn )
				CurTurn = DestTurn-UU_360_DEGREES;
		}
		else
		{
			CurTurn-=CurTurnSpeed;
			if( CurTurn<=DestTurn )
				CurTurn = DestTurn-UU_360_DEGREES;
		}
	}
	else
	{
		CurTurn+=UU_360_DEGREES;
		if( (CurTurn+32768)>=DestTurn && CurTurn<DestTurn )
		{
			CurTurn+=CurTurnSpeed;
			if( CurTurn>=DestTurn )
				CurTurn = DestTurn;
		}
		else
		{
			CurTurn-=CurTurnSpeed;
			if( CurTurn<=DestTurn )
				CurTurn = DestTurn;
		}
	}
	return CurTurn;
}
simulated function bool CanYawUpTo( rotator OldRot, rotator NewRot, int MaxRotChange )
{
	local int nv;

	OldRot = Normalize(OldRot-NewRot);
	nv = MaxRotChange*-1;
	Return (OldRot.Roll<MaxRotChange && OldRot.Roll>nv && OldRot.Pitch<MaxRotChange && OldRot.Pitch>nv);
}
final simulated function vector CalcGravityStrength( vector Gravity, vector FloorN )
{
	Gravity-=(Gravity dot FloorN) * FloorN;
	Return Gravity;
}

// Canvas:
simulated static function bool WorldToScreen(Vector WorldLocation, Pawn ThePlayer, vector EyePos, rotator ScreenRot,
     float ScreenWidth, float ScreenHeight, out float X, out float Y)
{
	local vector RelativeToPlayer;
	local float Scale;

	RelativeToPlayer = (WorldLocation - EyePos) << ScreenRot;

	if (RelativeToPlayer.X < 0.01)
		return false;

	Scale = (ScreenWidth / 2) / Tan(ThePlayer.FovAngle/2/180*Pi);

	X = RelativeToPlayer.Y / RelativeToPlayer.X * Scale + ScreenWidth / 2;
	Y = - RelativeToPlayer.Z / RelativeToPlayer.X * Scale + ScreenHeight / 2;
	return (X>0 && Y>0 && X<ScreenWidth && Y<ScreenHeight);
}

simulated static function vector NormalWeightSum(float ratioA, vector A, vector B)
{
	if (ratioA >= 1f)
		return Normal(A);
	return Normal(ratioA*A + (1f - ratioA)*B);
}

simulated static function bool IsDemoPlayback(LevelInfo Level)
{
	return Level.NetMode == NM_Client && Level.GetAddressURL() == ":7777";
}

defaultproperties
{
	DistDetail=2.000000
	LODBias=4.000000
	DrawType=DT_Mesh
}
