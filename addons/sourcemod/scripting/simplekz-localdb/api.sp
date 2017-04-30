/*
	API
	
	Simple KZ Local DB API.
*/

/*===============================  Forwards  ===============================*/

void CreateGlobalForwards()
{
	gH_OnDatabaseConnect = CreateGlobalForward("SKZ_DB_OnDatabaseConnect", ET_Ignore, Param_Cell, Param_Cell);
	gH_OnPlayerSetup = CreateGlobalForward("SKZ_DB_OnPlayerSetup", ET_Ignore, Param_Cell, Param_Cell);
	gH_OnMapIDRetrieved = CreateGlobalForward("SKZ_DB_OnMapIDRetrieved", ET_Ignore, Param_Cell);
	gH_OnTimeInserted = CreateGlobalForward("SKZ_DB_OnTimeInserted", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
}

void Call_OnDatabaseConnect()
{
	Call_StartForward(gH_OnDatabaseConnect);
	Call_PushCell(gH_DB);
	Call_PushCell(g_DBType);
	Call_Finish();
}

void Call_OnPlayerSetup(int client, int steamID)
{
	Call_StartForward(gH_OnPlayerSetup);
	if (GetSteamAccountID(client) == steamID)
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

void Call_OnMapIDRetrieved()
{
	Call_StartForward(gH_OnMapIDRetrieved);
	Call_PushCell(gI_DBCurrentMapID);
	Call_Finish();
}

void Call_OnTimeInserted(int client, int steamID, int mapID, int course, KZStyle style, int runTimeMS, int teleportsUsed, int theoreticalRunTimeMS)
{
	Call_StartForward(gH_OnTimeInserted);
	if (GetSteamAccountID(client) == steamID)
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