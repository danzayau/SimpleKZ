/*	commands.sp
	
	Commands for player use.
*/


void RegisterCommands() {
	RegConsoleCmd("sm_maprank", CommandMapRank, "[KZ] Prints map time and rank to chat. Usage: !maprank <player> <map>");
	RegConsoleCmd("sm_pb", CommandMapRank, "[KZ] Prints map time and rank to chat. Usage: !maprank <player> <map>");
	RegConsoleCmd("sm_maprecord", CommandMapRecord, "[KZ] Prints map record times to chat. Usage: !maprecord <map>");
	RegConsoleCmd("sm_wr", CommandMapRecord, "[KZ] Prints map record times to chat. Usage: !maprecord <map>");
	RegConsoleCmd("sm_maptop", CommandMapTop, "[KZ] Opens a menu showing the top times of a map. Usage !maptop <map>");
}



/*===============================  Command Handlers  ===============================*/

public Action CommandMapRank(int client, int args) {
	if (args < 1) {
		DB_PrintPBs(client, client, gC_CurrentMap);
	}
	else if (args == 1) {
		char specifiedPlayer[MAX_NAME_LENGTH];
		GetCmdArg(1, specifiedPlayer, sizeof(specifiedPlayer));
		
		int target = FindTarget(client, specifiedPlayer, true, false);
		if (target != -1) {
			DB_PrintPBs(client, target, gC_CurrentMap);
		}
	}
	else {
		char specifiedPlayer[MAX_NAME_LENGTH];
		GetCmdArg(1, specifiedPlayer, sizeof(specifiedPlayer));
		char specifiedMap[33];
		GetCmdArg(2, specifiedMap, sizeof(specifiedMap));
		
		int target = FindTarget(client, specifiedPlayer, true, false);
		if (target != -1) {
			DB_PrintPBs(client, target, specifiedMap);
		}
	}
	return Plugin_Handled;
}

public Action CommandMapRecord(int client, int args) {
	if (args < 1) {
		DB_PrintMapRecords(client, gC_CurrentMap);
	}
	else {
		char specifiedMap[33];
		GetCmdArg(1, specifiedMap, sizeof(specifiedMap));
		DB_PrintMapRecords(client, specifiedMap);
	}
	return Plugin_Handled;
}

public Action CommandMapTop(int client, int args) {
	if (args < 1) {
		gC_MapTopMap[client] = gC_CurrentMap;
	}
	else {
		GetCmdArg(1, gC_MapTopMap[client], sizeof(gC_MapTopMap[]));
	}
	DisplayMapTopMenu(client);
	return Plugin_Handled;
} 