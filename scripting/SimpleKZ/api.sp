/*	api.sp

	API for other plugins.
*/


/*=====  Forwards  ======*/

Handle gH_Forward_SimpleKZ_OnTimerStarted;
Handle gH_Forward_SimpleKZ_OnTimerEnded;

void CreateGlobalForwards() {
	gH_Forward_SimpleKZ_OnTimerStarted = CreateGlobalForward("SimpleKZ_OnTimerStarted", ET_Event, Param_Cell);
	gH_Forward_SimpleKZ_OnTimerEnded = CreateGlobalForward("SimpleKZ_OnTimerEnded", ET_Event, Param_Cell);
}

void Call_SimpleKZ_OnTimerStarted(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnTimerStarted);
	Call_PushCell(client);
	Call_Finish();
}

void Call_SimpleKZ_OnTimerEnded(int client) {
	Call_StartForward(gH_Forward_SimpleKZ_OnTimerEnded);
	Call_PushCell(client);
	Call_Finish();
}



/*=====  Natives  ======*/

void CreateNatives() {
	CreateNative("SimpleKZ_GetTimerRunning", Native_GetTimerRunning);
	CreateNative("SimpleKZ_SetTimerRunning", Native_SetTimerRunning);
}

public int Native_GetTimerRunning(Handle plugin, int numParams) {
	return view_as<int>(gB_TimerRunning[GetNativeCell(1)]);
}

public int Native_SetTimerRunning(Handle plugin, int numParams) {
	gB_TimerRunning[GetNativeCell(1)] = view_as<bool>(GetNativeCell(2));
} 