/*	
	Virtual Buttons
	
	Lets players press buttons without looking.
*/



#define STANDARD_VIRTUAL_BUTTON_RADIUS 32.0 
#define LEGACY_VIRTUAL_BUTTON_RADIUS 70.0

static float virtualStartOrigin[MAXPLAYERS + 1][3];
static float virtualEndOrigin[MAXPLAYERS + 1][3];
static int virtualStartCourse[MAXPLAYERS + 1];
static int virtualEndCourse[MAXPLAYERS + 1];



// =========================  LISTENERS  ========================= //

void OnButtonPress_VirtualButtons(int client, int button)
{
	if (button == IN_USE)
	{
		if (GetHasStartedTimerThisMap(client) && InRangeOfStartButton(client))
		{
			TimerStart(client, virtualStartCourse[client]);
		}
		else if (GetHasStartedTimerThisMap(client) && InRangeOfEndButton(client))
		{
			TimerEnd(client, virtualEndCourse[client]);
		}
	}
}

void OnStartButtonPress_VirtualButtons(int client, int course)
{
	Movement_GetOrigin(client, virtualStartOrigin[client]);
	virtualStartCourse[client] = course;
}

void OnEndButtonPress_VirtualButtons(int client, int course)
{
	Movement_GetOrigin(client, virtualEndOrigin[client]);
	virtualEndCourse[client] = course;
}



// =========================  PRIVATE  ========================= //

static bool InRangeOfStartButton(int client)
{
	float origin[3];
	Movement_GetOrigin(client, origin);
	float distanceToButton = GetVectorDistance(origin, virtualStartOrigin[client]);
	
	switch (GetOption(client, Option_Style))
	{
		case Style_Standard:return distanceToButton <= STANDARD_VIRTUAL_BUTTON_RADIUS;
		case Style_Legacy:return distanceToButton <= LEGACY_VIRTUAL_BUTTON_RADIUS;
	}
	return false;
}

static bool InRangeOfEndButton(int client)
{
	float origin[3];
	Movement_GetOrigin(client, origin);
	float distanceToButton = GetVectorDistance(origin, virtualEndOrigin[client]);
	
	switch (GetOption(client, Option_Style))
	{
		case Style_Standard:return distanceToButton <= STANDARD_VIRTUAL_BUTTON_RADIUS;
		case Style_Legacy:return distanceToButton <= LEGACY_VIRTUAL_BUTTON_RADIUS;
	}
	return false;
} 