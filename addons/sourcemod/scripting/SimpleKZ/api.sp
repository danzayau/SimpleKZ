/*	api.sp

	Simple KZ Core API.
*/


/*===============================  Forwards  ===============================*/

Handle gH_Forward_SimpleKZ_OnDatabaseConnect;
Handle gH_Forward_SimpleKZ_OnChangeMovementStyle;
Handle gH_Forward_SimpleKZ_OnPerfectBunnyhop;
Handle gH_Forward_SimpleKZ_OnTimerStarted;
Handle gH_Forward_SimpleKZ_OnTimerEnded;
Handle gH_Forward_SimpleKZ_OnTimerPaused;
Handle gH_Forward_SimpleKZ_OnTimerResumed;
Handle gH_Forward_SimpleKZ_OnTimerForceStopped;
Handle gH_Forward_SimpleKZ_OnTimerTeleport;

void CreateGlobalForwards() {
	gH_Forward_SimpleKZ_OnDatabaseConnect = CreateGlobalForward("SimpleKZ_OnDatabaseConnect", ET_Event, Param_Cell, Param_Cell);
	gH_Forward_SimpleKZ_OnChangeMovementStyle = CreateGlobalForward("SimpleKZ_OnChangeMovementStyle", ET_Event, Param_Cell, Param_Cell);
	gH_Forward_SimpleKZ_OnPerfectBunnyhop = CreateGlobalForward("SimpleKZ_OnPerfectBunnyhop", ET_Event, Param_Cell);
	gH_Forward_SimpleKZ_OnTimerStarted = CreateGlobalForward("SimpleKZ_OnTimerStarted", ET_Event, Param_Cell, Param_Cell);
	gH_Forward_SimpleKZ_OnTimerEnded = CreateGlobalForward("SimpleKZ_OnTimerEnded", ET_Event, Param_Cell, Param_Float, Param_Cell, Param_Float, Param_Cell);
	gH_Forward_SimpleKZ_OnTimerPaused = CreateGlobalForward("SimpleKZ_OnTimerPaused", ET_Event, Param_Cell);
	gH_Forward_SimpleKZ_OnTimerResumed = CreateGlobalForward("SimpleKZ_OnTimerResumed", ET_Event, Param_Cell);
	gH_Forward_SimpleKZ_OnTimerForceStopped = CreateGlobalForward("SimpleKZ_OnTimerForceStopped", ET_Event, Param_Cell);
	gH_Forward_SimpleKZ_OnTimerTeleport = CreateGlobalForward("SimpleKZ_OnTimerTeleport", ET_Event, Param_Cell);
}

void Call_SimpleKZ_OnDatabaseConnect() {
	Call_StartForward(gH_Forward_SimpleKZ_OnDatabaseConnect);
	Call_PushCell(gH_DB);
	Call_PushCell(g_DBType);
	Call_Finish();
}

void Call_SimpleKZ_OnChangeMovementStyle(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnChangeMovementStyle);
	Call_PushCell(client);
	Call_PushCell(g_MovementStyle[client]);
	Call_Finish();
}

void Call_SimpleKZ_OnPerfectBunnyhop(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnPerfectBunnyhop);
	Call_PushCell(client);
	Call_Finish();
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
	Call_PushFloat(gF_CurrentTime[client]);
	Call_PushCell(gI_TeleportsUsed[client]);
	Call_PushFloat(gF_CurrentTime[client] - gF_WastedTime[client]);
	Call_PushCell(g_MovementStyle[client]);
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

void Call_SimpleKZ_OnTimerTeleport(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnTimerTeleport);
	Call_PushCell(client);
	Call_Finish();
}



/*===============================  Natives  ===============================*/

void CreateNatives() {
	CreateNative("SimpleKZ_GetMovementStyle", Native_GetMovementStyle);
	CreateNative("SimpleKZ_SetMovementStyle", Native_SetMovementStyle);
	CreateNative("SimpleKZ_GetHitPerf", Native_GetHitPerf);
	
	CreateNative("SimpleKZ_StartTimer", Native_StartTimer);
	CreateNative("SimpleKZ_EndTimer", Native_EndTimer);
	CreateNative("SimpleKZ_ForceStopTimer", Native_ForceStopTimer);
	CreateNative("SimpleKZ_GetTimerRunning", Native_GetTimerRunning);
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
}

public int Native_GetMovementStyle(Handle plugin, int numParams) {
	return view_as<int>(g_MovementStyle[GetNativeCell(1)]);
}

public int Native_SetMovementStyle(Handle plugin, int numParams) {
	SetMovementStyle(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetHitPerf(Handle plugin, int numParams) {
	return view_as<int>(gB_HitPerf[GetNativeCell(1)]);
}

public int Native_StartTimer(Handle plugin, int numParams) {
	TimerStart(GetNativeCell(1));
}

public int Native_EndTimer(Handle plugin, int numParams) {
	TimerEnd(GetNativeCell(1));
}

public int Native_ForceStopTimer(Handle plugin, int numParams) {
	TimerForceStop(GetNativeCell(1));
}

public int Native_GetTimerRunning(Handle plugin, int numParams) {
	return view_as<int>(gB_TimerRunning[GetNativeCell(1)]);
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