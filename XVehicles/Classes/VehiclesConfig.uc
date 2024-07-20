//=============================================================================
// VehiclesConfig.
//=============================================================================
class VehiclesConfig expands Info Config(XVehicles);

var int Version;
var VehiclesConfig Instance;

var() config bool bHideState;
var() config bool bPulseAltHeal;
var() config bool bDisableTeamSpawn;
var() config bool bDisableFastWarShell;
var() config bool bAllowTranslocator;
var() config bool bDisableFlagAnnouncer;
var() config bool bAllowCameraShakeInVehicle;

struct ReplInfo
{
	var int Version;
	var() config bool bHideState;
	var() config bool bPulseAltHeal;
	var() config bool bDisableTeamSpawn;
	var() config bool bDisableFastWarShell;
	var() config bool bAllowTranslocator;
	var() config bool bDisableFlagAnnouncer;
	var() config bool bAllowCameraShakeInVehicle;
};
var ReplInfo ReplI;

replication
{
	reliable if (Role == ROLE_Authority)
		ReplI;
}

simulated function PostNetBeginPlay()
{
	default.bHideState = ReplI.bHideState;
	default.bPulseAltHeal = ReplI.bPulseAltHeal;
	default.bDisableTeamSpawn = ReplI.bDisableTeamSpawn;
	default.bDisableFastWarShell = ReplI.bDisableFastWarShell;
	default.bAllowTranslocator = ReplI.bAllowTranslocator;
	default.bDisableFlagAnnouncer = ReplI.bDisableFlagAnnouncer;
	default.bAllowCameraShakeInVehicle = ReplI.bAllowCameraShakeInVehicle;
}

function Store()
{
	ReplI.bHideState = default.bHideState;
	ReplI.bPulseAltHeal = default.bPulseAltHeal;
	ReplI.bDisableTeamSpawn = default.bDisableTeamSpawn;
	ReplI.bDisableFastWarShell = default.bDisableFastWarShell;
	ReplI.bAllowTranslocator = default.bAllowTranslocator;
	ReplI.bDisableFlagAnnouncer = default.bDisableFlagAnnouncer;
	ReplI.bAllowCameraShakeInVehicle = default.bAllowCameraShakeInVehicle;
	
	ReplI.Version = ++default.Version;
}

static function Update(Actor Source)
{
	if (default.Instance == None || default.Instance.bDeleteMe || default.Instance.Level != Source.Level)
		default.Instance = Source.Spawn(class'VehiclesConfig');
	default.Instance.Store();
}

defaultproperties
{
	bPulseAltHeal=True
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
}
