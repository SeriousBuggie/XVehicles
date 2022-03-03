//=============================================================================
// XVehiclesSummon.
//=============================================================================
class XVehiclesSummon expands Mutator;

function Mutate(string MutateString, PlayerPawn Sender)
{
	local class<Vehicle> V;
	
	if (MutateString ~= "veh 1") V = class'JeepSDX';
	if (MutateString ~= "veh 2") V = class'JeepTDX';
	if (MutateString ~= "veh 3") V = class'Kraht';
	if (MutateString ~= "veh 4") V = class'TankGKOne';
	if (MutateString ~= "veh 5") V = class'TankML';
	if (MutateString ~= "veh 6") V = class'Shrali';
	
	if (V != None && Sender != None) Sender.Spawn(V);
	
	Super.Mutate(MutateString, Sender);
}

defaultproperties
{
}
