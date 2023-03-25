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

struct ReplInfo
{
	var int Version;
	var() config bool bHideState;
	var() config bool bPulseAltHeal;
	var() config bool bDisableTeamSpawn;
	var() config bool bDisableFastWarShell;
	var() config bool bAllowTranslocator;
	var() config bool bDisableFlagAnnouncer;
};
var ReplInfo Repl;

replication
{
	reliable if (Role == ROLE_Authority)
		Repl;
}

simulated function PostNetBeginPlay()
{
	default.bHideState = Repl.bHideState;
	default.bPulseAltHeal = Repl.bPulseAltHeal;
	default.bDisableTeamSpawn = Repl.bDisableTeamSpawn;
	default.bDisableFastWarShell = Repl.bDisableFastWarShell;
	default.bAllowTranslocator = Repl.bAllowTranslocator;
	default.bDisableFlagAnnouncer = Repl.bDisableFlagAnnouncer;
}

function Store()
{
	Repl.bHideState = default.bHideState;
	Repl.bPulseAltHeal = default.bPulseAltHeal;
	Repl.bDisableTeamSpawn = default.bDisableTeamSpawn;
	Repl.bDisableFastWarShell = default.bDisableFastWarShell;
	Repl.bAllowTranslocator = default.bAllowTranslocator;
	Repl.bDisableFlagAnnouncer = default.bDisableFlagAnnouncer;
	
	Repl.Version = ++default.Version;
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
