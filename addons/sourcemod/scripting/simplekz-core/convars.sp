/*
	ConVars
	
	ConVars for server control over features of the plugin.
*/



ConVar gCV_ChatProcessing;
ConVar gCV_ChatPrefix;
ConVar gCV_ConnectionMessages;
ConVar gCV_DefaultStyle;
ConVar gCV_PlayerModelT;
ConVar gCV_PlayerModelCT;
ConVar gCV_PlayerModelAlpha;

ConVar gCV_DisableImmunityAlpha;
ConVar gCV_FullAlltalk;

ConVar gCV_StyleCVar[STYLECVAR_COUNT];



// =========================  PUBLIC  ========================= //

void CreateConVars()
{
	gCV_ChatProcessing = CreateConVar("kz_chat_processing", "1", "Whether SimpleKZ processes player chat messages.", _, true, 0.0, true, 1.0);
	gCV_ChatPrefix = CreateConVar("kz_chat_prefix", "{grey}[{lightgreen}KZ{grey}] ", "Chat prefix used for SimpleKZ messages.");
	gCV_ConnectionMessages = CreateConVar("kz_connection_messages", "1", "Whether SimpleKZ handles connection and disconnection messages.", _, true, 0.0, true, 1.0);
	gCV_DefaultStyle = CreateConVar("kz_default_style", "0", "Default movement style (0 = Standard, 1 = Legacy, 2 = Competitive).", _, true, 0.0, true, 2.0);
	gCV_PlayerModelT = CreateConVar("kz_player_model_t", "models/player/tm_leet_varianta.mdl", "Model to change Terrorists to (applies after map change).");
	gCV_PlayerModelCT = CreateConVar("kz_player_model_ct", "models/player/ctm_idf_variantc.mdl", "Model to change Counter-Terrorists to (applies after map change).");
	gCV_PlayerModelAlpha = CreateConVar("kz_player_model_alpha", "100", "Amount of alpha (transparency) to set player models to.", _, true, 0.0, true, 255.0);
	
	FindConVars();
}



// =========================  PRIVATE  ========================= //

static void FindConVars()
{
	gCV_DisableImmunityAlpha = FindConVar("sv_disable_immunity_alpha");
	gCV_FullAlltalk = FindConVar("sv_full_alltalk");
	
	gCV_StyleCVar[StyleCVar_Accelerate] = FindConVar("sv_accelerate");
	gCV_StyleCVar[StyleCVar_Friction] = FindConVar("sv_friction");
	gCV_StyleCVar[StyleCVar_AirAccelerate] = FindConVar("sv_airaccelerate");
	gCV_StyleCVar[StyleCVar_LadderScaleSpeed] = FindConVar("sv_ladder_scale_speed");
	gCV_StyleCVar[StyleCVar_MaxVelocity] = FindConVar("sv_maxvelocity");
	gCV_StyleCVar[StyleCVar_Gravity] = FindConVar("sv_gravity");
	gCV_StyleCVar[StyleCVar_EnableBunnyhopping] = FindConVar("sv_enablebunnyhopping");
	gCV_StyleCVar[StyleCVar_AutoBunnyhopping] = FindConVar("sv_autobunnyhopping");
	gCV_StyleCVar[StyleCVar_StaminaMax] = FindConVar("sv_staminamax");
	gCV_StyleCVar[StyleCVar_StaminaLandCost] = FindConVar("sv_staminalandcost");
	gCV_StyleCVar[StyleCVar_StaminaJumpCost] = FindConVar("sv_staminajumpcost");
	gCV_StyleCVar[StyleCVar_StaminaRecoveryRate] = FindConVar("sv_staminarecoveryrate");
	gCV_StyleCVar[StyleCVar_MaxSpeed] = FindConVar("sv_maxspeed");
	gCV_StyleCVar[StyleCVar_WaterAccelerate] = FindConVar("sv_wateraccelerate");
	gCV_StyleCVar[StyleCVar_TimeBetweenDucks] = FindConVar("sv_timebetweenducks");
	gCV_StyleCVar[StyleCVar_AccelerateUseWeaponSpeed] = FindConVar("sv_accelerate_use_weapon_speed");
	
	// Remove these notify flags because these ConVars are being set constantly
	for (int i = 0; i < STYLECVAR_COUNT; i++)
	{
		gCV_StyleCVar[i].Flags &= ~FCVAR_NOTIFY;
	}
} 