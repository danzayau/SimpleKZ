/*	commands.sp
	
	Commands for player use.
*/


void RegisterCommands() {
	RegConsoleCmd("sm_top", CommandTop, "[KZ] Opens a menu showing the top record holders on the server.");
	RegConsoleCmd("sm_maptop", CommandMapTop, "[KZ] Opens a menu showing the top times of a map. Usage !maptop <map>");
	RegConsoleCmd("sm_bmaptop", CommandBMapTop, "[KZ] Opens a menu showing the top bonus times of a map. Usage !btop <#bonus> <map>");
	RegConsoleCmd("sm_pb", CommandPB, "[KZ] Prints PB map time and rank to chat. Usage: !pb <map> <player>");
	RegConsoleCmd("sm_bpb", CommandBPB, "[KZ] Prints PB bonus time and rank to chat. Usage: !bpb <#bonus> <map> <player>");
	RegConsoleCmd("sm_wr", CommandWR, "[KZ] Prints map record times to chat. Usage: !wr <map>");
	RegConsoleCmd("sm_bwr", CommandBWR, "[KZ] Prints bonus record times to chat. Usage: !bwr <#bonus> <map>");
	RegConsoleCmd("sm_pc", CommandPC, "[KZ] Prints map completion to chat. Usage !pc <player>");
	
	RegAdminCmd("sm_updatemappool", CommandUpdateMapPool, ADMFLAG_ROOT, "[KZ] Updates the ranked map pool with the list of maps in cfg/sourcemod/SimpleKZ/mappool.cfg.");
}



/*===============================  Command Handlers  ===============================*/

public Action CommandTop(int client, int args) {
	g_PlayerTopStyle[client] = SimpleKZ_GetOptionStyle(client);
	DisplayPlayerTopMenu(client);
	return Plugin_Handled;
}

public Action CommandMapTop(int client, int args) {
	if (args < 1) {
		// Open map top for current map
		DB_OpenMapTop(client, gI_CurrentMapID, 0, SimpleKZ_GetOptionStyle(client));
	}
	else {
		// Open map top for specified map
		char specifiedMap[33];
		GetCmdArg(1, specifiedMap, sizeof(specifiedMap));
		DB_OpenMapTop_SearchMap(client, specifiedMap, 0, SimpleKZ_GetOptionStyle(client));
	}
	
	return Plugin_Handled;
}

public Action CommandBMapTop(int client, int args) {
	if (args < 1) {
		// Open bonus 1 top for current map
		DB_OpenMapTop(client, gI_CurrentMapID, 1, SimpleKZ_GetOptionStyle(client));
	}
	else if (args == 1) {
		// Open specified bonus top for current map
		char argBonus[4];
		GetCmdArg(1, argBonus, sizeof(argBonus));
		int bonus = StringToInt(argBonus);
		
		if (bonus > 0) {
			DB_OpenMapTop(client, gI_CurrentMapID, bonus, SimpleKZ_GetOptionStyle(client));
		}
	}
	else {
		// Open specified bonus top for specified map
		char argBonus[4], argMap[33];
		GetCmdArg(1, argBonus, sizeof(argBonus));
		GetCmdArg(2, argMap, sizeof(argMap));
		int bonus = StringToInt(argBonus);
		
		if (bonus > 0) {
			DB_OpenMapTop_SearchMap(client, argMap, bonus, SimpleKZ_GetOptionStyle(client));
		}
	}
	
	return Plugin_Handled;
}

public Action CommandPB(int client, int args) {
	if (args < 1) {
		DB_PrintPBs(client, SimpleKZ_GetPlayerID(client), gI_CurrentMapID, 0, SimpleKZ_GetOptionStyle(client));
	}
	else if (args == 1) {
		char argMap[33];
		GetCmdArg(1, argMap, sizeof(argMap));
		DB_PrintPBs_FindMap(client, SimpleKZ_GetPlayerID(client), argMap, 0, SimpleKZ_GetOptionStyle(client));
	}
	else {
		char argMap[33], argPlayer[MAX_NAME_LENGTH];
		GetCmdArg(1, argMap, sizeof(argMap));
		GetCmdArg(2, argPlayer, sizeof(argPlayer));
		DB_PrintPBs_FindPlayerAndMap(client, argPlayer, argMap, 0, SimpleKZ_GetOptionStyle(client));
	}
	return Plugin_Handled;
}

public Action CommandBPB(int client, int args) {
	return Plugin_Handled;
}

public Action CommandWR(int client, int args) {
	if (args < 1) {
		DB_PrintRecords(client, gI_CurrentMapID, 0, SimpleKZ_GetOptionStyle(client));
	}
	else {
		char argMap[33];
		GetCmdArg(1, argMap, sizeof(argMap));
		DB_PrintRecords_FindMap(client, argMap, 0, SimpleKZ_GetOptionStyle(client));
	}
	return Plugin_Handled;
}

public Action CommandBWR(int client, int args) {
	if (args < 1) {
		DB_PrintRecords(client, gI_CurrentMapID, 1, SimpleKZ_GetOptionStyle(client));
	}
	else if (args == 1) {
		char argBonus[4];
		GetCmdArg(1, argBonus, sizeof(argBonus));
		int bonus = StringToInt(argBonus);
		
		if (bonus > 0) {
			DB_PrintRecords(client, gI_CurrentMapID, bonus, SimpleKZ_GetOptionStyle(client));
		}
	}
	else {
		char argBonus[4], argMap[33];
		GetCmdArg(1, argBonus, sizeof(argBonus));
		GetCmdArg(2, argMap, sizeof(argMap));
		int bonus = StringToInt(argBonus);
		
		if (bonus > 0) {
			DB_PrintRecords_FindMap(client, argMap, bonus, SimpleKZ_GetOptionStyle(client));
		}
	}
	return Plugin_Handled;
}

public Action CommandPC(int client, int args) {
	if (args < 1) {
		DB_GetCompletion(client, client, SimpleKZ_GetOptionStyle(client), true);
	}
	return Plugin_Handled;
}



/*===============================  Command Handlers  ===============================*/

public Action CommandUpdateMapPool(int client, int args) {
	DB_UpdateRankedMapPool(client);
} 