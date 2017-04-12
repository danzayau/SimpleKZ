/*
	Block Radio
	
	Block radio messages from players.
*/

void BlockRadioAddCommandListeners()
{
	for (int i = 0; i < sizeof(gC_RadioCommands); i++)
	{
		AddCommandListener(CommandBlock, gC_RadioCommands[i]);
	}
} 