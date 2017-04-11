/*   
    Timer
    
    Timer and checkpoint/teleport system.
*/

#include "simplekz-core/timer/button_press.sp"
#include "simplekz-core/timer/no_bhop_cp.sp"
#include "simplekz-core/timer/pause.sp"
#include "simplekz-core/timer/teleporting.sp"
#include "simplekz-core/timer/wasted_time.sp"
#include "simplekz-core/timer/misc.sp"

void SetupTimer(int client)
{
	gB_TimerRunning[client] = false;
	gB_Paused[client] = false;
	gB_HasStartedThisMap[client] = false;
	TimerReset(client);
}

void UpdateTimer(int client)
{
	if (IsPlayerAlive(client) && gB_TimerRunning[client] && !gB_Paused[client])
	{
		gF_CurrentTime[client] += GetTickInterval();
	}
}

void TimerReset(int client)
{
	// Reset all stored variables
	gF_CurrentTime[client] = 0.0;
	gF_LastResumeTime[client] = 0.0;
	gB_HasResumedInThisRun[client] = false;
	gI_CheckpointCount[client] = 0;
	gI_TeleportsUsed[client] = 0;
	gF_LastCheckpointTime[client] = 0.0;
	gF_LastGoCheckTime[client] = 0.0;
	gF_LastGoCheckWastedTime[client] = 0.0;
	gF_LastUndoTime[client] = 0.0;
	gF_LastUndoWastedTime[client] = 0.0;
	gF_LastTeleportToStartTime[client] = 0.0;
	gF_LastTeleportToStartWastedTime[client] = 0.0;
	gF_WastedTime[client] = 0.0;
	gB_HasSavedPosition[client] = false;
}

void TimerStart(int client, int course)
{
	// Have to be on ground and not noclipping to start the timer
	if (!g_MovementPlayer[client].onGround || g_MovementPlayer[client].noclipping)
	{
		return;
	}
	
	Resume(client);
	TimerReset(client);
	gB_TimerRunning[client] = true;
	gI_CurrentCourse[client] = course;
	gB_HasStartedThisMap[client] = true;
	g_MovementPlayer[client].GetOrigin(gF_StartOrigin[client]);
	g_MovementPlayer[client].GetEyeAngles(gF_StartAngles[client]);
	PlayTimerStartSound(client);
	Call_SimpleKZ_OnTimerStart(client);
	CloseTPMenu(client);
}

void TimerEnd(int client, int course)
{
	if (gB_TimerRunning[client] && course == gI_CurrentCourse[client])
	{
		gB_TimerRunning[client] = false;
		PrintEndTimeString(client);
		if (g_SlayOnEnd[client] == KZSlayOnEnd_Enabled)
		{
			CreateTimer(3.0, SlayPlayer, client);
		}
		PlayTimerEndSound(client);
		Call_SimpleKZ_OnTimerEnd(client);
		CloseTPMenu(client);
	}
}

bool TimerForceStop(int client)
{
	if (gB_TimerRunning[client])
	{
		PlayTimerForceStopSound(client);
		gB_TimerRunning[client] = false;
		Call_SimpleKZ_OnTimerForceStop(client);
		CloseTPMenu(client);
		return true;
	}
	return false;
}

void TimerForceStopAll()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client))
		{
			TimerForceStop(client);
		}
	}
} 