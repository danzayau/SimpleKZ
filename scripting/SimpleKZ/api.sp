/*	api.sp

	API for other plugins.
*/


/*======  Forwards  ======*/

Handle gH_Forward_SimpleKZ_OnTimerStarted;
Handle gH_Forward_SimpleKZ_OnTimerEnded;

void CreateGlobalForwards() {
	gH_Forward_SimpleKZ_OnTimerStarted = CreateGlobalForward("SimpleKZ_OnTimerStarted", ET_Event, Param_Cell);
	gH_Forward_SimpleKZ_OnTimerEnded = CreateGlobalForward("SimpleKZ_OnTimerEnded", ET_Event, Param_Cell, Param_Float, Param_Cell, Param_Float);
}

void Call_SimpleKZ_OnTimerStarted(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnTimerStarted);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SimpleKZ_OnTimerEnded(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnTimerEnded);
	Call_PushCell(client);
	Call_PushFloat(gF_CurrentTime[client]);
	Call_PushCell(gI_TeleportsUsed[client]);
	Call_PushFloat(gF_WastedTime[client]);
	Call_Finish();
}



/*======  Natives  ======*/

void CreateNatives() {
	CreateNative("SimpleKZ_StartTimer", Native_StartTimer);
	CreateNative("SimpleKZ_EndTimer", Native_EndTimer);
	CreateNative("SimpleKZ_ForceStopTimer", Native_ForceStopTimer);
}

public int Native_StartTimer(Handle plugin, int numParams) {
	StartTimer(GetNativeCell(1));
}

public int Native_EndTimer(Handle plugin, int numParams) {
	EndTimer(GetNativeCell(1));
}

public int Native_ForceStopTimer(Handle plugin, int numParams) {
	ForceStopTimer(GetNativeCell(1));
} 