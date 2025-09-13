Class KeyBindObject extends Object;

var string KeyNames[255], Aliases[ArrayCount(KeyNames)], Cache[20];
var bool bKeysInit;
var int LevelStartTime;
var int CachePos;

static function string GetKeyName(int KeyCode)
{
	return default.KeyNames[KeyCode];
}

static function Refresh(Actor Other)
{
	local PlayerPawn PL;
	local int i;
	
	for (i = 0; i < ArrayCount(default.Cache); i++)
		Default.Cache[i] = "";
	
	PL = Class'VActor'.Static.FindNetOwner(Other);
	Default.bKeysInit = True;
	for (i = 0; i < ArrayCount(Default.KeyNames); i++)
	{
		Default.KeyNames[i] = PL.ConsoleCommand("KEYNAME " $ i);
		if (Default.KeyNames[i] != "")
			Default.Aliases[i] = Caps(PL.ConsoleCommand("KEYBINDING " $ Default.KeyNames[i]));
	}
}

static function int GetLevelStartTime(LevelInfo Level)
{
	local int ret;
	ret = Level.Month;
	ret = ret*31 + Level.Day;
	ret = ret*24 + Level.Hour;
	ret = ret*60 + Level.Minute;
	ret = ret*60 + Level.Second - Level.TimeSeconds/Level.TimeDilation;
	return ret;
}

static function string FindKeyBinding(string KBName, Actor Other)
{
	local PlayerPawn PL;
	local int i, k, m, j, CurLevelStartTime;
	local string Alias, ch, KBNameCaps;
	
	CurLevelStartTime = GetLevelStartTime(Other.Level);
	if (Abs(default.LevelStartTime - CurLevelStartTime) > 5)
	{
		default.CachePos = 0;
		default.bKeysInit = false;
	}
	
	for (j = 0; j < default.CachePos; j += 2)
		if (Default.Cache[j] ~= KBName)
			return Default.Cache[j + 1];
	
	default.LevelStartTime = CurLevelStartTime;

	if (!Default.bKeysInit)
		Refresh(Other);
	
	KBNameCaps = Caps(KBName);
	for (i = 0; i < ArrayCount(Default.KeyNames); i++)
	{
		m = InStr(Default.Aliases[i], KBNameCaps);
		if (m >= 0)
		{
			Alias = Default.Aliases[i];
			for (k = m; k >= m; k = InStr(Mid(Alias, m), KBNameCaps) + m)
			{
				m = k + Len(KBNameCaps);
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
					Default.Cache[default.CachePos++] = KBNameCaps;
					Default.Cache[default.CachePos++] = Default.KeyNames[i];
				}
					
				Return Default.KeyNames[i];
			}
		}
	}
	
	if (KBName ~= "ThrowWeapon")
	{
		for (i = 0; i < ArrayCount(Default.KeyNames); i++)
			if ((Default.KeyNames[i] != "B" || Default.KeyNames[i] != "G") &&
				Default.Aliases[i] == "")
			{
				PL = Class'VActor'.Static.FindNetOwner(Other);
				PL.ConsoleCommand("SET INPUT" @ Default.KeyNames[i] @ KBName);
				Default.Aliases[i] = KBName;
				Return Default.KeyNames[i];
			}
	}
	
	Return "";
}

defaultproperties
{
}
