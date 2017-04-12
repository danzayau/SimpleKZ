/*
	Player Collision
	
	Controls whether players can block (collide with) other players.
*/

// Sets the player's collision group so they don't get blocked by other players.
void PlayerCollisionUpdate(int client) {
	SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
} 