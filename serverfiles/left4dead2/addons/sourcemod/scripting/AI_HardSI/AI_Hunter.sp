#pragma semicolon 1

#include <sdktools>
#define DEBUG_HUNTER_AIM 0
#define DEBUG_HUNTER_RNG 0
#define DEBUG_HUNTER_ANGLE 0

#define POSITIVE 0
#define NEGATIVE 1
#define X 0
#define Y 1
#define Z 2

// Vanilla Cvars
Handle hCvarHunterCommittedAttackRange;
Handle hCvarHunterPounceReadyRange;
Handle hCvarHunterLeapAwayGiveUpRange; 
Handle hCvarHunterPounceMaxLoftAngle; 
Handle hCvarLungeInterval; 
// Gaussian random number generator for pounce angles
Handle hCvarPounceAngleMean;
Handle hCvarPounceAngleStd; // standard deviation
// Pounce vertical angle
Handle hCvarPounceVerticalAngle;
// Distance at which hunter begins pouncing fast
Handle hCvarFastPounceProximity; 
// Distance at which hunter considers pouncing straight
Handle hCvarStraightPounceProximity;
// Aim offset(degrees) sensitivity
Handle hCvarAimOffsetSensitivityHunter;
// Wall detection
Handle hCvarWallDetectionDistance;
// Handle hCvarPwDistance;

bool bHasQueuedLunge[MAXPLAYERS];
bool bCanLunge[MAXPLAYERS];

public void Hunter_OnModuleStart() {
	// Set aggressive hunter cvars		
	hCvarHunterCommittedAttackRange = FindConVar("hunter_committed_attack_range"); // range at which hunter is committed to attack	
	hCvarHunterPounceReadyRange = FindConVar("hunter_pounce_ready_range"); // range at which hunter prepares pounce	
	hCvarHunterLeapAwayGiveUpRange = FindConVar("hunter_leap_away_give_up_range"); // range at which shooting a non-committed hunter will cause it to leap away	
	hCvarLungeInterval = FindConVar("z_lunge_interval"); // cooldown on lunges
	hCvarHunterPounceMaxLoftAngle = FindConVar("hunter_pounce_max_loft_angle"); // maximum vertical angle hunters can pounce
	SetConVarInt(hCvarHunterCommittedAttackRange, 10000);
	SetConVarInt(hCvarHunterPounceReadyRange, 500);
	SetConVarInt(hCvarHunterLeapAwayGiveUpRange, 0); 
	SetConVarInt(hCvarHunterPounceMaxLoftAngle, 0);
	
	// proximity to nearest survivor when plugin starts to force hunters to lunge ASAP
	hCvarFastPounceProximity = CreateConVar("ai_fast_pounce_proximity", "1000", "At what distance to start pouncing fast");
	
	// Verticality
	hCvarPounceVerticalAngle = CreateConVar("ai_pounce_vertical_angle", "7", "Vertical angle to which AI hunter pounces will be restricted");
	
	// Pounce angle
	hCvarPounceAngleMean = CreateConVar( "ai_pounce_angle_mean", "10", "Mean angle produced by Gaussian RNG" );
	hCvarPounceAngleStd = CreateConVar( "ai_pounce_angle_std", "20", "One standard deviation from mean as produced by Gaussian RNG" );
	hCvarStraightPounceProximity = CreateConVar( "ai_straight_pounce_proximity", "200", "Distance to nearest survivor at which hunter will consider pouncing straight");
	
	// Aim offset sensitivity
	hCvarAimOffsetSensitivityHunter = CreateConVar("ai_aim_offset_sensitivity_hunter",
									"30",
									"If the hunter has a target, it will not straight pounce if the target's aim on the horizontal axis is within this radius",
									FCVAR_NONE,
									true, 0.0, true, 179.0 );
	// How far in front of hunter to check for a wall
	hCvarWallDetectionDistance = CreateConVar("ai_wall_detection_distance", "-1", "How far in front of himself infected bot will check for a wall. Use '-1' to disable feature");
	
	// 扣人的距离
	//hCvarPwDistance = CreateConVar("ai_hunter_pw_distance", "100", "扣人的距离");
	
	SetConVarInt(FindConVar("z_pounce_damage_interrupt"), 150);
}

public void Hunter_OnModuleEnd() {
	// Reset aggressive hunter cvars
	ResetConVar(hCvarHunterCommittedAttackRange);
	ResetConVar(hCvarHunterPounceReadyRange);
	ResetConVar(hCvarHunterLeapAwayGiveUpRange);
	ResetConVar(hCvarHunterPounceMaxLoftAngle);
	
	ResetConVar(FindConVar("z_pounce_damage_interrupt"));
}

public Action Hunter_OnSpawn(int botHunter) {
	bHasQueuedLunge[botHunter] = false;
	bCanLunge[botHunter] = true;
	return Plugin_Handled;
}

/***********************************************************************************************************************************************************************************

																		FAST POUNCING

***********************************************************************************************************************************************************************************/

public Action Hunter_OnPlayerRunCmd(int hunter, int& buttons, int& impulse, float vel[3], float eyeAngles[3], int& weapon) {
	buttons &= ~IN_ATTACK2; // block scratches
	int flags = GetEntityFlags(hunter);
	//Proceed if the hunter is in a position to pounce
	float hunterPos[3];
	GetClientAbsOrigin(hunter, hunterPos);	
	int iSurvivorsProximity = GetSurvivorProximity(hunterPos);
	if( (flags & FL_DUCKING) && (flags & FL_ONGROUND) ) {		
		bool bHasLOS = view_as<bool>( GetEntProp(hunter, Prop_Send, "m_hasVisibleThreats") ); // Line of sight to survivors		
		// Start fast pouncing if close enough to survivors
		if( bHasLOS ) {
			if( iSurvivorsProximity < GetConVarInt(hCvarFastPounceProximity) ) {
				buttons &= ~IN_ATTACK; // release attack button; precautionary					
				// Queue a pounce/lunge
				if (!bHasQueuedLunge[hunter]) { // check lunge interval timer has not already been initiated
					bCanLunge[hunter] = false;
					bHasQueuedLunge[hunter] = true; // block duplicate lunge interval timers
					CreateTimer(GetConVarFloat(hCvarLungeInterval), Timer_LungeInterval, hunter, TIMER_FLAG_NO_MAPCHANGE);
				} else if (bCanLunge[hunter]) { // end of lunge interval; lunge!
					buttons |= IN_ATTACK;
					bHasQueuedLunge[hunter] = false; // unblock lunge interval timer
				} // else lunge queue is being processed
			}
		}	 
	}
	
	// if ( ( flags & FL_ONGROUND ) && ( iSurvivorsProximity < GetConVarInt(hCvarPwDistance) ) ) {
		// buttons &= ~IN_DUCK;
		// buttons &= ~IN_ATTACK;
	// }
	
	// if ( ( flags & FL_ONGROUND ) && ( iSurvivorsProximity < 50 ) ) {
		// buttons &= ~IN_DUCK;
		// buttons &= ~IN_ATTACK;
		// buttons |= IN_ATTACK2;
	// }
	
	//Block Jumping and Crouching when on ladder
	if (GetEntityMoveType(hunter) & MOVETYPE_LADDER) {
		buttons &= ~IN_JUMP;
		buttons &= ~IN_DUCK;
	}
	
	return Plugin_Changed;
}

/***********************************************************************************************************************************************************************************

																	POUNCING AT AN ANGLE TO SURVIVORS

***********************************************************************************************************************************************************************************/

public Action Hunter_OnPounce(int botHunter) {
	int entLunge = GetEntPropEnt(botHunter, Prop_Send, "m_customAbility"); // get the hunter's lunge entity				
	float lungeVector[3]; 
	GetEntPropVector(entLunge, Prop_Send, "m_queuedLunge", lungeVector); // get the vector from the lunge entity
	
	// Avoid pouncing straight forward if there is a wall close in front
	float hunterPos[3];
	float hunterAngle[3];
	GetClientAbsOrigin(botHunter, hunterPos);
	GetClientEyeAngles(botHunter, hunterAngle); 
	// Fire traceray in front of hunter 
	TR_TraceRayFilter( hunterPos, hunterAngle, MASK_PLAYERSOLID, RayType_Infinite, TracerayFilter, botHunter );
	float impactPos[3];
	TR_GetEndPosition( impactPos );
	// Check first object hit
	if( GetVectorDistance(hunterPos, impactPos) < GetConVarInt(hCvarWallDetectionDistance) ) { // wall detected in front
		if( GetRandomInt(0, 1) ) { // 50% chance left or right
			AngleLunge( entLunge, 45.0 );
		} else {
			AngleLunge( entLunge, 315.0 );
		}
		
			#if DEBUG_HUNTER_AIM
				PrintToChatAll("Pouncing sideways to avoid wall");
			#endif
		
	} else {
		// Angle pounce if survivor is watching the hunter approach
		GetClientAbsOrigin(botHunter, hunterPos);		
		if( IsTargetWatchingAttacker(botHunter, GetConVarInt(hCvarAimOffsetSensitivityHunter)) && GetSurvivorProximity(hunterPos) > GetConVarInt(hCvarStraightPounceProximity) ) {			
			float pounceAngle = GaussianRNG( float(GetConVarInt(hCvarPounceAngleMean)), float(GetConVarInt(hCvarPounceAngleStd)) );
			AngleLunge( entLunge, pounceAngle );
			LimitLungeVerticality( entLunge );
			
				#if DEBUG_HUNTER_AIM
					int target = GetClientAimTarget(botHunter);
					if( IsSurvivor(target) ) {
						char[] targetName[32];
						GetClientName(target, targetName, sizeof(targetName));
						PrintToChatAll("The aim of hunter's target(%s) is %f degrees off", targetName, GetPlayerAimOffset(target, botHunter));
						PrintToChatAll("Angling pounce to throw off survivor");
					} 
					
				#endif
	
			return Plugin_Changed;					
		}	
	}
	return Plugin_Continue;
}

public bool TracerayFilter( int impactEntity, int contentMask, int rayOriginEntity ) {
	return impactEntity != rayOriginEntity;
}
// Credits to High Cookie and Standalone for working out the math behind hunter lunges
void AngleLunge( int lungeEntity, float turnAngle ) {	
	// Get the original lunge's vector
	float lungeVector[3];
	GetEntPropVector(lungeEntity, Prop_Send, "m_queuedLunge", lungeVector);
	float x = lungeVector[X];
	float y = lungeVector[Y];
	float z = lungeVector[Z];
	
	// Create a new vector of the desired angle from the original
	turnAngle = DegToRad(turnAngle); // convert angle to radian form
	float forcedLunge[3];
	forcedLunge[X] = x * Cosine(turnAngle) - y * Sine(turnAngle); 
	forcedLunge[Y] = x * Sine(turnAngle)   + y * Cosine(turnAngle);
	forcedLunge[Z] = z;
	
	SetEntPropVector(lungeEntity, Prop_Send, "m_queuedLunge", forcedLunge);	
}

// Stop pounces being too high
void LimitLungeVerticality( int lungeEntity ) {
	// Get vertical angle restriction
	float vertAngle = float(GetConVarInt(hCvarPounceVerticalAngle));
	// Get the original lunge's vector
	float lungeVector[3];
	GetEntPropVector(lungeEntity, Prop_Send, "m_queuedLunge", lungeVector);
	float x = lungeVector[X];
	float y = lungeVector[Y];
	float z = lungeVector[Z];
	
	vertAngle = DegToRad(vertAngle);	
	float flatLunge[3];
	// First rotation
	flatLunge[Y] = y * Cosine(vertAngle) - z * Sine(vertAngle);
	flatLunge[Z] = y * Sine(vertAngle) + z * Cosine(vertAngle);
	// Second rotation
	flatLunge[X] = x * Cosine(vertAngle) + z * Sine(vertAngle);
	flatLunge[Z] = x * -Sine(vertAngle) + z * Cosine(vertAngle);
	
	SetEntPropVector(lungeEntity, Prop_Send, "m_queuedLunge", flatLunge);
}

/** 
 * Thanks to Newteee:
 * Random number generator fit to a bellcurve. Function to generate Gaussian Random Number fit to a bellcurve with a specified mean and std
 * Uses Polar Form of the Box-Muller transformation
*/
float GaussianRNG( float mean, float std ) {		 
	// Randomising positive/negative
	float chanceToken = GetRandomFloat( 0.0, 1.0 );
	int signBit;	
	if( chanceToken >= 0.5 ) {
		signBit = POSITIVE;
	} else {
		signBit = NEGATIVE;
	}	   
	
	float x1;
	float x2;
	float w;
	// Box-Muller algorithm
	do {
		// Generate random number
		float random1 = GetRandomFloat( 0.0, 1.0 );	// Random number between 0 and 1
		float random2 = GetRandomFloat( 0.0, 1.0 );	// Random number between 0 and 1
	 
		// x1 = FloatMul(2.0, random1) - 1.0;
		// x2 = FloatMul(2.0, random2) - 1.0;
		// w = FloatMul(x1, x1) + FloatMul(x2, x2);

		x1 = 2.0 * random1 - 1.0;
		x2 = 2.0 * random2 - 1.0;
		w = x1 * x1 + x2 * x2;
	 
	} while( w >= 1.0 );	 
	static float e = 2.71828;
	// w = SquareRoot( FloatMul( -2.0, FloatDiv( Logarithm(w, e), w ) )  ); 
	w = SquareRoot( -2.0 * (Logarithm(w, e) / w) );

	// Random normal variable
	// float y1 = FloatMul(x1, w);
	// float y2 = FloatMul(x2, w);
	float y1 = x1 * w;
	float y2 = x2 * w;
	 
	// Random gaussian variable with std and mean
	// float z1 = FloatMul(y1, std) + mean;
	// float z2 = FloatMul(y2, std) - mean;
	float z1 = y1 * std + mean;
	float z2 = y2 * std - mean;
	
	
	#if DEBUG_HUNTER_RNG	
		if( signBit == NEGATIVE )PrintToChatAll("Angle: %f", z1);
		else PrintToChatAll("Angle: %f", z2);
	#endif
	
	// Output z1 or z2 depending on sign
	if( signBit == NEGATIVE )return z1;
	else return z2;
}

// After the given interval, hunter is allowed to pounce/lunge
public Action Timer_LungeInterval(Handle timer, int client) {
	bCanLunge[client] = true;
}