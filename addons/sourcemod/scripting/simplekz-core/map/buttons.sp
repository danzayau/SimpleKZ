/*
	Mapping API - Buttons
	
	Hooks between func_buttons and SimpleKZ.
*/

// Creates regexes used to detect certain entity names.
void MapButtonsCreateRegexes()
{
	gRE_BonusStartButton = CompileRegex("^climb_bonus(\\d+)_startbutton$");
	gRE_BonusEndButton = CompileRegex("^climb_bonus(\\d+)_endbutton$");
}

// Hooks up the map with the mapping API.
void MapButtonsUpdate()
{
	MapButtonsSetupHooks();
}



/*===============================  Public Callbacks  ===============================*/

public void OnStartButtonPress(const char[] name, int caller, int activator, float delay)
{
	if (!IsValidEntity(caller) || !IsValidClient(activator))
	{
		return;
	}
	
	g_KZPlayer[activator].GetOrigin(gF_StartButtonOrigin[activator]);
	TimerStart(activator, 0);
}

public void OnEndButtonPress(const char[] name, int caller, int activator, float delay)
{
	if (!IsValidEntity(caller) || !IsValidClient(activator))
	{
		return;
	}
	
	g_KZPlayer[activator].GetOrigin(gF_EndButtonOrigin[activator]);
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

// Hooks up func_button entities. Note: Most map entities are recreated on round start.
static void MapButtonsSetupHooks()
{
	int entity = -1;
	char tempString[32];
	
	while ((entity = FindEntityByClassname(entity, "func_button")) != -1)
	{
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
} 