/*
	Hide Weapon
	
	Weapon viewmodel visiblity.
*/

// Updates viewmodel visiblity depending on what the player has set their option to.
void HideWeaponUpdate(int client)
{
	if (g_ShowingWeapon[client] == KZShowingWeapon_Enabled)
	{
		SetDrawViewModel(client, true);
	}
	else
	{
		SetDrawViewModel(client, false);
	}
}



/*===============================  Static Functions  ===============================*/

static void SetDrawViewModel(int client, bool drawViewModel)
{
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", drawViewModel);
} 