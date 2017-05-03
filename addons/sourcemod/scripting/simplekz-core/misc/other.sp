/*
	Other
	
	Small features that aren't worth splitting into their own file.
*/

// Executes kz.cfg
void KZConfigOnMapStart()
{
	char kzConfigPath[] = "sourcemod/simplekz/kz.cfg";
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
	if (!GetConVarBool(gCV_ConnectionMessages))
	{
		return;
	}
	if (!IsValidClient(client) || IsFakeClient(client))
	{
		return;
	}
	
	CPrintToChatAll("%T", "Client Connection Message", client, client);
}

// Hooked to player_disconnect event
void PrintDisconnectMessage(int client, Event event)
{
	if (!GetConVarBool(gCV_ConnectionMessages))
	{
		return;
	}
	
	SetEventBroadcast(event, true);
	
	if (!IsValidClient(client) || IsFakeClient(client))
	{
		return;
	}
	
	char reason[64];
	GetEventString(event, "reason", reason, sizeof(reason));
	CPrintToChatAll("%T", "Client Disconnection Message", client, client, reason);
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