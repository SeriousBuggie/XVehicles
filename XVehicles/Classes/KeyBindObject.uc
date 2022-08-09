Class KeyBindObject extends Object;

var string KeyNames[255],Aliases[255];
var bool bKeysInit;

static function string FindKeyBinding( string KBName, Actor Other )
{
	local PlayerPawn PL;
	local byte i;

	PL = Class'VActor'.Static.FindNetOwner(Other);
	if( !Default.bKeysInit )
	{
		Default.bKeysInit = True;
		for ( i=0; i<255; i++ )
		{
			Default.KeyNames[i] = PL.ConsoleCommand( "KEYNAME "$i );
			if( Default.KeyNames[i]!="" )
				Default.Aliases[i] = Caps(PL.ConsoleCommand("KEYBINDING "$Default.KeyNames[i]));
		}
	}
	KBName = Caps(KBName);
	for ( i=0; i<255; i++ )
	{
		if( InStr(Default.Aliases[i],KBName)>=0 )
			Return Default.KeyNames[i];
	}
	Return "";
}

defaultproperties
{
}
