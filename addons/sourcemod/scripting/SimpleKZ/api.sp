/*	api.sp

	Simple KZ Core API.
*/


/*===============================  Forwards  ===============================*/

Handle gH_Forward_SimpleKZ_OnTimerStarted;
Handle gH_Forward_SimpleKZ_OnTimerEnded;
Handle gH_Forward_SimpleKZ_OnTimerPaused;
Handle gH_Forward_SimpleKZ_OnTimerResumed;
Handle gH_Forward_SimpleKZ_OnTimerForceStopped;
Handle gH_Forward_SimpleKZ_OnDatabaseConnect;

void CreateGlobalForwards() {
	gH_Forward_SimpleKZ_OnTimerStarted = CreateGlobalForward("SimpleKZ_OnTimerStarted", ET_Event, Param_Cell, Param_Cell);
	gH_Forward_SimpleKZ_OnTimerEnded = CreateGlobalForward("SimpleKZ_OnTimerEnded", ET_Event, Param_Cell, Param_Float, Param_Cell, Param_Float);
	gH_Forward_SimpleKZ_OnTimerPaused = CreateGlobalForward("SimpleKZ_OnTimerPaused", ET_Event, Param_Cell);
	gH_Forward_SimpleKZ_OnTimerResumed = CreateGlobalForward("SimpleKZ_OnTimerResumed", ET_Event, Param_Cell);
	gH_Forward_SimpleKZ_OnTimerForceStopped = CreateGlobalForward("SimpleKZ_OnTimerForceStopped", ET_Event, Param_Cell);
	gH_Forward_SimpleKZ_OnDatabaseConnect = CreateGlobalForward("SimpleKZ_OnDatabaseConnect", ET_Event, Param_Cell, Param_Cell);
}

void Call_SimpleKZ_OnTimerStarted(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnTimerStarted);
	Call_PushCell(client);
	Call_PushCell(!gB_HasStartedThisMap[client]);
	Call_Finish();
}

void Call_SimpleKZ_OnTimerEnded(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnTimerEnded);
	Call_PushCell(client);
	Call_PushFloat(gF_CurrentTime[client] - gF_WastedTime[client]);
	Call_PushCell(gI_TeleportsUsed[client]);
	Call_PushFloat(gF_WastedTime[client]);
	Call_Finish();
}

void Call_SimpleKZ_OnTimerPaused(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnTimerPaused);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SimpleKZ_OnTimerResumed(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnTimerResumed);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SimpleKZ_OnTimerForceStopped(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnTimerForceStopped);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SimpleKZ_OnDatabaseConnect() {
	Call_StartForward(gH_Forward_SimpleKZ_OnDatabaseConnect);
	Call_PushCell(gH_DB);
	Call_PushCell(g_DBType);
	Call_Finish();
}



/*===============================  Natives  ===============================*/

void CreateNatives() {
	CreateNative("SimpleKZ_StartTimer", Native_StartTimer);
	CreateNative("SimpleKZ_EndTimer", Native_EndTimer);
	CreateNative("SimpleKZ_ForceStopTimer", Native_ForceStopTimer);
	CreateNative("SimpleKZ_GetCurrentTime", Native_GetCurrentTime);
}

public int Native_StartTimer(Handle plugin, int numParams) {
	Call_SimpleKZ_OnTimerStarted(GetNativeCell(1));
}

public int Native_EndTimer(Handle plugin, int numParams) {
	Call_SimpleKZ_OnTimerEnded(GetNativeCell(1));
}

public int Native_ForceStopTimer(Handle plugin, int numParams) {
	Call_SimpleKZ_OnTimerForceStopped(GetNativeCell(1));
}

public int Native_GetCurrentTime(Handle plugin, int numParams) {
	if (gB_TimerRunning[GetNativeCell(1)]) {
		return view_as<int>(gF_CurrentTime[GetNativeCell(1)]);
	}
	return view_as<int>(-1.0);
} 