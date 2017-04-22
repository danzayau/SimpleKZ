/*
	Other
	
	Small features that aren't worth splitting into their own file.
*/

// Executes kz.cfg
void KZConfigOnMapStart()
{
	char kzConfigPath[] = "sourcemod/SimpleKZ/kz.cfg";
	char kzConfigPathFull[64];
	FormatEx(kzConfigPathFull, sizeof(kzConfigPathFull), "cfg/%s", kzConfigPath);
	
	if (FileExists(kzConfigPathFull))
	{
		ServerCommand("exec %s", kzConfigPath);
	}
	else
	{
		SetFailState("Failed to load config (cfg/%s not found).", kzConfigPath);
	}
}

void PrintConnectMessage(int client)
{
	if (!IsValidClient(client) || IsFakeClient(client))
	{
		return;
	}
	
	char name[MAX_NAME_LENGTH], clientIP[32], country[45];
	GetClientName(client, name, MAX_NAME_LENGTH);
	GetClientIP(client, clientIP, sizeof(clientIP));
	if (!GeoipCountry(clientIP, country, sizeof(country)))
	{
		country = "Unknown";
	}
	CPrintToChatAll("%T", "Client Connection Message", client, name, country);
}

// Hooked to player_disconnect event
void PrintDisconnectMessage(Event event)
{
	SetEventBroadcast(event, true);
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client) || IsFakeClient(client))
	{
		return;
	}
	
	char reason[64], name[MAX_NAME_LENGTH];
	GetEventString(event, "reason", reason, sizeof(reason));
	GetClientName(client, name, MAX_NAME_LENGTH);
	CPrintToChatAll("%T", "Client Disconnection Message", client, name, reason);
}

// Replaces the jointeam command so that it uses the helper function instead
void JoinTeamAddCommandListeners()
{
	AddCommandListener(CommandJoinTeam, "jointeam");
}

// Force sv_full_alltalk 1 - it likes to set itself to 0, so it's hooked to round_start event
void ForceAllTalkOnRoundStart()
{
	SetConVarInt(gCV_FullAlltalk, 1);
} 