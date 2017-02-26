/*	convars.sp
	
	ConVars for server control over features of the plugin.
*/

void RegisterConVars() {
	gCV_FullAlltalk = FindConVar("sv_full_alltalk");
	
	gCV_DefaultStyle = CreateConVar("kz_default_style", "0", "The default movement style (0=Standard, 1=Legacy).");
	gCV_CustomChat = CreateConVar("kz_custom_chat", "1", "Whether or not SimpleKZ customises player chat (in case you want to use another chat plugin).");
	gCV_PlayerModelT = CreateConVar("mt_player_model_t", "models/player/tm_leet_varianta.mdl", "The model to change Terrorists to (applies after map change).");
	gCV_PlayerModelCT = CreateConVar("mt_player_model_ct", "models/player/ctm_idf_variantc.mdl", "The model to change Counter-Terrorists to (applies after map change).");
} 