/*
	Mapping API
	
	Hooks between map entities and SimpleKZ.
*/

// Creates regexes used to detect certain entity names.
void MappingAPICreateRegexes()
{
	gRE_BonusStartButton = CompileRegex("^climb_bonus(\\d+)_startbutton$");
	gRE_BonusEndButton = CompileRegex("^climb_bonus(\\d+)_endbutton$");
}

// Hooks up the map with the mapping API.
void MappingAPIUpdate()
{
	SetupKZProMap();
	SetupMapEntityHooks();
}



/*===============================  Public Callbacks  ===============================*/

public void OnStartButtonPress(const char[] name, int caller, int activator, float delay)
{
	if (!IsValidEntity(caller) || !IsValidClient(activator))
	{
		return;
	}
	
	g_MovementPlayer[activator].GetOrigin(gF_StartButtonOrigin[activator]);
	TimerStart(activator, 0);
}

public void OnEndButtonPress(const char[] name, int caller, int activator, float delay)
{
	if (!IsValidEntity(caller) || !IsValidClient(activator))
	{
		return;
	}
	
	g_MovementPlayer[activator].GetOrigin(gF_EndButtonOrigin[activator]);
	TimerEnd(activator, 0);
}

public void OnBonusStartButtonPress(const char[] name, int caller, int activator, float delay)
{
	if (!IsValidEntity(caller) || !IsValidClient(activator)) {
		return;
	}
	
	char tempString[32];
	GetEntPropString(caller, Prop_Data, "m_iName", tempString, sizeof(tempString));
	if (MatchRegex(gRE_BonusStartButton, tempString) > 0)
	{
		GetRegexSubString(gRE_BonusStartButton, 1, tempString, sizeof(tempString));
		int bonus = StringToInt(tempString);
		if (bonus > 0)
		{
			TimerStart(activator, bonus);
		}
	}
}

public void OnBonusEndButtonPress(const char[] name, int caller, int activator, float delay)
{
	if (!IsValidEntity(caller) || !IsValidClient(activator))
	{
		return;
	}
	
	char tempString[32];
	GetEntPropString(caller, Prop_Data, "m_iName", tempString, sizeof(tempString));
	if (MatchRegex(gRE_BonusEndButton, tempString) > 0)
	{
		GetRegexSubString(gRE_BonusEndButton, 1, tempString, sizeof(tempString));
		int bonus = StringToInt(tempString);
		if (bonus > 0)
		{
			TimerEnd(activator, bonus);
		}
	}
}



/*===============================  Static Functions  ===============================*/

// Check the map name to see if it's got a kzpro_ tag, and set the kzpro map bool.
static void SetupKZProMap()
{
	char map[64], mapPieces[5][64], mapPrefix[1][64];
	GetCurrentMap(map, sizeof(map));
	int lastPiece = ExplodeString(map, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	ExplodeString(mapPieces[lastPiece - 1], "_", mapPrefix, sizeof(mapPrefix), sizeof(mapPrefix[]));
	gB_CurrentMapIsKZPro = StrEqual(mapPrefix[0], "kzpro", false);
}

// Hooks up entities with the mapping API. Note: Most entities are recreated on round start.
static void SetupMapEntityHooks()
{
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "func_button")) != -1)
	{
		SetupFuncButtonHooks(entity);
	}
}

static void SetupFuncButtonHooks(int entity)
{
	char tempString[32];
	GetEntPropString(entity, Prop_Data, "m_iName", tempString, sizeof(tempString));
	
	if (StrEqual("climb_startbutton", tempString, false))
	{
		HookSingleEntityOutput(entity, "OnPressed", OnStartButtonPress);
	}
	else if (StrEqual("climb_endbutton", tempString, false))
	{
		HookSingleEntityOutput(entity, "OnPressed", OnEndButtonPress);
	}
	else if (MatchRegex(gRE_BonusStartButton, tempString) > 0)
	{
		HookSingleEntityOutput(entity, "OnPressed", OnBonusStartButtonPress);
	}
	else if (MatchRegex(gRE_BonusEndButton, tempString) > 0)
	{
		HookSingleEntityOutput(entity, "OnPressed", OnBonusEndButtonPress);
	}
} 