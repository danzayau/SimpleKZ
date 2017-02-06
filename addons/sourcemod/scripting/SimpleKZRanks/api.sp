/*	api.sp

	Simple KZ Ranks API.
*/


/*===============================  Forwards  ===============================*/

Handle gH_Forward_SimpleKZ_OnGetRecord;

void CreateGlobalForwards() {
	gH_Forward_SimpleKZ_OnGetRecord = CreateGlobalForward("SimpleKZ_OnGetRecord", ET_Event, Param_Cell, Param_Cell);
}

void Call_SimpleKZ_OnGetRecord(int client, RecordType recordType) {
	Call_StartForward(gH_Forward_SimpleKZ_OnGetRecord);
	Call_PushCell(client);
	Call_PushCell(recordType);
	Call_Finish();
} 