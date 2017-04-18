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
	RemoveCrouchJumpBind(g_KZPlayer[client], buttons);
	TweakVelMod(g_KZPlayer[client]);
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
	if (jumped && HitPerf(g_KZPlayer[client]))
	{
		gB_HitPerf[client] = true;
		TweakTakeoffSpeed(g_KZPlayer[client]);
		Call_SKZ_OnPerfectBunnyhop(client);
	}
	else
	{
		gB_HitPerf[client] = false;
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
	switch (player.style) {
		case KZStyle_Standard:
		{
			gCV_Accelerate.FloatValue = 6.5;
			gCV_Friction.FloatValue = 5.2;
			gCV_AirAccelerate.FloatValue = 100.0;
			gCV_LadderScaleSpeed.FloatValue = 1.0;
			gCV_MaxVelocity.FloatValue = 3500.0;
			gCV_Gravity.FloatValue = 800.0;
			
			gCV_EnableBunnyhopping.BoolValue = true;
			gCV_AutoBunnyhopping.BoolValue = false;
			
			gCV_StaminaMax.FloatValue = 0.0;
			gCV_StaminaLandCost.FloatValue = 0.0;
			gCV_StaminaJumpCost.FloatValue = 0.0;
			gCV_StaminaRecoveryRate.FloatValue = 0.0;
			
			gCV_MaxSpeed.FloatValue = 320.0;
			gCV_WaterAccelerate.FloatValue = 10.0;
			gCV_TimeBetweenDucks.FloatValue = 0.4;
		}
		case KZStyle_Legacy:
		{
			gCV_Accelerate.FloatValue = 6.5;
			gCV_Friction.FloatValue = 5.0;
			gCV_AirAccelerate.FloatValue = 100.0;
			gCV_LadderScaleSpeed.FloatValue = 1.0;
			gCV_MaxVelocity.FloatValue = 3500.0;
			gCV_Gravity.FloatValue = 800.0;
			
			gCV_EnableBunnyhopping.BoolValue = true;
			gCV_AutoBunnyhopping.BoolValue = false;
			
			gCV_StaminaMax.FloatValue = 0.0;
			gCV_StaminaLandCost.FloatValue = 0.0;
			gCV_StaminaJumpCost.FloatValue = 0.0;
			gCV_StaminaRecoveryRate.FloatValue = 0.0;
			
			gCV_MaxSpeed.FloatValue = 320.0;
			gCV_WaterAccelerate.FloatValue = 10.0;
			gCV_TimeBetweenDucks.FloatValue = 0.4;
		}
	}
}



/*===============================  Velocity Modifier  ===============================*/

static void TweakVelMod(KZPlayer player)
{
	if (!player.onGround)
	{
		return;
	}
	
	switch (player.style)
	{
		case KZStyle_Standard:
		{
			player.velocityModifier = CalcPrestrafeVelMod(player) * CalcWeaponVelMod(player);
		}
		case KZStyle_Legacy:
		{
			player.velocityModifier = CalcPrestrafeVelMod(player) * CalcWeaponVelMod(player);
		}
	}
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
	// Universal Weapon Speed
	int weaponEnt = GetEntPropEnt(player.id, Prop_Data, "m_hActiveWeapon");
	if (IsValidEntity(weaponEnt))
	{
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
	}
	
	return SPEED_NORMAL / SPEED_NO_WEAPON; // Weapon entity not found so must have no weapon (260 u/s).
}



/*===============================  Jump Tweaks  ===============================*/

static bool HitPerf(KZPlayer player)
{
	switch (g_Style[player.id])
	{
		case KZStyle_Standard:
		{
			return player.takeoffTick - player.landingTick <= STANDARD_PERF_TICKS;
		}
	}
	
	return player.takeoffTick - player.landingTick <= 1;
}

static void TweakTakeoffSpeed(KZPlayer player)
{
	float oldVelocity[3], landingVelocity[3], baseVelocity[3];
	player.GetVelocity(oldVelocity);
	player.GetLandingVelocity(landingVelocity);
	player.GetBaseVelocity(baseVelocity);
	
	float newVelocity[3];
	newVelocity = landingVelocity;
	newVelocity[2] = 0.0; // Only tweak horizontal speed
	NormalizeVector(newVelocity, newVelocity);
	ScaleVector(newVelocity, CalcTakeoffSpeed(player));
	newVelocity[2] = oldVelocity[2];
	AddVectors(newVelocity, baseVelocity, newVelocity);
	
	player.SetVelocity(newVelocity);
}

static float CalcTakeoffSpeed(KZPlayer player)
{
	switch (g_Style[player.id])
	{
		case KZStyle_Standard:
		{
			if (player.landingSpeed > SPEED_NORMAL)
			{
				return 0.2 * player.landingSpeed + 200; // The magic formula
			}
		}
		case KZStyle_Legacy:
		{
			if (player.landingSpeed > LEGACY_PERF_SPEED_CAP)
			{
				return LEGACY_PERF_SPEED_CAP;
			}
		}
	}
	
	return player.speed;
}



/*===============================  Other Tweaks  ===============================*/

static void RemoveCrouchJumpBind(KZPlayer player, int &buttons)
{
	if (player.onGround && buttons & IN_JUMP && !(player.oldButtons & IN_JUMP) && !(player.oldButtons & IN_DUCK))
	{
		buttons &= ~IN_DUCK;
	}
}

static void ReduceDuckSlowdown(KZPlayer player)
{
	if (player.duckSpeed < DUCK_SPEED_MINIMUM)
	{
		player.duckSpeed = DUCK_SPEED_MINIMUM;
	}
} 