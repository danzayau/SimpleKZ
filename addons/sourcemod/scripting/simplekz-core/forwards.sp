/*
	Forwards
	
	SimpleKZ Core plugin global forwards.
*/



static Handle H_OnClientSetup;
static Handle H_OnOptionChanged;
static Handle H_OnTimerStart;
static Handle H_OnTimerStart_Post;
static Handle H_OnTimerEnd;
static Handle H_OnTimerEnd_Post;
static Handle H_OnTimerStopped;
static Handle H_OnPause;
static Handle H_OnPause_Post;
static Handle H_OnResume;
static Handle H_OnResume_Post;
static Handle H_OnMakeCheckpoint;
static Handle H_OnMakeCheckpoint_Post;
static Handle H_OnTeleportToCheckpoint;
static Handle H_OnTeleportToCheckpoint_Post;
static Handle H_OnTeleportToStart;
static Handle H_OnTeleportToStart_Post;
static Handle H_OnUndoTeleport;
static Handle H_OnUndoTeleport_Post;



void CreateGlobalForwards()
{
	H_OnClientSetup = CreateGlobalForward("SKZ_OnClientSetup", ET_Ignore, Param_Cell);
	H_OnOptionChanged = CreateGlobalForward("SKZ_OnOptionChanged", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	H_OnTimerStart = CreateGlobalForward("SKZ_OnTimerStart", ET_Hook, Param_Cell, Param_Cell, Param_Cell);
	H_OnTimerStart_Post = CreateGlobalForward("SKZ_OnTimerStart_Post", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	H_OnTimerEnd = CreateGlobalForward("SKZ_OnTimerEnd", ET_Hook, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell, Param_Float);
	H_OnTimerEnd_Post = CreateGlobalForward("SKZ_OnTimerEnd_Post", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Cell, Param_Float);
	H_OnTimerStopped = CreateGlobalForward("SKZ_OnTimerStopped", ET_Ignore, Param_Cell);
	H_OnPause = CreateGlobalForward("SKZ_OnPause", ET_Hook, Param_Cell);
	H_OnPause_Post = CreateGlobalForward("SKZ_OnPause_Post", ET_Ignore, Param_Cell);
	H_OnResume = CreateGlobalForward("SKZ_OnResume_Post", ET_Hook, Param_Cell);
	H_OnResume_Post = CreateGlobalForward("SKZ_OnResume_Post", ET_Ignore, Param_Cell);
	H_OnMakeCheckpoint = CreateGlobalForward("SKZ_OnMakeCheckpoint", ET_Hook, Param_Cell);
	H_OnMakeCheckpoint_Post = CreateGlobalForward("SKZ_OnMakeCheckpoint_Post", ET_Ignore, Param_Cell);
	H_OnTeleportToCheckpoint = CreateGlobalForward("SKZ_OnTeleportToCheckpoint", ET_Hook, Param_Cell);
	H_OnTeleportToCheckpoint_Post = CreateGlobalForward("SKZ_OnTeleportToCheckpoint_Post", ET_Ignore, Param_Cell);
	H_OnTeleportToStart = CreateGlobalForward("SKZ_OnTeleportToStart", ET_Hook, Param_Cell);
	H_OnTeleportToStart_Post = CreateGlobalForward("SKZ_OnTeleportToStart_Post", ET_Ignore, Param_Cell);
	H_OnUndoTeleport = CreateGlobalForward("SKZ_OnUndoTeleport", ET_Hook, Param_Cell);
	H_OnUndoTeleport_Post = CreateGlobalForward("SKZ_OnUndoTeleport_Post", ET_Ignore, Param_Cell);
}

int Call_SKZ_OnClientSetup(int client)
{
	Call_StartForward(H_OnClientSetup);
	Call_PushCell(client);
	return Call_Finish();
}

int Call_SKZ_OnTimerStart(int client, int course, int style, Action &result)
{
	Call_StartForward(H_OnTimerStart);
	Call_PushCell(client);
	Call_PushCell(course);
	Call_PushCell(style);
	return Call_Finish(result);
}

int Call_SKZ_OnTimerStart_Post(int client, int course, int style)
{
	Call_StartForward(H_OnTimerStart_Post);
	Call_PushCell(client);
	Call_PushCell(course);
	Call_PushCell(style);
	return Call_Finish();
}

int Call_SKZ_OnTimerEnd(int client, int course, int style, float time, int teleportsUsed, float theoreticalTime, Action &result)
{
	Call_StartForward(H_OnTimerEnd);
	Call_PushCell(client);
	Call_PushCell(course);
	Call_PushCell(style);
	Call_PushFloat(time);
	Call_PushCell(teleportsUsed);
	Call_PushFloat(theoreticalTime);
	return Call_Finish(result);
}

int Call_SKZ_OnTimerEnd_Post(int client, int course, int style, float time, int teleportsUsed, float theoreticalTime)
{
	Call_StartForward(H_OnTimerEnd_Post);
	Call_PushCell(client);
	Call_PushCell(course);
	Call_PushCell(style);
	Call_PushFloat(time);
	Call_PushCell(teleportsUsed);
	Call_PushFloat(theoreticalTime);
	return Call_Finish();
}

int Call_SKZ_OnTimerStopped(int client)
{
	Call_StartForward(H_OnTimerStopped);
	Call_PushCell(client);
	return Call_Finish();
}

int Call_SKZ_OnPause(int client, Action &result)
{
	Call_StartForward(H_OnPause);
	Call_PushCell(client);
	return Call_Finish(result);
}

int Call_SKZ_OnPause_Post(int client)
{
	Call_StartForward(H_OnPause_Post);
	Call_PushCell(client);
	return Call_Finish();
}

int Call_SKZ_OnResume(int client, Action &result)
{
	Call_StartForward(H_OnResume);
	Call_PushCell(client);
	return Call_Finish(result);
}

int Call_SKZ_OnResume_Post(int client)
{
	Call_StartForward(H_OnResume_Post);
	Call_PushCell(client);
	return Call_Finish();
}

int Call_SKZ_OnMakeCheckpoint(int client, Action &result)
{
	Call_StartForward(H_OnMakeCheckpoint);
	Call_PushCell(client);
	return Call_Finish(result);
}

int Call_SKZ_OnMakeCheckpoint_Post(int client)
{
	Call_StartForward(H_OnMakeCheckpoint_Post);
	Call_PushCell(client);
	return Call_Finish();
}

int Call_SKZ_OnTeleportToCheckpoint(int client, Action &result)
{
	Call_StartForward(H_OnTeleportToCheckpoint);
	Call_PushCell(client);
	return Call_Finish(result);
}

int Call_SKZ_OnTeleportToCheckpoint_Post(int client)
{
	Call_StartForward(H_OnTeleportToCheckpoint_Post);
	Call_PushCell(client);
	return Call_Finish();
}

int Call_SKZ_OnTeleportToStart(int client, Action &result)
{
	Call_StartForward(H_OnTeleportToStart);
	Call_PushCell(client);
	return Call_Finish(result);
}

int Call_SKZ_OnTeleportToStart_Post(int client)
{
	Call_StartForward(H_OnTeleportToStart_Post);
	Call_PushCell(client);
	return Call_Finish();
}

int Call_SKZ_OnUndoTeleport(int client, Action &result)
{
	Call_StartForward(H_OnUndoTeleport);
	Call_PushCell(client);
	return Call_Finish();
}

int Call_SKZ_OnUndoTeleport_Post(int client)
{
	Call_StartForward(H_OnUndoTeleport_Post);
	Call_PushCell(client);
	return Call_Finish();
}

int Call_SKZ_OnOptionChanged(int client, Option option, int optionValue)
{
	Call_StartForward(H_OnOptionChanged);
	Call_PushCell(client);
	Call_PushCell(option);
	Call_PushCell(optionValue);
	return Call_Finish();
} 