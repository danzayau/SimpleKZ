/*
	God Mode
	
	Controls if players can take damage.
*/

// Sets the player so they don't take damage.
void GodModeUpdate(int client) {
	SetEntProp(client, Prop_Data, "m_takedamage", 0, 1); // Godmode
} 