/*	api.sp

	Simple KZ Ranks API.
*/


/*===============================  Forwards  ===============================*/

Handle gH_SKZ_OnNewRecord;
Handle gH_SKZ_OnNewPersonalBest;

void CreateGlobalForwards() {
	gH_SKZ_OnNewRecord = CreateGlobalForward("SKZ_OnNewRecord", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Float);
	gH_SKZ_OnNewPersonalBest = CreateGlobalForward("SKZ_OnNewPersonalBest", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_Cell, Param_Cell);
}

void Call_SKZ_OnNewRecord(int client, int mapID, int course, KZStyle style, KZRecordType recordType, float runTime) {
	Call_StartForward(gH_SKZ_OnNewRecord);
	Call_PushCell(client);
	Call_PushCell(mapID);
	Call_PushCell(course);
	Call_PushCell(style);
	Call_PushCell(recordType);
	Call_PushFloat(runTime);
	Call_Finish();
}

void Call_SKZ_OnNewPersonalBest(int client, int mapID, int course, KZStyle style, KZTimeType timeType, bool firstTime, float runTime, float improvement, int rank, int maxRank) {
	Call_StartForward(gH_SKZ_OnNewPersonalBest);
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