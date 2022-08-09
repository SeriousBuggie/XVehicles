// Master attachment for certain types of vehicles that only has passenger 
// attachments (which delay the location updates for some some whatever reason)
// This attach isn't updated by the vehicle, so where it spawns, it stays
Class MasterAttach extends VehicleAttachment;

simulated function Tick( float Delta )
{
	if (OwnerVehicle!=None)
		OwnerVehicle.AttachmentsTick(Delta);
}

defaultproperties
{
	bHidden=True
	Mesh=LodMesh'UnrealShare.WoodenBoxM'
	DrawScale=0.010000
}
