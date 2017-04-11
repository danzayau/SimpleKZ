/*	movementtweaker.sp
	
	Implementation of plugin-based movement mechanics and styles.
*/


/*===============================  General Tweak (Called OnPlayerRunCmd)  ===============================*/

void TweakMovementGeneral(MovementPlayer player) {
	if (player.onGround) {
		player.velocityModifier = PrestrafeVelocityModifier(player) * WeaponVelocityModifier(player);
	}
}

float PrestrafeVelocityModifier(MovementPlayer player) {
	// Note: Still trying to get Legacy prestrafe to feel like it does in KZTimer
	if (g_Style[player.id] == KZStyle_Legacy && player.speed < STYLE_LEGACY_SPEED_PRESTRAFE_MINIMUM) {
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
	switch (g_Style[player.id]) {
		case KZStyle_Standard: {
			// If _only_ WA or WD or SA or SD are pressed, then return true.
			// Oh and... this looks stupid
			return ((player.buttons & IN_FORWARD && !(player.buttons & IN_BACK)) || (!(player.buttons & IN_FORWARD) && player.buttons & IN_BACK))
			 && ((player.buttons & IN_MOVELEFT && !(player.buttons & IN_MOVERIGHT)) || (!(player.buttons & IN_MOVELEFT) && player.buttons & IN_MOVERIGHT));
		}
		case KZStyle_Legacy: {
			return player.buttons & IN_MOVELEFT || player.buttons & IN_MOVERIGHT;
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

void TweakMovementTakeoffSpeed(MovementPlayer player) {
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
	switch (g_Style[player.id]) {
		case KZStyle_Standard: {
			return player.jumpTick - player.landingTick <= STYLE_DEFAULT_PERF_TICKS;
		}
		case KZStyle_Legacy: {
			return player.jumpTick - player.landingTick <= STYLE_LEGACY_PERF_TICKS;
		}
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
	switch (g_Style[player.id]) {
		case KZStyle_Standard: {
			if (player.landingSpeed > SPEED_NORMAL) {
				return 0.2 * player.landingSpeed + 200; // The magic formula
			}
		}
		case KZStyle_Legacy: {
			if (player.landingSpeed > STYLE_LEGACY_PERF_SPEED_CAP) {
				return STYLE_LEGACY_PERF_SPEED_CAP;
			}
		}
	}
	return player.speed;
}

void TweakMovementPerfectCrouchJump(MovementPlayer player) {
	float newVelocity[3];
	player.GetVelocity(newVelocity);
	newVelocity[2] = VELOCITY_VERTICAL_NORMAL_JUMP;
	player.SetVelocity(newVelocity);
}



/*===============================  Other Tweaks  ===============================*/

void TweakMovementDuckSlowdown(MovementPlayer player) {
	if (player.duckSpeed < DUCK_SPEED_MINIMUM) {
		player.duckSpeed = DUCK_SPEED_MINIMUM;
	}
} 