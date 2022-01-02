#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>

ConVar
	g_hLungeInterval,
	g_hFastPounceProximity,
	g_hPounceVerticalAngle,
	g_hPounceAngleMean,
	g_hPounceAngleStd,
	g_hStraightPounceProximity,
	g_hAimOffsetSensitivityHunter,
	g_hWallDetectionDistance;

float
	g_fLungeInterval,
	g_fFastPounceProximity,
	g_fPounceVerticalAngle,
	g_fPounceAngleMean,
	g_fPounceAngleStd,
	g_fStraightPounceProximity,
	g_fWallDetectionDistance;

int
	g_iAimOffsetSensitivityHunter;

bool
	g_bCanLunge[MAXPLAYERS + 1],
	g_bHasQueuedLunge[MAXPLAYERS + 1];

public Plugin myinfo =
{
	name = "AI HUNTER",
	author = "Breezy",
	description = "Improves the AI behaviour of special infected",
	version = "1.0",
	url = "github.com/breezyplease"
};

public void OnPluginStart()
{	
	g_hFastPounceProximity = CreateConVar("ai_fast_pounce_proximity", "1000.0", "At what distance to start pouncing fast");
	g_hPounceVerticalAngle = CreateConVar("ai_pounce_vertical_angle", "12.0", "Vertical angle to which AI hunter pounces will be restricted");
	g_hPounceAngleMean = CreateConVar("ai_pounce_angle_mean", "10.0", "Mean angle produced by Gaussian RNG");
	g_hPounceAngleStd = CreateConVar("ai_pounce_angle_std", "20.0", "One standard deviation from mean as produced by Gaussian RNG");
	g_hStraightPounceProximity = CreateConVar("ai_straight_pounce_proximity", "350.0", "Distance to nearest survivor at which hunter will consider pouncing straight");
	g_hAimOffsetSensitivityHunter = CreateConVar("ai_aim_offset_sensitivity_hunter", "180", "If the hunter has a target, it will not straight pounce if the target's aim on the horizontal axis is within this radius");
	g_hWallDetectionDistance = CreateConVar("ai_wall_detection_distance", "20.0", "How far in front of himself infected bot will check for a wall. Use '-1' to disable feature");

	FindConVar("hunter_pounce_ready_range").SetFloat(2000.0);
	FindConVar("hunter_pounce_max_loft_angle").SetFloat(0.0);
	FindConVar("hunter_leap_away_give_up_range").SetFloat(0.0);
	FindConVar("z_pounce_silence_range").SetFloat(999999.0);
	FindConVar("hunter_committed_attack_range").SetFloat(999999.0);
	FindConVar("z_pounce_crouch_delay").SetFloat(0.1);
	//FindConVar("z_pounce_damage_interrupt").SetInt(150);
	g_hLungeInterval = FindConVar("z_lunge_interval");

	g_hLungeInterval.AddChangeHook(vConVarChanged);
	g_hFastPounceProximity.AddChangeHook(vConVarChanged);
	g_hPounceVerticalAngle.AddChangeHook(vConVarChanged);
	g_hPounceAngleMean.AddChangeHook(vConVarChanged);
	g_hPounceAngleStd.AddChangeHook(vConVarChanged);
	g_hStraightPounceProximity.AddChangeHook(vConVarChanged);
	g_hAimOffsetSensitivityHunter.AddChangeHook(vConVarChanged);
	g_hWallDetectionDistance.AddChangeHook(vConVarChanged);
	
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("ability_use", Event_AbilityUse);
}

public void OnPluginEnd()
{
	FindConVar("hunter_committed_attack_range").RestoreDefault();
	FindConVar("hunter_pounce_ready_range").RestoreDefault();
	FindConVar("hunter_leap_away_give_up_range").RestoreDefault();
	FindConVar("hunter_pounce_max_loft_angle").RestoreDefault();
	FindConVar("z_pounce_crouch_delay").RestoreDefault();
	//FindConVar("z_pounce_damage_interrupt").RestoreDefault();
}

public void OnConfigsExecuted()
{
	vGetCvars();
}

void vConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	vGetCvars();
}

void vGetCvars()
{
	g_fLungeInterval = g_hLungeInterval.FloatValue;
	g_fFastPounceProximity = g_hFastPounceProximity.FloatValue;
	g_fPounceVerticalAngle = g_hPounceVerticalAngle.FloatValue;
	g_fPounceAngleMean = g_hPounceAngleMean.FloatValue;
	g_fPounceAngleStd = g_hPounceAngleStd.FloatValue;
	g_fStraightPounceProximity = g_hStraightPounceProximity.FloatValue;
	g_iAimOffsetSensitivityHunter = g_hAimOffsetSensitivityHunter.IntValue;
	g_fWallDetectionDistance = g_hWallDetectionDistance.FloatValue;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	g_bHasQueuedLunge[client] = false;
	g_bCanLunge[client] = true;
}

void Event_AbilityUse(Event event, const char[] name, bool dontBroadcast)
{
	char sAbility[16];
	event.GetString("ability", sAbility, sizeof(sAbility));
	if(strcmp(sAbility, "ability_lunge") == 0)
		vHunter_OnPounce(GetClientOfUserId(event.GetInt("userid")));
}

public Action OnPlayerRunCmd(int client, int &buttons)
{
	if(!IsFakeClient(client) || GetClientTeam(client) != 3 || !IsPlayerAlive(client) || GetEntProp(client, Prop_Send, "m_zombieClass") != 3 || GetEntProp(client, Prop_Send, "m_isGhost") == 1)
		return Plugin_Continue;

	buttons &= ~IN_ATTACK2;
	
	static int flags;
	flags = GetEntityFlags(client);
	if(flags & FL_DUCKING != 0 && flags & FL_ONGROUND != 0 && GetEntProp(client, Prop_Send, "m_hasVisibleThreats"))
	{
		static float vPos[3];
		GetClientAbsOrigin(client, vPos);
		if(fNearestSurvivorDistance(client, vPos) < g_fFastPounceProximity)
		{
			buttons &= ~IN_ATTACK;			
			if(!g_bHasQueuedLunge[client])
			{
				g_bCanLunge[client] = false;
				g_bHasQueuedLunge[client] = true;
				CreateTimer(g_fLungeInterval, Timer_LungeInterval, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			}
			else if(g_bCanLunge[client])
			{
				buttons |= IN_ATTACK;
				g_bHasQueuedLunge[client] = false;
			}
		}	
	}

	return Plugin_Changed;
}

float fNearestSurvivorDistance(int client, const float vOrigin[3])
{
	static int i;
	static int iNum;
	static float vTarget[3];
	static float fDists[MAXPLAYERS + 1];

	iNum = 0;

	for(i = 1; i <= MaxClients; i++)
	{
		if(i != client && IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			GetClientAbsOrigin(i, vTarget);
			fDists[iNum++] = GetVectorDistance(vOrigin, vTarget);
		}
	}

	if(iNum == 0)
		return -1.0;

	SortFloats(fDists, iNum, Sort_Ascending);
	return fDists[0];
}

Action Timer_LungeInterval(Handle timer, int client)
{
	g_bCanLunge[GetClientOfUserId(client)] = true;
}

bool bIsBotHunter(int client)
{
	return client && IsClientInGame(client) && IsFakeClient(client) && GetClientTeam(client) == 3 && GetEntProp(client, Prop_Send, "m_zombieClass") == 3;
}

void vHunter_OnPounce(int client)
{	
	if(!bIsBotHunter(client))
		return;

	static int iLunge;
	iLunge = GetEntPropEnt(client, Prop_Send, "m_customAbility");			

	static float vPos[3];
	
	GetClientAbsOrigin(client, vPos);
	if(g_fWallDetectionDistance > 0.0 && bHitWall(client, vPos))
	{
		if(GetRandomInt(0, 1))
			vAngleLunge(iLunge, 45.0);
		else
			vAngleLunge(iLunge, 315.0);
	}
	else
	{	
		if(bIsTargetWatchingAttacker(client, g_iAimOffsetSensitivityHunter) && fNearestSurvivorDistance(client, vPos) > g_fStraightPounceProximity)
		{			
			static float fPounceAngle;
			fPounceAngle = fGaussianRNG(g_fPounceAngleMean, g_fPounceAngleStd);
			vAngleLunge(iLunge, fPounceAngle);
			vLimitLungeVerticality(iLunge);				
		}	
	}
}

bool bHitWall(int client, float vStart[3])
{
	static float vEnd[3];
	GetClientEyeAngles(client, vEnd);
	GetAngleVectors(vEnd, vEnd, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(vEnd, vEnd);
	ScaleVector(vEnd, g_fWallDetectionDistance);
	AddVectors(vStart, vEnd, vEnd);

	static float vMins[3];
	static float vMaxs[3];
	GetClientMins(client, vMins);
	GetClientMaxs(client, vMaxs);
	
	vMins[0] += 3.0;
	vMins[1] += 3.0;
	vMaxs[0] -= 3.0;
	vMaxs[1] -= 3.0;
	vMins[2] *= 0.5;
	vMaxs[2] *= 0.5;

	vStart[2] += 5.0;
	vEnd[2] += 5.0;

	static Handle hTrace;
	hTrace = TR_TraceHullFilterEx(vStart, vEnd, vMins, vMaxs, MASK_PLAYERSOLID_BRUSHONLY, bTraceEntityFilter);

	static bool bDidHit;
	bDidHit = false;

	if(hTrace != null)
	{
		bDidHit = TR_DidHit(hTrace);
		delete hTrace;
	}
	
	return bDidHit;
}

bool bTraceEntityFilter(int entity, int contentsMask)
{
	if(entity <= MaxClients)
		return false;

	static char sClassName[9];
	GetEntityClassname(entity, sClassName, sizeof(sClassName));
	return (sClassName[0] != 'i' || sClassName[0] != 'w' || strcmp(sClassName, "infected") != 0 || strcmp(sClassName, "witch") != 0);
}

bool bIsTargetWatchingAttacker(int iAttacker, int iOffsetThreshold)
{
	static int iTarget;
	static bool bIsWatching;

	bIsWatching = true;
	iTarget = GetClientAimTarget(iAttacker);
	if(bIsAliveSurvivor(iTarget))
	{
		static int iAimOffset;
		iAimOffset = RoundToNearest(fGetPlayerAimOffset(iTarget, iAttacker));
		if(iAimOffset <= iOffsetThreshold)
			bIsWatching = true;
		else 
			bIsWatching = false;
	}
	return bIsWatching;
}

float fGetPlayerAimOffset(int iAttacker, int iTarget)
{
	static float vAim[3];
	static float vTarget[3];
	static float vAttacker[3];

	GetClientEyeAngles(iAttacker, vAim);
	vAim[0] = vAim[2] = 0.0;
	GetAngleVectors(vAim, vAim, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(vAim, vAim);
	
	GetClientAbsOrigin(iTarget, vTarget);
	GetClientAbsOrigin(iAttacker, vAttacker);
	vAttacker[2] = vTarget[2] = 0.0;
	MakeVectorFromPoints(vAttacker, vTarget, vAttacker);
	NormalizeVector(vAttacker, vAttacker);
	
	return RadToDeg(ArcCosine(GetVectorDotProduct(vAim, vAttacker)));
}

void vAngleLunge(int iLunge, float fTurnAngle)
{	
	static float vLunge[3];
	GetEntPropVector(iLunge, Prop_Send, "m_queuedLunge", vLunge);

	fTurnAngle = DegToRad(fTurnAngle);

	static float vForcedLunge[3];
	vForcedLunge[0] = vLunge[0] * Cosine(fTurnAngle) - vLunge[1] * Sine(fTurnAngle);
	vForcedLunge[1] = vLunge[0] * Sine(fTurnAngle) + vLunge[1] * Cosine(fTurnAngle);
	vForcedLunge[2] = vLunge[2];
	
	SetEntPropVector(iLunge, Prop_Send, "m_queuedLunge", vForcedLunge);	
}

void vLimitLungeVerticality(int iLunge)
{
	static float vLunge[3];
	GetEntPropVector(iLunge, Prop_Send, "m_queuedLunge", vLunge);

	static float fVertAngle;
	fVertAngle = DegToRad(g_fPounceVerticalAngle);	

	static float vFlatLunge[3];
	vFlatLunge[1] = vLunge[1] * Cosine(fVertAngle) - vLunge[2] * Sine(fVertAngle);
	vFlatLunge[2] = vLunge[1] * Sine(fVertAngle) + vLunge[2] * Cosine(fVertAngle);
	vFlatLunge[0] = vLunge[0] * Cosine(fVertAngle) + vLunge[2] * Sine(fVertAngle);
	vFlatLunge[2] = vLunge[0] * -Sine(fVertAngle) + vLunge[2] * Cosine(fVertAngle);
	
	SetEntPropVector(iLunge, Prop_Send, "m_queuedLunge", vFlatLunge);
}

/** 
 * Thanks to Newteee:
 * Random number generator fit to a bellcurve. Function to generate Gaussian Random Number fit to a bellcurve with a specified mean and std
 * Uses Polar Form of the Box-Muller transformation
*/
float fGaussianRNG(float fMean, float fStd)
{
	static float fX1;
	static float fX2;
	static float fW;

	do
	{
		fX1 = 2.0 * GetRandomFloat(0.0, 1.0) - 1.0;
		fX2 = 2.0 * GetRandomFloat(0.0, 1.0) - 1.0;
		fW = Pow(fX1, 2.0) + Pow(fX2, 2.0);
	}while(fW >= 1.0);
	
	static float e = 2.71828;
	fW = SquareRoot(-2.0 * (Logarithm(fW, e) / fW));

	static float fY1;
	static float fY2;
	fY1 = fX1 * fW;
	fY2 = fX2 * fW;

	static float fZ1;
	static float fZ2;
	fZ1 = fY1 * fStd + fMean;
	fZ2 = fY2 * fStd - fMean;

	return GetRandomFloat(0.0, 1.0) < 0.5 ? fZ1 : fZ2;
}

bool bIsAliveSurvivor(int client)
{
	return bIsValidClient(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client);
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client);
}