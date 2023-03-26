Class KeyBindObject extends Object;

var string KeyNames[255], Aliases[ArrayCount(KeyNames)], Cache[20];
var bool bKeysInit;
var LevelInfo Level;
var int CachePos;

static function string FindKeyBinding(string KBName, Actor Other)
{
	local PlayerPawn PL;
	local int i, k, m, j;
	local string Alias, ch;
	
	if (default.Level != Other.Level)
	{
		default.CachePos = 0;
		default.bKeysInit = false;
	}
	
	for (j = 0; j < default.CachePos; j += 2)
		if (Default.Cache[j] ~= KBName)
			return Default.Cache[j + 1];
	
	default.Level = Other.Level;

	PL = Class'VActor'.Static.FindNetOwner(Other);
	if (!Default.bKeysInit)
	{
		Default.bKeysInit = True;
		for (i = 0; i < ArrayCount(Default.KeyNames); i++)
		{
			Default.KeyNames[i] = PL.ConsoleCommand("KEYNAME " $ i);
			if (Default.KeyNames[i] != "")
				Default.Aliases[i] = Caps(PL.ConsoleCommand("KEYBINDING " $ Default.KeyNames[i]));
		}
	}
	KBName = Caps(KBName);
	for (i = 0; i < ArrayCount(Default.KeyNames); i++)
	{
		m = InStr(Default.Aliases[i], KBName);
		if (m >= 0)
		{
			Alias = Default.Aliases[i];
			for (k = m; k >= m; k = InStr(Mid(Alias, m), KBName) + m)
			{
				m = k + Len(KBName);
				j = k - 1;
				while (j >= 0 && Mid(Alias, j, 1) == " ")
					j--;
				if (j >= 0 && Mid(Alias, j, 1) != "|")
					continue;
				while (Mid(Alias, m, 1) == " ")
					m++;
				ch = Mid(Alias, m, 1);
				if (ch != "|" && ch != "")
					continue;
					
				if (default.CachePos < ArrayCount(Default.Cache))
				{
					Default.Cache[default.CachePos++] = KBName;
					Default.Cache[default.CachePos++] = Default.KeyNames[i];
				}
					
				Return Default.KeyNames[i];
			}
		}
	}
	Return "";
}

defaultproperties
{
}
