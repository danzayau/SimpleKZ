/*
	Movement Tweak
	
	Plugin-based movement mechanics and styles.
*/

#define SPEED_NORMAL 250.0
#define SPEED_NO_WEAPON 260.0
#define PRESTRAFE_VELMOD_MAX 1.104 // Calculated 276/250
#define PRESTRAFE_VELMOD_INCREMENT 0.0014 // Per tick when prestrafing
#define PRESTRAFE_VELMOD_DECREMENT 0.0021 // Per tick when not prestrafing
#define VELOCITY_VERTICAL_NORMAL_JUMP 292.54 // After one tick after jumping
#define DUCK_SPEED_MINIMUM 7.0

#define STYLE_DEFAULT_PERF_TICKS 2

#define STYLE_LEGACY_PERF_TICKS 1
#define STYLE_LEGACY_PERF_SPEED_CAP 380.0
#define STYLE_LEGACY_SPEED_PRESTRAFE_MINIMUM 175.0

void MovementTweakOnPlayerRunCmd(int client)
{
	if (g_KZPlayer[client].onGround)
	{
		MovementTweakVelocityModifier(g_KZPlayer[client]);
	}
}

void MovementTweakOnStartTouchGround(int client)
{
	MovementTweakDuckSlowdown(g_KZPlayer[client]);
}

void MovementTweakOnStopTouchGround(int client, bool jumped, bool ducked)
{
	if (jumped)
	{
		MovementTweakTakeoffSpeed(g_KZPlayer[client]);
		if (g_Style[client] == KZStyle_Standard && ducked)
		{
			MovementTweakPerfectCrouchJump(g_KZPlayer[client]);
		}
	}
	else
	{
		gB_HitPerf[client] = false; // Not a jump so not a perf
	}
	
	if (g_Style[client] == KZStyle_Standard)
	{
		gF_PrestrafeVelocityModifier[client] = 1.0; // No 'pre b-hopping' in Standard
	}
}

void MovementTweakOnStopTouchLadder(int client)
{
	gB_HitPerf[client] = false;
}

void MovementTweakOnStopNoclipping(int client)
{
	gB_HitPerf[client] = false;
}



/*===============================  General Tweak  ===============================*/

static void MovementTweakVelocityModifier(KZPlayer player)
{
	player.velocityModifier = PrestrafeVelocityModifier(player) * WeaponVelocityModifier(player);
}

static float PrestrafeVelocityModifier(KZPlayer player)
{
	// Note: Still trying to get Legacy prestrafe to feel like it does in KZTimer
	if (g_Style[player.id] == KZStyle_Legacy && player.speed < STYLE_LEGACY_SPEED_PRESTRAFE_MINIMUM)
	{
		gF_PrestrafeVelocityModifier[player.id] = 1.0;
	}
	// If correct prestrafe technique is detected, increase prestrafe modifier
	else if (player.turning && CheckIfValidPrestrafeKeys(player))
	{
		gF_PrestrafeVelocityModifier[player.id] += PRESTRAFE_VELMOD_INCREMENT;
	}
	// Else not prestrafing, so decrease prestrafe modifier
	else
	{
		gF_PrestrafeVelocityModifier[player.id] -= PRESTRAFE_VELMOD_DECREMENT;
	}
	
	// Ensure prestrafe modifier is in range
	if (gF_PrestrafeVelocityModifier[player.id] < 1.0)
	{
		gF_PrestrafeVelocityModifier[player.id] = 1.0;
	}
	else if (gF_PrestrafeVelocityModifier[player.id] > PRESTRAFE_VELMOD_MAX)
	{
		gF_PrestrafeVelocityModifier[player.id] = PRESTRAFE_VELMOD_MAX;
	}
	
	return gF_PrestrafeVelocityModifier[player.id];
}

static bool CheckIfValidPrestrafeKeys(KZPlayer player)
{
	switch (g_Style[player.id])
	{
		case KZStyle_Standard:
		{
			// If _only_ WA or WD or SA or SD are pressed, then return true.
			// Oh and... this looks stupid
			return ((player.buttons & IN_FORWARD && !(player.buttons & IN_BACK)) || (!(player.buttons & IN_FORWARD) && player.buttons & IN_BACK))
			 && ((player.buttons & IN_MOVELEFT && !(player.buttons & IN_MOVERIGHT)) || (!(player.buttons & IN_MOVELEFT) && player.buttons & IN_MOVERIGHT));
		}
		case KZStyle_Legacy:
		{
			return player.buttons & IN_MOVELEFT || player.buttons & IN_MOVERIGHT;
		}
	}
	return false;
}

static float WeaponVelocityModifier(KZPlayer player)
{
	// Universal Weapon Speed
	int weaponEnt = GetEntPropEnt(player.id, Prop_Data, "m_hActiveWeapon");
	if (IsValidEntity(weaponEnt))
	{
		char weaponName[64];
		GetEntityClassname(weaponEnt, weaponName, sizeof(weaponName)); // What weapon the client is holding.
		
		// Get weapon speed and work out how much to scale the modifier.
		int numberOfWeapons = sizeof(gC_WeaponNames);
		for (int weaponID = 0; weaponID < numberOfWeapons; weaponID++)
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

static void MovementTweakTakeoffSpeed(KZPlayer player)
{
	if (HitPerf(player))
	{
		gB_HitPerf[player.id] = true;
		ApplyTakeoffSpeed(player, CalculateTweakedTakeoffSpeed(player));
		Call_SKZ_OnPerfectBunnyhop(player.id);
	}
	else
	{
		gB_HitPerf[player.id] = false;
	}
}

static bool HitPerf(KZPlayer player)
{
	switch (g_Style[player.id])
	{
		case KZStyle_Standard:
		{
			return player.jumpTick - player.landingTick <= STYLE_DEFAULT_PERF_TICKS;
		}
		case KZStyle_Legacy:
		{
			return player.jumpTick - player.landingTick <= STYLE_LEGACY_PERF_TICKS;
		}
	}
	return player.jumpTick - player.landingTick <= 1;
}

static float ApplyTakeoffSpeed(KZPlayer player, float speed)
{
	float oldVelocity[3], landingVelocity[3], baseVelocity[3];
	player.GetVelocity(oldVelocity);
	player.GetLandingVelocity(landingVelocity);
	player.GetBaseVelocity(baseVelocity);
	
	float newVelocity[3];
	newVelocity = landingVelocity;
	newVelocity[2] = 0.0; // Only adjust horizontal speed
	NormalizeVector(newVelocity, newVelocity);
	ScaleVector(newVelocity, speed);
	newVelocity[2] = oldVelocity[2];
	AddVectors(newVelocity, baseVelocity, newVelocity);
	
	player.SetVelocity(newVelocity);
	player.takeoffSpeed = speed;
}

static float CalculateTweakedTakeoffSpeed(KZPlayer player)
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
			if (player.landingSpeed > STYLE_LEGACY_PERF_SPEED_CAP)
			{
				return STYLE_LEGACY_PERF_SPEED_CAP;
			}
		}
	}
	return player.speed;
}

static void MovementTweakPerfectCrouchJump(KZPlayer player)
{
	float newVelocity[3];
	player.GetVelocity(newVelocity);
	newVelocity[2] = VELOCITY_VERTICAL_NORMAL_JUMP;
	player.SetVelocity(newVelocity);
}



/*===============================  Other Tweaks  ===============================*/

static void MovementTweakDuckSlowdown(KZPlayer player)
{
	if (player.duckSpeed < DUCK_SPEED_MINIMUM)
	{
		player.duckSpeed = DUCK_SPEED_MINIMUM;
	}
} 