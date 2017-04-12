/*
	Miscellaneous
	
	Miscellaneous functions.
*/

/*===============================  Includes  ===============================*/

#include "simplekz-core/misc/block_radio.sp"
#include "simplekz-core/misc/button_press.sp"
#include "simplekz-core/misc/chat_processing.sp"
#include "simplekz-core/misc/god_mode.sp"
#include "simplekz-core/misc/hide_players.sp"
#include "simplekz-core/misc/hide_weapon.sp"
#include "simplekz-core/misc/mapping_api.sp"
#include "simplekz-core/misc/measure.sp"
#include "simplekz-core/misc/no_cp_on_bhop.sp"
#include "simplekz-core/misc/options.sp"
#include "simplekz-core/misc/pistol.sp"
#include "simplekz-core/misc/player_collision.sp"
#include "simplekz-core/misc/player_model.sp"
#include "simplekz-core/misc/stop_sounds.sp"
#include "simplekz-core/misc/teleport.sp"
#include "simplekz-core/misc/other.sp"



/*===============================  Helper Functions  ===============================*/

// Teleports the player (intended for destination on ground).
// Handles important stuff like storing postion for undo.
void DoTeleport(int client, float destination[3], float eyeAngles[3])
{
	// Store old variables here to avoid incorrect behaviour when teleporting to undo position
	float oldOrigin[3], oldAngles[3];
	g_MovementPlayer[client].GetOrigin(oldOrigin);
	g_MovementPlayer[client].GetEyeAngles(oldAngles);
	
	TeleportEntity(client, destination, eyeAngles, view_as<float>( { 0.0, 0.0, -50.0 } ));
	CreateTimer(0.0, Timer_ZeroVelocity, client); // Prevent booster exploits
	gI_TeleportsUsed[client]++;
	// Store position for undo
	if (g_MovementPlayer[client].onGround)
	{
		gB_LastTeleportOnGround[client] = true;
		gF_UndoOrigin[client] = oldOrigin;
		gF_UndoAngle[client] = oldAngles;
	}
	else
	{
		gB_LastTeleportOnGround[client] = false;
	}
}

// Switches the players team. Handles important stuff like saving and restoring their position.
void JoinTeam(int client, int team)
{
	if (team == CS_TEAM_SPECTATOR)
	{
		g_MovementPlayer[client].GetOrigin(gF_SavedOrigin[client]);
		g_MovementPlayer[client].GetEyeAngles(gF_SavedAngles[client]);
		gB_HasSavedPosition[client] = true;
		if (gB_TimerRunning[client])
		{
			Pause(client);
		}
		ChangeClientTeam(client, CS_TEAM_SPECTATOR);
	}
	else if (team == CS_TEAM_CT || team == CS_TEAM_T)
	{
		// Switch teams without killing them (no death notice)
		CS_SwitchTeam(client, team);
		CS_RespawnPlayer(client);
		if (gB_HasSavedPosition[client])
		{
			TeleportEntity(client, gF_SavedOrigin[client], gF_SavedAngles[client], view_as<float>( { 0.0, 0.0, -50.0 } ));
			gB_HasSavedPosition[client] = false;
			if (gB_Paused[client])
			{
				FreezePlayer(client);
			}
		}
		else
		{
			// The player will be teleported to the spawn point, so force stop their timer
			SKZ_ForceStopTimer(client);
		}
	}
	CloseTPMenu(client);
}

// Returns the player's current run type depending on how many teleports they've used.
KZTimeType GetCurrentTimeType(int client)
{
	if (gI_TeleportsUsed[client] == 0)
	{
		return KZTimeType_Pro;
	}
	else
	{
		return KZTimeType_Normal;
	}
}

// Returns which client the player is spectating.
int GetSpectatedClient(int client)
{
	return GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
}

// Emits a sound to other players that are spectating the client.
void EmitSoundToClientSpectators(int client, const char[] sound)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && GetSpectatedClient(i) == client)
		{
			EmitSoundToClient(i, sound);
		}
	}
}

// Puts the player into noclip if they aren't already, or else sets them to normal movement.
void ToggleNoclip(int client)
{
	if (!IsPlayerAlive(client))
	{
		return;
	}
	
	if (g_MovementPlayer[client].moveType != MOVETYPE_NOCLIP)
	{
		g_MovementPlayer[client].moveType = MOVETYPE_NOCLIP;
	}
	else
	{
		g_MovementPlayer[client].moveType = MOVETYPE_WALK;
	}
}

// Teleports a player to another target player.
void GotoPlayer(int client, int target)
{
	if (!IsValidClient(client) || !IsValidClient(target) || !IsPlayerAlive(target) || client == target)
	{
		return;
	}
	
	float targetOrigin[3];
	float targetAngles[3];
	
	g_MovementPlayer[target].GetOrigin(targetOrigin);
	g_MovementPlayer[target].GetEyeAngles(targetAngles);
	
	// Leave spectators if necessary
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		CS_SwitchTeam(client, CS_TEAM_T);
	}
	// Respawn the player if necessary
	if (!IsPlayerAlive(client))
	{
		CS_RespawnPlayer(client);
	}
	TeleportEntity(client, targetOrigin, targetAngles, view_as<float>( { 0.0, 0.0, -100.0 } ));
	CPrintToChat(client, "%t %t", "KZ Prefix", "Goto Success", target);
}

// Stops the player and prevents them from moving.
void FreezePlayer(int client)
{
	g_MovementPlayer[client].SetVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
	g_MovementPlayer[client].moveType = MOVETYPE_NONE;
}



/*===============================  Helper Callbacks  ===============================*/

// Slays the player.
public Action Timer_SlayPlayer(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		ForcePlayerSuicide(client);
	}
	return Plugin_Continue;
}

// Removes all velocity from the player.
public Action Timer_ZeroVelocity(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		g_MovementPlayer[client].SetVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
		g_MovementPlayer[client].SetBaseVelocity(view_as<float>( { 0.0, 0.0, 0.0 } ));
	}
	return Plugin_Continue;
}

// Trace filter do detect player entities
public bool TraceFilterPlayers(int entity, int contentsMask)
{
	return (entity > MaxClients);
} 