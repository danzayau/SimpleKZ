/*
	API
	
	Simple KZ Core API.
*/

/*===============================  Forwards  ===============================*/

void CreateGlobalForwards()
{
	gH_OnTimerStart = CreateGlobalForward("SKZ_OnTimerStart", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	gH_OnTimerEnd = CreateGlobalForward("SKZ_OnTimerEnd", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell, Param_Float);
	gH_OnTimerForceStop = CreateGlobalForward("SKZ_OnTimerForceStop", ET_Ignore, Param_Cell);
	gH_OnChangeOption = CreateGlobalForward("SKZ_OnChangeOption", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	gH_OnPerfectBunnyhop = CreateGlobalForward("SKZ_OnPerfectBunnyhop", ET_Ignore, Param_Cell);
	gH_OnPause = CreateGlobalForward("SKZ_OnPause", ET_Ignore, Param_Cell);
	gH_OnResume = CreateGlobalForward("SKZ_OnResume", ET_Ignore, Param_Cell);
	gH_OnTeleportToStart = CreateGlobalForward("SKZ_OnTeleportToStart", ET_Ignore, Param_Cell);
	gH_OnMakeCheckpoint = CreateGlobalForward("SKZ_OnMakeCheckpoint", ET_Ignore, Param_Cell);
	gH_OnTeleportToCheckpoint = CreateGlobalForward("SKZ_OnTeleportToCheckpoint", ET_Ignore, Param_Cell);
	gH_OnUndoTeleport = CreateGlobalForward("SKZ_OnUndoTeleport", ET_Ignore, Param_Cell);
}

void Call_SKZ_OnTimerStart(int client, int course)
{
	Call_StartForward(gH_OnTimerStart);
	Call_PushCell(client);
	Call_PushCell(course);
	Call_PushCell(g_Style[client]);
	Call_Finish();
}

void Call_SKZ_OnTimerEnd(int client, int course)
{
	Call_StartForward(gH_OnTimerEnd);
	Call_PushCell(client);
	Call_PushCell(course);
	Call_PushCell(g_Style[client]);
	Call_PushFloat(gF_CurrentTime[client]);
	Call_PushCell(gI_TeleportsUsed[client]);
	Call_PushFloat(gF_CurrentTime[client] - gF_WastedTime[client]);
	Call_Finish();
}

void Call_SKZ_OnTimerForceStop(int client)
{
	Call_StartForward(gH_OnTimerForceStop);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SKZ_OnPause(int client)
{
	Call_StartForward(gH_OnPause);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SKZ_OnResume(int client)
{
	Call_StartForward(gH_OnResume);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SKZ_OnTeleportToStart(int client)
{
	Call_StartForward(gH_OnTeleportToStart);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SKZ_OnMakeCheckpoint(int client)
{
	Call_StartForward(gH_OnMakeCheckpoint);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SKZ_OnTeleportToCheckpoint(int client)
{
	Call_StartForward(gH_OnTeleportToCheckpoint);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SKZ_OnUndoTeleport(int client)
{
	Call_StartForward(gH_OnUndoTeleport);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SKZ_OnChangeOption(int client, KZOption option, any optionValue)
{
	Call_StartForward(gH_OnChangeOption);
	Call_PushCell(client);
	Call_PushCell(option);
	Call_PushCell(optionValue);
	Call_Finish();
}

void Call_SKZ_OnPerfectBunnyhop(int client)
{
	Call_StartForward(gH_OnPerfectBunnyhop);
	Call_PushCell(client);
	Call_Finish();
}



/*===============================  Natives  ===============================*/

void CreateNatives()
{
	CreateNative("SKZ_GetHitPerf", Native_GetHitPerf);
	
	CreateNative("SKZ_StartTimer", Native_StartTimer);
	CreateNative("SKZ_EndTimer", Native_EndTimer);
	CreateNative("SKZ_ForceStopTimer", Native_ForceStopTimer);
	CreateNative("SKZ_ForceStopTimerAll", Native_ForceStopTimerAll);
	CreateNative("SKZ_GetTimerRunning", Native_GetTimerRunning);
	CreateNative("SKZ_GetCurrentCourse", Native_GetCurrentCourse);
	CreateNative("SKZ_GetPaused", Native_GetPaused);
	CreateNative("SKZ_GetCurrentTime", Native_GetCurrentTime);
	CreateNative("SKZ_GetCheckpointCount", Native_GetCheckpointCount);
	
	CreateNative("SKZ_TeleportToStart", Native_TeleportToStart);
	CreateNative("SKZ_MakeCheckpoint", Native_MakeCheckpoint);
	CreateNative("SKZ_TeleportToCheckpoint", Native_TeleportToCheckpoint);
	CreateNative("SKZ_UndoTeleport", Native_UndoTeleport);
	CreateNative("SKZ_Pause", Native_Pause);
	CreateNative("SKZ_Resume", Native_Resume);
	CreateNative("SKZ_TogglePause", Native_TogglePause);
	
	CreateNative("SKZ_GetDefaultStyle", Native_GetDefaultStyle);
	CreateNative("SKZ_GetOption", Native_GetOption);
	CreateNative("SKZ_SetOption", Native_SetOption);
	
	CreateNative("SKZ_PlayErrorSound", Native_PlayErrorSound);
}

public int Native_GetHitPerf(Handle plugin, int numParams)
{
	return view_as<int>(gB_HitPerf[GetNativeCell(1)]);
}

public int Native_StartTimer(Handle plugin, int numParams)
{
	TimerStart(GetNativeCell(1), GetNativeCell(2));
}

public int Native_EndTimer(Handle plugin, int numParams)
{
	TimerEnd(GetNativeCell(1), GetNativeCell(2));
}

public int Native_ForceStopTimer(Handle plugin, int numParams)
{
	return view_as<int>(TimerForceStopNative(GetNativeCell(1)));
}

public int Native_ForceStopTimerAll(Handle plugin, int numParams)
{
	TimerForceStopAllNative();
}

public int Native_GetTimerRunning(Handle plugin, int numParams)
{
	return view_as<int>(gB_TimerRunning[GetNativeCell(1)]);
}

public int Native_GetCurrentCourse(Handle plugin, int numParams)
{
	return gI_LastCourseStarted[GetNativeCell(1)];
}

public int Native_GetPaused(Handle plugin, int numParams)
{
	return view_as<int>(gB_Paused[GetNativeCell(1)]);
}

public int Native_GetCurrentTime(Handle plugin, int numParams)
{
	return view_as<int>(gF_CurrentTime[GetNativeCell(1)]);
}

public int Native_GetCheckpointCount(Handle plugin, int numParams)
{
	return gI_CheckpointCount[GetNativeCell(1)];
}

public int Native_TeleportToStart(Handle plugin, int numParams)
{
	TeleportToStart(GetNativeCell(1));
}

public int Native_MakeCheckpoint(Handle plugin, int numParams)
{
	MakeCheckpoint(GetNativeCell(1));
}

public int Native_TeleportToCheckpoint(Handle plugin, int numParams)
{
	TeleportToCheckpoint(GetNativeCell(1));
}

public int Native_UndoTeleport(Handle plugin, int numParams)
{
	UndoTeleport(GetNativeCell(1));
}

public int Native_Pause(Handle plugin, int numParams)
{
	Pause(GetNativeCell(1));
}

public int Native_Resume(Handle plugin, int numParams)
{
	Resume(GetNativeCell(1));
}

public int Native_TogglePause(Handle plugin, int numParams)
{
	TogglePause(GetNativeCell(1));
}

public int Native_GetDefaultStyle(Handle plugin, int numParams)
{
	return GetConVarInt(gCV_DefaultStyle);
}

public int Native_GetOption(Handle plugin, int numParams)
{
	return GetOption(GetNativeCell(1), GetNativeCell(2));
}

public int Native_SetOption(Handle plugin, int numParams)
{
	SetOption(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3));
}

public int Native_PlayErrorSound(Handle plugin, int numParams)
{
	PlayErrorSound(GetNativeCell(1));
} 