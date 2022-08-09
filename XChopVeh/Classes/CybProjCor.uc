//////////////////////////////////////////////////////////////
//				Feralidragon (15-01-2011)
//
// NW3 CYBOT LAUNCHER BUILD 1.00
//////////////////////////////////////////////////////////////

class CybProjCor expands NaliTrail;

#exec TEXTURE IMPORT NAME=CybProjCorRed FILE=Coronas\CybProjCorRed.bmp GROUP=Coronas FLAGS=2
#exec TEXTURE IMPORT NAME=CybProjCorBlue FILE=Coronas\CybProjCorBlue.bmp GROUP=Coronas FLAGS=2
#exec TEXTURE IMPORT NAME=CybProjCorGreen FILE=Coronas\CybProjCorGreen.bmp GROUP=Coronas FLAGS=2
#exec TEXTURE IMPORT NAME=CybProjCorYellow FILE=Coronas\CybProjCorYellow.bmp GROUP=Coronas FLAGS=2

defaultproperties
{
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'XVehicles.Coronas.CybProjCorRed'
	DrawScale=0.180000
	ScaleGlow=1.650000
	SpriteProjForward=16.000000
}
