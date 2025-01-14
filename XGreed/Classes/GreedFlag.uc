//=============================================================================
// GreedFlag.
//=============================================================================
class GreedFlag expands CTFFlag;

function PostBeginPlay()
{
}

auto state Stub
{
Begin:
	SetupLook();
}

function Touch(Actor Other)
{
	if (RegisterTouch(Other))
	{
		PendingTouch = Other.PendingTouch;
		Other.PendingTouch = self;
	}
}

function PostTouch(Actor Other)
{
	if (RegisterTouch(Other))
		Greed(Level.Game).ScoreFlag(Pawn(Other), self);
}

function bool RegisterTouch(Actor Other)
{
	local Pawn aPawn;
        
	aPawn = Pawn(Other);
	if (aPawn != None && aPawn.bIsPlayer && aPawn.Health > 0 && aPawn.PlayerReplicationInfo != None)
	{
		aPawn.MoveTimer = -1;
		if (aPawn.PlayerReplicationInfo.Team == Team)
		{
			aPawn.ClientMessage("You must bring the skulls to the opposing base to score. This is your base.", 'CriticalEvent');
			return false;
		}
		return true;
	}
	return false;
}

function SetupLook()
{
	local rotator R;
	HomeBase.GotoState(''); // disable checker
	HomeBase.bHidden = true; // hide it
	HomeBase.AmbientSound = Sound'A_Gameplay_ONS_ConduitAmbient';
	HomeBase.SoundRadius = 64;
	HomeBase.ExtraCost = 100000; // prevent walk through if not goal
	HomeBase.AnimSequence = '';
	R.Yaw = HomeBase.Rotation.Yaw;
	SetRotation(R);

	// set own Control Point look
	LightBrightness = 255;
	LightSaturation = 0;	
	if (HomeBase.Team == 0)
	{
		DrawScale = 0.4;
		Mesh = mesh'DomR';
		Texture = texture'RedSkin2';
		LightHue = 0;
	}
	else if (HomeBase.Team == 1)
	{
		DrawScale = 0.4;
		Mesh = mesh'DomB';
		Texture = texture'BlueSkin2'; 
		LightHue = 170;
	}
	else if (HomeBase.Team == 2)
	{
		DrawScale = 1.0;
		Mesh = mesh'UDamage';
		Texture = Texture'UnrealShare.Belt_fx.ShieldBelt.NewGreen'; //FireTexture'UnrealShare.Belt_fx.ShieldBelt.Greenshield'; 
		LightHue = 85;
	}
	else if (HomeBase.Team == 3)
	{
		DrawScale = 0.7;
		Mesh = mesh'MercSymbol';
		Texture = texture'GoldSkin2';
		LightHue = 35;
	}
}

defaultproperties
{
	bHidden=False
	Physics=PHYS_Rotating
	RemoteRole=ROLE_SimulatedProxy
	Style=STY_Translucent
	Texture=Texture'Botpack.Skins.JDomN0'
	Mesh=LodMesh'Botpack.DomN'
	DrawScale=0.400000
	AmbientGlow=255
	bMeshEnviroMap=True
	bGameRelevant=True
	SoundRadius=64
	SoundVolume=255
	LightType=LT_SubtlePulse
	LightSaturation=255
	LightRadius=7
	RotationRate=(Pitch=0,Yaw=5000,Roll=0)
	DesiredRotation=(Yaw=30000)
}
