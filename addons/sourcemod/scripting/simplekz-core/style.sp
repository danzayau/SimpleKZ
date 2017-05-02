/*
	Style
	
	Plugin-based movement mechanics and styles.
*/

#define SPEED_NORMAL 250.0
#define SPEED_NO_WEAPON 260.0
#define DUCK_SPEED_MINIMUM 7.0

#define PRE_VELMOD_MAX 1.104 // Calculated 276/250

#define STANDARD_PERF_TICKS 2
#define STANDARD_PRE_VELMOD_INCREMENT 0.0014 // Per tick when prestrafing
#define STANDARD_PRE_VELMOD_DECREMENT 0.0021 // Per tick when not prestrafing

#define LEGACY_PERF_SPEED_CAP 380.0



void StyleOnPlayerRunCmd(int client, int &buttons)
{
	if (IsPlayerAlive(client))
	{
		RemoveCrouchJumpBind(g_KZPlayer[client], buttons);
		TweakVelMod(g_KZPlayer[client]);
	}
}

void StyleOnClientPreThinkPost(int client)
{
	TweakConVars(g_KZPlayer[client]);
}

void StyleOnStartTouchGround(int client)
{
	ReduceDuckSlowdown(g_KZPlayer[client]);
}

void StyleOnStopTouchGround(int client, bool jumped)
{
	if (jumped)
	{
		TweakJump(g_KZPlayer[client]);
	}
	
	if (g_Style[client] == KZStyle_Standard)
	{  // No 'pre b-hopping' in Standard
		gF_PreVelMod[client] = 1.0;
	}
}

void StyleOnStopTouchLadder(int client)
{
	gB_HitPerf[client] = false;
}

void StyleOnStopNoclipping(int client)
{
	gB_HitPerf[client] = false;
}



/*===============================  ConVars Tweak  ===============================*/

static void TweakConVars(KZPlayer player)
{
	gCV_Accelerate.FloatValue = GetStyleSetting(player, KZStyleSetting_Accelerate);
	gCV_Friction.FloatValue = GetStyleSetting(player, KZStyleSetting_Friction);
	gCV_AirAccelerate.FloatValue = GetStyleSetting(player, KZStyleSetting_AirAccelerate);
	gCV_LadderScaleSpeed.FloatValue = GetStyleSetting(player, KZStyleSetting_LadderScaleSpeed);
	gCV_MaxVelocity.FloatValue = GetStyleSetting(player, KZStyleSetting_MaxVelocity);
	gCV_Gravity.FloatValue = GetStyleSetting(player, KZStyleSetting_Gravity);
	
	gCV_EnableBunnyhopping.FloatValue = GetStyleSetting(player, KZStyleSetting_EnableBunnyhopping);
	gCV_AutoBunnyhopping.FloatValue = GetStyleSetting(player, KZStyleSetting_AutoBunnyhopping);
	
	gCV_StaminaMax.FloatValue = GetStyleSetting(player, KZStyleSetting_StaminaMax);
	gCV_StaminaLandCost.FloatValue = GetStyleSetting(player, KZStyleSetting_StaminaLandCost);
	gCV_StaminaJumpCost.FloatValue = GetStyleSetting(player, KZStyleSetting_StaminaJumpCost);
	gCV_StaminaRecoveryRate.FloatValue = GetStyleSetting(player, KZStyleSetting_StaminaRecoveryRate);
	
	gCV_MaxSpeed.FloatValue = GetStyleSetting(player, KZStyleSetting_MaxSpeed);
	gCV_WaterAccelerate.FloatValue = GetStyleSetting(player, KZStyleSetting_WaterAccelerate);
	gCV_TimeBetweenDucks.FloatValue = GetStyleSetting(player, KZStyleSetting_TimeBetweenDucks);
	gCV_AccelerateUseWeaponSpeed.FloatValue = GetStyleSetting(player, KZStyleSetting_AccelerateUseWeaponSpeed);
}

static float GetStyleSetting(KZPlayer player, KZStyleSetting setting)
{
	return gF_StyleSettings[player.style][view_as<int>(setting)];
}



/*===============================  Velocity Modifier  ===============================*/

static void TweakVelMod(KZPlayer player)
{
	if (!player.onGround)
	{
		return;
	}
	
	player.velocityModifier = CalcPrestrafeVelMod(player) * CalcWeaponVelMod(player);
}

static float CalcPrestrafeVelMod(KZPlayer player)
{
	switch (player.style)
	{
		case KZStyle_Standard:
		{
			if (player.turning
				 && ((player.buttons & IN_FORWARD && !(player.buttons & IN_BACK)) || (!(player.buttons & IN_FORWARD) && player.buttons & IN_BACK))
				 && ((player.buttons & IN_MOVELEFT && !(player.buttons & IN_MOVERIGHT)) || (!(player.buttons & IN_MOVELEFT) && player.buttons & IN_MOVERIGHT)))
			{
				gF_PreVelMod[player.id] += STANDARD_PRE_VELMOD_INCREMENT;
			}
			else
			{
				gF_PreVelMod[player.id] -= STANDARD_PRE_VELMOD_DECREMENT;
			}
		}
		case KZStyle_Legacy:
		{
			// KZTimer prestrafe (not exactly the same, and is only for 128 tick)
			if (!player.turning)
			{
				if (GetEngineTime() - gF_PreVelModLastChange[player.id] > 0.2)
				{
					gF_PreVelMod[player.id] = 1.0;
					gF_PreVelModLastChange[player.id] = GetEngineTime();
				}
			}
			else if ((player.buttons & IN_MOVELEFT || player.buttons & IN_MOVERIGHT) && player.speed > 248.9)
			{
				float increment = 0.0009;
				if (gF_PreVelMod[player.id] > 1.04)
				{
					increment = 0.001;
				}
				
				gI_PreTickCounter[player.id]++;
				if (gI_PreTickCounter[player.id] < 75)
				{
					gF_PreVelMod[player.id] += increment;
					if (gF_PreVelMod[player.id] > PRE_VELMOD_MAX)
					{
						if (gF_PreVelMod[player.id] > PRE_VELMOD_MAX + 0.007)
						{
							gF_PreVelMod[player.id] = PRE_VELMOD_MAX - 0.001;
						}
						else
						{
							gF_PreVelMod[player.id] -= 0.007;
						}
					}
					gF_PreVelMod[player.id] += increment;
				}
				else
				{
					gF_PreVelMod[player.id] -= 0.0045;
					gI_PreTickCounter[player.id] -= 2;
				}
			}
			else {
				gF_PreVelMod[player.id] -= 0.04;
			}
		}
		case KZStyle_Competitive:
		{
			gF_PreVelMod[player.id] = 1.0;
		}
	}
	
	// Keep prestrafe velocity modifier within range
	if (gF_PreVelMod[player.id] < 1.0)
	{
		gF_PreVelMod[player.id] = 1.0;
		gI_PreTickCounter[player.id] = 0;
	}
	else if (gF_PreVelMod[player.id] > PRE_VELMOD_MAX)
	{
		gF_PreVelMod[player.id] = PRE_VELMOD_MAX;
	}
	
	return gF_PreVelMod[player.id];
}

static float CalcWeaponVelMod(KZPlayer player)
{
	if (player.style == KZStyle_Competitive)
	{
		return 1.0;
	}
	
	// Universal Weapon Speed
	int weaponEnt = GetEntPropEnt(player.id, Prop_Data, "m_hActiveWeapon");
	if (!IsValidEntity(weaponEnt))
	{
		return SPEED_NORMAL / SPEED_NO_WEAPON; // Weapon entity not found so must have no weapon (260 u/s).
	}
	
	char weaponName[64];
	GetEntityClassname(weaponEnt, weaponName, sizeof(weaponName)); // What weapon the client is holding.
	
	// Get weapon speed and work out how much to scale the modifier.
	int weaponCount = sizeof(gC_WeaponNames);
	for (int weaponID = 0; weaponID < weaponCount; weaponID++)
	{
		if (StrEqual(weaponName, gC_WeaponNames[weaponID]))
		{
			return SPEED_NORMAL / gI_WeaponRunSpeeds[weaponID];
		}
	}
	
	return 1.0; // If weapon isn't found (new weapon?)
}



/*===============================  Jump Tweaks  ===============================*/

static void TweakJump(KZPlayer player)
{
	if (HitPerf(player))
	{
		gB_HitPerf[player.id] = true;
		
		if (NeedToTweakTakeoffSpeed(player))
		{
			float velocity[3], baseVelocity[3], newVelocity[3];
			player.GetVelocity(velocity);
			player.GetBaseVelocity(baseVelocity);
			player.GetLandingVelocity(newVelocity);
			newVelocity[2] = velocity[2];
			AdjustVectorSpeed(newVelocity, CalcTweakedTakeoffSpeed(player), newVelocity);
			AddVectors(newVelocity, baseVelocity, newVelocity);
			player.SetVelocity(newVelocity);
			gF_TakeoffSpeed[player.id] = player.speed;
		}
		else
		{
			gF_TakeoffSpeed[player.id] = player.takeoffSpeed;
		}
	}
	else
	{
		gB_HitPerf[player.id] = false;
		gF_TakeoffSpeed[player.id] = player.takeoffSpeed;
	}
}

static bool HitPerf(KZPlayer player)
{
	if (player.style == KZStyle_Standard)
	{
		return player.takeoffTick - player.landingTick <= STANDARD_PERF_TICKS;
	}
	return player.hitPerf;
}

static bool NeedToTweakTakeoffSpeed(KZPlayer player)
{
	switch (player.style)
	{
		case KZStyle_Standard:return true;
		case KZStyle_Legacy:return player.takeoffSpeed > LEGACY_PERF_SPEED_CAP;
		case KZStyle_Competitive:return false;
	}
	return false;
}

static float CalcTweakedTakeoffSpeed(KZPlayer player)
{
	switch (player.style)
	{
		case KZStyle_Standard:
		{
			if (player.landingSpeed > SPEED_NORMAL)
			{
				return 0.2 * player.landingSpeed + 200; // Formula
			}
			return player.landingSpeed;
		}
		case KZStyle_Legacy:
		{
			return LEGACY_PERF_SPEED_CAP;
		}
	}
	return -1.0; // This should never happen
}



/*===============================  Other Tweaks  ===============================*/

static void RemoveCrouchJumpBind(KZPlayer player, int &buttons)
{
	if (player.style == KZStyle_Competitive)
	{
		return;
	}
	
	if (player.onGround && buttons & IN_JUMP && !(gI_OldButtons[player.id] & IN_JUMP) && !(gI_OldButtons[player.id] & IN_DUCK))
	{
		buttons &= ~IN_DUCK;
	}
}

static void ReduceDuckSlowdown(KZPlayer player)
{
	if (player.style == KZStyle_Competitive)
	{
		return;
	}
	
	if (player.duckSpeed < DUCK_SPEED_MINIMUM)
	{
		player.duckSpeed = DUCK_SPEED_MINIMUM;
	}
} 