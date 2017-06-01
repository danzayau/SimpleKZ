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
#define STANDARD_PRE_VELMOD_DECREMENT_MIDAIR 0.0011063829787234 // Per tick when in air - calculated 0.104velmod/94ticks

#define LEGACY_PERF_SPEED_CAP 380.0

static bool SKZHitPerf[MAXPLAYERS + 1];
static float SKZTakeoffSpeed[MAXPLAYERS + 1];
static int oldButtons[MAXPLAYERS + 1];
static float preVelMod[MAXPLAYERS + 1];
static float preVelModLastChange[MAXPLAYERS + 1];
static int preTickCounter[MAXPLAYERS + 1];
static float preVelModLanding[MAXPLAYERS + 1];

static char weaponNames[][] = 
{
	"weapon_knife", "weapon_hkp2000", "weapon_deagle", "weapon_elite", "weapon_fiveseven", 
	"weapon_glock", "weapon_p250", "weapon_tec9", "weapon_decoy", "weapon_flashbang", 
	"weapon_hegrenade", "weapon_incgrenade", "weapon_molotov", "weapon_smokegrenade", "weapon_taser", 
	"weapon_ak47", "weapon_aug", "weapon_awp", "weapon_bizon", "weapon_famas", 
	"weapon_g3sg1", "weapon_galilar", "weapon_m249", "weapon_m4a1", "weapon_mac10", 
	"weapon_mag7", "weapon_mp7", "weapon_mp9", "weapon_negev", "weapon_nova", 
	"weapon_p90", "weapon_sawedoff", "weapon_scar20", "weapon_sg556", "weapon_ssg08", 
	"weapon_ump45", "weapon_xm1014"
};

static int weaponRunSpeeds[sizeof(weaponNames)] = 
{
	250, 240, 230, 240, 240, 
	240, 240, 240, 245, 245, 
	245, 245, 245, 245, 220, 
	215, 220, 200, 240, 220, 
	215, 215, 195, 225, 240, 
	225, 220, 240, 150, 220, 
	230, 210, 215, 210, 230, 
	230, 215
};

static float styleCVarValues[STYLE_COUNT][STYLECVAR_COUNT] = 
{
	{ 6.5, 5.2, 100.0, 1.0, 3500.0, 800.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 320.0, 10.0, 0.4, 0.0 }, 
	{ 6.5, 5.0, 100.0, 1.0, 3500.0, 800.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 320.0, 10.0, 0.4, 0.0 }, 
	{ 5.5, 5.2, 12.0, 0.78, 3500.0, 800.0, 0.0, 0.0, 80.0, 0.05, 0.08, 60.0, 320.0, 10.0, 0.4, 1.0 }
};



// =========================  PUBLIC  ========================= //

bool GetSKZHitPerf(int client)
{
	return SKZHitPerf[client];
}

float GetSKZTakeoffSpeed(int client)
{
	return SKZTakeoffSpeed[client];
}



// =========================  LISTENERS  ========================= //

void OnPlayerRunCmd_Style(int client, int &buttons)
{
	if (!IsPlayerAlive(client))
	{
		return;
	}
	
	KZPlayer player = new KZPlayer(client);
	RemoveCrouchJumpBind(player, buttons);
	TweakVelMod(player);
	oldButtons[client] = buttons;
}

void OnClientPreThink_Style(int client)
{
	KZPlayer player = new KZPlayer(client);
	TweakConVars(player);
}

void OnPlayerSpawn_Style(int client)
{
	SKZHitPerf[client] = false;
	SKZTakeoffSpeed[client] = 0.0;
}

void OnStartTouchGround_Style(int client)
{
	KZPlayer player = new KZPlayer(client);
	ReduceDuckSlowdown(player);
	preVelModLanding[client] = preVelMod[client];
}

void OnStopTouchGround_Style(int client, bool jumped)
{
	KZPlayer player = new KZPlayer(client);
	if (jumped)
	{
		TweakJump(player);
	}
	else
	{
		SKZHitPerf[client] = false;
		SKZTakeoffSpeed[client] = Movement_GetTakeoffSpeed(client);
	}
}

void OnChangeMoveType_Style(int client, MoveType newMoveType)
{
	if (newMoveType == MOVETYPE_WALK)
	{
		SKZHitPerf[client] = false;
		SKZTakeoffSpeed[client] = Movement_GetTakeoffSpeed(client);
	}
}



// =========================  PRIVATE  ========================= //

// CONVARS

static void TweakConVars(KZPlayer player)
{
	int style = player.style;
	for (int i = 0; i < STYLECVAR_COUNT; i++)
	{
		gCV_StyleCVar[i].FloatValue = styleCVarValues[style][i];
	}
}



// VELOCITY MODIFIER

static void TweakVelMod(KZPlayer player)
{
	player.velocityModifier = CalcPrestrafeVelMod(player) * CalcWeaponVelMod(player);
}

static float CalcPrestrafeVelMod(KZPlayer player)
{
	switch (player.style)
	{
		case Style_Standard:
		{
			if (!player.onGround)
			{
				preVelMod[player.id] -= STANDARD_PRE_VELMOD_DECREMENT_MIDAIR;
			}
			else if (player.turning
				 && ((player.buttons & IN_FORWARD && !(player.buttons & IN_BACK)) || (!(player.buttons & IN_FORWARD) && player.buttons & IN_BACK))
				 && ((player.buttons & IN_MOVELEFT && !(player.buttons & IN_MOVERIGHT)) || (!(player.buttons & IN_MOVELEFT) && player.buttons & IN_MOVERIGHT)))
			{
				preVelMod[player.id] += STANDARD_PRE_VELMOD_INCREMENT;
			}
			else
			{
				preVelMod[player.id] -= STANDARD_PRE_VELMOD_DECREMENT;
			}
		}
		case Style_Legacy:
		{
			if (!player.onGround)
			{
				return preVelMod[player.id]; // No changes in midair
			}
			
			// KZTimer prestrafe (not exactly the same, and is only for 128 tick)
			if (!player.turning)
			{
				if (GetEngineTime() - preVelModLastChange[player.id] > 0.2)
				{
					preVelMod[player.id] = 1.0;
					preVelModLastChange[player.id] = GetEngineTime();
				}
			}
			else if ((player.buttons & IN_MOVELEFT || player.buttons & IN_MOVERIGHT) && player.speed > 248.9)
			{
				float increment = 0.0009;
				if (preVelMod[player.id] > 1.04)
				{
					increment = 0.001;
				}
				
				preTickCounter[player.id]++;
				if (preTickCounter[player.id] < 75)
				{
					preVelMod[player.id] += increment;
					if (preVelMod[player.id] > PRE_VELMOD_MAX)
					{
						if (preVelMod[player.id] > PRE_VELMOD_MAX + 0.007)
						{
							preVelMod[player.id] = PRE_VELMOD_MAX - 0.001;
						}
						else
						{
							preVelMod[player.id] -= 0.007;
						}
					}
					preVelMod[player.id] += increment;
				}
				else
				{
					preVelMod[player.id] -= 0.0045;
					preTickCounter[player.id] -= 2;
				}
			}
			else {
				preVelMod[player.id] -= 0.04;
			}
		}
		default:
		{
			preVelMod[player.id] = 1.0;
			return 1.0;
		}
	}
	
	// Keep prestrafe velocity modifier within range
	if (preVelMod[player.id] < 1.0)
	{
		preVelMod[player.id] = 1.0;
		preTickCounter[player.id] = 0;
	}
	else if (preVelMod[player.id] > PRE_VELMOD_MAX)
	{
		preVelMod[player.id] = PRE_VELMOD_MAX;
	}
	
	return preVelMod[player.id];
}

static float CalcWeaponVelMod(KZPlayer player)
{
	if (player.style == Style_Competitive)
	{
		return 1.0;
	}
	
	int weaponEnt = GetEntPropEnt(player.id, Prop_Data, "m_hActiveWeapon");
	if (!IsValidEntity(weaponEnt))
	{
		return SPEED_NORMAL / SPEED_NO_WEAPON; // Weapon entity not found, so no weapon
	}
	
	char weaponName[64];
	GetEntityClassname(weaponEnt, weaponName, sizeof(weaponName)); // Weapon the client is holding
	
	// Get weapon speed and work out how much to scale the modifier
	int weaponCount = sizeof(weaponNames);
	for (int weaponID = 0; weaponID < weaponCount; weaponID++)
	{
		if (StrEqual(weaponName, weaponNames[weaponID]))
		{
			return SPEED_NORMAL / weaponRunSpeeds[weaponID];
		}
	}
	
	return 1.0; // If weapon isn't found (new weapon?)
}



// JUMPING

static void TweakJump(KZPlayer player)
{
	if (HitSKZPerf(player))
	{
		SKZHitPerf[player.id] = true;
		
		if (NeedToTweakTakeoffSpeed(player))
		{
			float velocity[3], baseVelocity[3], newVelocity[3];
			player.GetVelocity(velocity);
			player.GetBaseVelocity(baseVelocity);
			player.GetLandingVelocity(newVelocity);
			newVelocity[2] = velocity[2];
			SetVectorHorizontalLength(newVelocity, CalcTweakedTakeoffSpeed(player));
			AddVectors(newVelocity, baseVelocity, newVelocity);
			player.SetVelocity(newVelocity);
			SKZTakeoffSpeed[player.id] = player.speed;
			if (player.style == Style_Standard)
			{
				preVelMod[player.id] = preVelModLanding[player.id];
			}
		}
		else if (player.style == Style_Competitive)
		{
			// MovementAPI takeoff speed is wrong if hit a perf on sv_enablebunnyhopping 0
			SKZTakeoffSpeed[player.id] = player.speed;
		}
		else
		{
			SKZTakeoffSpeed[player.id] = player.takeoffSpeed;
		}
	}
	else
	{
		SKZHitPerf[player.id] = false;
		SKZTakeoffSpeed[player.id] = player.takeoffSpeed;
	}
}

static bool HitSKZPerf(KZPlayer player)
{
	if (player.style == Style_Standard)
	{
		return player.takeoffTick - player.landingTick <= STANDARD_PERF_TICKS;
	}
	return player.hitPerf;
}

// Returns true if need to tweak player's speed after hitting a perf
static bool NeedToTweakTakeoffSpeed(KZPlayer player)
{
	switch (player.style)
	{
		case Style_Standard:return !player.hitPerf || player.takeoffSpeed > SPEED_NORMAL;
		case Style_Legacy:return player.takeoffSpeed > LEGACY_PERF_SPEED_CAP;
	}
	return false;
}

// Takeoff speed assuming player has met the conditions to need tweaking
static float CalcTweakedTakeoffSpeed(KZPlayer player)
{
	switch (player.style)
	{
		case Style_Standard:
		{
			// Formula
			if (player.landingSpeed > SPEED_NORMAL)
			{
				return (0.2 * player.landingSpeed + 200) * preVelModLanding[player.id];
			}
			return player.landingSpeed;
		}
		case Style_Legacy:
		{
			return LEGACY_PERF_SPEED_CAP;
		}
	}
	return -1.0; // This should never happen
}



// OTHER

static void RemoveCrouchJumpBind(KZPlayer player, int &buttons)
{
	if (player.style == Style_Competitive)
	{
		return;
	}
	
	if (player.onGround && buttons & IN_JUMP && !(oldButtons[player.id] & IN_JUMP) && !(oldButtons[player.id] & IN_DUCK))
	{
		buttons &= ~IN_DUCK;
	}
}

static void ReduceDuckSlowdown(KZPlayer player)
{
	if (player.style == Style_Competitive)
	{
		return;
	}
	
	if (player.duckSpeed < DUCK_SPEED_MINIMUM)
	{
		player.duckSpeed = DUCK_SPEED_MINIMUM;
	}
} 