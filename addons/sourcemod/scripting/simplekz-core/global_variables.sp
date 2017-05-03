/*	
	Global Variables
	
	Declarations of the many, many global variables.
*/


/* General */
KZPlayer g_KZPlayer[MAXPLAYERS + 1];
bool gB_LateLoad;
bool gB_BaseComm;
bool gB_SKZLocalRanks;
bool gB_ClientIsSetUp[MAXPLAYERS + 1];

// Styles translation phrases for chat messages (respective to KZStyle enum)
char gC_StylePhrases[view_as<int>(KZStyle)][] = 
{
	"Style - Standard", 
	"Style - Legacy", 
	"Style - Competitive"
};


/* Forwards */
Handle gH_OnClientSetup;
Handle gH_OnTimerStart;
Handle gH_OnTimerEnd;
Handle gH_OnTimerForceStop;
Handle gH_OnPause;
Handle gH_OnResume;
Handle gH_OnTeleportToStart;
Handle gH_OnMakeCheckpoint;
Handle gH_OnTeleportToCheckpoint;
Handle gH_OnUndoTeleport;
Handle gH_OnChangeOption;


/* simplekz-core ConVars */
ConVar gCV_ChatProcessing;
ConVar gCV_ConnectionMessages;
ConVar gCV_DefaultStyle;
ConVar gCV_PlayerModelT;
ConVar gCV_PlayerModelCT;


/* CS:GO ConVars */
ConVar gCV_Accelerate;
ConVar gCV_Friction;
ConVar gCV_AirAccelerate;
ConVar gCV_LadderScaleSpeed;
ConVar gCV_Gravity;

ConVar gCV_EnableBunnyhopping;
ConVar gCV_AutoBunnyhopping;

ConVar gCV_StaminaMax;
ConVar gCV_StaminaLandCost;
ConVar gCV_StaminaJumpCost;
ConVar gCV_StaminaRecoveryRate;

ConVar gCV_MaxVelocity;
ConVar gCV_MaxSpeed;
ConVar gCV_WaterAccelerate;
ConVar gCV_TimeBetweenDucks;
ConVar gCV_AccelerateUseWeaponSpeed;

ConVar gCV_DisableImmunityAlpha;
ConVar gCV_FullAlltalk;


/* Timer */
bool gB_TimerRunning[MAXPLAYERS + 1];
float gF_CurrentTime[MAXPLAYERS + 1];
bool gB_HasStartedThisMap[MAXPLAYERS + 1];
int gI_LastCourseStarted[MAXPLAYERS + 1];
bool gB_HasEndedThisMap[MAXPLAYERS + 1];


/* Pause */
bool gB_Paused[MAXPLAYERS + 1];
float gF_LastPauseTime[MAXPLAYERS + 1];
bool gB_HasPausedInThisRun[MAXPLAYERS + 1];
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

// Showing keys option phrases
char gC_ShowingKeysOptionPhrases[view_as<int>(KZShowingKeys)][] = 
{
	"Options Menu - Spectating", 
	"Options Menu - Always", 
	"Options Menu - Disabled"
};

// Timer text option menu phrases
char gC_TimerTextOptionPhrases[view_as<int>(KZTimerText)][] = 
{
	"Options Menu - Disabled", 
	"Options Menu - Info Panel", 
	"Options Menu - Bottom", 
	"Options Menu - Top"
	
};

// Speed text option menu phrases
char gC_SpeedTextOptionPhrases[view_as<int>(KZSpeedText)][] = 
{
	"Options Menu - Disabled", 
	"Options Menu - Info Panel", 
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
KZErrorSounds g_ErrorSounds[MAXPLAYERS + 1];
KZTimerText g_TimerText[MAXPLAYERS + 1];
KZSpeedText g_SpeedText[MAXPLAYERS + 1];


/* Button Press */
float gF_VirtualStartButtonOrigin[MAXPLAYERS + 1][3];
float gF_VirtualEndButtonOrigin[MAXPLAYERS + 1][3];
int gI_VirtualStartButtonCourse[MAXPLAYERS + 1];
int gI_VirtualEndButtonCourse[MAXPLAYERS + 1];


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
bool gB_LastTeleportInBhopTrigger[MAXPLAYERS + 1];
float gF_UndoOrigin[MAXPLAYERS + 1][3];
float gF_UndoAngle[MAXPLAYERS + 1][3];


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


/* Style */
int gI_OldButtons[MAXPLAYERS + 1];
float gF_PreVelMod[MAXPLAYERS + 1];
float gF_PreVelModLastChange[MAXPLAYERS + 1];
int gI_PreTickCounter[MAXPLAYERS + 1];
bool gB_SKZHitPerf[MAXPLAYERS + 1];
float gF_SKZTakeoffSpeed[MAXPLAYERS + 1];

// Weapon class names - Knife/USP first followed by other pistols faster average linear search
char gC_WeaponNames[][] = 
{
	"weapon_knife", "weapon_hkp2000", "weapon_deagle", "weapon_elite", "weapon_fiveseven", 
	"weapon_glock", "weapon_p250", "weapon_tec9", "weapon_decoy", "weapon_flashbang", 
	"weapon_hegrenade", "weapon_incgrenade", "weapon_molotov", "weapon_smokegrenade", "weapon_taser", 
	"weapon_ak47", "weapon_aug", "weapon_awp", "weapon_bizon", "weapon_famas", 
	"weapon_g3sg1", "weapon_galilar", "weapon_m249", "weapon_m4a1", "weapon_mac10", 
	"weapon_mag7", "weapon_mp7", "weapon_mp9", "weapon_negev", "weapon_nova", 
	"weapon_p90", "weapon_sawedoff", "weapon_scar20", "weapon_sg556", "weapon_ssg08", 
	"weapon_ump45", "weapon_xm1014"
};

// Max movement speed of weapons (respective to gC_WeaponNames)
int gI_WeaponRunSpeeds[sizeof(gC_WeaponNames)] = 
{
	250, 240, 230, 240, 240, 
	240, 240, 240, 245, 245, 
	245, 245, 245, 245, 220, 
	215, 220, 200, 240, 220, 
	215, 215, 195, 225, 240, 
	225, 220, 240, 150, 220, 
	230, 210, 215, 210, 230, 
	230, 215
};

// Style settings (respective to KZStyleSetting enumeration)
float gF_StyleSettings[view_as<int>(KZStyle)][/*view_as<int>(KZStyleSetting)*/] = 
{
	{ 6.5, 5.2, 100.0, 1.0, 3500.0, 800.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 320.0, 10.0, 0.4, 0.0 }, 
	{ 6.5, 5.0, 100.0, 1.0, 3500.0, 800.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 320.0, 10.0, 0.4, 0.0 }, 
	{ 5.5, 5.2, 12.0, 0.78, 3500.0, 800.0, 0.0, 0.0, 80.0, 0.05, 0.08, 60.0, 320.0, 10.0, 0.4, 1.0 }
};


/* Pistol */
// Pistol Entity Names (entity name | alias | team that buys it) 
// (respective to the KZPistol enumeration)
char gC_Pistols[view_as<int>(KZPistol)][][] = 
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