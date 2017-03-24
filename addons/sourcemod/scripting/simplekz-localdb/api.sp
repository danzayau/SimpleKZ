/*	api.sp

	Simple KZ Core API.
*/


/*===============================  Forwards  ===============================*/

Handle gH_Forward_SimpleKZ_OnDatabaseConnect;
Handle gH_Forward_SimpleKZ_OnRetrievePlayerID;
Handle gH_Forward_SimpleKZ_OnRetrieveCurrentMapID;
Handle gH_Forward_SimpleKZ_OnStoreTimeInDB;

void CreateGlobalForwards() {
	gH_Forward_SimpleKZ_OnDatabaseConnect = CreateGlobalForward("SimpleKZ_OnDatabaseConnect", ET_Event, Param_Cell, Param_Cell);
	gH_Forward_SimpleKZ_OnRetrievePlayerID = CreateGlobalForward("SimpleKZ_OnRetrievePlayerID", ET_Event, Param_Cell, Param_Cell);
	gH_Forward_SimpleKZ_OnRetrieveCurrentMapID = CreateGlobalForward("SimpleKZ_OnRetrieveCurrentMapID", ET_Event, Param_Cell);
	gH_Forward_SimpleKZ_OnStoreTimeInDB = CreateGlobalForward("SimpleKZ_OnStoreTimeInDB", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
}

void Call_SimpleKZ_OnDatabaseConnect() {
	Call_StartForward(gH_Forward_SimpleKZ_OnDatabaseConnect);
	Call_PushCell(gH_DB);
	Call_PushCell(g_DBType);
	Call_Finish();
}

void Call_SimpleKZ_OnRetrievePlayerID(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnRetrievePlayerID);
	Call_PushCell(client);
	Call_PushCell(gI_DBPlayerID[client]);
	Call_Finish();
}

void Call_SimpleKZ_OnRetrieveCurrentMapID() {
	Call_StartForward(gH_Forward_SimpleKZ_OnRetrieveCurrentMapID);
	Call_PushCell(gI_DBCurrentMapID);
	Call_Finish();
}

void Call_SimpleKZ_OnStoreTimeInDB(int client, int playerID, int mapID, int course, KZStyle style, int runTimeMS, int teleportsUsed, int theoreticalRunTimeMS) {
	Call_StartForward(gH_Forward_SimpleKZ_OnStoreTimeInDB);
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
	CreateNative("SimpleKZ_GetPlayerID", Native_GetPlayerID);
	CreateNative("SimpleKZ_GetCurrentMapID", Native_GetCurrentMapID);
}

public int Native_GetPlayerID(Handle plugin, int numParams) {
	return gI_DBPlayerID[GetNativeCell(1)];
}

public int Native_GetCurrentMapID(Handle plugin, int numParams) {
	return gI_DBCurrentMapID;
} 