/*
	Block Radio
	
	Block radio messages from players.
*/

void BlockRadioAddCommandListeners()
{
	int numberOfRadioCommands = sizeof(gC_RadioCommands);
	for (int i = 0; i < numberOfRadioCommands; i++)
	{
		AddCommandListener(CommandBlock, gC_RadioCommands[i]);
	}
} 