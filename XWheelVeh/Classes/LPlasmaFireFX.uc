class LPlasmaFireFX expands xWheelVehEffects;

#exec TEXTURE IMPORT NAME=LPlasmaFireFX FILE=Effects\LPlasmaFireFX.bmp GROUP=Effects FLAGS=2

var vector PrePivotRel;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority && bNetInitial )
		PrePivotRel;
}

simulated function Tick( float DeltaTime)
{
	if (Level.NetMode != NM_DedicatedServer)
	{
		DrawScale = LifeSpan * Default.DrawScale / Default.LifeSpan;
		ScaleGlow = LifeSpan * Default.ScaleGlow / Default.LifeSpan;
		if (Owner != None)
			PrePivot = PrePivotRel >> Owner.Rotation;
	}
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
