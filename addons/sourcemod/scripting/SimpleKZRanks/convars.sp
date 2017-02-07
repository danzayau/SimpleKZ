/*	convars.sp
	
	ConVars for server control over features of the plugin.
*/


ConVar gCV_AutoAddMaps;

void RegisterConVars() {
	gCV_AutoAddMaps = CreateConVar("kz_auto_add_maps", "1", "Whether or not maps that aren't already in the database are added to the ranked map pool when they are played.");
} 