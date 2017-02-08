/*	convars.sp
	
	ConVars for server control over features of the plugin.
*/


ConVar gCV_Chat;

void RegisterConVars() {
	gCV_Chat = CreateConVar("kz_chat", "1", "Whether or not SimpleKZ handles player chat commands (in case you want to use another chat plugin).");
} 