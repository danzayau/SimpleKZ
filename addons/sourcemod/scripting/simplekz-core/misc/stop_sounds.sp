/*
	Stop Sounds
	
	Stops the player from hearing unwanted sounds.
*/

void StopSounds(int client)
{
	ClientCommand(client, "snd_playsounds Music.StopAllExceptMusic");
	CPrintToChat(client, "%t %t", "KZ Prefix", "Stopped Sounds");
}

void StopSoundsCreateHooks()
{
	AddNormalSoundHook(view_as<NormalSHook>(OnNormalSound));
}



/*===============================  Public Callbacks  ===============================*/

public Action OnNormalSound(int[] clients, int &numClients, char[] sample, int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char[] soundEntry, int &seed)
{
	char className[20];
	GetEntityClassname(entity, className, sizeof(className));
	if (StrEqual(className, "func_button", false))
	{
		return Plugin_Handled; // No sounds directly from func_button
	}
	return Plugin_Continue;
} 