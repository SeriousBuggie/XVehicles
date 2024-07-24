class ShraliEnergyDot expands xTreadVehEffects;

#exec TEXTURE IMPORT NAME=BrightRedDot FILE=Effects\BrightRedDot.bmp GROUP=Effects FLAGS=2

var vector PrePivotRel;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		PrePivotRel;
}

simulated function Tick( float DeltaTime)
{
	ScaleGlow = (Default.LifeSpan - LifeSpan) * Default.ScaleGlow / Default.LifeSpan;
	if (Level.NetMode != NM_DedicatedServer && Owner != None)
		PrePivot = PrePivotRel >> Owner.Rotation;
}

defaultproperties
{
	bNetTemporary=False
	bTrailerSameRotation=True
	bTrailerPrePivot=True
	Physics=PHYS_Trailer
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=6.000000
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'XTreadVeh.Effects.BrightRedDot'
	DrawScale=0.435000
	ScaleGlow=2.000000
	SpriteProjForward=2.500000
	bUnlit=True
	LightType=LT_Steady
	LightBrightness=80
	LightRadius=20
}
