// https://forums.alliedmods.net/showthread.php?t=239492

#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define L4D2 Nightmarish Common
#define PLUGIN_VERSION "1.1.0-thhp"
#define DEBUG 0

ConVar cvarType1Damage;

bool isMapRunning = false;
Handle PluginStartTimer = null;

public Plugin myinfo = 
{
    name = "[L4D2] Nightmarish Common",
    author = "Mortiegama",
    description = "Empowering the lowest of the infected to make sure that hordes become your worst nightmare.",
    version = PLUGIN_VERSION,
    url = ""
}

	//AtomicStryker - Damage Mod (SDK Hooks):
	//https://forums.alliedmods.net/showthread.php?p=1184761
	
	//Bacardi - Cleaning up code:
	//https://forums.alliedmods.net/showpost.php?p=2128853&postcount=4

public void OnPluginStart()
{
	CreateConVar("l4d_ncm_version", PLUGIN_VERSION, "Nightmarish Common Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	cvarType1Damage= CreateConVar("l4d_ncm_type1damage", "2.0", "Type 1: Multiplier for damage done to the Survivors (Def 2.0)", 0, true, 0.0, false, _);

	AutoExecConfig(true, "plugin.L4D2.NightmarishCommon");
	PluginStartTimer = CreateTimer(3.0, OnPluginStart_Delayed);
}

public Action OnPluginStart_Delayed(Handle timer)
{
	if(PluginStartTimer != null)
	{
 		KillTimer(PluginStartTimer);
		PluginStartTimer = null;
	}
	return Plugin_Stop;
}

public void OnMapStart()
{
	isMapRunning = true;
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage_Survivor);
}

public Action OnTakeDamage_Survivor(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (!isMapRunning || IsServerProcessing() == false) return Plugin_Stop;

	if (IsValidCommon(attacker))
	{
		if (IsValidClient(victim) && GetClientTeam(victim) == 2)
		{
			float damagemod = GetConVarFloat(cvarType1Damage);
			if (FloatCompare(damagemod, 1.0) != 0) { damage = damage * damagemod; }
		}
	}

	return Plugin_Changed;
}

public void OnMapEnd()
{
	isMapRunning = false;
}

int IsValidCommon(int common)
{
	if(common > MaxClients && IsValidEdict(common) && IsValidEntity(common))
	{
		char classname[32];
		GetEdictClassname(common, classname, sizeof(classname));
		if(StrEqual(classname, "infected")) { return true; }
	}
	return false;
}

public int IsValidClient(int client)
{
	if (client <= 0) return false;
	if (client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	if (!IsPlayerAlive(client)) return false;
	return true;
}