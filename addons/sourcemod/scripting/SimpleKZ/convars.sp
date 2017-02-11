/*	convars.sp
	
	ConVars for server control over features of the plugin.
*/


ConVar gCV_Custom_Chat;

void RegisterConVars() {
	gCV_Custom_Chat = CreateConVar("kz_custom_chat", "1", "Whether or not SimpleKZ customises player chat (in case you want to use another chat plugin).");
} 