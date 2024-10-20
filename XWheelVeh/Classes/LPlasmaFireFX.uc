class LPlasmaFireFX expands xWheelVehEffects;

#exec TEXTURE IMPORT NAME=LPlasmaFireFX FILE=Effects\LPlasmaFireFX.bmp GROUP=Effects FLAGS=2

var vector PrePivotRel;

replication
{
	// Variables the server should send to the client.
	reliable if (Role == ROLE_Authority)
		PrePivotRel;
}

simulated function Tick(float DeltaTime)
{
	local float Scale;
	Scale = LifeSpan / Default.LifeSpan;
	DrawScale = Default.DrawScale * Scale;
	ScaleGlow = Default.ScaleGlow * Scale;
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
	LifeSpan=0.400000
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'XWheelVeh.Effects.LPlasmaFireFX'
	DrawScale=1.250000
	ScaleGlow=1.500000
	SpriteProjForward=10.000000
	bUnlit=True
}
