class JTDXWheel expands JSDXWheel;

//Skinning
#exec TEXTURE IMPORT NAME=WheelHIIITDXSk01 FILE=SKINS\WheelHIIITDXSk01.bmp GROUP=Skins LODSET=2
#exec TEXTURE IMPORT NAME=WheelHIIITDXSk02 FILE=SKINS\WheelHIIITDXSk02.bmp GROUP=Skins LODSET=2

defaultproperties
{
	MultiSkins(1)=Texture'XWheelVeh.Skins.WheelHIIITDXSk01'
	MultiSkins(2)=Texture'XWheelVeh.Skins.WheelHIIITDXSk02'
}
