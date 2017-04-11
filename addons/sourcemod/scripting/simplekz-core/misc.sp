/*    
    Miscellaneous
    
    Miscellaneous functions.
*/

#include "simplekz-core/misc/client.sp"

bool IsValidClient(int client)
{
	return 1 <= client && client <= MaxClients && IsClientInGame(client);
}

float FloatMax(float a, float b)
{
	if (a > b)
	{
		return a;
	}
	return b;
}

void String_ToLower(const char[] input, char[] output, int size)
{
	size--;
	int i = 0;
	while (input[i] != '\0' && i < size)
	{
		output[i] = CharToLower(input[i]);
		i++;
	}
	output[i] = '\0';
}

void CreateMovementPlayers()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		g_MovementPlayer[client] = new MovementPlayer(client);
	}
}

void CreateRegexes()
{
	gRE_BonusStartButton = CompileRegex("^climb_bonus(\\d+)_startbutton$");
	gRE_BonusEndButton = CompileRegex("^climb_bonus(\\d+)_endbutton$");
}

void CreateCommandListeners()
{
	AddCommandListener(OnSay, "say");
	AddCommandListener(OnSay, "say_team");
	AddCommandListener(CommandJoinTeam, "jointeam");
	for (int i = 0; i < sizeof(gC_RadioCommands); i++)
	{
		AddCommandListener(CommandBlock, gC_RadioCommands[i]);
	}
}

void ExecuteKZConfig()
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

void CreateHooks()
{
	HookEvent("player_disconnect", OnPlayerDisconnect, EventHookMode_Pre);
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Pre);
	HookEvent("player_team", OnPlayerJoinTeam, EventHookMode_Pre);
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Pre);
	HookEvent("round_start", OnRoundStart, EventHookMode_Pre);
	
	HookEntityOutput("trigger_multiple", "OnStartTouch", OnTrigMultiStartTouch);
	
	AddNormalSoundHook(view_as<NormalSHook>(OnNormalSound));
}

void SetupMap()
{
	char map[64];
	GetCurrentMap(map, sizeof(map));
	// Get just the map name (e.g. remove workshop/id/ prefix)
	char mapPieces[5][64];
	int lastPiece = ExplodeString(map, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	FormatEx(gC_CurrentMap, sizeof(gC_CurrentMap), "%s", mapPieces[lastPiece - 1]);
	String_ToLower(gC_CurrentMap, gC_CurrentMap, sizeof(gC_CurrentMap));
	// Check for kzpro_ tag
	char mapPrefix[1][64];
	ExplodeString(gC_CurrentMap, "_", mapPrefix, sizeof(mapPrefix), sizeof(mapPrefix[]));
	gB_CurrentMapIsKZPro = StrEqual(mapPrefix[0], "kzpro");
	
	// Precache stuff
	PrecacheModels();
}

void PrecacheModels()
{
	gI_GlowSprite = PrecacheModel("materials/sprites/bluelaser1.vmt", true); // Measure
	PrecachePlayerModels();
}

void PrecachePlayerModels()
{
	GetConVarString(gCV_PlayerModelT, gC_PlayerModelT, sizeof(gC_PlayerModelT));
	GetConVarString(gCV_PlayerModelCT, gC_PlayerModelCT, sizeof(gC_PlayerModelCT));
	
	PrecacheModel(gC_PlayerModelT, true);
	AddFileToDownloadsTable(gC_PlayerModelT);
	PrecacheModel(gC_PlayerModelCT, true);
	AddFileToDownloadsTable(gC_PlayerModelCT);
} 