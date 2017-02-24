/*	api.sp

	Simple KZ Ranks API.
*/


/*===============================  Forwards  ===============================*/

Handle gH_Forward_SimpleKZ_OnBeatMapRecord;
Handle gH_Forward_SimpleKZ_OnBeatMapFirstTime;
Handle gH_Forward_SimpleKZ_OnImproveTime;

void CreateGlobalForwards() {
	gH_Forward_SimpleKZ_OnBeatMapRecord = CreateGlobalForward("SimpleKZ_OnBeatMapRecord", ET_Event, Param_Cell, Param_String, Param_Cell, Param_Float, Param_Cell);
	gH_Forward_SimpleKZ_OnBeatMapFirstTime = CreateGlobalForward("SimpleKZ_OnBeatMapFirstTime", ET_Event, Param_Cell, Param_String, Param_Cell, Param_Float, Param_Cell, Param_Cell, Param_Cell);
	gH_Forward_SimpleKZ_OnImproveTime = CreateGlobalForward("SimpleKZ_OnImproveTime", ET_Event, Param_Cell, Param_String, Param_Cell, Param_Float, Param_Float, Param_Cell, Param_Cell, Param_Cell);
}

void Call_SimpleKZ_OnBeatMapRecord(int client, const char[] map, RecordType recordType, float runTime, MovementStyle style) {
	Call_StartForward(gH_Forward_SimpleKZ_OnBeatMapRecord);
	Call_PushCell(client);
	Call_PushString(map);
	Call_PushCell(recordType);
	Call_PushFloat(runTime);
	Call_PushCell(style);
	Call_Finish();
}

void Call_SimpleKZ_OnBeatMapFirstTime(int client, const char[] map, RunType runType, float runTime, int rank, int maxRank, MovementStyle style) {
	Call_StartForward(gH_Forward_SimpleKZ_OnBeatMapFirstTime);
	Call_PushCell(client);
	Call_PushString(map);
	Call_PushCell(runType);
	Call_PushFloat(runTime);
	Call_PushCell(rank);
	Call_PushCell(maxRank);
	Call_PushCell(style);
	Call_Finish();
}

void Call_SimpleKZ_OnImproveTime(int client, const char[] map, RunType runType, float runTime, float improvement, int rank, int maxRank, MovementStyle style) {
	Call_StartForward(gH_Forward_SimpleKZ_OnImproveTime);
	Call_PushCell(client);
	Call_PushString(map);
	Call_PushCell(runType);
	Call_PushFloat(runTime);
	Call_PushFloat(improvement);
	Call_PushCell(rank);
	Call_PushCell(maxRank);
	Call_PushCell(style);
	Call_Finish();
} 