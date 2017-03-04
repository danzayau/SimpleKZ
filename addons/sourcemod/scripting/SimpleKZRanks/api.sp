/*	api.sp

	Simple KZ Ranks API.
*/


/*===============================  Forwards  ===============================*/

Handle gH_Forward_SimpleKZ_OnNewRecord;
Handle gH_Forward_SimpleKZ_OnNewPersonalBest;

void CreateGlobalForwards() {
	gH_Forward_SimpleKZ_OnNewRecord = CreateGlobalForward("SimpleKZ_OnNewRecord", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Float);
	gH_Forward_SimpleKZ_OnNewPersonalBest = CreateGlobalForward("SimpleKZ_OnNewPersonalBest", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_Cell, Param_Cell);
}

void Call_SimpleKZ_OnNewRecord(int client, int mapID, int course, MovementStyle style, RecordType recordType, float runTime) {
	Call_StartForward(gH_Forward_SimpleKZ_OnNewRecord);
	Call_PushCell(client);
	Call_PushCell(mapID);
	Call_PushCell(course);
	Call_PushCell(style);
	Call_PushCell(recordType);
	Call_PushFloat(runTime);
	Call_Finish();
}

void Call_SimpleKZ_OnNewPersonalBest(int client, int mapID, int course, MovementStyle style, TimeType timeType, bool firstTime, float runTime, float improvement, int rank, int maxRank) {
	Call_StartForward(gH_Forward_SimpleKZ_OnNewPersonalBest);
	Call_PushCell(client);
	Call_PushCell(mapID);
	Call_PushCell(course);
	Call_PushCell(style);
	Call_PushCell(timeType);
	Call_PushCell(firstTime);
	Call_PushFloat(runTime);
	Call_PushFloat(improvement);
	Call_PushCell(rank);
	Call_PushCell(maxRank);
	Call_Finish();
} 