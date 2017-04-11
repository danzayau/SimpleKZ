/*    
    ConVars
    
    ConVars for server control over features of the plugin.
*/

void CreateConVars()
{
	gCV_DisableImmunityAlpha = FindConVar("sv_disable_immunity_alpha");
	gCV_FullAlltalk = FindConVar("sv_full_alltalk");
	
	gCV_ChatProcessing = CreateConVar("kz_chat_processing", "1", "Whether or not SimpleKZ processes player chat (in case you want to use another chat plugin).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_DefaultStyle = CreateConVar("kz_default_style", "0", "The default movement style (0 = Standard, 1 = Legacy).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_PlayerModelT = CreateConVar("kz_player_model_t", "models/player/tm_leet_varianta.mdl", "The model to change Terrorists to (applies after map change).", FCVAR_NOTIFY);
	gCV_PlayerModelCT = CreateConVar("kz_player_model_ct", "models/player/ctm_idf_variantc.mdl", "The model to change Counter-Terrorists to (applies after map change).", FCVAR_NOTIFY);
} 