/*    
    Measure Menu
    
    Lets players measure the distance between two points.
    
    Credits to DaFox (https://forums.alliedmods.net/showthread.php?t=88830?t=88830)
*/

void CreateMeasureMenuAll()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		CreateMeasureMenu(client);
	}
}

static void CreateMeasureMenu(int client)
{
	gH_MeasureMenu[client] = new Menu(MenuHandler_Measure);
}

public int MenuHandler_Measure(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: //Point A (Green)
			{
				MeasureGetPos(param1, 0);
			}
			case 1: //Point B (Red)
			{
				MeasureGetPos(param1, 1);
			}
			case 2:
			{  //Find Distance
				if (gB_MeasurePosSet[param1][0] && gB_MeasurePosSet[param1][1])
				{
					float vDist = GetVectorDistance(gF_MeasurePos[param1][0], gF_MeasurePos[param1][1]);
					float vHightDist = (gF_MeasurePos[param1][1][2] - gF_MeasurePos[param1][0][2]);
					CPrintToChat(param1, "%t %t", "KZ Prefix", "Measure Result", vDist, vHightDist);
					MeasureBeam(param1, gF_MeasurePos[param1][0], gF_MeasurePos[param1][1], 5.0, 2.0, 200, 200, 200);
				}
				else
				{
					CPrintToChat(param1, "%t %t", "KZ Prefix", "Measure Failure (Points Not Set)");
				}
			}
		}
		DisplayMenu(gH_MeasureMenu[param1], param1, MENU_TIME_FOREVER);
	}
	else if (action == MenuAction_Cancel)
	{
		MeasureResetPos(param1);
	}
}

void DisplayMeasureMenu(int client)
{
	MeasureResetPos(client);
	UpdateMeasureMenu(client, gH_MeasureMenu[client]);
	gH_MeasureMenu[client].Display(client, MENU_TIME_FOREVER);
}

static void UpdateMeasureMenu(int client, Menu menu)
{
	menu.SetTitle("%T", "Measure Menu - Title", client);
	
	char text[32];
	menu.RemoveAllItems();
	FormatEx(text, sizeof(text), "%T", "Measure Menu - Point A", client);
	menu.AddItem("", text);
	FormatEx(text, sizeof(text), "%T", "Measure Menu - Point B", client);
	menu.AddItem("", text);
	FormatEx(text, sizeof(text), "%T", "Measure Menu - Get Distance", client);
	menu.AddItem("", text);
}

static void MeasureGetPos(int client, int arg)
{
	float origin[3];
	float angles[3];
	
	GetClientEyePosition(client, origin);
	GetClientEyeAngles(client, angles);
	
	Handle trace = TR_TraceRayFilterEx(origin, angles, MASK_SHOT, RayType_Infinite, TraceFilterPlayers, client);
	
	if (!TR_DidHit(trace))
	{
		CloseHandle(trace);
		CPrintToChat(client, "%t %t", "KZ Prefix", "Measure Failure (Not Aiming at Solid)");
		return;
	}
	
	TR_GetEndPosition(origin, trace);
	CloseHandle(trace);
	
	gF_MeasurePos[client][arg][0] = origin[0];
	gF_MeasurePos[client][arg][1] = origin[1];
	gF_MeasurePos[client][arg][2] = origin[2];
	
	if (arg == 0)
	{
		if (gH_P2PRed[client] != INVALID_HANDLE)
		{
			CloseHandle(gH_P2PRed[client]);
			gH_P2PRed[client] = INVALID_HANDLE;
		}
		gB_MeasurePosSet[client][0] = true;
		gH_P2PRed[client] = CreateTimer(1.0, Timer_P2PRed, client, TIMER_REPEAT);
		P2PXBeam(client, 0);
	}
	else
	{
		if (gH_P2PGreen[client] != INVALID_HANDLE)
		{
			CloseHandle(gH_P2PGreen[client]);
			gH_P2PGreen[client] = INVALID_HANDLE;
		}
		gB_MeasurePosSet[client][1] = true;
		P2PXBeam(client, 1);
		gH_P2PGreen[client] = CreateTimer(1.0, Timer_P2PGreen, client, TIMER_REPEAT);
	}
}

public Action Timer_P2PRed(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		P2PXBeam(client, 0);
	}
}

public Action Timer_P2PGreen(Handle timer, int client)
{
	if (IsValidClient(client))
	{
		P2PXBeam(client, 1);
	}
}

static void P2PXBeam(int client, int arg)
{
	float Origin0[3];
	float Origin1[3];
	float Origin2[3];
	float Origin3[3];
	
	Origin0[0] = (gF_MeasurePos[client][arg][0] + 8.0);
	Origin0[1] = (gF_MeasurePos[client][arg][1] + 8.0);
	Origin0[2] = gF_MeasurePos[client][arg][2];
	
	Origin1[0] = (gF_MeasurePos[client][arg][0] - 8.0);
	Origin1[1] = (gF_MeasurePos[client][arg][1] - 8.0);
	Origin1[2] = gF_MeasurePos[client][arg][2];
	
	Origin2[0] = (gF_MeasurePos[client][arg][0] + 8.0);
	Origin2[1] = (gF_MeasurePos[client][arg][1] - 8.0);
	Origin2[2] = gF_MeasurePos[client][arg][2];
	
	Origin3[0] = (gF_MeasurePos[client][arg][0] - 8.0);
	Origin3[1] = (gF_MeasurePos[client][arg][1] + 8.0);
	Origin3[2] = gF_MeasurePos[client][arg][2];
	
	if (arg == 0)
	{
		MeasureBeam(client, Origin0, Origin1, 0.97, 2.0, 0, 255, 0);
		MeasureBeam(client, Origin2, Origin3, 0.97, 2.0, 0, 255, 0);
	}
	else
	{
		MeasureBeam(client, Origin0, Origin1, 0.97, 2.0, 255, 0, 0);
		MeasureBeam(client, Origin2, Origin3, 0.97, 2.0, 255, 0, 0);
	}
}

static void MeasureBeam(int client, float vecStart[3], float vecEnd[3], float life, float width, int r, int g, int b)
{
	TE_Start("BeamPoints");
	TE_WriteNum("m_nModelIndex", gI_GlowSprite);
	TE_WriteNum("m_nHaloIndex", 0);
	TE_WriteNum("m_nStartFrame", 0);
	TE_WriteNum("m_nFrameRate", 0);
	TE_WriteFloat("m_fLife", life);
	TE_WriteFloat("m_fWidth", width);
	TE_WriteFloat("m_fEndWidth", width);
	TE_WriteNum("m_nFadeLength", 0);
	TE_WriteFloat("m_fAmplitude", 0.0);
	TE_WriteNum("m_nSpeed", 0);
	TE_WriteNum("r", r);
	TE_WriteNum("g", g);
	TE_WriteNum("b", b);
	TE_WriteNum("a", 255);
	TE_WriteNum("m_nFlags", 0);
	TE_WriteVector("m_vecStartPoint", vecStart);
	TE_WriteVector("m_vecEndPoint", vecEnd);
	TE_SendToClient(client);
}

static void MeasureResetPos(int client)
{
	if (gH_P2PRed[client] != INVALID_HANDLE)
	{
		CloseHandle(gH_P2PRed[client]);
		gH_P2PRed[client] = INVALID_HANDLE;
	}
	if (gH_P2PGreen[client] != INVALID_HANDLE)
	{
		CloseHandle(gH_P2PGreen[client]);
		gH_P2PGreen[client] = INVALID_HANDLE;
	}
	gB_MeasurePosSet[client][0] = false;
	gB_MeasurePosSet[client][1] = false;
	
	gF_MeasurePos[client][0][0] = 0.0; //This is stupid.
	gF_MeasurePos[client][0][1] = 0.0;
	gF_MeasurePos[client][0][2] = 0.0;
	gF_MeasurePos[client][1][0] = 0.0;
	gF_MeasurePos[client][1][1] = 0.0;
	gF_MeasurePos[client][1][2] = 0.0;
}

public bool TraceFilterPlayers(int entity, int contentsMask)
{
	return (entity > MaxClients);
} 