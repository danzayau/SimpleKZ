/*	
	Virtual Buttons
	
	Lets players press buttons without looking.
*/

#define STANDARD_VIRTUAL_BUTTON_RADIUS 32.0 
#define LEGACY_VIRTUAL_BUTTON_RADIUS 70.0

void ButtonPressOnButtonPress(int client, int button)
{
	if (button == IN_USE)
	{
		if (gB_HasStartedThisMap[client] && InRangeOfStartButton(g_KZPlayer[client]))
		{
			TimerStart(client, gI_VirtualStartButtonCourse[client]);
		}
		else if (gB_HasEndedThisMap[client] && InRangeOfEndButton(g_KZPlayer[client]))
		{
			TimerEnd(client, gI_VirtualEndButtonCourse[client]);
		}
	}
}

static bool InRangeOfStartButton(KZPlayer player)
{
	float origin[3];
	player.GetOrigin(origin);
	float distanceToButton = GetVectorDistance(origin, gF_VirtualStartButtonOrigin[player.id]);
	
	if (player.style == KZStyle_Legacy)
	{
		return distanceToButton <= LEGACY_VIRTUAL_BUTTON_RADIUS;
	}
	return distanceToButton <= STANDARD_VIRTUAL_BUTTON_RADIUS;
}

static bool InRangeOfEndButton(KZPlayer player)
{
	float origin[3];
	player.GetOrigin(origin);
	float distanceToButton = GetVectorDistance(origin, gF_VirtualEndButtonOrigin[player.id]);
	
	if (player.style == KZStyle_Legacy)
	{
		return distanceToButton <= LEGACY_VIRTUAL_BUTTON_RADIUS;
	}
	return distanceToButton <= STANDARD_VIRTUAL_BUTTON_RADIUS;
} 