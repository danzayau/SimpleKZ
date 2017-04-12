/*	api.sp

	Simple KZ Core API.
*/


/*===============================  Forwards  ===============================*/

Handle gH_SKZ_OnDatabaseConnect;
Handle gH_SKZ_OnRetrievePlayerID;
Handle gH_SKZ_OnRetrieveCurrentMapID;
Handle gH_SKZ_OnStoreTimeInDB;

void CreateGlobalForwards() {
	gH_SKZ_OnDatabaseConnect = CreateGlobalForward("SKZ_OnDatabaseConnect", ET_Event, Param_Cell, Param_Cell);
	gH_SKZ_OnRetrievePlayerID = CreateGlobalForward("SKZ_OnRetrievePlayerID", ET_Event, Param_Cell, Param_Cell);
	gH_SKZ_OnRetrieveCurrentMapID = CreateGlobalForward("SKZ_OnRetrieveCurrentMapID", ET_Event, Param_Cell);
	gH_SKZ_OnStoreTimeInDB = CreateGlobalForward("SKZ_OnStoreTimeInDB", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
}

void Call_SKZ_OnDatabaseConnect() {
	Call_StartForward(gH_SKZ_OnDatabaseConnect);
	Call_PushCell(gH_DB);
	Call_PushCell(g_DBType);
	Call_Finish();
}

void Call_SKZ_OnRetrievePlayerID(int client) {
	Call_StartForward(gH_SKZ_OnRetrievePlayerID);
	Call_PushCell(client);
	Call_PushCell(gI_DBPlayerID[client]);
	Call_Finish();
}

void Call_SKZ_OnRetrieveCurrentMapID() {
	Call_StartForward(gH_SKZ_OnRetrieveCurrentMapID);
	Call_PushCell(gI_DBCurrentMapID);
	Call_Finish();
}

void Call_SKZ_OnStoreTimeInDB(int client, int playerID, int mapID, int course, KZStyle style, int runTimeMS, int teleportsUsed, int theoreticalRunTimeMS) {
	Call_StartForward(gH_SKZ_OnStoreTimeInDB);
	Call_PushCell(client);
	Call_PushCell(playerID);
	Call_PushCell(mapID);
	Call_PushCell(course);
	Call_PushCell(style);
	Call_PushCell(runTimeMS);
	Call_PushCell(teleportsUsed);
	Call_PushCell(theoreticalRunTimeMS);
	Call_Finish();
}


/*===============================  Natives  ===============================*/

void CreateNatives() {
	CreateNative("SKZ_GetPlayerID", Native_GetPlayerID);
	CreateNative("SKZ_GetCurrentMapID", Native_GetCurrentMapID);
}

public int Native_GetPlayerID(Handle plugin, int numParams) {
	return gI_DBPlayerID[GetNativeCell(1)];
}

public int Native_GetCurrentMapID(Handle plugin, int numParams) {
	return gI_DBCurrentMapID;
} 