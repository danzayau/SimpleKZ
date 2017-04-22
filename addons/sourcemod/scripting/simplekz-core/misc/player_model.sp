/*
	Player Models
	
	Controls the model of the player.
*/

#define PLAYER_MODEL_ALPHA 100

void PlayerModelUpdate(int client)
{
	if (GetClientTeam(client) == CS_TEAM_T)
	{
		SetEntityModel(client, gC_PlayerModelT);
	}
	else if (GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntityModel(client, gC_PlayerModelCT);
	}
	
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, _, _, _, PLAYER_MODEL_ALPHA);
}

void PlayerModelOnMapStart()
{
	SetConVarInt(gCV_DisableImmunityAlpha, 1); // Ensures player transparency works	
	
	GetConVarString(gCV_PlayerModelT, gC_PlayerModelT, sizeof(gC_PlayerModelT));
	GetConVarString(gCV_PlayerModelCT, gC_PlayerModelCT, sizeof(gC_PlayerModelCT));
	
	PrecacheModel(gC_PlayerModelT, true);
	AddFileToDownloadsTable(gC_PlayerModelT);
	PrecacheModel(gC_PlayerModelCT, true);
	AddFileToDownloadsTable(gC_PlayerModelCT);
} 