/*
	Natives
	
	SimpleKZ Core plugin natives.
*/



void CreateNatives()
{
	CreateNative("SKZ_IsClientSetUp", Native_IsClientSetUp);
	CreateNative("SKZ_StartTimer", Native_StartTimer);
	CreateNative("SKZ_EndTimer", Native_EndTimer);
	CreateNative("SKZ_StopTimer", Native_StopTimer);
	CreateNative("SKZ_StopTimerAll", Native_StopTimerAll);
	CreateNative("SKZ_TeleportToStart", Native_TeleportToStart);
	CreateNative("SKZ_MakeCheckpoint", Native_MakeCheckpoint);
	CreateNative("SKZ_TeleportToCheckpoint", Native_TeleportToCheckpoint);
	CreateNative("SKZ_UndoTeleport", Native_UndoTeleport);
	CreateNative("SKZ_Pause", Native_Pause);
	CreateNative("SKZ_Resume", Native_Resume);
	CreateNative("SKZ_TogglePause", Native_TogglePause);
	CreateNative("SKZ_PlayErrorSound", Native_PlayErrorSound);
	CreateNative("SKZ_GetDefaultStyle", Native_GetDefaultStyle);
	CreateNative("SKZ_GetTimerRunning", Native_GetTimerRunning);
	CreateNative("SKZ_GetCurrentCourse", Native_GetCurrentCourse);
	CreateNative("SKZ_GetPaused", Native_GetPaused);
	CreateNative("SKZ_GetCurrentTime", Native_GetCurrentTime);
	CreateNative("SKZ_GetWastedTime", Native_GetWastedTime);
	CreateNative("SKZ_GetCheckpointCount", Native_GetCheckpointCount);
	CreateNative("SKZ_GetOption", Native_GetOption);
	CreateNative("SKZ_SetOption", Native_SetOption);
	CreateNative("SKZ_GetHitPerf", Native_GetHitPerf);
	CreateNative("SKZ_GetTakeoffSpeed", Native_GetTakeoffSpeed);
	CreateNative("SKZ_PrintToChat", Native_PrintToChat);
}

public int Native_IsClientSetUp(Handle plugin, int numParams)
{
	return gB_ClientIsSetUp[GetNativeCell(1)];
}

public int Native_StartTimer(Handle plugin, int numParams)
{
	TimerStart(GetNativeCell(1), GetNativeCell(2));
}

public int Native_EndTimer(Handle plugin, int numParams)
{
	TimerEnd(GetNativeCell(1), GetNativeCell(2));
}

public int Native_StopTimer(Handle plugin, int numParams)
{
	return view_as<int>(TimerStop(GetNativeCell(1)));
}

public int Native_StopTimerAll(Handle plugin, int numParams)
{
	TimerStopAll();
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

public int Native_PlayErrorSound(Handle plugin, int numParams)
{
	PlayErrorSound(GetNativeCell(1));
}

public int Native_GetDefaultStyle(Handle plugin, int numParams)
{
	return GetConVarInt(gCV_DefaultStyle);
}

public int Native_GetTimerRunning(Handle plugin, int numParams)
{
	return view_as<int>(GetTimerRunning(GetNativeCell(1)));
}

public int Native_GetCurrentCourse(Handle plugin, int numParams)
{
	return GetCurrentCourse(GetNativeCell(1));
}

public int Native_GetPaused(Handle plugin, int numParams)
{
	return view_as<int>(GetPaused(GetNativeCell(1)));
}

public int Native_GetCurrentTime(Handle plugin, int numParams)
{
	return view_as<int>(GetCurrentTime(GetNativeCell(1)));
}

public int Native_GetWastedTime(Handle plugin, int numParams)
{
	return view_as<int>(GetWastedTime(GetNativeCell(1)));
}

public int Native_GetCheckpointCount(Handle plugin, int numParams)
{
	return GetCheckpointCount(GetNativeCell(1));
}

public int Native_GetOption(Handle plugin, int numParams)
{
	return GetOption(GetNativeCell(1), GetNativeCell(2));
}

public int Native_SetOption(Handle plugin, int numParams)
{
	SetOption(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3), GetNativeCell(4));
}

public int Native_GetHitPerf(Handle plugin, int numParams)
{
	return view_as<int>(GetSKZHitPerf(GetNativeCell(1)));
}

public int Native_GetTakeoffSpeed(Handle plugin, int numParams)
{
	return view_as<int>(GetSKZTakeoffSpeed(GetNativeCell(1)));
}

public int Native_PrintToChat(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	bool addPrefix = GetNativeCell(2);
	
	char buffer[256];
	FormatNativeString(0, 3, 4, sizeof(buffer), _, buffer);
	
	if (addPrefix)
	{
		char prefix[64];
		gCV_ChatPrefix.GetString(prefix, sizeof(prefix));
		Format(buffer, sizeof(buffer), "%s%s", prefix, buffer);
	}
	
	CPrintToChat(client, "%s", buffer);
} 