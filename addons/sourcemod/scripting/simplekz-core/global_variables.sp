/*	
	Global Variables
	
	Declarations of the many, many global variables.
*/


/* General */
KZPlayer g_KZPlayer[MAXPLAYERS + 1];
bool gB_LateLoad;

// Styles translation phrases for chat messages (respective to KZStyle enum)
char gC_StylePhrases[view_as<int>(KZStyle)][] = 
{
	"Style - Standard", 
	"Style - Legacy"
};


/* Forwards */
Handle gH_OnChangeOption;
Handle gH_OnPerfectBunnyhop;
Handle gH_OnTimerStart;
Handle gH_OnTimerEnd;
Handle gH_OnTimerForceStop;
Handle gH_OnPlayerPause;
Handle gH_OnPlayerResume;


/* ConVars */
ConVar gCV_DisableImmunityAlpha;
ConVar gCV_FullAlltalk;
ConVar gCV_ChatProcessing;
ConVar gCV_DefaultStyle;
ConVar gCV_PlayerModelT;
ConVar gCV_PlayerModelCT;


/* Timer */
bool gB_TimerRunning[MAXPLAYERS + 1];
float gF_CurrentTime[MAXPLAYERS + 1];
int gI_CurrentCourse[MAXPLAYERS + 1];
int gI_LastCourseStarted[MAXPLAYERS + 1];
int gI_LastCourseEnded[MAXPLAYERS + 1];


/* Pause */
bool gB_Paused[MAXPLAYERS + 1];
float gF_LastResumeTime[MAXPLAYERS + 1];
bool gB_HasResumedInThisRun[MAXPLAYERS + 1];


/* Wasted Time */
float gF_LastCheckpointTime[MAXPLAYERS + 1];
float gF_LastGoCheckTime[MAXPLAYERS + 1];
float gF_LastGoCheckWastedTime[MAXPLAYERS + 1];
float gF_LastUndoTime[MAXPLAYERS + 1];
float gF_LastUndoWastedTime[MAXPLAYERS + 1];
float gF_LastTeleportToStartTime[MAXPLAYERS + 1];
float gF_LastTeleportToStartWastedTime[MAXPLAYERS + 1];
float gF_WastedTime[MAXPLAYERS + 1];


/* Map API */
bool gB_CurrentMapIsKZPro;
Regex gRE_BonusStartButton;
Regex gRE_BonusEndButton;
int gI_JustTouchedTrigMulti[MAXPLAYERS + 1];


/* Menus */
Menu gH_MeasureMenu[MAXPLAYERS + 1];
Menu g_PistolMenu[MAXPLAYERS + 1];
Menu g_StyleMenu[MAXPLAYERS + 1];
Menu g_TPMenu[MAXPLAYERS + 1];
bool gB_TPMenuIsShowing[MAXPLAYERS + 1];
Menu g_OptionsMenu[MAXPLAYERS + 1];
bool gB_CameFromOptionsMenu[MAXPLAYERS + 1];

// Timer text option menu phrases
char gC_TimerTextOptionPhrases[][] = 
{
	"Options Menu - Disabled", 
	"Options Menu - Top", 
	"Options Menu - Bottom"
};


/* Options */
KZStyle g_Style[MAXPLAYERS + 1];
KZShowingTPMenu g_ShowingTPMenu[MAXPLAYERS + 1];
KZShowingInfoPanel g_ShowingInfoPanel[MAXPLAYERS + 1];
KZShowingKeys g_ShowingKeys[MAXPLAYERS + 1];
KZShowingPlayers g_ShowingPlayers[MAXPLAYERS + 1];
KZShowingWeapon g_ShowingWeapon[MAXPLAYERS + 1];
KZAutoRestart g_AutoRestart[MAXPLAYERS + 1];
KZSlayOnEnd g_SlayOnEnd[MAXPLAYERS + 1];
KZPistol g_Pistol[MAXPLAYERS + 1];
KZCheckpointMessages g_CheckpointMessages[MAXPLAYERS + 1];
KZCheckpointSounds g_CheckpointSounds[MAXPLAYERS + 1];
KZTeleportSounds g_TeleportSounds[MAXPLAYERS + 1];
KZTimerText g_TimerText[MAXPLAYERS + 1];


/* Button Press */
int gI_OldButtons[MAXPLAYERS + 1];
bool gB_HasStartedThisMap[MAXPLAYERS + 1];
bool gB_HasEndedThisMap[MAXPLAYERS + 1];
float gF_StartButtonOrigin[MAXPLAYERS + 1][3];
float gF_EndButtonOrigin[MAXPLAYERS + 1][3];


/* Player Model */
char gC_PlayerModelT[256];
char gC_PlayerModelCT[256];


/* Teleports (and Checkpoints) */
float gF_StartOrigin[MAXPLAYERS + 1][3];
float gF_StartAngles[MAXPLAYERS + 1][3];
int gI_CheckpointCount[MAXPLAYERS + 1];
int gI_TeleportsUsed[MAXPLAYERS + 1];
float gF_CheckpointOrigin[MAXPLAYERS + 1][3];
float gF_CheckpointAngles[MAXPLAYERS + 1][3];
bool gB_LastTeleportOnGround[MAXPLAYERS + 1];
float gF_UndoOrigin[MAXPLAYERS + 1][3];
float gF_UndoAngle[MAXPLAYERS + 1][3];
float gF_PauseAngles[MAXPLAYERS + 1][3];


/* Position Restoration */
bool gB_HasSavedPosition[MAXPLAYERS + 1];
float gF_SavedOrigin[MAXPLAYERS + 1][3];
float gF_SavedAngles[MAXPLAYERS + 1][3];


/* Measure */
int gI_GlowSprite;
bool gB_MeasurePosSet[MAXPLAYERS + 1][2];
float gF_MeasurePos[MAXPLAYERS + 1][2][3];
Handle gH_P2PRed[MAXPLAYERS + 1];
Handle gH_P2PGreen[MAXPLAYERS + 1];


/* Block Radio */
char gC_RadioCommands[][] = 
{
	"coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", 
	"fallback", "sticktog", "getinpos", "stormfront", "report", "roger", "enemyspot", 
	"needbackup", "sectorclear", "inposition", "reportingin", "getout", "negative", 
	"enemydown", "compliment", "thanks", "cheer"
};


/* Movement Tweak */
float gF_PrestrafeVelocityModifier[MAXPLAYERS + 1];
bool gB_HitPerf[MAXPLAYERS + 1];

char gC_WeaponNames[][] = 
{
	"weapon_ak47", "weapon_aug", "weapon_awp", "weapon_bizon", "weapon_deagle", 
	"weapon_decoy", "weapon_elite", "weapon_famas", "weapon_fiveseven", "weapon_flashbang", 
	"weapon_g3sg1", "weapon_galilar", "weapon_glock", "weapon_hegrenade", "weapon_hkp2000", 
	"weapon_incgrenade", "weapon_knife", "weapon_m249", "weapon_m4a1", "weapon_mac10", 
	"weapon_mag7", "weapon_molotov", "weapon_mp7", "weapon_mp9", "weapon_negev", 
	"weapon_nova", "weapon_p250", "weapon_p90", "weapon_sawedoff", "weapon_scar20", 
	"weapon_sg556", "weapon_smokegrenade", "weapon_ssg08", "weapon_taser", "weapon_tec9", 
	"weapon_ump45", "weapon_xm1014"
};

// Max movement speed of weapons (respective to gC_WeaponNames)
int gI_WeaponRunSpeeds[sizeof(gC_WeaponNames)] = 
{
	215, 220, 200, 240, 230, 
	245, 240, 220, 240, 245, 
	215, 215, 240, 245, 240, 
	245, 250, 195, 225, 240, 
	225, 245, 220, 240, 195, 
	220, 240, 230, 210, 215, 
	210, 245, 230, 240, 240, 
	230, 215
};


/* Pistol */
// Pistol Entity Names (entity name | alias | team that buys it) 
// Respective to the KZPistol enumeration. */
char gC_Pistols[][][] = 
{
	{ "weapon_hkp2000", "P2000 / USP-S", "CT" }, 
	{ "weapon_glock", "Glock-18", "T" }, 
	{ "weapon_p250", "P250", "EITHER" }, 
	{ "weapon_elite", "Dual Berettas", "EITHER" }, 
	{ "weapon_deagle", "Deagle", "EITHER" }, 
	{ "weapon_cz75a", "CZ75-Auto", "EITHER" }, 
	{ "weapon_fiveseven", "Five-SeveN", "CT" }, 
	{ "weapon_tec9", "Tec-9", "T" }
}; 