/*
	Chat Processing
	
	Processes chat messages.
*/

// Processes the message, and returns what should be returned to OnClientSayCommand.
Action ChatProcessingOnClientSayCommand(int client, const char[] message)
{
	if (!GetConVarBool(gCV_ChatProcessing))
	{
		return Plugin_Continue;
	}
	
	if (gB_BaseComm && BaseComm_IsClientGagged(client))
	{
		return Plugin_Handled;
	}
	
	// Change to lower case and resend (potential) command messages
	if ((message[0] == '/' || message[0] == '!') && IsCharUpper(message[1]))
	{
		char newMessage[128];
		int length = strlen(message);
		for (int i = 0; i <= length; i++)
		{
			newMessage[i] = CharToLower(message[i]);
		}
		FakeClientCommand(client, "say %s", newMessage);
		return Plugin_Handled;
	}
	
	// Don't print the message if it is a chat trigger, or starts with @, or is empty
	if (IsChatTrigger() || message[0] == '@' || !message[0])
	{
		return Plugin_Handled;
	}
	
	// Print the message to chat
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		CPrintToChatAll("{bluegrey}%N{default} : %s", client, message);
	}
	else
	{
		CPrintToChatAll("{lime}%N{default} : %s", client, message);
	}
	return Plugin_Handled;
} 