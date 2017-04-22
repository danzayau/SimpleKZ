/*
	Block Radio
	
	Block radio messages from players.
*/

void BlockRadioAddCommandListeners()
{
	int radioCommandCount = sizeof(gC_RadioCommands);
	for (int i = 0; i < radioCommandCount; i++)
	{
		AddCommandListener(CommandBlock, gC_RadioCommands[i]);
	}
} 