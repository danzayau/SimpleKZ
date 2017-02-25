/*	misc.sp

	Miscellaneous functions.
*/

bool IsValidClient(int client) {
	return 1 <= client && client <= MaxClients && IsClientInGame(client);
}

void SetupClient(int client) {
	AddItemsPlayerTopMenu(client);
	gB_HasSeenPBs[client] = false;
}

void FakePrecacheSound(const char[] relativeSoundPath) {
	AddToStringTable(FindStringTable("soundprecache"), relativeSoundPath);
}

void EmitSoundToClientSpectators(int client, const char[] sound) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsValidClient(i) && GetSpectatedPlayer(i) == client) {
			EmitSoundToClient(i, sound);
		}
	}
}

int GetSpectatedPlayer(int client) {
	return GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
}

void String_ToLower(const char[] input, char[] output, int size) {
	size--;
	int i = 0;
	while (input[i] != '\0' && i < size) {
		output[i] = CharToLower(input[i]);
		i++;
	}
	output[i] = '\0';
} 