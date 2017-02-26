/*	commands.sp
	
	Commands for player use.
*/


void RegisterCommands() {
	RegConsoleCmd("sm_pb", CommandPB, "[KZ] Prints map time and rank to chat. Usage: !pb <map> <player>");
	RegConsoleCmd("sm_wr", CommandWR, "[KZ] Prints map record times to chat. Usage: !wr <map>");
	RegConsoleCmd("sm_maptop", CommandMapTop, "[KZ] Opens a menu showing the top times of a map. Usage !maptop <map>");
	RegConsoleCmd("sm_pc", CommandPC, "[KZ] Prints map completion to chat. Usage !pc <player>");
	RegConsoleCmd("sm_top", CommandPlayerTop, "[KZ] Opens a menu showing the top record holders on the server.");
	
	RegAdminCmd("sm_updatemappool", CommandUpdateMapPool, ADMFLAG_ROOT, "[KZ] Updates the ranked map pool with the list of maps in cfg/sourcemod/SimpleKZ/mappool.cfg.");
}



/*===============================  Command Handlers  ===============================*/

public Action CommandPB(int client, int args) {
	if (args < 1) {
		DB_PrintPBs(client, client, gI_CurrentMapID, 0, SimpleKZ_GetOptionStyle(client));
	}
	else if (args == 1) {
		char specifiedMap[33];
		GetCmdArg(1, specifiedMap, sizeof(specifiedMap));
		DB_PrintPBs_SearchMap(client, client, specifiedMap, 0, SimpleKZ_GetOptionStyle(client));
	}
	else {
		char specifiedMap[33];
		GetCmdArg(1, specifiedMap, sizeof(specifiedMap));
		char specifiedPlayer[MAX_NAME_LENGTH];
		GetCmdArg(2, specifiedPlayer, sizeof(specifiedPlayer));
		int target = FindTarget(client, specifiedPlayer, true, false);
		
		if (target != -1) {
			DB_PrintPBs_SearchMap(client, target, specifiedMap, 0, SimpleKZ_GetOptionStyle(client));
		}
	}
	return Plugin_Handled;
}

public Action CommandWR(int client, int args) {
	if (args < 1) {
		DB_PrintRecords(client, gI_CurrentMapID, 0, SimpleKZ_GetOptionStyle(client));
	}
	else {
		char specifiedMap[33];
		GetCmdArg(1, specifiedMap, sizeof(specifiedMap));
		DB_PrintRecords_SearchMap(client, specifiedMap, 0, SimpleKZ_GetOptionStyle(client));
	}
	return Plugin_Handled;
}

public Action CommandMapTop(int client, int args) {
	if (args < 1) {
		DB_OpenMapTop(client, gI_CurrentMapID, 0, SimpleKZ_GetOptionStyle(client));
	}
	else {
		char specifiedMap[33];
		GetCmdArg(1, specifiedMap, sizeof(specifiedMap));
		DB_OpenMapTop_SearchMap(client, specifiedMap, 0, SimpleKZ_GetOptionStyle(client));
	}
	
	return Plugin_Handled;
}

public Action CommandPC(int client, int args) {
	if (args < 1) {
		DB_GetCompletion(client, client, SimpleKZ_GetOptionStyle(client), true);
	}
	else {
		char specifiedPlayer[MAX_NAME_LENGTH];
		GetCmdArg(1, specifiedPlayer, sizeof(specifiedPlayer));
		
		int target = FindTarget(client, specifiedPlayer, true, false);
		if (target != -1) {
			DB_GetCompletion(client, target, SimpleKZ_GetOptionStyle(client), true);
		}
	}
	return Plugin_Handled;
}

public Action CommandPlayerTop(int client, int args) {
	g_PlayerTopStyle[client] = SimpleKZ_GetOptionStyle(client);
	DisplayPlayerTopMenu(client);
	return Plugin_Handled;
}



/*===============================  Command Handlers  ===============================*/

public Action CommandUpdateMapPool(int client, int args) {
	DB_UpdateRankedMapPool(client);
} 