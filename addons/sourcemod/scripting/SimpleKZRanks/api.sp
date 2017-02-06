/*	api.sp

	Simple KZ Ranks API.
*/


/*===============================  Forwards  ===============================*/

Handle gH_Forward_SimpleKZ_OnGetRecord;

void CreateGlobalForwards() {
	gH_Forward_SimpleKZ_OnGetRecord = CreateGlobalForward("SimpleKZ_OnGetRecord", ET_Event, Param_Cell, Param_String, Param_Cell, Param_Float);
}

void Call_SimpleKZ_OnGetRecord(int client, const char[] map, RecordType recordType, float runTime) {
	Call_StartForward(gH_Forward_SimpleKZ_OnGetRecord);
	Call_PushCell(client);
	Call_PushString(map);
	Call_PushCell(recordType);
	Call_PushFloat(runTime);
	Call_Finish();
} 