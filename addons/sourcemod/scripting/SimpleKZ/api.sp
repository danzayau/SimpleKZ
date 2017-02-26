/*	api.sp

	Simple KZ Core API.
*/


/*===============================  Forwards  ===============================*/

Handle gH_Forward_SimpleKZ_OnChangeMovementStyle;
Handle gH_Forward_SimpleKZ_OnPerfectBunnyhop;
Handle gH_Forward_SimpleKZ_OnTimerStart;
Handle gH_Forward_SimpleKZ_OnTimerEnd;
Handle gH_Forward_SimpleKZ_OnTimerForceStop;
Handle gH_Forward_SimpleKZ_OnPlayerPause;
Handle gH_Forward_SimpleKZ_OnPlayerResume;
Handle gH_Forward_SimpleKZ_OnPlayerTeleport;
Handle gH_Forward_SimpleKZ_OnDatabaseConnect;
Handle gH_Forward_SimpleKZ_OnRetrievePlayerID;

void CreateGlobalForwards() {
	gH_Forward_SimpleKZ_OnChangeMovementStyle = CreateGlobalForward("SimpleKZ_OnChangeMovementStyle", ET_Event, Param_Cell, Param_Cell);
	gH_Forward_SimpleKZ_OnPerfectBunnyhop = CreateGlobalForward("SimpleKZ_OnPerfectBunnyhop", ET_Event, Param_Cell);
	gH_Forward_SimpleKZ_OnTimerStart = CreateGlobalForward("SimpleKZ_OnTimerStart", ET_Event, Param_Cell, Param_Cell, Param_Cell);
	gH_Forward_SimpleKZ_OnTimerEnd = CreateGlobalForward("SimpleKZ_OnTimerEnd", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell, Param_Float);
	gH_Forward_SimpleKZ_OnTimerForceStop = CreateGlobalForward("SimpleKZ_OnTimerForceStop", ET_Event, Param_Cell);
	gH_Forward_SimpleKZ_OnPlayerPause = CreateGlobalForward("SimpleKZ_OnTimerPause", ET_Event, Param_Cell);
	gH_Forward_SimpleKZ_OnPlayerResume = CreateGlobalForward("SimpleKZ_OnTimerResume", ET_Event, Param_Cell);
	gH_Forward_SimpleKZ_OnPlayerTeleport = CreateGlobalForward("SimpleKZ_OnTimerTeleport", ET_Event, Param_Cell);
	gH_Forward_SimpleKZ_OnDatabaseConnect = CreateGlobalForward("SimpleKZ_OnDatabaseConnect", ET_Event, Param_Cell, Param_Cell);
	gH_Forward_SimpleKZ_OnRetrievePlayerID = CreateGlobalForward("SimpleKZ_OnRetrievePlayerID", ET_Event, Param_Cell, Param_Cell);
}

void Call_SimpleKZ_OnChangeMovementStyle(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnChangeMovementStyle);
	Call_PushCell(client);
	Call_PushCell(g_Style[client]);
	Call_Finish();
}

void Call_SimpleKZ_OnPerfectBunnyhop(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnPerfectBunnyhop);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SimpleKZ_OnTimerStart(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnTimerStart);
	Call_PushCell(client);
	Call_PushCell(gI_CurrentCourse[client]);
	Call_PushCell(g_Style[client]);
	Call_Finish();
}

void Call_SimpleKZ_OnTimerEnd(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnTimerEnd);
	Call_PushCell(client);
	Call_PushCell(gI_CurrentCourse[client]);
	Call_PushCell(g_Style[client]);
	Call_PushFloat(gF_CurrentTime[client]);
	Call_PushCell(gI_TeleportsUsed[client]);
	Call_PushFloat(gF_CurrentTime[client] - gF_WastedTime[client]);
	Call_Finish();
}

void Call_SimpleKZ_OnTimerForceStop(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnTimerForceStop);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SimpleKZ_OnPlayerPause(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnPlayerPause);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SimpleKZ_OnPlayerResume(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnPlayerResume);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SimpleKZ_OnPlayerTeleport(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnPlayerTeleport);
	Call_PushCell(client);
	Call_Finish();
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
	Call_PushCell(gI_PlayerID[client]);
	Call_Finish();
}



/*===============================  Natives  ===============================*/

void CreateNatives() {
	CreateNative("SimpleKZ_GetHitPerf", Native_GetHitPerf);
	
	CreateNative("SimpleKZ_ForceStopTimer", Native_ForceStopTimer);
	CreateNative("SimpleKZ_ForceStopTimerAll", Native_ForceStopTimerAll);
	CreateNative("SimpleKZ_GetTimerRunning", Native_GetTimerRunning);
	CreateNative("SimpleKZ_GetCurrentCourse", Native_GetCurrentCourse);
	CreateNative("SimpleKZ_GetPaused", Native_GetPaused);
	CreateNative("SimpleKZ_GetCurrentTime", Native_GetCurrentTime);
	CreateNative("SimpleKZ_GetCheckpointCount", Native_GetCheckpointCount);
	
	CreateNative("SimpleKZ_TeleportToStart", Native_TeleportToStart);
	CreateNative("SimpleKZ_MakeCheckpoint", Native_MakeCheckpoint);
	CreateNative("SimpleKZ_TeleportToCheckpoint", Native_TeleportToCheckpoint);
	CreateNative("SimpleKZ_UndoTeleport", Native_UndoTeleport);
	CreateNative("SimpleKZ_Pause", Native_Pause);
	CreateNative("SimpleKZ_Resume", Native_Resume);
	CreateNative("SimpleKZ_TogglePause", Native_TogglePause);
	
	CreateNative("SimpleKZ_GetDefaultStyle", Native_GetDefaultStyle);
	CreateNative("SimpleKZ_GetOptionStyle", Native_GetOptionStyle);
	CreateNative("SimpleKZ_SetOptionStyle", Native_SetOptionStyle);
	
	CreateNative("SimpleKZ_GetPlayerID", Native_GetPlayerID);
}

public int Native_GetHitPerf(Handle plugin, int numParams) {
	return view_as<int>(gB_HitPerf[GetNativeCell(1)]);
}

public int Native_ForceStopTimer(Handle plugin, int numParams) {
	TimerForceStop(GetNativeCell(1));
}

public int Native_ForceStopTimerAll(Handle plugin, int numParams) {
	TimerForceStopAll();
}

public int Native_GetTimerRunning(Handle plugin, int numParams) {
	return view_as<int>(gB_TimerRunning[GetNativeCell(1)]);
}

public int Native_GetCurrentCourse(Handle plugin, int numParams) {
	return gI_CurrentCourse[GetNativeCell(1)];
}

public int Native_GetPaused(Handle plugin, int numParams) {
	return view_as<int>(gB_Paused[GetNativeCell(1)]);
}

public int Native_GetCurrentTime(Handle plugin, int numParams) {
	return view_as<int>(gF_CurrentTime[GetNativeCell(1)]);
}

public int Native_GetCheckpointCount(Handle plugin, int numParams) {
	return gI_CheckpointCount[GetNativeCell(1)];
}

public int Native_TeleportToStart(Handle plugin, int numParams) {
	TeleportToStart(GetNativeCell(1));
}

public int Native_MakeCheckpoint(Handle plugin, int numParams) {
	MakeCheckpoint(GetNativeCell(1));
}

public int Native_TeleportToCheckpoint(Handle plugin, int numParams) {
	TeleportToCheckpoint(GetNativeCell(1));
}

public int Native_UndoTeleport(Handle plugin, int numParams) {
	UndoTeleport(GetNativeCell(1));
}

public int Native_Pause(Handle plugin, int numParams) {
	Pause(GetNativeCell(1));
}

public int Native_Resume(Handle plugin, int numParams) {
	Resume(GetNativeCell(1));
}

public int Native_TogglePause(Handle plugin, int numParams) {
	TogglePause(GetNativeCell(1));
}

public int Native_GetOptionStyle(Handle plugin, int numParams) {
	return view_as<int>(g_Style[GetNativeCell(1)]);
}

public int Native_SetOptionStyle(Handle plugin, int numParams) {
	SetMovementStyle(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetDefaultStyle(Handle plugin, int numParams) {
	return GetConVarInt(gCV_DefaultStyle);
}

public int Native_GetPlayerID(Handle plugin, int numParams) {
	return gI_PlayerID[GetNativeCell(1)];
} 