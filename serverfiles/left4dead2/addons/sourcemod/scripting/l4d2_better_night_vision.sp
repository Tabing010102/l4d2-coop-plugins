#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

// Double tap check delay
#define DOUBLE_TAP_DELAY 0.3

// Global handles for ConVars
ConVar g_hCvarColor;
ConVar g_hCvarDistance;
ConVar g_hCvarRadius;
ConVar g_hCvarHeight;
ConVar g_hCvarBrightness;

// Player data
float g_fLastImpulseTime[MAXPLAYERS + 1];
int g_iLightEntity[MAXPLAYERS + 1];

public Plugin myinfo =
{
    name = "L4D2 Better Night Vision",
    author = "HandSonic",
    description = "Toggle Infected Vision by double tapping F (hold SHIFT to add overhead light)",
    version = "1.0.5",
    url = ""
};

public void OnPluginStart()
{
    // --- Create ConVars ---
    // Default Color: "200 200 200 200" (RGBA values).
    g_hCvarColor = CreateConVar("l4d2_bnv_color", "200 200 200 200", "The color of the night vision light (R G B A).");
    
    // Default Distance: 1000.0 (Far visibility)
    g_hCvarDistance = CreateConVar("l4d2_bnv_distance", "1000.0", "Max distance the light can reach.");
    
    // Default Radius: 32.0 (Wide floodlight)
    g_hCvarRadius = CreateConVar("l4d2_bnv_radius", "32.0", "Width of the light beam (Spotlight Radius).");
    
    // Default Height: 70.0 (Above head)
    g_hCvarHeight = CreateConVar("l4d2_bnv_height", "70.0", "Z-Offset above the player origin.");
    
    // Default Brightness: 1.0
    g_hCvarBrightness = CreateConVar("l4d2_bnv_brightness", "1.0", "Brightness intensity of the light.");

    // Auto-generate config file in cfg/sourcemod/l4d2_better_night_vision.cfg
    AutoExecConfig(true, "l4d2_better_night_vision");

    // Cleanup on reload
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            RemoveNightVision(i);
            g_fLastImpulseTime[i] = 0.0;
        }
    }
}

public void OnClientConnected(int client)
{
    g_fLastImpulseTime[client] = 0.0;
    g_iLightEntity[client] = 0;
}

public void OnClientDisconnect(int client)
{
    RemoveNightVision(client);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
    if (!IsValidSurvivor(client)) return Plugin_Continue;

    if (impulse == 100)
    {
        float fCurrentTime = GetEngineTime();
        float fTimeDiff = fCurrentTime - g_fLastImpulseTime[client];

        if (fTimeDiff <= DOUBLE_TAP_DELAY)
        {
            // Double tap detected
            // Holding SHIFT (walk key, "+speed" -> IN_SPEED) = add overhead light
            bool bWithLight = (buttons & IN_SPEED) != 0;
            ToggleNightVision(client, bWithLight);
            g_fLastImpulseTime[client] = 0.0;
            impulse = 0; // Block flashlight
            return Plugin_Changed;
        }
        else
        {
            // First tap
            g_fLastImpulseTime[client] = fCurrentTime;
            return Plugin_Continue;
        }
    }
    return Plugin_Continue;
}

void ToggleNightVision(int client, bool bWithLight)
{
    // Night Vision is ON if the light entity exists OR the native effect is enabled.
    // (Default/no-SHIFT mode has no light entity, so the light alone can't be used as the state.)
    bool bLightOn = (g_iLightEntity[client] != 0 && IsValidEntity(g_iLightEntity[client]));
    if (bLightOn || GetEntProp(client, Prop_Send, "m_bNightVisionOn") != 0)
    {
        // --- Turn OFF --- (either mode, SHIFT or not)
        RemoveNightVision(client);
        if (bLightOn)
        {
            PrintHintText(client, "Night Vision Plus OFF");
        }
        else
        {
            PrintHintText(client, "Night Vision OFF");
        }
    }
    else
    {
        // --- Turn ON ---
        
        // Enable Native Night Vision Effect
        // This netprop (m_bNightVisionOn) adds the visual noise and slight brightness
        SetEntProp(client, Prop_Send, "m_bNightVisionOn", 1);
        
        if (bWithLight)
        {
            // SHIFT held: Create Dynamic Light (Illumination)
            CreatePlayerLight(client);
            PrintHintText(client, "Night Vision Plus ON");
        }
        else
        {
            // No SHIFT (default): native effect only, no overhead light
            PrintHintText(client, "Night Vision ON");
        }
    }
}

void CreatePlayerLight(int client)
{
    // Ensure cleanup first
    if (g_iLightEntity[client] != 0 && IsValidEntity(g_iLightEntity[client]))
    {
        AcceptEntityInput(g_iLightEntity[client], "Kill");
    }

    int light = CreateEntityByName("light_dynamic");
    if (light != -1)
    {
        // Retrieve values from ConVars
        char sColor[64];
        g_hCvarColor.GetString(sColor, sizeof(sColor));
        float fDistance = g_hCvarDistance.FloatValue;
        float fRadius = g_hCvarRadius.FloatValue;
        float fBrightness = g_hCvarBrightness.FloatValue;
        float fHeight = g_hCvarHeight.FloatValue;
        char sBrightness[16];
        FloatToString(fBrightness, sBrightness, sizeof(sBrightness));

        // Set Light Properties
        DispatchKeyValue(light, "_light", sColor);
        DispatchKeyValue(light, "brightness", sBrightness);
        DispatchKeyValueFloat(light, "spotlight_radius", fRadius);
        DispatchKeyValueFloat(light, "distance", fDistance);
        DispatchKeyValue(light, "style", "0");
        DispatchSpawn(light);

        // Position Logic (Above Head)
        float pos[3];
        GetClientAbsOrigin(client, pos);
        pos[2] += fHeight; 
        TeleportEntity(light, pos, NULL_VECTOR, NULL_VECTOR);

        // Attach logic
        SetVariantString("!activator");
        AcceptEntityInput(light, "SetParent", client);
        
        // Set Owner for SDKHook
        SetEntPropEnt(light, Prop_Send, "m_hOwnerEntity", client);
        SDKHook(light, SDKHook_SetTransmit, Hook_OnTransmitLight);
        
        g_iLightEntity[client] = light;
    }
}

void RemoveNightVision(int client)
{
    // 1. Disable Native Overlay
    if (IsClientInGame(client))
    {
        SetEntProp(client, Prop_Send, "m_bNightVisionOn", 0);
    }

    // 2. Kill Light Entity
    if (g_iLightEntity[client] != 0 && IsValidEntity(g_iLightEntity[client]))
    {
        AcceptEntityInput(g_iLightEntity[client], "Kill");
    }
    g_iLightEntity[client] = 0;
}

// SDKHook to ensure only the owner sees the light
public Action Hook_OnTransmitLight(int entity, int client)
{
    int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
    if (owner == client) 
    {
        return Plugin_Continue;
    }
    return Plugin_Handled;
}

bool IsValidSurvivor(int client)
{
    return (client > 0 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2);
}