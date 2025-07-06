/*=======================================================================================
	Plugin Info:

*	Name	:	Survivor Chat Select
*	Author	:	mi123645
*	Descrp	:	This plugin allows players to change their character or model
*	Link	:	https://forums.alliedmods.net/showthread.php?t=107121

*   Edits by:   DeathChaos25
*	Descrp	:	Compatibility with fakezoey plugin added
*   Link    :   https://forums.alliedmods.net/showthread.php?t=258189

*   Edits by:   Cookie
*	Descrp	:	Support for cookies added

*   Edits by:   Merudo
*	Descrp	:	Fixed bugs with misplaced weapon models after selecting a survivor & added admin menu support (!sm_admin)
*   Link    :   "https://forums.alliedmods.net/showthread.php?p=2399150#post2399150"

========================================================================================*/
#pragma semicolon 1
#define PLUGIN_VERSION "1.6.4"
#define PLUGIN_NAME "Survivor Chat Character Select Menu"
#define PLUGIN_PREFIX "\x01[\x04SCS\x01]"

#include <sourcemod>
#include <sdktools>
#include <clientprefs>
#include <adminmenu>

#pragma newdecls required

TopMenu hTopMenu;

ConVar convarSpawn;
ConVar convarAdminsOnly;
ConVar convarCookies;

#define MODEL_BILL "models/survivors/survivor_namvet.mdl"
#define MODEL_FRANCIS "models/survivors/survivor_biker.mdl"
#define MODEL_LOUIS "models/survivors/survivor_manager.mdl"
#define MODEL_ZOEY "models/survivors/survivor_teenangst.mdl"

#define MODEL_NICK "models/survivors/survivor_gambler.mdl"
#define MODEL_ROCHELLE "models/survivors/survivor_producer.mdl"
#define MODEL_COACH "models/survivors/survivor_coach.mdl"
#define MODEL_ELLIS "models/survivors/survivor_mechanic.mdl"

#define NICK 0
#define ROCHELLE 1
#define COACH 2
#define ELLIS 3
#define BILL 4
#define ZOEY 5
#define FRANCIS 6
#define LOUIS 7

int g_iSelectedClient[MAXPLAYERS+1];
Handle g_hClientID;
Handle g_hClientModel;

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = "DeatChaos25, Mi123456, & Merudo modded by Huckster",
	description = "Select a survivor character by typing their name or csm in to chat.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showpost.php?p=2816381&postcount=905"
}

public void OnPluginStart()  
{  
	g_hClientID = RegClientCookie("Player_Character", "Player's default character ID.", CookieAccess_Protected);
	g_hClientModel = RegClientCookie("Player_Model", "Player's default character model.", CookieAccess_Protected);

	RegConsoleCmd("sm_zoey", ZoeyUse, "Changes your survivor character into Zoey");  
	RegConsoleCmd("sm_nick", NickUse, "Changes your survivor character into Nick");  
	RegConsoleCmd("sm_ellis", EllisUse, "Changes your survivor character into Ellis");  
	RegConsoleCmd("sm_coach", CoachUse, "Changes your survivor character into Coach");  
	RegConsoleCmd("sm_rochelle", RochelleUse, "Changes your survivor character into Rochelle");  
	RegConsoleCmd("sm_bill", BillUse, "Changes your survivor character into Bill");  
	RegConsoleCmd("sm_francis", BikerUse, "Changes your survivor character into Francis");  
	RegConsoleCmd("sm_louis", LouisUse, "Changes your survivor character into Louis");  
	
	RegConsoleCmd("sm_z", ZoeyUse, "Changes your survivor character into Zoey");
	RegConsoleCmd("sm_n", NickUse, "Changes your survivor character into Nick");
	RegConsoleCmd("sm_e", EllisUse, "Changes your survivor character into Ellis");
	RegConsoleCmd("sm_c", CoachUse, "Changes your survivor character into Coach");
	RegConsoleCmd("sm_r", RochelleUse, "Changes your survivor character into Rochelle");
	RegConsoleCmd("sm_b", BillUse, "Changes your survivor character into Bill");
	RegConsoleCmd("sm_f", BikerUse, "Changes your survivor character into Francis");
	RegConsoleCmd("sm_l", LouisUse, "Changes your survivor character into Louis");
	
	RegAdminCmd("sm_scs", InitiateMenuAdmin, ADMFLAG_ROOT, "Brings up a menu to change a client's characters");
	RegConsoleCmd("sm_csm", ShowMenu, "Brings up a menu to select a client's character");
	
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("player_bot_replace", Event_PlayerToBot, EventHookMode_Post);

	convarAdminsOnly = CreateConVar("sc_csm_admins_only", "0", "Changes access to the sm_csm and sm_scs command. 0:Everyone, 1=Admins only.", 0, true, 0.0, true, 1.0);			
	convarSpawn	= CreateConVar("sc_csm_botschange", "1", "Change new bots to least prevalent survivor? 1:Enable, 0:Disable", 0, true, 0.0, true, 1.0);
	convarCookies = CreateConVar("sc_csm_cookies", "1", "Store a player's survivor? 1:Enable, 0:Disable", 0, true, 0.0, true, 1.0);
	
	AutoExecConfig(true, "survivor_chat_csm");
	
	/* Account for late loading */
	TopMenu topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != null))
	{
		OnAdminMenuReady(topmenu);
	}
}

// *********************************************************************************
// Character Select functions
// *********************************************************************************	

public Action NickUse(int client, int args)
{
	SurvivorChange(client, NICK, MODEL_NICK, "Nick");
	return Plugin_Continue;	
}
public Action EllisUse(int client, int args)  
{
	SurvivorChange(client, ELLIS, MODEL_ELLIS, "Ellis");
	return Plugin_Continue;	
}

public Action CoachUse(int client, int args)
{
	SurvivorChange(client, COACH, MODEL_COACH, "Coach");
	return Plugin_Continue;	
}

public Action RochelleUse(int client, int args)  
{  
	SurvivorChange(client, ROCHELLE, MODEL_ROCHELLE, "Rochelle");	
	return Plugin_Continue;
} 
 
public Action BillUse(int client, int args)
{
	SurvivorChange(client, BILL, MODEL_BILL, "Bill");
	return Plugin_Continue;
}

public Action ZoeyUse(int client, int args)
{
	SurvivorChange(client, ZOEY, MODEL_ZOEY, "Zoey");
	return Plugin_Continue;	
}
 
public Action BikerUse(int client, int args)  
{  
	SurvivorChange(client, FRANCIS, MODEL_FRANCIS, "Francis");	
	return Plugin_Continue;
} 
 
public Action LouisUse(int client, int args)
{
	SurvivorChange(client, LOUIS, MODEL_LOUIS, "Louis");
	return Plugin_Continue;
}

// Function changes the survivor
void SurvivorChange(int client, int prop, char[] model,  char[] name, bool save = true)
{
	if(!IsSurvivor(client))
	{
		PrintToChat(client, "You must be a hunter to use this command!");
		return;
	}

	if (IsFakeClient(client))  // if bot, change name
	{
		SetClientInfo(client, "name", name);
	}
	
	SetEntProp(client, Prop_Send, "m_survivorCharacter", prop);
	SetEntityModel(client, model);
	ReEquipWeapons(client);
	
	if (convarCookies.BoolValue && save)
	{
		char sID[2];
		IntToString(prop, sID, 2);
		SetClientCookie(client, g_hClientID, sID);
		SetClientCookie(client, g_hClientModel, model);
		PrintToChat(client, "%s \x03Your \x04default \x01character is now set to \x03%s\x01.", PLUGIN_PREFIX, name);
	}
}
	
public void OnMapStart()
{
	SetConVarInt(FindConVar("precache_all_survivors"), 1);
	
	if (!IsModelPrecached("models/survivors/survivor_teenangst.mdl"))
		PrecacheModel("models/survivors/survivor_teenangst.mdl", false); 
	if (!IsModelPrecached("models/survivors/survivor_biker.mdl"))     
		PrecacheModel("models/survivors/survivor_biker.mdl", false); 
	if (!IsModelPrecached("models/survivors/survivor_manager.mdl"))
		PrecacheModel("models/survivors/survivor_manager.mdl", false); 
	if (!IsModelPrecached("models/survivors/survivor_namvet.mdl"))
		PrecacheModel("models/survivors/survivor_namvet.mdl", false); 
	if (!IsModelPrecached("models/survivors/survivor_gambler.mdl"))
		PrecacheModel("models/survivors/survivor_gambler.mdl", false); 
	if (!IsModelPrecached("models/survivors/survivor_coach.mdl"))
		PrecacheModel("models/survivors/survivor_coach.mdl", false); 
	if (!IsModelPrecached("models/survivors/survivor_mechanic.mdl"))
		PrecacheModel("models/survivors/survivor_mechanic.mdl", false); 
	if (!IsModelPrecached("models/survivors/survivor_producer.mdl"))
		PrecacheModel("models/survivors/survivor_producer.mdl", false); 
}

bool IsSurvivor(int client)
{
	if(client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2)
	{
		return true;
	}
	return false;
}

// *********************************************************************************
// Character Select menu
// *********************************************************************************

/* This Admin Menu was taken from csm, all credits go to Mi123645 */ 
public Action InitiateMenuAdmin(int client, int args)  
{ 
	if (client == 0)  
	{ 
		ReplyToCommand(client, "Menu is in-game only.");
	} 
	
	char name[MAX_NAME_LENGTH]; char number[10]; 
	
	Handle menu = CreateMenu(ShowMenu2);
	SetMenuTitle(menu, "Select a client:");
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		if (GetClientTeam(i) != 2) continue;
		//if (i == client) continue;
		
		Format(name, sizeof(name), "%N", i);
		Format(number, sizeof(number), "%i", i);
		AddMenuItem(menu, number, name);
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Continue;
} 

public int ShowMenu2(Handle menu, MenuAction action, int client, int param2)  
{ 
	switch (action)  
	{ 
		case MenuAction_Select:  
		{ 
			char number[4]; 
			GetMenuItem(menu, param2, number, sizeof(number)); 
			
			g_iSelectedClient[client] = StringToInt(number);

			ShowMenuAdmin(client, 0);
		}
		case MenuAction_Cancel: 
		{ 
			if (param2 == MenuCancel_ExitBack && hTopMenu != INVALID_HANDLE)
			{
				DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_End:  
		{ 
			CloseHandle(menu); 
		}
	}
	return 0;	
} 

public Action ShowMenuAdmin(int client, int args)  
{ 
	char sMenuEntry[8]; 
	
	Handle menu = CreateMenu(CharMenuAdmin); 
	SetMenuTitle(menu, "Choose a character:"); 
	
	IntToString(NICK, sMenuEntry, sizeof(sMenuEntry)); 
	AddMenuItem(menu, sMenuEntry, "Nick"); 
	IntToString(ROCHELLE, sMenuEntry, sizeof(sMenuEntry)); 
	AddMenuItem(menu, sMenuEntry, "Rochelle"); 
	IntToString(COACH, sMenuEntry, sizeof(sMenuEntry)); 
	AddMenuItem(menu, sMenuEntry, "Coach"); 
	IntToString(ELLIS, sMenuEntry, sizeof(sMenuEntry)); 
	AddMenuItem(menu, sMenuEntry, "Ellis"); 
	
	IntToString(BILL, sMenuEntry, sizeof(sMenuEntry)); 
	AddMenuItem(menu, sMenuEntry, "Bill");     
	IntToString(ZOEY, sMenuEntry, sizeof(sMenuEntry)); 
	AddMenuItem(menu, sMenuEntry, "Zoey"); 
	IntToString(FRANCIS, sMenuEntry, sizeof(sMenuEntry)); 
	AddMenuItem(menu, sMenuEntry, "Francis"); 
	IntToString(LOUIS, sMenuEntry, sizeof(sMenuEntry)); 
	AddMenuItem(menu, sMenuEntry, "Louis"); 
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Continue;
} 

public int CharMenuAdmin(Handle menu, MenuAction action, int client, int param2)  
{ 
	switch (action)  
	{ 
		case MenuAction_Select:  
		{ 
			char item[8]; 
			GetMenuItem(menu, param2, item, sizeof(item)); 
			
			switch(StringToInt(item))
			{
				case NICK: {SurvivorChange(g_iSelectedClient[client], NICK, MODEL_NICK, "Nick",false);}
				case ROCHELLE: {SurvivorChange(g_iSelectedClient[client], ROCHELLE, MODEL_ROCHELLE,	"Rochelle",false);}
				case COACH: {SurvivorChange(g_iSelectedClient[client], COACH, MODEL_COACH, "Coach",false);}
				case ELLIS: {SurvivorChange(g_iSelectedClient[client], ELLIS, MODEL_ELLIS, "Ellis",false);}
				case BILL: {SurvivorChange(g_iSelectedClient[client], BILL, MODEL_BILL, "Bill",false);}
				case ZOEY: {SurvivorChange(g_iSelectedClient[client], ZOEY, MODEL_ZOEY, "Zoey",false);}
				case FRANCIS: {SurvivorChange(g_iSelectedClient[client], FRANCIS, MODEL_FRANCIS, "Francis",false);}
				case LOUIS: {SurvivorChange(g_iSelectedClient[client], LOUIS, MODEL_LOUIS, "Louis", false);}
			}
		}
		case MenuAction_Cancel: {} 
		case MenuAction_End: {CloseHandle(menu);} 
	}
	return 0;
} 

public Action ShowMenu(int client, int args)
{
	if (client == 0)
	{
		ReplyToCommand(client, "[SCS] Character Select Menu is in-game only.");
	}
	if (GetClientTeam(client) != 2)
	{
		ReplyToCommand(client, "[SCS] Character Select Menu is only available to survivors.");
	}
	if (!IsPlayerAlive(client)) 
	{
		ReplyToCommand(client, "[SCS] You must be alive to use the Character Select Menu!");
	}
	if (GetUserFlagBits(client) == 0 && convarAdminsOnly.BoolValue)
	{
		ReplyToCommand(client, "[SCS] Character Select Menu is only available to admins.");
	}
	char sMenuEntry[8];
	
	Handle menu = CreateMenu(CharMenu);
	SetMenuTitle(menu, "Choose a character:");
	
	IntToString(NICK, sMenuEntry, sizeof(sMenuEntry));
	AddMenuItem(menu, sMenuEntry, "Nick");
	IntToString(ROCHELLE, sMenuEntry, sizeof(sMenuEntry));
	AddMenuItem(menu, sMenuEntry, "Rochelle");
	IntToString(COACH, sMenuEntry, sizeof(sMenuEntry));
	AddMenuItem(menu, sMenuEntry, "Coach");
	IntToString(ELLIS, sMenuEntry, sizeof(sMenuEntry));
	AddMenuItem(menu, sMenuEntry, "Ellis");
	
	IntToString(BILL, sMenuEntry, sizeof(sMenuEntry));
	AddMenuItem(menu, sMenuEntry, "Bill");
	IntToString(ZOEY, sMenuEntry, sizeof(sMenuEntry));
	AddMenuItem(menu, sMenuEntry, "Zoey");
	IntToString(FRANCIS, sMenuEntry, sizeof(sMenuEntry));
	AddMenuItem(menu, sMenuEntry, "Francis");
	IntToString(LOUIS, sMenuEntry, sizeof(sMenuEntry));
	AddMenuItem(menu, sMenuEntry, "Louis");
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Continue;
}

public int CharMenu(Handle menu, MenuAction action, int param1, int param2) 
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char item[8];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			switch(StringToInt(item))
			{
				case NICK: {NickUse(param1, NICK);}
				case ROCHELLE: {RochelleUse(param1, ROCHELLE);}
				case COACH: {CoachUse(param1, COACH);}
				case ELLIS: {EllisUse(param1, ELLIS);}
				case BILL: {BillUse(param1, BILL);}
				case ZOEY: {ZoeyUse(param1, ZOEY);}
				case FRANCIS: {BikerUse(param1, FRANCIS);}
				case LOUIS: {LouisUse(param1, LOUIS);}
			}
		}

		case MenuAction_Cancel: {} 
		case MenuAction_End: {CloseHandle(menu);}
	}
	return 0;
}

// *********************************************************************************
// Admin Menu entry
// *********************************************************************************

//// Added for admin menu
public void OnAdminMenuReady(Handle aTopMenu)
{
	TopMenu topmenu = TopMenu.FromHandle(aTopMenu);

	/* Block us from being called twice */
	if (topmenu == hTopMenu)
	{
		return;
	}
	
	/* Save the Handle */
	hTopMenu = topmenu;
	
	// Find player's menu ...
	TopMenuObject player_commands = hTopMenu.FindCategory(ADMINMENU_PLAYERCOMMANDS);

	if (player_commands != INVALID_TOPMENUOBJECT)
	{
		AddToTopMenu (hTopMenu, "Select player's survivor", TopMenuObject_Item, InitiateMenuAdmin2, player_commands, "Select player's survivor", ADMFLAG_GENERIC);
	}
}

public void InitiateMenuAdmin2(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int client, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Select player's survivor", "", client);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		InitiateMenuAdmin(client, 0);
	}
}
// *********************************************************************************
// Cookie loading
// *********************************************************************************

public void Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(client && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 2 && convarCookies.BoolValue)
	{
		CreateTimer(0.3, Timer_LoadCookie, GetClientUserId(client));
	}
}

public Action Timer_LoadCookie(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	char sID[2], sModel[PLATFORM_MAX_PATH];

	if(client && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 2 && convarCookies.BoolValue && AreClientCookiesCached(client))
	{
		GetClientCookie(client, g_hClientID, sID, sizeof(sID));
		GetClientCookie(client, g_hClientModel, sModel, sizeof(sModel));
	
		if(strlen(sID) && strlen(sModel) && IsModelPrecached(sModel))
		{
			SetEntProp(client, Prop_Send, "m_survivorCharacter", StringToInt(sID)); 
			SetEntityModel(client, sModel); 
		}
		else if (client && IsClientInGame(client))
		{
			PrintToChat(client, "%s Couldn't load your default character. Type \x04!csm \x01to choose your \x03default \x01character.", PLUGIN_PREFIX);
		}
	}
	return Plugin_Handled;
}

// *********************************************************************************
// Bots spawn as survivor with fewest clones
// *********************************************************************************

char survivor_models[8][] = {MODEL_NICK, MODEL_ROCHELLE, MODEL_COACH, MODEL_ELLIS, MODEL_BILL, MODEL_ZOEY, MODEL_FRANCIS, MODEL_LOUIS};
char survivor_commands[8][] = {"sm_nick", "sm_rochelle", "sm_coach", "sm_ellis", "sm_bill", "sm_zoey", "sm_francis", "sm_louis"};

public Action Event_PlayerToBot(Handle event, char[] name, bool dontBroadcast)
{
	int player = GetClientOfUserId(GetEventInt(event, "player"));
	int bot = GetClientOfUserId(GetEventInt(event, "bot")); 

	// If bot replace bot (due to bot creation)
	if(player > 0 && GetClientTeam(player)== 2 && IsFakeClient(player) && convarSpawn.BoolValue)
	{
		FakeClientCommand(bot, survivor_commands[GetFewestSurvivor(bot)]);
	}
	return Plugin_Handled;
}

int GetFewestSurvivor(int clientignore = -1)
{
	char Model[128];
	int Survivors[8];

	for (int client=1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && GetClientTeam(client) == 2 && client != clientignore)
		{
			GetClientModel(client, Model, 128);
			for (int s = 0; s < 8; s++)
			{
				if (StrEqual(Model, survivor_models[s])) Survivors[s] = Survivors[s] + 1;
			}
		}
	}
	
	int minS = 1;
	int min = 9999;
	
	for (int s = 0; s < 8; s++)
	{
		if (Survivors[s] < min)
		{
			minS = s;
			min = Survivors[s];
		}
	}
	return minS;
}

// *********************************************************************************
// Reequip weapons functions
// *********************************************************************************

enum
{
	iClip = 0,
	iAmmo,
	iUpgrade,
	iUpAmmo,
};

// ------------------------------------------------------------------
// Save weapon details, remove weapon, create new weapons with exact same properties
// Needed otherwise there will be animation bugs after switching characters due to different weapon mount points
// ------------------------------------------------------------------
void ReEquipWeapons(int client)
{
	int i_Weapon = GetEntDataEnt2(client, FindSendPropInfo("CBasePlayer", "m_hActiveWeapon"));
	
	// Don't bother with the weapon fix if dead or unarmed
	if (!IsPlayerAlive(client) || !IsValidEdict(i_Weapon) || !IsValidEntity(i_Weapon)) return;

	int iSlot0 = GetPlayerWeaponSlot(client, 0);
	int iSlot1 = GetPlayerWeaponSlot(client, 1);
	int iSlot2 = GetPlayerWeaponSlot(client, 2);
	int iSlot3 = GetPlayerWeaponSlot(client, 3);
	int iSlot4 = GetPlayerWeaponSlot(client, 4);
	
	char sWeapon[64];
	GetClientWeapon(client, sWeapon, sizeof(sWeapon));
	
	//  Protection against grenade duplication exploit (throwing grenade then quickly changing character)
	if (iSlot2 > 0 && strcmp(sWeapon, "weapon_vomitjar", true) && strcmp(sWeapon, "weapon_pipe_bomb", true) && strcmp(sWeapon, "weapon_molotov", true))
	{
		GetEdictClassname(iSlot2, sWeapon, 64);
		DeletePlayerSlot(client, iSlot2);
		CheatCommand(client, "give", sWeapon, "");
	}
	if (iSlot3 > 0)
	{
		GetEdictClassname(iSlot3, sWeapon, 64);
		DeletePlayerSlot(client, iSlot3);
		CheatCommand(client, "give", sWeapon, "");
	}
	if (iSlot4 > 0)
	{
		GetEdictClassname(iSlot4, sWeapon, 64);
		DeletePlayerSlot(client, iSlot4);
		CheatCommand(client, "give", sWeapon, "");
	}
	if (iSlot1 > 0) ReEquipSlot1(client, iSlot1);
	if (iSlot0 > 0) ReEquipSlot0(client, iSlot0);
}

// --------------------------------------
// Extra work to save/load ammo details
// --------------------------------------
void ReEquipSlot0(int client, int iSlot0)
{
	int iWeapon0[4];
	char sWeapon[64];
	
	GetEdictClassname(iSlot0, sWeapon, 64);
		
	iWeapon0[iClip] = GetEntProp(iSlot0, Prop_Send, "m_iClip1", 4);
	iWeapon0[iAmmo] = GetClientAmmo(client, sWeapon);
	iWeapon0[iUpgrade] = GetEntProp(iSlot0, Prop_Send, "m_upgradeBitVec", 4);
	iWeapon0[iUpAmmo] = GetEntProp(iSlot0, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", 4);
		
	DeletePlayerSlot(client, iSlot0);
	CheatCommand(client, "give", sWeapon, "");
		
	iSlot0 = GetPlayerWeaponSlot(client, 0);
	if (iSlot0 > 0)
	{
		SetEntProp(iSlot0, Prop_Send, "m_iClip1", iWeapon0[iClip], 4);
		SetClientAmmo(client, sWeapon, iWeapon0[iAmmo]);
		SetEntProp(iSlot0, Prop_Send, "m_upgradeBitVec", iWeapon0[iUpgrade], 4);
		SetEntProp(iSlot0, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", iWeapon0[iUpAmmo], 4);
	}
}

// --------------------------------------
// Extra work to identify melee weapon, & save/load ammo details
// --------------------------------------
void ReEquipSlot1(int client, int iSlot1)
{
	char className[64];
	char modelName[64];
	
	char sWeapon[64];
	sWeapon[0] = '\0';
	int Ammo = -1;
	int iSlot = -1;
	
	GetEdictClassname(iSlot1, className, sizeof(className));
	
	// Try to find weapon name without models
	if (!strcmp(className, "weapon_melee", true))
	{	
		GetEntPropString(iSlot1, Prop_Data, "m_strMapSetScriptName", sWeapon, 64);
	}
	else if (strcmp(className, "weapon_pistol", true)) 
	{
		GetEdictClassname(iSlot1, sWeapon, 64);
	}
	
	// IF model checking is required
	if (sWeapon[0] == '\0')
	{
		GetEntPropString(iSlot1, Prop_Data, "m_ModelName", modelName, sizeof(modelName));

		if (StrContains(modelName, "v_pistolA.mdl", true) != -1) sWeapon = "weapon_pistol";
		else if (StrContains(modelName, "v_dual_pistolA.mdl", true) != -1) sWeapon = "dual_pistol";
		else if (StrContains(modelName, "v_desert_eagle.mdl", true) != -1) sWeapon = "weapon_pistol_magnum";
		else if (StrContains(modelName, "v_bat.mdl", true) != -1) sWeapon = "baseball_bat";
		else if (StrContains(modelName, "v_cricket_bat.mdl", true) != -1) sWeapon = "cricket_bat";
		else if (StrContains(modelName, "v_crowbar.mdl", true) != -1) sWeapon = "crowbar";
		else if (StrContains(modelName, "v_fireaxe.mdl", true) != -1) sWeapon = "fireaxe";
		else if (StrContains(modelName, "v_katana.mdl", true) != -1) sWeapon = "katana";
		else if (StrContains(modelName, "v_golfclub.mdl", true) != -1) sWeapon = "golfclub";
		else if (StrContains(modelName, "v_machete.mdl", true) != -1) sWeapon = "machete";
		else if (StrContains(modelName, "v_tonfa.mdl", true) != -1) sWeapon = "tonfa";
		else if (StrContains(modelName, "v_electric_guitar.mdl", true) != -1) sWeapon = "electric_guitar";
		else if (StrContains(modelName, "v_frying_pan.mdl", true) != -1) sWeapon = "frying_pan";
		else if (StrContains(modelName, "v_knife_t.mdl", true) != -1) sWeapon = "knife";
		else if (StrContains(modelName, "v_chainsaw.mdl", true) != -1) sWeapon = "weapon_chainsaw";
		else if (StrContains(modelName, "v_riotshield.mdl", true) != -1) sWeapon = "alliance_shield";
		else if (StrContains(modelName, "v_fubar.mdl", true) != -1) sWeapon = "fubar";
		else if (StrContains(modelName, "v_paintrain.mdl", true) != -1) sWeapon = "nail_board";
		else if (StrContains(modelName, "v_sledgehammer.mdl", true) != -1) sWeapon = "sledgehammer";
		else if (StrContains(modelName, "v_shovel.mdl", true) != -1) sWeapon = "shovel";
		else if (StrContains(modelName, "v_pitchfork.mdl", true) != -1) sWeapon = "pitchfork";
	}

	// IF Weapon properly identified, save then delete then reequip
	if (sWeapon[0] != '\0')
	{
		// IF Weapon uses ammo, save it
		if (!strcmp(sWeapon, "dual_pistol", true) || !strcmp(sWeapon, "weapon_pistol", true)
		|| !strcmp(sWeapon, "weapon_pistol_magnum", true) || !strcmp(sWeapon, "weapon_chainsaw", true))
		{
			Ammo = GetEntProp(iSlot1, Prop_Send, "m_iClip1", 4);
		}
	
		DeletePlayerSlot(client, iSlot1);
		
		// Reequip weapon (special code for dual pistols)
		if (!strcmp(sWeapon, "dual_pistol", true))
		{
			 CheatCommand(client, "give", "weapon_pistol", "");
			 CheatCommand(client, "give", "weapon_pistol", "");
		}
		else CheatCommand(client, "give", sWeapon, "");
		
		// Restore ammo
		if (Ammo >= 0)
		{
			iSlot = GetPlayerWeaponSlot(client, 1);
			if (iSlot > 0) SetEntProp(iSlot, Prop_Send, "m_iClip1", Ammo, 4);
		}
	}
}

void DeletePlayerSlot(int client, int weapon)
{
	if(RemovePlayerItem(client, weapon)) AcceptEntityInput(weapon, "Kill");
}

void CheatCommand(int client, const char[] command, const char[] argument1, const char[] argument2)
{
	int userFlags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_GENERIC);
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s %s", command, argument1, argument2);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, userFlags);
}

// *********************************************************************************
// Get/Set ammo
// *********************************************************************************

int GetClientAmmo(int client, char[] weapon)
{
	int weapon_offset = GetWeaponOffset(weapon);
	int iAmmoOffset = FindSendPropInfo("CTerrorPlayer", "m_iAmmo");
	
	return weapon_offset > 0 ? GetEntData(client, iAmmoOffset+weapon_offset) : 0;
}

void SetClientAmmo(int client, char[] weapon, int count)
{
	int weapon_offset = GetWeaponOffset(weapon);
	int iAmmoOffset = FindSendPropInfo("CTerrorPlayer", "m_iAmmo");
	
	if (weapon_offset > 0) SetEntData(client, iAmmoOffset+weapon_offset, count);
}

int GetWeaponOffset(char[] weapon)
{
	int weapon_offset;

	if (StrEqual(weapon, "weapon_rifle") || StrEqual(weapon, "weapon_rifle_sg552") || StrEqual(weapon, "weapon_rifle_desert") || StrEqual(weapon, "weapon_rifle_ak47"))
	{
		weapon_offset = 12;
	}
	else if (StrEqual(weapon, "weapon_rifle_m60"))
	{
		weapon_offset = 24;
	}
	else if (StrEqual(weapon, "weapon_smg") || StrEqual(weapon, "weapon_smg_silenced") || StrEqual(weapon, "weapon_smg_mp5"))
	{
		weapon_offset = 20;
	}
	else if (StrEqual(weapon, "weapon_pumpshotgun") || StrEqual(weapon, "weapon_shotgun_chrome"))
	{
		weapon_offset = 28;
	}
	else if (StrEqual(weapon, "weapon_autoshotgun") || StrEqual(weapon, "weapon_shotgun_spas"))
	{
		weapon_offset = 32;
	}
	else if (StrEqual(weapon, "weapon_hunting_rifle"))
	{
		weapon_offset = 36;
	}
	else if (StrEqual(weapon, "weapon_sniper_scout") || StrEqual(weapon, "weapon_sniper_military") || StrEqual(weapon, "weapon_sniper_awp"))
	{
		weapon_offset = 40;
	}
	else if (StrEqual(weapon, "weapon_grenade_launcher"))
	{
		weapon_offset = 68;
	}

	return weapon_offset;
}