Class PassengerCameraA extends DriverCameraActor;

simulated function Tick( float Delta )
{
	local vector V;
	local rotator R;
	local float RRoll;
	
	if (KeepWait <= 0)
	{
		if (CurrentViewMult < DesiredViewMult)
			CurrentViewMult += (FMax(0.1,Abs(CurrentViewMult - DesiredViewMult)) * Delta);
		else if (CurrentViewMult > DesiredViewMult)
			CurrentViewMult -= (FMax(0.1,Abs(CurrentViewMult - DesiredViewMult)) * Delta);
	
		if (CurrentViewMult != DesiredViewMult && Abs(CurrentViewMult - DesiredViewMult) < 0.025)
		{
			CurrentViewMult = DesiredViewMult;
			OldDesiredViewMult = DesiredViewMult;
		}
	}
	else
		KeepWait -= Delta;

	RRoll = Rotation.Roll;

	if( VehicleOwner==None )
		Return;
	if( Owner==None || PlayerPawn(Owner)==None )
		Return;
	if( Level.NetMode!=NM_Client && !VehicleOwner.bVehicleBlewUp )
	{
		if( PlayerPawn(Owner).ViewTarget==None )
			PlayerPawn(Owner).ViewTarget = Self;
		else if( PlayerPawn(Owner).bBehindView && PlayerPawn(Owner).ViewTarget==Self )
			PlayerPawn(Owner).bBehindView = False;
	}
	VehicleOwner.CalcCameraPos(V,R,CurrentViewMult,SeatNum);
	Move(V-Location);

	//Vertical shake support
	MoveSmooth(PlayerPawn(Owner).ShakeVert * 0.01 * vect(0,0,1));

	R.Roll = RRoll;
	SetRotation(R);
}

simulated function Destroyed()
{
	if (PlayerPawn(Owner) != None)
		PlayerPawn(Owner).ViewTarget = None;

	Super(Info).Destroyed();
}

defaultproperties
{
}
