/*
	API
	
	Simple KZ Local DB API.
*/

/*===============================  Forwards  ===============================*/

void CreateGlobalForwards()
{
	gH_OnDatabaseConnect = CreateGlobalForward("SKZ_DB_OnDatabaseConnect", ET_Ignore, Param_Cell, Param_Cell);
	gH_OnClientSetup = CreateGlobalForward("SKZ_DB_OnClientSetup", ET_Ignore, Param_Cell, Param_Cell);
	gH_OnMapSetup = CreateGlobalForward("SKZ_DB_OnMapSetup", ET_Ignore, Param_Cell);
	gH_OnTimeInserted = CreateGlobalForward("SKZ_DB_OnTimeInserted", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
}

void Call_OnDatabaseConnect()
{
	Call_StartForward(gH_OnDatabaseConnect);
	Call_PushCell(gH_DB);
	Call_PushCell(g_DBType);
	Call_Finish();
}

void Call_OnClientSetup(int client, int steamID)
{
	Call_StartForward(gH_OnClientSetup);
	if (IsValidClient(client) && GetSteamAccountID(client) == steamID)
	{
		Call_PushCell(client);
	}
	else
	{
		Call_PushCell(-1);
	}
	Call_PushCell(steamID);
	Call_Finish();
}

void Call_OnMapSetup()
{
	Call_StartForward(gH_OnMapSetup);
	Call_PushCell(gI_DBCurrentMapID);
	Call_Finish();
}

void Call_OnTimeInserted(int client, int steamID, int mapID, int course, KZStyle style, int runTimeMS, int teleportsUsed, int theoreticalRunTimeMS)
{
	Call_StartForward(gH_OnTimeInserted);
	if (IsValidClient(client) && GetSteamAccountID(client) == steamID)
	{
		Call_PushCell(client);
	}
	else
	{
		Call_PushCell(-1);
	}
	Call_PushCell(steamID);
	Call_PushCell(mapID);
	Call_PushCell(course);
	Call_PushCell(style);
	Call_PushCell(runTimeMS);
	Call_PushCell(teleportsUsed);
	Call_PushCell(theoreticalRunTimeMS);
	Call_Finish();
}


/*===============================  Natives  ===============================*/

void CreateNatives()
{
	CreateNative("SKZ_DB_GetDatabase", Native_GetDatabase);
	CreateNative("SKZ_DB_GetDatabaseType", Native_GetDatabaseType);
	CreateNative("SKZ_DB_GetCurrentMapID", Native_GetCurrentMapID);
}

public int Native_GetDatabase(Handle plugin, int numParams)
{
	SetNativeCellRef(1, gH_DB);
}

public int Native_GetDatabaseType(Handle plugin, int numParams)
{
	return view_as<int>(g_DBType);
}

public int Native_GetCurrentMapID(Handle plugin, int numParams)
{
	return gI_DBCurrentMapID;
} 