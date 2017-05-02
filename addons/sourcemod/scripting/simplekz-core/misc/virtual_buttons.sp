/*	
	Virtual Buttons
	
	Lets players press buttons without looking.
*/

#define DISTANCE_BUTTON_PRESS_CHECK 40.0 // Max distance from saved press position to detect a press

// Detects and handles if the player has tried to press a start of end button.
void ButtonPressOnButtonPress(int client, int button)
{
	if (button == IN_USE)
	{
		float origin[3];
		g_KZPlayer[client].GetOrigin(origin);
		
		if (gB_HasStartedThisMap[client] && GetVectorDistance(origin, gF_VirtualStartButtonOrigin[client]) <= DISTANCE_BUTTON_PRESS_CHECK)
		{
			TimerStart(client, gI_VirtualStartButtonCourse[client]);
		}
		else if (gB_HasEndedThisMap[client]
			 && GetVectorDistance(origin, gF_VirtualEndButtonOrigin[client]) <= DISTANCE_BUTTON_PRESS_CHECK)
		{
			TimerEnd(client, gI_VirtualEndButtonCourse[client]);
		}
	}
} 