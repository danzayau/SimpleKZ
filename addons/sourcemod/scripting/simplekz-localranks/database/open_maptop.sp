/*
	Database - Open Map Top
	
	Opens the map top menu for the map course and given style.
	See also:
		menus/maptop.sp
*/



void DB_OpenMapTop(int client, int mapID, int course, int style)
{
	char query[1024];
	
	DataPack data = new DataPack();
	data.WriteCell(client);
	data.WriteCell(mapID);
	data.WriteCell(course);
	data.WriteCell(style);
	
	Transaction txn = SQL_CreateTransaction();
	
	// Retrieve Map Name of MapID
	FormatEx(query, sizeof(query), sql_maps_getname, mapID);
	txn.AddQuery(query);
	// Check for existence of map course with that MapID and Course
	FormatEx(query, sizeof(query), sql_mapcourses_findid, mapID, course);
	txn.AddQuery(query);
	
	SQL_ExecuteTransaction(gH_DB, txn, DB_TxnSuccess_OpenMapTopMenu, DB_TxnFailure_Generic, data, DBPrio_Low);
}

public void DB_TxnSuccess_OpenMapTopMenu(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
	data.Reset();
	int client = data.ReadCell();
	int mapID = data.ReadCell();
	int course = data.ReadCell();
	int style = data.ReadCell();
	data.Close();
	
	if (!IsValidClient(client))
	{
		return;
	}
	
	// Get name of map
	if (SQL_FetchRow(results[0]))
	{
		SQL_FetchString(results[0], 0, gC_MapTopMapName[client], sizeof(gC_MapTopMapName[]));
	}
	// Check if the map course exists in the database
	if (SQL_GetRowCount(results[1]) == 0)
	{
		if (course == 0)
		{
			SKZ_PrintToChat(client, true, "%t", "Main Course Not Found", gC_MapTopMapName[client]);
		}
		else
		{
			SKZ_PrintToChat(client, true, "%t", "Bonus Not Found", gC_MapTopMapName[client], course);
		}
		return;
	}
	
	gI_MapTopMapID[client] = mapID;
	gI_MapTopCourse[client] = course;
	g_MapTopStyle[client] = style;
	MapTopMenuDisplay(client);
}

void DB_OpenMapTop_FindMap(int client, const char[] mapSearch, int course, int style)
{
	DataPack data = new DataPack();
	data.WriteCell(client);
	data.WriteString(mapSearch);
	data.WriteCell(course);
	data.WriteCell(style);
	
	DB_FindMap(mapSearch, DB_TxnSuccess_OpenMapTopMenu_FindMap, data, DBPrio_Low);
}

public void DB_TxnSuccess_OpenMapTopMenu_FindMap(Handle db, DataPack data, int numQueries, Handle[] results, any[] queryData)
{
	data.Reset();
	int client = data.ReadCell();
	char mapSearch[33];
	data.ReadString(mapSearch, sizeof(mapSearch));
	int course = data.ReadCell();
	int style = data.ReadCell();
	data.Close();
	
	if (!IsValidClient(client))
	{
		return;
	}
	
	if (SQL_GetRowCount(results[0]) == 0)
	{
		SKZ_PrintToChat(client, true, "%t", "Map Not Found", mapSearch);
		return;
	}
	else if (SQL_FetchRow(results[0]))
	{  // Result is the MapID
		DB_OpenMapTop(client, SQL_FetchInt(results[0], 0), course, style);
	}
} 