/*
	ConVars
	
	ConVars for server control over features of the plugin.
*/

void CreateConVars()
{
	gCV_ChatProcessing = CreateConVar("kz_chat_processing", "1", "Whether or not SimpleKZ processes player chat (in case you want to use another chat plugin).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_DefaultStyle = CreateConVar("kz_default_style", "0", "The default movement style (0 = Standard, 1 = Legacy).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gCV_PlayerModelT = CreateConVar("kz_player_model_t", "models/player/tm_leet_varianta.mdl", "The model to change Terrorists to (applies after map change).", FCVAR_NOTIFY);
	gCV_PlayerModelCT = CreateConVar("kz_player_model_ct", "models/player/ctm_idf_variantc.mdl", "The model to change Counter-Terrorists to (applies after map change).", FCVAR_NOTIFY);
	
	FindConVars();
}

void FindConVars()
{
	gCV_DisableImmunityAlpha = FindConVar("sv_disable_immunity_alpha");
	gCV_FullAlltalk = FindConVar("sv_full_alltalk");
	
	gCV_Accelerate = FindConVar("sv_accelerate");
	gCV_Friction = FindConVar("sv_friction");
	gCV_AirAccelerate = FindConVar("sv_airaccelerate");
	gCV_LadderScaleSpeed = FindConVar("sv_ladder_scale_speed");
	gCV_MaxVelocity = FindConVar("sv_maxvelocity");
	gCV_Gravity = FindConVar("sv_gravity");
	
	gCV_EnableBunnyhopping = FindConVar("sv_enablebunnyhopping");
	gCV_AutoBunnyhopping = FindConVar("sv_autobunnyhopping");
	
	gCV_StaminaMax = FindConVar("sv_staminamax");
	gCV_StaminaLandCost = FindConVar("sv_staminalandcost");
	gCV_StaminaJumpCost = FindConVar("sv_staminajumpcost");
	gCV_StaminaRecoveryRate = FindConVar("sv_staminarecoveryrate");
	
	gCV_MaxSpeed = FindConVar("sv_maxspeed");
	gCV_WaterAccelerate = FindConVar("sv_wateraccelerate");
	gCV_TimeBetweenDucks = FindConVar("sv_timebetweenducks");
	gCV_AccelerateUseWeaponSpeed = FindConVar("sv_accelerate_use_weapon_speed");
	
	
	// Remove these notify flags because these ConVars are being set constantly
	gCV_Accelerate.Flags &= ~FCVAR_NOTIFY;
	gCV_Friction.Flags &= ~FCVAR_NOTIFY;
	gCV_AirAccelerate.Flags &= ~FCVAR_NOTIFY;
	gCV_LadderScaleSpeed.Flags &= ~FCVAR_NOTIFY;
	gCV_MaxVelocity.Flags &= ~FCVAR_NOTIFY;
	gCV_Gravity.Flags &= ~FCVAR_NOTIFY;
	
	gCV_EnableBunnyhopping.Flags &= ~FCVAR_NOTIFY;
	gCV_AutoBunnyhopping.Flags &= ~FCVAR_NOTIFY;
	
	gCV_StaminaMax.Flags &= ~FCVAR_NOTIFY;
	gCV_StaminaLandCost.Flags &= ~FCVAR_NOTIFY;
	gCV_StaminaJumpCost.Flags &= ~FCVAR_NOTIFY;
	gCV_StaminaRecoveryRate.Flags &= ~FCVAR_NOTIFY;
	
	gCV_MaxSpeed.Flags &= ~FCVAR_NOTIFY;
	gCV_WaterAccelerate.Flags &= ~FCVAR_NOTIFY;
	gCV_TimeBetweenDucks.Flags &= ~FCVAR_NOTIFY;
	gCV_AccelerateUseWeaponSpeed.Flags &= ~FCVAR_NOTIFY;
} 