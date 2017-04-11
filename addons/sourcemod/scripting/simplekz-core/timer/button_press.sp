/*    
    Button Press
    
    Start and end button press detection.
*/

void CheckForTimerButtonPress(int client)
{
	// If just pressed +use button
	if (!(gI_OldButtons[client] & IN_USE) && GetClientButtons(client) & IN_USE)
	{
		float origin[3];
		g_MovementPlayer[client].GetOrigin(origin);
		// If didnt just start time
		if (!(gB_TimerRunning[client] && gF_CurrentTime[client] < 0.1)
			 && gB_HasStartedThisMap[client]
			 && GetVectorDistance(origin, gF_StartButtonOrigin[client]) <= DISTANCE_BUTTON_PRESS_CHECK)
		{
			TimerStart(client, gI_LastCourseStarted[client]);
		}
		else if (gB_HasEndedThisMap[client] && GetVectorDistance(origin, gF_EndButtonOrigin[client]) <= DISTANCE_BUTTON_PRESS_CHECK)
		{
			TimerEnd(client, gI_LastCourseEnded[client]);
		}
	}
	gI_OldButtons[client] = GetClientButtons(client);
} 