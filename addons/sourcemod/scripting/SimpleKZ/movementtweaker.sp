/*	movementtweaker.sp
	
	Implementation of plugin-based movement mechanics and styles.
*/


void SetMovementStyle(int client, MovementStyle style) {
	if (g_MovementStyle[client] != style) {
		g_MovementStyle[client] = style;
		if (gB_TimerRunning[client]) {
			TimerForceStop(client);
			CPrintToChat(client, "%t %t", "KZ_Tag", "TimeStopped_ChangeStyle");
		}
		Call_SimpleKZ_OnChangeMovementStyle(client);
	}
}



/*===============================  Movement API Events  ===============================*/

public void OnStartTouchGround(int client) {
	MovementTweakDuckSlowdown(g_MovementPlayer[client]);
}

public void OnStopTouchGround(int client, bool jumped, bool ducked, bool landed) {
	if (jumped) {
		MovementTweakTakeoffSpeed(g_MovementPlayer[client]);
		if (g_MovementStyle[client] == MovementStyle_Standard && ducked) {
			MovementTweakPerfectCrouchJump(g_MovementPlayer[client]);
		}
	}
	// Reset prestrafe modifier if Standard (this is what enables 'pre b-hopping' in Legacy)
	if (g_MovementStyle[client] == MovementStyle_Standard) {
		gF_PrestrafeVelocityModifier[client] = 1.0;
	}
}



/*===============================  General Tweak (Called OnPlayerRunCmd)  ===============================*/

void MovementTweakGeneral(MovementPlayer player) {
	if (player.onGround) {
		player.velocityModifier = PrestrafeVelocityModifier(player) * WeaponVelocityModifier(player);
	}
}

float PrestrafeVelocityModifier(MovementPlayer player) {
	// Note: Still trying to get Legacy prestrafe to feel like it does in KZTimer
	if (g_MovementStyle[player.id] == MovementStyle_Legacy && player.speed < 200.0) {
		gF_PrestrafeVelocityModifier[player.id] = 1.0;
	}
	// If correct prestrafe technique is detected, increase prestrafe modifier
	else if (player.turning && CheckIfValidPrestrafeKeys(player)) {
		gF_PrestrafeVelocityModifier[player.id] += PRESTRAFE_VELMOD_INCREMENT;
	}
	// Else not prestrafing, so decrease prestrafe modifier
	else {
		gF_PrestrafeVelocityModifier[player.id] -= PRESTRAFE_VELMOD_DECREMENT;
	}
	
	// Ensure prestrafe modifier is in range
	if (gF_PrestrafeVelocityModifier[player.id] < 1.0) {
		gF_PrestrafeVelocityModifier[player.id] = 1.0;
	}
	else if (gF_PrestrafeVelocityModifier[player.id] > PRESTRAFE_VELMOD_MAX) {
		gF_PrestrafeVelocityModifier[player.id] = PRESTRAFE_VELMOD_MAX;
	}
	
	return gF_PrestrafeVelocityModifier[player.id];
}

bool CheckIfValidPrestrafeKeys(MovementPlayer player) {
	if (g_MovementStyle[player.id] == MovementStyle_Standard) {
		// If _only_ WA or WD or SA or SD are pressed, then return true.
		if (((player.buttons & IN_FORWARD && !(player.buttons & IN_BACK)) || (!(player.buttons & IN_FORWARD) && player.buttons & IN_BACK))
			 && ((player.buttons & IN_MOVELEFT && !(player.buttons & IN_MOVERIGHT)) || (!(player.buttons & IN_MOVELEFT) && player.buttons & IN_MOVERIGHT))) {
			return true;
		}
	}
	else if (g_MovementStyle[player.id] == MovementStyle_Legacy) {
		if (player.buttons & IN_MOVELEFT || player.buttons & IN_MOVERIGHT) {
			return true;
		}
	}
	return false;
}

float WeaponVelocityModifier(MovementPlayer player) {
	// Universal Weapon Speed
	int weaponEnt = GetEntPropEnt(player.id, Prop_Data, "m_hActiveWeapon");
	if (IsValidEntity(weaponEnt)) {
		char weaponName[64];
		GetEntityClassname(weaponEnt, weaponName, sizeof(weaponName)); // What weapon the client is holding.
		// Get weapon speed and work out how much to scale the modifier.
		for (int weaponID = 0; weaponID < sizeof(gC_WeaponNames); weaponID++) {
			if (StrEqual(weaponName, gC_WeaponNames[weaponID])) {
				return SPEED_NORMAL / gI_WeaponRunSpeeds[weaponID];
			}
		}
	}
	return SPEED_NORMAL / SPEED_NO_WEAPON; // Weapon entity not found so must have no weapon (260 u/s).
}



/*===============================  Jump Tweaks  ===============================*/

void MovementTweakTakeoffSpeed(MovementPlayer player) {
	if (HitPerf(player)) {
		gB_HitPerf[player.id] = true;
		ApplyTakeoffSpeed(player, CalculateTweakedTakeoffSpeed(player));
		Call_SimpleKZ_OnPerfectBunnyhop(player.id);
	}
	else {
		gB_HitPerf[player.id] = false;
	}
}

bool HitPerf(MovementPlayer player) {
	if (g_MovementStyle[player.id] == MovementStyle_Standard) {
		return player.jumpTick - player.landingTick <= STYLE_DEFAULT_PERF_TICKS;
	}
	else if (g_MovementStyle[player.id] == MovementStyle_Legacy) {
		return player.jumpTick - player.landingTick <= STYLE_LEGACY_PERF_TICKS;
	}
	return player.jumpTick - player.landingTick <= 1;
}

float ApplyTakeoffSpeed(MovementPlayer player, float speed) {
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

float CalculateTweakedTakeoffSpeed(MovementPlayer player) {
	if (g_MovementStyle[player.id] == MovementStyle_Standard && player.landingSpeed > SPEED_NORMAL) {
		return 0.2 * player.landingSpeed + 200;
	}
	else if (g_MovementStyle[player.id] == MovementStyle_Legacy && player.speed > STYLE_LEGACY_PERF_SPEED_CAP) {
		return STYLE_LEGACY_PERF_SPEED_CAP;
	}
	return player.landingSpeed;
}

void MovementTweakPerfectCrouchJump(MovementPlayer player) {
	float newVelocity[3];
	player.GetVelocity(newVelocity);
	newVelocity[2] = VELOCITY_VERTICAL_NORMAL_JUMP;
	player.SetVelocity(newVelocity);
}



/*===============================  Other Tweaks  ===============================*/

void MovementTweakDuckSlowdown(MovementPlayer player) {
	if (g_MovementStyle[player.id] == MovementStyle_Standard || g_MovementStyle[player.id] == MovementStyle_Legacy) {
		if (player.duckSpeed < DUCK_SPEED_MINIMUM) {
			player.duckSpeed = DUCK_SPEED_MINIMUM;
		}
	}
} 