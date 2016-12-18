/*	convars.sp
	
	Implements convars for server control over features of the plugin.
*/


// ConVars

ConVar g_cvGodmode;


void RegisterConVars() {
	g_cvGodmode = CreateConVar("kz_godmode", "1", "Sets whether godmode is enabled.");
	SetUpConVarHooks();
}

void SetUpConVarHooks() {
	HookConVarChange(g_cvGodmode, GodmodeChanged);
}


// ConVar Hooks

public void GodmodeChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
	for (new client = 1; client <= MaxClients; client++)
	{
		
		if (g_cvGodmode) {
			SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
		}
		else {
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
		}
	}
} 