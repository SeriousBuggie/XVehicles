class TankMGMuz expands xTreadVehEffects;

var vector PrePivotRel;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		PrePivotRel;
}

simulated function PostBeginPlay()
{
	LoopAnim('Shoot');
}

simulated function Tick( float DeltaTime)
{
	if (Owner != None)
		PrePivot = PrePivotRel >> Owner.Rotation;
}

defaultproperties
{
      PrePivotRel=(X=0.000000,Y=0.000000,Z=0.000000)
      bNetTemporary=False
      bTrailerSameRotation=True
      bTrailerPrePivot=True
      Physics=PHYS_Trailer
      RemoteRole=ROLE_SimulatedProxy
      DrawType=DT_Mesh
      Style=STY_Translucent
      Texture=Texture'Botpack.Skins.Muzzy'
      Mesh=LodMesh'Botpack.muzzEF3'
      DrawScale=0.100000
      bUnlit=True
      bParticles=True
      LightType=LT_Steady
      LightEffect=LE_NonIncidence
      LightBrightness=128
      LightHue=28
      LightSaturation=32
      LightRadius=6
}
