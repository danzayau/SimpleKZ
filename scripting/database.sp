/*	database.sp

*/

#define MYSQL 0
#define SQLITE 1

#include "databasequeries.sp"


// Functions

void db_ConnectToDatabase() {
	char error[255];
	char databaseType[8];
	
	gDB_database = SQL_Connect("simplekz", false, error, sizeof(error));
	if (g_hDb == INVALID_HANDLE) {
		SetFailState("Unable to connect to database (%s).", error);
	}
	else {
		SQL_ReadDriver(g_dbLocal, databaseType, sizeof(databaseType));
		
		if (StrEqual(databaseType, "mysql", false)) {
			gDB_databaseType = MYSQL;
		}
		else if (StrEqual(databaseType, "sqlite", false)) {
			gDB_databaseType = SQLITE;
		}
		else {
			SetFailState("Invalid database type (use SQLite or MySQL).");
		}
		
		SQL_SetCharSet(gDB_database, "UTF8");
		
		db_createTables();
	}
}

void db_CreateTables() {
	
}