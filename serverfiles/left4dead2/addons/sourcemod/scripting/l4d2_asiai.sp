#include <sourcemod>
#include <sdktools>
#include <left4dhooks>

#include "modules/hardcoop_util.sp"
 
 public PlVers:__version =
{
	version = 5,
	filevers = "1.9.0.6281",
	date = "05/31/2020",
	time = "17:16:32"
};
// new Float:NULL_VECTOR[3];
// new String:NULL_STRING[4];
public Extension:__ext_core =
{
	name = "Core",
	file = "core",
	autoload = 0,
	required = 0,
};
// new MaxClients;
public Extension:__ext_sdktools =
{
	name = "SDKTools",
	file = "sdktools.ext",
	autoload = 1,
	required = 1,
};
// new localIPRanges[4] =
// {
// 	1702256493, 1935819107, 1869374806, 2037672291
// };
//string value: m_vecAbsVelocity
new String:chatColorNames[12][] =
{
	"normal",
	"orange",
	"red",
	"redblue",
	"blue",
	"bluered",
	"team",
	"lightgreen",
	"gray",
	"green",
	"olivegreen",
	"black"
};
new String:chatColorTags[12][16] =
{
	"normal",
	"orange",
	"red",
	"redblue",
	"blue",
	"bluered",
	"team",
	"lightgreen",
	"gray",
	"green",
	"olivegreen",
	"black"
};
new chatColorInfo[12][4] =
{
	{
		1, -1, 1, -3
	},
	{
		1, 0, 1, -3
	},
	{
		3, 9, 1, 2
	},
	{
		3, 4, 1, 2
	},
	{
		3, 9, 1, 3
	},
	{
		3, 2, 1, 3
	},
	{
		3, 9, 1, -2
	},
	{
		3, 9, 1, 0
	},
	{
		3, 9, 1, -1
	},
	{
		4, 0, 1, -3
	},
	{
		5, 9, 1, -3
	},
	{
		6, 9, 1, -3
	}
};
new bool:checkTeamPlay;
new Handle:mp_teamplay;
new bool:isSayText2_supported = 1;
new chatSubject = -2;
new Float:getPlayersInRadius_distances[66];
new printToChat_excludeclient;
new String:_smlib_empty_twodimstring_array[1][16];
new base64_cFillChar = 3308130;
new base64_decodeTable[256] =
{
	3308130, 1886221434, 0, 12079, 47, 1162690887, 0, 1162690887, 0, 46, 11822, 623866661, 115, 42, 46, 46, 11822, 623866661, 115, 25202, 1162690887, 0, 25207, 1095124292, 1599360085, 1414091351, 1095786309, 18516, 11822, 46, 623866661, 115, 623866661, 115, 1869897581, 1702193006, 1701738319, 114, 1869635437, 1701015157, 1635021889, 1919249251, 0, 1633902445, 1098478194, 1667331188, 7497067, 1970298733, 1818586477, 1635021889, 1919249251, 0, 1869242221, 2036689763, 1635021889, 1919249251, 0, 1702256493, 1769099107, 7235943, 1870290797, 1701405293, 1935764547, 115, 0, 0, 0, 0, 1634164602, 1701338995, 1752460385, 0, 1735290740, 1650419061, 1801545074, 1869768287, 1633967981, 1701273965, 1869439327, 7630453, 1802464627, 1952412261, 1969712751, 1701076837, 7954796, 0, 0, 1836019554, 1700754021, 1936683128, 1952408677, 1600482665, 1701605236, 1668178290, 101, 1836019554, 1985966693, 1953066351, 1818584159, 31073, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1953396072, 1667199589, 1768779119, 1684370548, 1953784159, 1600873313, 1735287154, 101, 1953396072, 1885303397, 1668183407, 1701994341, 1601791073, 1735287154
};
new String:base64_mime_chars[4] = "bz2";
new String:base64_sTable[68] = "bz2";
new String:base64_url_chars[4] = "bz2";
new printToTop_excludeclient = 3308130;
new Handle:hCvarTongueDelay;
new Handle:hCvarSmokerHealth;
new Handle:hCvarChokeDamageInterrupt;
new Handle:hCvarBoomerExposedTimeTolerance;
new Handle:hCvarBoomerVomitDelay;
new Handle:hCvarHunterCommittedAttackRange;
new Handle:hCvarHunterPounceReadyRange;
new Handle:hCvarHunterLeapAwayGiveUpRange;
new Handle:hCvarHunterPounceMaxLoftAngle;
new Handle:hCvarLungeInterval;
new Handle:hCvarPounceAngleMean;
new Handle:hCvarPounceAngleStd;
new Handle:hCvarPounceVerticalAngle;
new Handle:hCvarFastPounceProximity;
new Handle:hCvarStraightPounceProximity;
new Handle:hCvarAimOffsetSensitivityHunter;
new Handle:hCvarWallDetectionDistance;
new bool:bHasQueuedLunge[65];
new bool:bCanLunge[65];
new Handle:hCvarChargeProximity;
new Handle:hCvarHealthThresholdCharger;
new bShouldCharge[65];
new Handle:hCvarJockeyLeapRange;
new bool:bCanLeap[65];
new Handle:hCvarJockeyStumbleRadius;
new Handle:hCvarTankBhop;
new bool:bHasBeenShoved[65];
public Plugin:myinfo =
{
	name = "AI: Hard SI",
	description = "Improves the AI behaviour of special infected",
	author = "Breezy",
	version = "1.0",
	url = "github.com/breezyplease"
};
// public void:__ext_core_SetNTVOptional()
// {
// 	MarkNativeAsOptional("GetFeatureStatus");
// 	MarkNativeAsOptional("RequireFeature");
// 	MarkNativeAsOptional("AddCommandListener");
// 	MarkNativeAsOptional("RemoveCommandListener");
// 	MarkNativeAsOptional("BfWriteBool");
// 	MarkNativeAsOptional("BfWriteByte");
// 	MarkNativeAsOptional("BfWriteChar");
// 	MarkNativeAsOptional("BfWriteShort");
// 	MarkNativeAsOptional("BfWriteWord");
// 	MarkNativeAsOptional("BfWriteNum");
// 	MarkNativeAsOptional("BfWriteFloat");
// 	MarkNativeAsOptional("BfWriteString");
// 	MarkNativeAsOptional("BfWriteEntity");
// 	MarkNativeAsOptional("BfWriteAngle");
// 	MarkNativeAsOptional("BfWriteCoord");
// 	MarkNativeAsOptional("BfWriteVecCoord");
// 	MarkNativeAsOptional("BfWriteVecNormal");
// 	MarkNativeAsOptional("BfWriteAngles");
// 	MarkNativeAsOptional("BfReadBool");
// 	MarkNativeAsOptional("BfReadByte");
// 	MarkNativeAsOptional("BfReadChar");
// 	MarkNativeAsOptional("BfReadShort");
// 	MarkNativeAsOptional("BfReadWord");
// 	MarkNativeAsOptional("BfReadNum");
// 	MarkNativeAsOptional("BfReadFloat");
// 	MarkNativeAsOptional("BfReadString");
// 	MarkNativeAsOptional("BfReadEntity");
// 	MarkNativeAsOptional("BfReadAngle");
// 	MarkNativeAsOptional("BfReadCoord");
// 	MarkNativeAsOptional("BfReadVecCoord");
// 	MarkNativeAsOptional("BfReadVecNormal");
// 	MarkNativeAsOptional("BfReadAngles");
// 	MarkNativeAsOptional("BfGetNumBytesLeft");
// 	MarkNativeAsOptional("BfWrite.WriteBool");
// 	MarkNativeAsOptional("BfWrite.WriteByte");
// 	MarkNativeAsOptional("BfWrite.WriteChar");
// 	MarkNativeAsOptional("BfWrite.WriteShort");
// 	MarkNativeAsOptional("BfWrite.WriteWord");
// 	MarkNativeAsOptional("BfWrite.WriteNum");
// 	MarkNativeAsOptional("BfWrite.WriteFloat");
// 	MarkNativeAsOptional("BfWrite.WriteString");
// 	MarkNativeAsOptional("BfWrite.WriteEntity");
// 	MarkNativeAsOptional("BfWrite.WriteAngle");
// 	MarkNativeAsOptional("BfWrite.WriteCoord");
// 	MarkNativeAsOptional("BfWrite.WriteVecCoord");
// 	MarkNativeAsOptional("BfWrite.WriteVecNormal");
// 	MarkNativeAsOptional("BfWrite.WriteAngles");
// 	MarkNativeAsOptional("BfRead.ReadBool");
// 	MarkNativeAsOptional("BfRead.ReadByte");
// 	MarkNativeAsOptional("BfRead.ReadChar");
// 	MarkNativeAsOptional("BfRead.ReadShort");
// 	MarkNativeAsOptional("BfRead.ReadWord");
// 	MarkNativeAsOptional("BfRead.ReadNum");
// 	MarkNativeAsOptional("BfRead.ReadFloat");
// 	MarkNativeAsOptional("BfRead.ReadString");
// 	MarkNativeAsOptional("BfRead.ReadEntity");
// 	MarkNativeAsOptional("BfRead.ReadAngle");
// 	MarkNativeAsOptional("BfRead.ReadCoord");
// 	MarkNativeAsOptional("BfRead.ReadVecCoord");
// 	MarkNativeAsOptional("BfRead.ReadVecNormal");
// 	MarkNativeAsOptional("BfRead.ReadAngles");
// 	MarkNativeAsOptional("BfRead.BytesLeft.get");
// 	MarkNativeAsOptional("PbReadInt");
// 	MarkNativeAsOptional("PbReadFloat");
// 	MarkNativeAsOptional("PbReadBool");
// 	MarkNativeAsOptional("PbReadString");
// 	MarkNativeAsOptional("PbReadColor");
// 	MarkNativeAsOptional("PbReadAngle");
// 	MarkNativeAsOptional("PbReadVector");
// 	MarkNativeAsOptional("PbReadVector2D");
// 	MarkNativeAsOptional("PbGetRepeatedFieldCount");
// 	MarkNativeAsOptional("PbSetInt");
// 	MarkNativeAsOptional("PbSetFloat");
// 	MarkNativeAsOptional("PbSetBool");
// 	MarkNativeAsOptional("PbSetString");
// 	MarkNativeAsOptional("PbSetColor");
// 	MarkNativeAsOptional("PbSetAngle");
// 	MarkNativeAsOptional("PbSetVector");
// 	MarkNativeAsOptional("PbSetVector2D");
// 	MarkNativeAsOptional("PbAddInt");
// 	MarkNativeAsOptional("PbAddFloat");
// 	MarkNativeAsOptional("PbAddBool");
// 	MarkNativeAsOptional("PbAddString");
// 	MarkNativeAsOptional("PbAddColor");
// 	MarkNativeAsOptional("PbAddAngle");
// 	MarkNativeAsOptional("PbAddVector");
// 	MarkNativeAsOptional("PbAddVector2D");
// 	MarkNativeAsOptional("PbRemoveRepeatedFieldValue");
// 	MarkNativeAsOptional("PbReadMessage");
// 	MarkNativeAsOptional("PbReadRepeatedMessage");
// 	MarkNativeAsOptional("PbAddMessage");
// 	MarkNativeAsOptional("Protobuf.ReadInt");
// 	MarkNativeAsOptional("Protobuf.ReadFloat");
// 	MarkNativeAsOptional("Protobuf.ReadBool");
// 	MarkNativeAsOptional("Protobuf.ReadString");
// 	MarkNativeAsOptional("Protobuf.ReadColor");
// 	MarkNativeAsOptional("Protobuf.ReadAngle");
// 	MarkNativeAsOptional("Protobuf.ReadVector");
// 	MarkNativeAsOptional("Protobuf.ReadVector2D");
// 	MarkNativeAsOptional("Protobuf.GetRepeatedFieldCount");
// 	MarkNativeAsOptional("Protobuf.SetInt");
// 	MarkNativeAsOptional("Protobuf.SetFloat");
// 	MarkNativeAsOptional("Protobuf.SetBool");
// 	MarkNativeAsOptional("Protobuf.SetString");
// 	MarkNativeAsOptional("Protobuf.SetColor");
// 	MarkNativeAsOptional("Protobuf.SetAngle");
// 	MarkNativeAsOptional("Protobuf.SetVector");
// 	MarkNativeAsOptional("Protobuf.SetVector2D");
// 	MarkNativeAsOptional("Protobuf.AddInt");
// 	MarkNativeAsOptional("Protobuf.AddFloat");
// 	MarkNativeAsOptional("Protobuf.AddBool");
// 	MarkNativeAsOptional("Protobuf.AddString");
// 	MarkNativeAsOptional("Protobuf.AddColor");
// 	MarkNativeAsOptional("Protobuf.AddAngle");
// 	MarkNativeAsOptional("Protobuf.AddVector");
// 	MarkNativeAsOptional("Protobuf.AddVector2D");
// 	MarkNativeAsOptional("Protobuf.RemoveRepeatedFieldValue");
// 	MarkNativeAsOptional("Protobuf.ReadMessage");
// 	MarkNativeAsOptional("Protobuf.ReadRepeatedMessage");
// 	MarkNativeAsOptional("Protobuf.AddMessage");
// 	VerifyCoreVersion();
// 	return void:0;
// }

// .2920.-40000005(Float:oper)
// {
// 	return oper ^ -2147483648;
// }

// .2920.-40000005(Float:oper)
// {
// 	return oper ^ -2147483648;
// }

// Float:operator*(Float:,_:)(Float:oper1, oper2)
// {
// 	return oper1 * float(oper2);
// }

// Float:operator*(Float:,_:)(Float:oper1, oper2)
// {
// 	return oper1 * float(oper2);
// }

// Float:operator/(Float:,_:)(Float:oper1, oper2)
// {
// 	return oper1 / float(oper2);
// }

// Float:operator/(Float:,_:)(Float:oper1, oper2)
// {
// 	return oper1 / float(oper2);
// }

// bool:operator<(Float:,_:)(Float:oper1, oper2)
// {
// 	return oper1 < float(oper2);
// }

// bool:operator<(Float:,_:)(Float:oper1, oper2)
// {
// 	return oper1 < float(oper2);
// }

// Float:DegToRad(Float:angle)
// {
// 	return angle * 3.1415927 / 180;
// }

// Float:RadToDeg(Float:angle)
// {
// 	return angle * 180 / 3.1415927;
// }

// void:SubtractVectors(Float:vec1[3], Float:vec2[3], Float:result[3])
// {
// 	result[0] = vec1[0] - vec2[0];
// 	result[1] = vec1[1] - vec2[1];
// 	result[2] = vec1[2] - vec2[2];
// 	return void:0;
// }

// void:ScaleVector(Float:vec[3], Float:scale)
// {
// 	new var1 = vec;
// 	var1[0] = var1[0] * scale;
// 	vec[1] *= scale;
// 	vec[2] *= scale;
// 	return void:0;
// }

// void:MakeVectorFromPoints(Float:pt1[3], Float:pt2[3], Float:output[3])
// {
// 	output[0] = pt2[0] - pt1[0];
// 	output[1] = pt2[1] - pt1[1];
// 	output[2] = pt2[2] - pt1[2];
// 	return void:0;
// }

// bool:StrEqual(String:str1[], String:str2[], bool:caseSensitive)
// {
// 	return strcmp(str1, str2, caseSensitive) == 0;
// }

// FindCharInString(String:str[], String:c, bool:reverse)
// {
// 	new len = strlen(str);
// 	if (!reverse)
// 	{
// 		new i;
// 		while (i < len)
// 		{
// 			if (c == str[i])
// 			{
// 				return i;
// 			}
// 			i++;
// 		}
// 	}
// 	else
// 	{
// 		new i = len + -1;
// 		while (0 <= i)
// 		{
// 			if (c == str[i])
// 			{
// 				return i;
// 			}
// 			i--;
// 		}
// 	}
// 	return -1;
// }

// StrCat(String:buffer[], maxlength, String:source[])
// {
// 	new len = strlen(buffer);
// 	if (len >= maxlength)
// 	{
// 		return 0;
// 	}
// 	return Format(buffer[len], maxlength - len, "%s", source);
// }

// MoveType:GetEntityMoveType(entity)
// {
// 	static bool:gotconfig;
// 	static String:datamap[32];
// 	if (!gotconfig)
// 	{
// 		new Handle:gc = LoadGameConfigFile("core.games");
// 		new bool:exists = GameConfGetKeyValue(gc, "m_MoveType", datamap, 32);
// 		CloseHandle(gc);
// 		if (!exists)
// 		{
// 			strcopy(datamap, 32, "m_MoveType");
// 		}
// 		gotconfig = true;
// 	}
// 	return GetEntProp(entity, PropType:1, datamap, 4, 0);
// }

// void:AddFileToDownloadsTable(String:filename[])
// {
// 	static table = -1;
// 	if (table == -1)
// 	{
// 		table = FindStringTable("downloadables");
// 	}
// 	new bool:save = LockStringTables(false);
// 	AddToStringTable(table, filename, "", -1);
// 	LockStringTables(save);
// 	return void:0;
// }

// Array_FindString(String:array[][], size, String:str[], bool:caseSensitive, start)
// {
// 	if (0 > start)
// 	{
// 		start = 0;
// 	}
// 	new i = start;
// 	while (i < size)
// 	{
// 		if (StrEqual(array[i], str, caseSensitive))
// 		{
// 			return i;
// 		}
// 		i++;
// 	}
// 	return -1;
// }

// Entity_IsValid(entity)
// {
// 	return IsValidEntity(entity);
// }

Entity_GetAbsVelocity(entity, Float:vec[3])
{
	GetEntPropVector(entity, PropType:1, "m_vecAbsVelocity", vec, 0);
	return 0;
}

Entity_SetAbsVelocity(entity, Float:vec[3])
{
	TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vec);
	return 0;
}

// bool:Entity_IsPlayer(entity)
// {
// 	 new var1;
// 	if (entity < 1 || entity > MaxClients)
// 	{
// 		return false;
// 	}
// 	return true;
// }

// bool:Entity_Kill(kenny, killChildren)
// {
// 	if (Entity_IsPlayer(kenny))
// 	{
// 		ForcePlayerSuicide(kenny);
// 		return true;
// 	}
// 	if (killChildren)
// 	{
// 		return AcceptEntityInput(kenny, "KillHierarchy", -1, -1, 0);
// 	}
// 	return AcceptEntityInput(kenny, "Kill", -1, -1, 0);
// }

// public Action:__smlib_Timer_ChangeOverTime(Handle:Timer, Handle:dataPack)
// {
// 	new entity = EntRefToEntIndex(ReadPackCell(dataPack));
// 	if (!Entity_IsValid(entity))
// 	{
// 		return Action:4;
// 	}
// 	new Float:interval = ReadPackFloat(dataPack);
// 	new currentCall = ReadPackCell(dataPack);
// 	new Function:callback = ReadPackFunction(dataPack);
// 	new any:result;
// 	Call_StartFunction(Handle:0, callback);
// 	Call_PushCellRef(entity);
// 	Call_PushFloatRef(interval);
// 	Call_PushCellRef(currentCall);
// 	Call_Finish(result);
// 	if (result)
// 	{
// 		ResetPack(dataPack, true);
// 		WritePackCell(dataPack, EntIndexToEntRef(entity));
// 		WritePackFloat(dataPack, interval);
// 		WritePackCell(dataPack, currentCall + 1);
// 		WritePackFunction(dataPack, callback);
// 		ResetPack(dataPack, false);
// 		CreateTimer(interval, __smlib_Timer_ChangeOverTime, dataPack, 0);
// 		return Action:4;
// 	}
// 	return Action:4;
// }

// Team_GetAnyClient(index)
// {
// 	static client_cache[32] =
// 	{
// 		-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
// 	};
// 	new client;
// 	if (0 < index)
// 	{
// 		client = client_cache[index];
// 		new var1;
// 		if (client > 0 && client <= MaxClients)
// 		{
// 			new var2;
// 			if (IsClientInGame(client) && index == GetClientTeam(client))
// 			{
// 				return client;
// 			}
// 		}
// 		client = -1;
// 	}
// 	client = 1;
// 	while (client <= MaxClients)
// 	{
// 		if (IsClientInGame(client))
// 		{
// 			if (!(index != GetClientTeam(client)))
// 			{
// 				client_cache[index] = client;
// 				return client;
// 			}
// 		}
// 		client++;
// 	}
// 	return -1;
// }

// Color_ChatInitialize()
// {
// 	static initialized;
// 	if (initialized)
// 	{
// 		return 0;
// 	}
// 	initialized = 1;
// 	decl String:gameFolderName[32];
// 	GetGameFolderName(gameFolderName, 32);
// 	chatColorInfo[11][2] = 0;
// 	new var1;
// 	if (strncmp(gameFolderName, "left4dead", 9, false) && !StrEqual(gameFolderName, "cstrike", false) && !StrEqual(gameFolderName, "tf", false))
// 	{
// 		chatColorInfo[7][2] = 0;
// 		chatColorInfo[8][2] = 0;
// 	}
// 	if (StrEqual(gameFolderName, "tf", false))
// 	{
// 		chatColorInfo[11][2] = 1;
// 		chatColorInfo[8] = 1;
// 		chatColorInfo[8][3] = -3;
// 	}
// 	else
// 	{
// 		if (strncmp(gameFolderName, "left4dead", 9, false))
// 		{
// 			if (StrEqual(gameFolderName, "hl2mp", false))
// 			{
// 				chatColorInfo[2][3] = 3;
// 				chatColorInfo[3][3] = 3;
// 				chatColorInfo[4][3] = 2;
// 				chatColorInfo[5][3] = 2;
// 				chatColorInfo[11][2] = 1;
// 				checkTeamPlay = true;
// 			}
// 			if (StrEqual(gameFolderName, "dod", false))
// 			{
// 				chatColorInfo[8] = 1;
// 				chatColorInfo[8][3] = -3;
// 				chatColorInfo[11][2] = 1;
// 				chatColorInfo[1][2] = 0;
// 			}
// 		}
// 		chatColorInfo[2][3] = 3;
// 		chatColorInfo[3][3] = 3;
// 		chatColorInfo[4][3] = 2;
// 		chatColorInfo[5][3] = 2;
// 		chatColorInfo[1] = 4;
// 		chatColorInfo[9] = 5;
// 	}
// 	if (GetUserMessageId("SayText2") == -1)
// 	{
// 		isSayText2_supported = false;
// 	}
// 	decl String:path_gamedata[256];
// 	BuildPath(PathType:0, path_gamedata, 256, "gamedata/%s.txt", "smlib_colors.games");
// 	if (FileExists(path_gamedata, false, "GAME"))
// 	{
// 		new Handle:gamedata;
// 		if ((gamedata = LoadGameConfigFile("smlib_colors.games")))
// 		{
// 			decl String:keyName[32];
// 			decl String:buffer[8];
// 			new i;
// 			while (i < 12)
// 			{
// 				Format(keyName, 32, "%s_code", chatColorNames[i]);
// 				if (GameConfGetKeyValue(gamedata, keyName, buffer, 6))
// 				{
// 					chatColorInfo[i][0] = StringToInt(buffer, 10);
// 				}
// 				Format(keyName, 32, "%s_alternative", chatColorNames[i]);
// 				if (GameConfGetKeyValue(gamedata, keyName, buffer, 6))
// 				{
// 					chatColorInfo[i][1] = buffer[0];
// 				}
// 				Format(keyName, 32, "%s_supported", chatColorNames[i]);
// 				if (GameConfGetKeyValue(gamedata, keyName, buffer, 6))
// 				{
// 					chatColorInfo[i][2] = StrEqual(buffer, "true", true);
// 				}
// 				Format(keyName, 32, "%s_subjecttype", chatColorNames[i]);
// 				if (GameConfGetKeyValue(gamedata, keyName, buffer, 6))
// 				{
// 					chatColorInfo[i][3] = StringToInt(buffer, 10);
// 				}
// 				i++;
// 			}
// 			if (GameConfGetKeyValue(gamedata, "checkteamplay", buffer, 6))
// 			{
// 				checkTeamPlay = StrEqual(buffer, "true", true);
// 			}
// 			CloseHandle(gamedata);
// 		}
// 	}
// 	mp_teamplay = FindConVar("mp_teamplay");
// 	return 0;
// }

// Color_GetChatColorInfo(&index, &subject)
// {
// 	Color_ChatInitialize();
// 	if (index == -1)
// 	{
// 		index = 0;
// 	}
// 	while (!chatColorInfo[index][2])
// 	{
// 		new alternative = chatColorInfo[index][1];
// 		if (alternative == -1)
// 		{
// 			index = 0;
// 			if (index == -1)
// 			{
// 				index = 0;
// 			}
// 			new newSubject = -2;
// 			new ChatColorSubjectType:type = chatColorInfo[index][3];
// 			switch (type)
// 			{
// 				case -3:
// 				{
// 				}
// 				case -2:
// 				{
// 					newSubject = chatSubject;
// 				}
// 				case -1:
// 				{
// 					newSubject = -1;
// 				}
// 				case 0:
// 				{
// 					newSubject = 0;
// 				}
// 				default:
// 				{
// 					new var1;
// 					if (!checkTeamPlay || GetConVarBool(mp_teamplay))
// 					{
// 						new var2;
// 						if (subject > 0 && subject <= MaxClients)
// 						{
// 							if (type == GetClientTeam(subject))
// 							{
// 								newSubject = subject;
// 							}
// 						}
// 						if (subject == -2)
// 						{
// 							new client = Team_GetAnyClient(type);
// 							if (client != -1)
// 							{
// 								newSubject = client;
// 							}
// 						}
// 					}
// 				}
// 			}
// 			new var5;
// 			if (type > ChatColorSubjectType:-3 && ((subject != -2 && newSubject != subject) || (newSubject == -2 || !isSayText2_supported)))
// 			{
// 				index = chatColorInfo[index][1];
// 				newSubject = Color_GetChatColorInfo(index, subject);
// 			}
// 			if (subject == -2)
// 			{
// 				subject = newSubject;
// 			}
// 			return newSubject;
// 		}
// 		index = alternative;
// 	}
// 	if (index == -1)
// 	{
// 		index = 0;
// 	}
// 	new newSubject = -2;
// 	new ChatColorSubjectType:type = chatColorInfo[index][3];
// 	switch (type)
// 	{
// 		case -3:
// 		{
// 		}
// 		case -2:
// 		{
// 			newSubject = chatSubject;
// 		}
// 		case -1:
// 		{
// 			newSubject = -1;
// 		}
// 		case 0:
// 		{
// 			newSubject = 0;
// 		}
// 		default:
// 		{
// 			new var1;
// 			if (!checkTeamPlay || GetConVarBool(mp_teamplay))
// 			{
// 				new var2;
// 				if (subject > 0 && subject <= MaxClients)
// 				{
// 					if (type == GetClientTeam(subject))
// 					{
// 						newSubject = subject;
// 					}
// 				}
// 				if (subject == -2)
// 				{
// 					new client = Team_GetAnyClient(type);
// 					if (client != -1)
// 					{
// 						newSubject = client;
// 					}
// 				}
// 			}
// 		}
// 	}
// 	new var5;
// 	if (type > ChatColorSubjectType:-3 && ((subject != -2 && newSubject != subject) || (newSubject == -2 || !isSayText2_supported)))
// 	{
// 		index = chatColorInfo[index][1];
// 		newSubject = Color_GetChatColorInfo(index, subject);
// 	}
// 	if (subject == -2)
// 	{
// 		subject = newSubject;
// 	}
// 	return newSubject;
// }

// public bool:_smlib_TraceEntityFilter(entity, contentsMask)
// {
// 	return entity == 0;
// }

// public __smlib_GetPlayersInRadius_Sort(player1, player2, clients[], Handle:hndl)
// {
// 	return FloatCompare(getPlayersInRadius_distances[player1], getPlayersInRadius_distances[player2]);
// }

// public Action:_smlib_Timer_Effect_Fade(Handle:Timer, Handle:dataPack)
// {
// 	new entity = ReadPackCell(dataPack);
// 	new kill = ReadPackCell(dataPack);
// 	new Function:callback = ReadPackFunction(dataPack);
// 	new any:data = ReadPackCell(dataPack);
// 	if (callback != -1)
// 	{
// 		Call_StartFunction(Handle:0, callback);
// 		Call_PushCell(entity);
// 		Call_PushCell(data);
// 		Call_Finish(0);
// 	}
// 	new var1;
// 	if (kill && IsValidEntity(entity))
// 	{
// 		Entity_Kill(entity, 0);
// 	}
// 	return Action:4;
// }

// bool:File_GetBaseName(String:path[], String:buffer[], size)
// {
// 	if (path[0])
// 	{
// 		new pos_start = FindCharInString(path, String:47, true);
// 		if (pos_start == -1)
// 		{
// 			pos_start = FindCharInString(path, String:92, true);
// 		}
// 		pos_start++;
// 		strcopy(buffer, size, path[pos_start]);
// 		return false;
// 	}
// 	buffer[0] = MissingTAG:0;
// 	return false;
// }

// bool:File_GetDirName(String:path[], String:buffer[], size)
// {
// 	if (path[0])
// 	{
// 		new pos_start = FindCharInString(path, String:47, true);
// 		if (pos_start == -1)
// 		{
// 			pos_start = FindCharInString(path, String:92, true);
// 			if (pos_start == -1)
// 			{
// 				buffer[0] = MissingTAG:0;
// 				return false;
// 			}
// 		}
// 		strcopy(buffer, size, path);
// 		buffer[pos_start] = MissingTAG:0;
// 		return false;
// 	}
// 	buffer[0] = MissingTAG:0;
// 	return false;
// }

// bool:File_GetFileName(String:path[], String:buffer[], size)
// {
// 	if (path[0])
// 	{
// 		File_GetBaseName(path, buffer, size);
// 		new pos_ext = FindCharInString(buffer, String:46, true);
// 		if (pos_ext != -1)
// 		{
// 			buffer[pos_ext] = MissingTAG:0;
// 		}
// 		return false;
// 	}
// 	buffer[0] = MissingTAG:0;
// 	return false;
// }

// File_GetExtension(String:path[], String:buffer[], size)
// {
// 	new extpos = FindCharInString(path, String:46, true);
// 	if (extpos == -1)
// 	{
// 		buffer[0] = MissingTAG:0;
// 		return 0;
// 	}
// 	extpos++;
// 	strcopy(buffer, size, path[extpos]);
// 	return 0;
// }

// File_AddToDownloadsTable(String:path[], bool:recursive, String:ignoreExts[][], size)
// {
// 	if (path[0])
// 	{
// 		if (FileExists(path, false, "GAME"))
// 		{
// 			new String:fileExtension[8];
// 			File_GetExtension(path, fileExtension, 5);
// 			new var1;
// 			if (StrEqual(fileExtension, _smlib_empty_twodimstring_array, false) || StrEqual(fileExtension, "ztmp", false))
// 			{
// 				return 0;
// 			}
// 			if (Array_FindString(ignoreExts, size, fileExtension, true, 0) != -1)
// 			{
// 				return 0;
// 			}
// 			decl String:path_new[256];
// 			strcopy(path_new, 256, path);
// 			ReplaceString(path_new, 256, "//", "/", true);
// 			AddFileToDownloadsTable(path_new);
// 		}
// 		else
// 		{
// 			new var2;
// 			if (recursive && DirExists(path, false, "GAME"))
// 			{
// 				decl String:dirEntry[256];
// 				new Handle:__dir = OpenDirectory(path, false, "GAME");
// 				while (ReadDirEntry(__dir, dirEntry, 256, 0))
// 				{
// 					new var3;
// 					if (!(StrEqual(dirEntry, ".", true) || StrEqual(dirEntry, "..", true)))
// 					{
// 						Format(dirEntry, 256, "%s/%s", path, dirEntry);
// 						File_AddToDownloadsTable(dirEntry, recursive, ignoreExts, size);
// 					}
// 				}
// 				CloseHandle(__dir);
// 			}
// 			if (FindCharInString(path, String:42, true))
// 			{
// 				new String:fileExtension[4];
// 				File_GetExtension(path, fileExtension, 4);
// 				if (StrEqual(fileExtension, "*", true))
// 				{
// 					decl String:dirName[256];
// 					decl String:fileName[256];
// 					decl String:dirEntry[256];
// 					File_GetDirName(path, dirName, 256);
// 					File_GetFileName(path, fileName, 256);
// 					StrCat(fileName, 256, ".");
// 					new Handle:__dir = OpenDirectory(dirName, false, "GAME");
// 					while (ReadDirEntry(__dir, dirEntry, 256, 0))
// 					{
// 						new var4;
// 						if (!(StrEqual(dirEntry, ".", true) || StrEqual(dirEntry, "..", true)))
// 						{
// 							if (strncmp(dirEntry, fileName, strlen(fileName), true))
// 							{
// 							}
// 							else
// 							{
// 								Format(dirEntry, 256, "%s/%s", dirName, dirEntry);
// 								File_AddToDownloadsTable(dirEntry, recursive, ignoreExts, size);
// 							}
// 						}
// 					}
// 					CloseHandle(__dir);
// 				}
// 			}
// 		}
// 		return 0;
// 	}
// 	return 0;
// }

// bool:File_Copy(String:source[], String:destination[])
// {
// 	new Handle:file_source = OpenFile(source, "rb", false, "GAME");
// 	if (file_source)
// 	{
// 		new Handle:file_destination = OpenFile(destination, "wb", false, "GAME");
// 		if (file_destination)
// 		{
// 			new buffer[32];
// 			new cache;
// 			while (!IsEndOfFile(file_source))
// 			{
// 				cache = ReadFile(file_source, buffer, 32, 1);
// 				WriteFile(file_destination, buffer, cache, 1);
// 			}
// 			CloseHandle(file_source);
// 			CloseHandle(file_destination);
// 			return true;
// 		}
// 		CloseHandle(file_source);
// 		return false;
// 	}
// 	return false;
// }

// bool:File_CopyRecursive(String:path[], String:destination[], bool:stop_on_error, dirMode)
// {
// 	if (FileExists(path, false, "GAME"))
// 	{
// 		return File_Copy(path, destination);
// 	}
// 	if (DirExists(path, false, "GAME"))
// 	{
// 		return Sub_File_CopyRecursive(path, destination, stop_on_error, FileType:1, dirMode);
// 	}
// 	return false;
// }

// bool:Sub_File_CopyRecursive(String:path[], String:destination[], bool:stop_on_error, FileType:fileType, dirMode)
// {
// 	if (fileType == FileType:2)
// 	{
// 		return File_Copy(path, destination);
// 	}
// 	if (fileType == FileType:1)
// 	{
// 		new var1;
// 		if (!CreateDirectory(destination, dirMode, false, "DEFAULT_WRITE_PATH") && stop_on_error)
// 		{
// 			return false;
// 		}
// 		new Handle:directory = OpenDirectory(path, false, "GAME");
// 		if (directory)
// 		{
// 			decl String:source_buffer[256];
// 			decl String:destination_buffer[256];
// 			new FileType:type;
// 			while (ReadDirEntry(directory, source_buffer, 256, type))
// 			{
// 				new var2;
// 				if (!(StrEqual(source_buffer, "..", true) || StrEqual(source_buffer, ".", true)))
// 				{
// 					Format(destination_buffer, 256, "%s/%s", destination, source_buffer);
// 					Format(source_buffer, 256, "%s/%s", path, source_buffer);
// 					if (type == FileType:2)
// 					{
// 						File_Copy(source_buffer, destination_buffer);
// 					}
// 					else
// 					{
// 						if (type == FileType:1)
// 						{
// 							new var3;
// 							if (!File_CopyRecursive(source_buffer, destination_buffer, stop_on_error, dirMode) && stop_on_error)
// 							{
// 								CloseHandle(directory);
// 								return false;
// 							}
// 						}
// 					}
// 				}
// 			}
// 			CloseHandle(directory);
// 		}
// 		return false;
// 	}
// 	else
// 	{
// 		if (!fileType)
// 		{
// 			return false;
// 		}
// 	}
// 	return true;
// }

// Client_Push(client, Float:clientEyeAngle[3], Float:power, VelocityOverride:override[3])
// {
// 	decl Float:forwardVector[3];
// 	decl Float:newVel[3];
// 	GetAngleVectors(clientEyeAngle, forwardVector, NULL_VECTOR, NULL_VECTOR);
// 	NormalizeVector(forwardVector, forwardVector);
// 	ScaleVector(forwardVector, power);
// 	Entity_GetAbsVelocity(client, newVel);
// 	new i;
// 	while (i < 3)
// 	{
// 		switch (override[i])
// 		{
// 			case 1:
// 			{
// 				newVel[i] = 0.0;
// 			}
// 			case 2:
// 			{
// 				if (newVel[i] < 0.0)
// 				{
// 					newVel[i] = 0.0;
// 				}
// 			}
// 			case 3:
// 			{
// 				if (newVel[i] < 0.0)
// 				{
// 					newVel[i] *= -1.0;
// 				}
// 			}
// 			default:
// 			{
// 			}
// 		}
// 		// new var1 = newVel[i];
// 		// var1 = var1[forwardVector[i]];
// 		newVel[i] += forwardVector[i];
// 		i++;
// 	}
// 	Entity_SetAbsVelocity(client, newVel);
// 	return 0;
// }


// Velocity
enum VelocityOverride {
	VelocityOvr_None = 0,
	VelocityOvr_Velocity,
	VelocityOvr_OnlyWhenNegative,
	VelocityOvr_InvertReuseVelocity
};
// Thanks Chanz (Infinite Jumping plugin)
// Client_Push(client, Float:clientEyeAngle[3], Float:power, VelocityOverride:override[3])
// stock Client_Push(client, Float:clientEyeAngle[3], Float:power, VelocityOverride:override[3]=VelocityOvr_None)
Client_Push(client, Float:clientEyeAngle[3], Float:power, VelocityOverride:override[3])
{
	decl Float:forwardVector[3],
	Float:newVel[3];
	
	GetAngleVectors(clientEyeAngle, forwardVector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(forwardVector, forwardVector);
	ScaleVector(forwardVector, power);
	//PrintToChatAll("Tank velocity: %.2f", forwardVector[1]);
	
	Entity_GetAbsVelocity(client,newVel);
	
	for(new i=0;i<3;i++){
		switch(override[i]){
			case VelocityOvr_Velocity:{
				newVel[i] = 0.0;
			}
			case VelocityOvr_OnlyWhenNegative:{				
				if(newVel[i] < 0.0){
					newVel[i] = 0.0;
				}
			}
			case VelocityOvr_InvertReuseVelocity:{				
				if(newVel[i] < 0.0){
					newVel[i] *= -1.0;
				}
			}
		}
		
		newVel[i] += forwardVector[i];
	}
	
	Entity_SetAbsVelocity(client,newVel);
}

// bool:IsSurvivor(client)
// {
// 	new var1;
// 	if (IsValidClient(client) && GetClientTeam(client) == 2)
// 	{
// 		return true;
// 	}
// 	return false;
// }

// bool:IsPinned(client)
// {
// 	new bool:bIsPinned;
// 	if (IsSurvivor(client))
// 	{
// 		if (0 < GetEntPropEnt(client, PropType:0, "m_tongueOwner", 0))
// 		{
// 			bIsPinned = true;
// 		}
// 		if (0 < GetEntPropEnt(client, PropType:0, "m_pounceAttacker", 0))
// 		{
// 			bIsPinned = true;
// 		}
// 		if (0 < GetEntPropEnt(client, PropType:0, "m_carryAttacker", 0))
// 		{
// 			bIsPinned = true;
// 		}
// 		if (0 < GetEntPropEnt(client, PropType:0, "m_pummelAttacker", 0))
// 		{
// 			bIsPinned = true;
// 		}
// 		if (0 < GetEntPropEnt(client, PropType:0, "m_jockeyAttacker", 0))
// 		{
// 			bIsPinned = true;
// 		}
// 	}
// 	return bIsPinned;
// }

// GetClosestSurvivor(Float:referencePos[3], excludeSurvivor)
// {
// 	new Float:survivorPos[3] = 0.0;
// 	new iClosestAbsDisplacement = -1;
// 	new closestSurvivor = -1;
// 	new client = 1;
// 	while (client < MaxClients)
// 	{
// 		new var1;
// 		if (IsSurvivor(client) && excludeSurvivor != client)
// 		{
// 			GetClientAbsOrigin(client, survivorPos);
// 			new iAbsDisplacement = RoundToNearest(GetVectorDistance(referencePos, survivorPos, false));
// 			if (0 > iClosestAbsDisplacement)
// 			{
// 				iClosestAbsDisplacement = iAbsDisplacement;
// 				closestSurvivor = client;
// 			}
// 			else
// 			{
// 				if (iAbsDisplacement < iClosestAbsDisplacement)
// 				{
// 					iClosestAbsDisplacement = iAbsDisplacement;
// 					closestSurvivor = client;
// 				}
// 			}
// 		}
// 		client++;
// 	}
// 	return closestSurvivor;
// }

// GetSurvivorProximity(Float:referencePos[3], specificSurvivor)
// {
// 	new targetSurvivor;
// 	new Float:targetSurvivorPos[3] = 0.0;
// 	new var1;
// 	if (specificSurvivor > 0 && IsSurvivor(specificSurvivor))
// 	{
// 		targetSurvivor = specificSurvivor;
// 	}
// 	else
// 	{
// 		targetSurvivor = GetClosestSurvivor(referencePos, -1);
// 	}
// 	GetEntPropVector(targetSurvivor, PropType:0, "m_vecOrigin", targetSurvivorPos, 0);
// 	return RoundToNearest(GetVectorDistance(referencePos, targetSurvivorPos, false));
// }

// L4D2_Infected:GetInfectedClass(client)
// {
// 	return GetEntProp(client, PropType:0, "m_zombieClass", 4, 0);
// }

// bool:IsInfected(client)
// {
// 	new var1;
// 	if (!IsClientInGame(client) || GetClientTeam(client) == 3)
// 	{
// 		return false;
// 	}
// 	return true;
// }

// bool:IsBotInfected(client)
// {
// 	if (!IsValidClient(client))
// 	{
// 		return false;
// 	}
// 	new var1;
// 	if (IsInfected(client) && IsFakeClient(client))
// 	{
// 		return true;
// 	}
// 	return false;
// }

// bool:IsBotCharger(client)
// {
// 	new var1;
// 	return IsBotInfected(client) && GetInfectedClass(client) == 6;
// }

// bool:IsValidClient(client)
// {
// 	new var1;
// 	if (client > 0 && client <= MaxClients && IsClientInGame(client))
// 	{
// 		return true;
// 	}
// 	return false;
// }

// public Action:Timer_KickBot(Handle:timer, any:client)
// {
// 	new var1;
// 	if (IsClientInGame(client) && !IsClientInKickQueue(client))
// 	{
// 		if (IsFakeClient(client))
// 		{
// 			KickClient(client, "");
// 		}
// 	}
// 	return Action:0;
// }

public Smoker_OnModuleStart()
{
	hCvarSmokerHealth = FindConVar("z_gas_health");
	HookConVarChange(hCvarSmokerHealth, ConVarChanged:OnSmokerHealthChanged);
	hCvarChokeDamageInterrupt = FindConVar("tongue_break_from_damage_amount");
	SetConVarInt(hCvarChokeDamageInterrupt, GetConVarInt(hCvarSmokerHealth), false, false);
	HookConVarChange(hCvarChokeDamageInterrupt, ConVarChanged:OnTongueCvarChange);
	hCvarTongueDelay = FindConVar("smoker_tongue_delay");
	SetConVarFloat(hCvarTongueDelay, 0.5, false, false);
	HookConVarChange(hCvarTongueDelay, ConVarChanged:OnTongueCvarChange);
	return 0;
}

public Smoker_OnModuleEnd()
{
	ResetConVar(hCvarChokeDamageInterrupt, false, false);
	ResetConVar(hCvarTongueDelay, false, false);
	return 0;
}

public OnTongueCvarChange()
{
	SetConVarFloat(hCvarTongueDelay, 0.5, false, false);
	SetConVarInt(hCvarChokeDamageInterrupt, GetConVarInt(hCvarSmokerHealth), false, false);
	return 0;
}

public Action:OnSmokerHealthChanged()
{
	SetConVarInt(hCvarChokeDamageInterrupt, GetConVarInt(hCvarSmokerHealth), false, false);
	return Action:0;
}

public Boomer_OnModuleStart()
{
	hCvarBoomerExposedTimeTolerance = FindConVar("boomer_exposed_time_tolerance");
	hCvarBoomerVomitDelay = FindConVar("boomer_vomit_delay");
	SetConVarFloat(hCvarBoomerExposedTimeTolerance, 10000.0, false, false);
	SetConVarFloat(hCvarBoomerVomitDelay, 0.1, false, false);
	return 0;
}

public Boomer_OnModuleEnd()
{
	ResetConVar(hCvarBoomerExposedTimeTolerance, false, false);
	ResetConVar(hCvarBoomerVomitDelay, false, false);
	return 0;
}

public Hunter_OnModuleStart()
{
	hCvarHunterCommittedAttackRange = FindConVar("hunter_committed_attack_range");
	hCvarHunterPounceReadyRange = FindConVar("hunter_pounce_ready_range");
	hCvarHunterLeapAwayGiveUpRange = FindConVar("hunter_leap_away_give_up_range");
	hCvarLungeInterval = FindConVar("z_lunge_interval");
	hCvarHunterPounceMaxLoftAngle = FindConVar("hunter_pounce_max_loft_angle");
	SetConVarInt(hCvarHunterCommittedAttackRange, 10000, false, false);
	SetConVarInt(hCvarHunterPounceReadyRange, 1000, false, false);
	SetConVarInt(hCvarHunterLeapAwayGiveUpRange, 0, false, false);
	SetConVarInt(hCvarHunterPounceMaxLoftAngle, 0, false, false);
	hCvarFastPounceProximity = CreateConVar("ai_fast_pounce_proximity", "2000", "At what distance to start pouncing fast", 0, false, 0.0, false, 0.0);
	hCvarPounceVerticalAngle = CreateConVar("ai_pounce_vertical_angle", "7", "Vertical angle to which AI hunter pounces will be restricted", 0, false, 0.0, false, 0.0);
	hCvarPounceAngleMean = CreateConVar("ai_pounce_angle_mean", "10", "Mean angle produced by Gaussian RNG", 0, false, 0.0, false, 0.0);
	hCvarPounceAngleStd = CreateConVar("ai_pounce_angle_std", "20", "One standard deviation from mean as produced by Gaussian RNG", 0, false, 0.0, false, 0.0);
	hCvarStraightPounceProximity = CreateConVar("ai_straight_pounce_proximity", "200", "Distance to nearest survivor at which hunter will consider pouncing straight", 0, false, 0.0, false, 0.0);
	hCvarAimOffsetSensitivityHunter = CreateConVar("ai_aim_offset_sensitivity_hunter", "360", "If the hunter has a target, it will not straight pounce if the target's aim on the horizontal axis is within this radius", 0, true, 0.0, true, 179.0);
	hCvarWallDetectionDistance = CreateConVar("ai_wall_detection_distance", "-1", "How far in front of himself infected bot will check for a wall. Use '-1' to disable feature", 0, false, 0.0, false, 0.0);
	return 0;
}

public Hunter_OnModuleEnd()
{
	ResetConVar(hCvarHunterCommittedAttackRange, false, false);
	ResetConVar(hCvarHunterPounceReadyRange, false, false);
	ResetConVar(hCvarHunterLeapAwayGiveUpRange, false, false);
	ResetConVar(hCvarHunterPounceMaxLoftAngle, false, false);
	return 0;
}

public Action:Hunter_OnSpawn(botHunter)
{
	bHasQueuedLunge[botHunter] = 0;
	bCanLunge[botHunter] = 1;
	return Action:3;
}

public Action:Hunter_OnPlayerRunCmd(hunter, &buttons, &impulse, Float:vel[3], Float:eyeAngles[3], &weapon)
{
	buttons = buttons & -2049;
	new flags = GetEntityFlags(hunter);
	// new var1;
	if (flags & 2 && flags & 1)
	{
		new Float:hunterPos[3] = 0.0;
		GetClientAbsOrigin(hunter, hunterPos);
		new iSurvivorsProximity = GetSurvivorProximity(hunterPos, -1);
		new bool:bHasLOS = GetEntProp(hunter, PropType:0, "m_hasVisibleThreats", 4, 0);
		if (bHasLOS)
		{
			if (GetConVarInt(hCvarFastPounceProximity) > iSurvivorsProximity)
			{
				buttons = buttons & -2;
				if (!bHasQueuedLunge[hunter])
				{
					bCanLunge[hunter] = 0;
					bHasQueuedLunge[hunter] = 1;
					CreateTimer(GetConVarFloat(hCvarLungeInterval), Timer_LungeInterval, hunter, 2);
				}
				if (bCanLunge[hunter])
				{
					buttons = buttons | 1;
					bHasQueuedLunge[hunter] = 0;
				}
			}
		}
	}
	return Action:1;
}

public Action:Hunter_OnPounce(botHunter)
{
	new entLunge = GetEntPropEnt(botHunter, PropType:0, "m_customAbility", 0);
	new Float:lungeVector[3] = 0.0;
	GetEntPropVector(entLunge, PropType:0, "m_queuedLunge", lungeVector, 0);
	new Float:hunterPos[3] = 0.0;
	new Float:hunterAngle[3] = 0.0;
	GetClientAbsOrigin(botHunter, hunterPos);
	GetClientEyeAngles(botHunter, hunterAngle);
	TR_TraceRayFilter(hunterPos, hunterAngle, 33636363, RayType:1, TracerayFilter, botHunter);
	new Float:impactPos[3] = 0.0;
	TR_GetEndPosition(impactPos, Handle:0);
	if (GetVectorDistance(hunterPos, impactPos, false) < GetConVarInt(hCvarWallDetectionDistance))
	{
		if (GetRandomInt(0, 1))
		{
			AngleLunge(entLunge, 45.0);
		}
		else
		{
			AngleLunge(entLunge, 315.0);
		}
	}
	else
	{
		GetClientAbsOrigin(botHunter, hunterPos);
		// new var1;
		if (IsTargetWatchingAttacker(botHunter, GetConVarInt(hCvarAimOffsetSensitivityHunter)) && GetSurvivorProximity(hunterPos, -1) > GetConVarInt(hCvarStraightPounceProximity))
		{
			new Float:pounceAngle = GaussianRNG(float(GetConVarInt(hCvarPounceAngleMean)), float(GetConVarInt(hCvarPounceAngleStd)));
			AngleLunge(entLunge, pounceAngle);
			LimitLungeVerticality(entLunge);
			return Action:1;
		}
	}
	return Action:0;
}

public bool:TracerayFilter(impactEntity, contentMask, any:rayOriginEntity)
{
	return rayOriginEntity != impactEntity;
}

AngleLunge(lungeEntity, Float:turnAngle)
{
	new Float:lungeVector[3] = 0.0;
	GetEntPropVector(lungeEntity, PropType:0, "m_queuedLunge", lungeVector, 0);
	new Float:x = lungeVector[0];
	new Float:y = lungeVector[1];
	new Float:z = lungeVector[2];
	turnAngle = DegToRad(turnAngle);
	new Float:forcedLunge[3] = 0.0;
	forcedLunge[0] = x * Cosine(turnAngle) - y * Sine(turnAngle);
	forcedLunge[1] = x * Sine(turnAngle) + y * Cosine(turnAngle);
	forcedLunge[2] = z;
	SetEntPropVector(lungeEntity, PropType:0, "m_queuedLunge", forcedLunge, 0);
	return 0;
}

// LimitLungeVerticality(lungeEntity)
// {
// 	new Float:vertAngle = float(GetConVarInt(hCvarPounceVerticalAngle));
// 	new Float:lungeVector[3] = 0.0;
// 	GetEntPropVector(lungeEntity, PropType:0, "m_queuedLunge", lungeVector, 0);
// 	new Float:x = lungeVector[0];
// 	new Float:y = lungeVector[1];
// 	new Float:z = lungeVector[2];
// 	vertAngle = DegToRad(vertAngle);
// 	new Float:flatLunge[3] = 0.0;
// 	flatLunge[1] = y * Cosine(vertAngle) - z * Sine(vertAngle);
// 	flatLunge[2] = y * Sine(vertAngle) + z * Cosine(vertAngle);
// 	flatLunge[0] = x * Cosine(vertAngle) + z * Sine(vertAngle);
// 	flatLunge[2] = x * .2920.-40000005(Sine(vertAngle)) + z * Cosine(vertAngle);
// 	SetEntPropVector(lungeEntity, PropType:0, "m_queuedLunge", flatLunge, 0);
// 	return 0;
// }

#define POSITIVE 0
#define NEGATIVE 1
#define X 0
#define Y 1
#define Z 2

// Stop pounces being too high
LimitLungeVerticality( lungeEntity ) {
	// Get vertical angle restriction
	new Float:vertAngle = float(GetConVarInt(hCvarPounceVerticalAngle));
	// Get the original lunge's vector
	new Float:lungeVector[3];
	GetEntPropVector(lungeEntity, Prop_Send, "m_queuedLunge", lungeVector);
	new Float:x = lungeVector[X];
	new Float:y = lungeVector[Y];
	new Float:z = lungeVector[Z];
	
	vertAngle = DegToRad(vertAngle);	
	new Float:flatLunge[3];
	// First rotation
	flatLunge[Y] = y * Cosine(vertAngle) - z * Sine(vertAngle);
	flatLunge[Z] = y * Sine(vertAngle) + z * Cosine(vertAngle);
	// Second rotation
	flatLunge[X] = x * Cosine(vertAngle) + z * Sine(vertAngle);
	flatLunge[Z] = x * -Sine(vertAngle) + z * Cosine(vertAngle);
	
	SetEntPropVector(lungeEntity, Prop_Send, "m_queuedLunge", flatLunge);
}

Float:GaussianRNG(Float:mean, Float:std)
{
	new Float:chanceToken = GetRandomFloat(0.0, 1.0);
	new signBit;
	if (chanceToken >= 0.5)
	{
		signBit = 0;
	}
	else
	{
		signBit = 1;
	}
	new Float:x1 = 0.0;
	new Float:x2 = 0.0;
	new Float:w = 0.0;
	do {
		new Float:random1 = GetRandomFloat(0.0, 1.0);
		new Float:random2 = GetRandomFloat(0.0, 1.0);
		x1 = random1 * 2.0 - 1.0;
		x2 = random2 * 2.0 - 1.0;
		w = x1 * x1 + x2 * x2;
	} while (w >= 1.0);
	static Float:e = 1076754509;
	w = SquareRoot(Logarithm(w, e) / w * -2.0);
	new Float:y1 = x1 * w;
	new Float:y2 = x2 * w;
	new Float:z1 = y1 * std + mean;
	new Float:z2 = y2 * std - mean;
	if (signBit == 1)
	{
		return z1;
	}
	return z2;
}

public Action:Timer_LungeInterval(Handle:timer, any:client)
{
	bCanLunge[client] = 1;
	return Action:0;
}

public Spitter_OnModuleStart()
{
	return 0;
}

public Spitter_OnModuleEnd()
{
	return 0;
}

public Charger_OnModuleStart()
{
	hCvarChargeProximity = CreateConVar("ai_charge_proximity", "250", "How close a charger will approach before charging", 0, false, 0.0, false, 0.0);
	hCvarHealthThresholdCharger = CreateConVar("ai_health_threshold_charger", "300", "Charger will charge if its health drops to this level", 0, false, 0.0, false, 0.0);
	return 0;
}

public Charger_OnModuleEnd()
{
	return 0;
}

public Action:Charger_OnSpawn(botCharger)
{
	bShouldCharge[botCharger] = 0;
	return Action:3;
}

public Action:Charger_OnPlayerRunCmd(charger, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	new Float:chargerPos[3] = 0.0;
	GetClientAbsOrigin(charger, chargerPos);
	new target = GetClientAimTarget(charger, true);
	new iSurvivorProximity = GetSurvivorProximity(chargerPos, target);
	new chargerHealth = GetEntProp(charger, PropType:0, "m_iHealth", 4, 0);
	new var1;
	if (chargerHealth > GetConVarInt(hCvarHealthThresholdCharger) && iSurvivorProximity > GetConVarInt(hCvarChargeProximity))
	{
		if (!bShouldCharge[charger])
		{
			BlockCharge(charger);
			return Action:1;
		}
	}
	else
	{
		bShouldCharge[charger] = 1;
	}
	return Action:0;
}

BlockCharge(charger)
{
	new chargeEntity = GetEntPropEnt(charger, PropType:0, "m_customAbility", 0);
	new bool:bHasSight = GetEntProp(charger, PropType:0, "m_hasVisibleThreats", 4, 0);
	new var1;
	if (chargeEntity > 0 || !bHasSight)
	{
		SetEntPropFloat(chargeEntity, PropType:0, "m_timestamp", GetGameTime() + 0.1, 0);
	}
	return 0;
}

Charger_OnCharge(charger)
{
	new aimTarget = GetClientAimTarget(charger, true);
	if (!IsSurvivor(aimTarget))
	{
		new Float:chargerPos[3] = 0.0;
		GetClientAbsOrigin(charger, chargerPos);
		new newTarget = GetClosestSurvivor(chargerPos, aimTarget);
		new var1;
		if (newTarget != -1 && GetSurvivorProximity(chargerPos, newTarget) <= GetConVarInt(hCvarChargeProximity))
		{
			aimTarget = newTarget;
		}
		ChargePrediction(charger, aimTarget);
	}
	return 0;
}

ChargePrediction(charger, survivor)
{
	new var1;
	if (!IsBotCharger(charger) || !IsSurvivor(survivor))
	{
		return 0;
	}
	new Float:survivorPos[3] = 0.0;
	new Float:chargerPos[3] = 0.0;
	new Float:attackDirection[3] = 0.0;
	new Float:attackAngle[3] = 0.0;
	GetClientAbsOrigin(charger, chargerPos);
	GetClientAbsOrigin(survivor, survivorPos);
	MakeVectorFromPoints(chargerPos, survivorPos, attackDirection);
	GetVectorAngles(attackDirection, attackAngle);
	TeleportEntity(charger, NULL_VECTOR, attackAngle, NULL_VECTOR);
	return 0;
}

public Jockey_OnModuleStart()
{
	hCvarJockeyLeapRange = FindConVar("z_jockey_leap_range");
	SetConVarInt(hCvarJockeyLeapRange, 1000, false, false);
	HookEvent("jockey_ride", OnJockeyRide, EventHookMode:0);
	hCvarJockeyStumbleRadius = CreateConVar("ai_jockey_stumble_radius", "50", "Stumble radius of a jockey landing a ride", 0, false, 0.0, false, 0.0);
	return 0;
}

public Jockey_OnModuleEnd()
{
	ResetConVar(hCvarJockeyLeapRange, false, false);
	return 0;
}

// Bhop
#define BoostForward 60.0

public Action:Jockey_OnPlayerRunCmd(jockey, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon, bool:hasBeenShoved)
{
	new flags = GetEntityFlags(jockey);
	new Float:fVelocity[3] = 0.0;
	GetEntPropVector(jockey, PropType:1, "m_vecVelocity", fVelocity, 0);
	new Float:currentspeed = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0));
	decl Float:clientEyeAngles[3];
	GetClientEyeAngles(jockey, clientEyeAngles);
	new Float:jockeyPos[3] = 0.0;
	GetClientAbsOrigin(jockey, jockeyPos);
	new iSurvivorsProximity = GetSurvivorProximity(jockeyPos, -1);
	new bool:bHasSight = GetEntProp(jockey, PropType:0, "m_hasVisibleThreats", 4, 0);
	new var1;
	// if (bHasSight && 600 > iSurvivorsProximity > 250 && currentspeed > 200.0)
	// {
	// 	if (flags & 1)
	// 	{
	// 		buttons = buttons | 4;
	// 		buttons = buttons | 2;
	// 		// if (buttons & 8)
	// 		// {
	// 		// 	Client_Push(jockey, clientEyeAngles, 60.0, 6300);
	// 		// }
	// 		// if (buttons & 16)
	// 		// {
	// 		// 	Client_Push(jockey, clientEyeAngles, 60.0, 6312);
	// 		// }
	// 		// if (buttons & 512)
	// 		// {
	// 		// 	Client_Push(jockey, clientEyeAngles, 60.0, 6324);
	// 		// }
	// 		// if (buttons & 1024)
	// 		// {
	// 		// 	Client_Push(jockey, clientEyeAngles, 60.0, 6336);
	// 		// }
	// 		if(buttons & IN_FORWARD)
	// 			Client_Push(jockey,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
					
	// 		if(buttons & IN_BACK){
	// 			clientEyeAngles[1] += 180.0;
	// 			Client_Push(jockey,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
	// 		}
					
	// 		if(buttons & IN_MOVELEFT){
	// 			clientEyeAngles[1] += 90.0;
	// 			Client_Push(jockey,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
	// 		}
					
	// 		if(buttons & IN_MOVERIGHT){
	// 			clientEyeAngles[1] += -90.0;
	// 			Client_Push(jockey,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
	// 		}
	// 	}
	// 	if (GetEntityMoveType(jockey) & 9)
	// 	{
	// 		buttons = buttons & -3;
	// 		buttons = buttons & -5;
	// 	}
	// code from: https://github.com/TGMaster/Sourcepawn/blob/master/hardcoop/ai_tankbehaviour.sp
	if (bHasSight && 600 > iSurvivorsProximity > 250 && currentspeed > 200.0)
	{
		buttons &= ~IN_ATTACK2;			// Block throwing rock
		if (flags & FL_ONGROUND) {
			buttons |= IN_DUCK;
			buttons |= IN_JUMP;
			if(buttons & IN_FORWARD)
				Client_Push(jockey,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
					
			if(buttons & IN_BACK){
				clientEyeAngles[1] += 180.0;
				Client_Push(jockey,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
			}
					
			if(buttons & IN_MOVELEFT){
				clientEyeAngles[1] += 90.0;
				Client_Push(jockey,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
			}
					
			if(buttons & IN_MOVERIGHT){
				clientEyeAngles[1] += -90.0;
				Client_Push(jockey,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
			}
		}
		//Block Jumping and Crouching when on ladder
		if (GetEntityMoveType(jockey) & MOVETYPE_LADDER) {
			buttons &= ~IN_JUMP;
			buttons &= ~IN_DUCK;
		}
	}
	return Action:0;
}

public Action:Jockey_OnSpawn(botJockey)
{
	bCanLeap[botJockey] = 1;
	return Action:3;
}

public Jockey_OnShoved(botJockey)
{
	bCanLeap[botJockey] = 0;
	new leapCooldown = GetConVarInt(FindConVar("z_jockey_leap_again_timer"));
	CreateTimer(float(leapCooldown), Timer_LeapCooldown, botJockey, 2);
	return 0;
}

public Action:Timer_LeapCooldown(Handle:timer, any:jockey)
{
	bCanLeap[jockey] = 1;
	return Action:0;
}

public OnJockeyRide(Handle:event, String:name[], bool:dontBroadcast)
{
	// if (IsCoop())
	// {
	// 	new attacker = GetClientOfUserId(GetEventInt(event, "userid", 0));
	// 	new victim = GetClientOfUserId(GetEventInt(event, "victim", 0));
	// 	new var1;
	// 	if (attacker > 0 && victim > 0)
	// 	{
	// 		StumbleBystanders(victim, attacker);
	// 	}
	// }
	return 0;
}

// bool:IsCoop()
// {
// 	decl String:GameName[16];
// 	GetConVarString(FindConVar("mp_gamemode"), GameName, 16);
// 	new var1;
// 	return !StrEqual(GameName, "versus", false) && !StrEqual(GameName, "scavenge", false);
// }

// StumbleBystanders(pinnedSurvivor, pinner)
// {
// 	decl Float:pinnedSurvivorPos[3];
// 	decl Float:pos[3];
// 	decl Float:dir[3];
// 	GetClientAbsOrigin(pinnedSurvivor, pinnedSurvivorPos);
// 	new radius = GetConVarInt(hCvarJockeyStumbleRadius);
// 	new i = 1;
// 	while (i <= MaxClients)
// 	{
// 		new var1;
// 		if (IsClientInGame(i) && IsPlayerAlive(i) && IsSurvivor(i))
// 		{
// 			new var2;
// 			if (pinnedSurvivor != i && pinner != i && !IsPinned(i))
// 			{
// 				GetClientAbsOrigin(i, pos);
// 				SubtractVectors(pos, pinnedSurvivorPos, dir);
// 				if (GetVectorLength(dir, false) <= float(radius))
// 				{
// 					NormalizeVector(dir, dir);
// 					L4D_StaggerPlayer(i, pinnedSurvivor, dir);
// 				}
// 			}
// 		}
// 		i++;
// 	}
// 	return 0;
// }

public Tank_OnModuleStart()
{
	hCvarTankBhop = CreateConVar("ai_tank_bhop", "1", "Flag to enable bhop facsimile on AI tanks", 0, false, 0.0, false, 0.0);
	return 0;
}

public Action:Tank_OnPlayerRunCmd(tank, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (GetConVarBool(hCvarTankBhop))
	{
		new flags = GetEntityFlags(tank);
		new Float:fVelocity[3] = 0.0;
		GetEntPropVector(tank, PropType:1, "m_vecVelocity", fVelocity, 0);
		new Float:currentspeed = SquareRoot(Pow(fVelocity[0], 2.0) + Pow(fVelocity[1], 2.0));
		decl Float:clientEyeAngles[3];
		GetClientEyeAngles(tank, clientEyeAngles);
		new Float:tankPos[3] = 0.0;
		GetClientAbsOrigin(tank, tankPos);
		new iSurvivorsProximity = GetSurvivorProximity(tankPos, -1);
		new bool:bHasSight = GetEntProp(tank, PropType:0, "m_hasVisibleThreats", 4, 0);
		new var1;
	// 	if (bHasSight && 600 > iSurvivorsProximity > 160 && currentspeed > 200.0)
	// 	{
	// 		if (flags & 1)
	// 		{
	// 			buttons = buttons | 4;
	// 			buttons = buttons | 2;
	// 			// if (buttons & 8)
	// 			// {
	// 			// 	Client_Push(tank, clientEyeAngles, 60.0, 6528);
	// 			// }
	// 			// if (buttons & 16)
	// 			// {
	// 			// 	Client_Push(tank, clientEyeAngles, 60.0, 6540);
	// 			// }
	// 			// if (buttons & 512)
	// 			// {
	// 			// 	Client_Push(tank, clientEyeAngles, 60.0, 6552);
	// 			// }
	// 			// if (buttons & 1024)
	// 			// {
	// 			// 	Client_Push(tank, clientEyeAngles, 60.0, 6564);
	// 			// }
	// 		if(buttons & IN_FORWARD)
	// 			Client_Push(tank,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
					
	// 		if(buttons & IN_BACK){
	// 			clientEyeAngles[1] += 180.0;
	// 			Client_Push(tank,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
	// 		}
					
	// 		if(buttons & IN_MOVELEFT){
	// 			clientEyeAngles[1] += 90.0;
	// 			Client_Push(tank,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
	// 		}
					
	// 		if(buttons & IN_MOVERIGHT){
	// 			clientEyeAngles[1] += -90.0;
	// 			Client_Push(tank,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
	// 		}
	// 		}
	// 		if (GetEntityMoveType(tank) & 9)
	// 		{
	// 			buttons = buttons & -3;
	// 			buttons = buttons & -5;
	// 		}
	// 	}
	// }
		if (bHasSight && 600 > iSurvivorsProximity > 250 && currentspeed > 200.0)
		{
			buttons &= ~IN_ATTACK2;			// Block throwing rock
			if (flags & FL_ONGROUND) {
				buttons |= IN_DUCK;
				buttons |= IN_JUMP;
				if(buttons & IN_FORWARD)
					Client_Push(tank,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
						
				if(buttons & IN_BACK){
					clientEyeAngles[1] += 180.0;
					Client_Push(tank,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
				}
						
				if(buttons & IN_MOVELEFT){
					clientEyeAngles[1] += 90.0;
					Client_Push(tank,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
				}
						
				if(buttons & IN_MOVERIGHT){
					clientEyeAngles[1] += -90.0;
					Client_Push(tank,clientEyeAngles,BoostForward,VelocityOverride:{VelocityOvr_None,VelocityOvr_None,VelocityOvr_None});
				}
			}
			//Block Jumping and Crouching when on ladder
			if (GetEntityMoveType(tank) & MOVETYPE_LADDER) {
				buttons &= ~IN_JUMP;
				buttons &= ~IN_DUCK;
			}
		}
	}
	return Action:0;
}

public Witch_OnModuleStart()
{
	return 0;
}

public Witch_OnModuleEnd()
{
	return 0;
}

public void:OnPluginStart()
{
	HookEvent("player_spawn", InitialiseSpecialInfected, EventHookMode:0);
	HookEvent("ability_use", OnAbilityUse, EventHookMode:0);
	Smoker_OnModuleStart();
	Hunter_OnModuleStart();
	Spitter_OnModuleStart();
	Boomer_OnModuleStart();
	Jockey_OnModuleStart();
	Charger_OnModuleStart();
	Tank_OnModuleStart();
	Witch_OnModuleStart();
	// return void:0;
}

public void:OnPluginEnd()
{
	Smoker_OnModuleEnd();
	Hunter_OnModuleEnd();
	Spitter_OnModuleEnd();
	Boomer_OnModuleEnd();
	Charger_OnModuleEnd();
	Witch_OnModuleEnd();
	// return void:0;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	new var1;
	if (IsBotInfected(client) && IsPlayerAlive(client))
	{
		new botInfected = client;
		switch (GetInfectedClass(botInfected))
		{
			case 3:
			{
				if (!bHasBeenShoved[botInfected])
				{
					return Hunter_OnPlayerRunCmd(botInfected, buttons, impulse, vel, angles, weapon);
				}
			}
			case 5:
			{
				return Jockey_OnPlayerRunCmd(botInfected, buttons, impulse, vel, angles, weapon, bHasBeenShoved[botInfected]);
			}
			case 6:
			{
				return Charger_OnPlayerRunCmd(botInfected, buttons, impulse, vel, angles, weapon);
			}
			case 8:
			{
				return Tank_OnPlayerRunCmd(botInfected, buttons, impulse, vel, angles, weapon);
			}
			default:
			{
				return Action:0;
			}
		}
	}
	return Action:0;
}

public Action:InitialiseSpecialInfected(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid", 0));
	if (IsBotInfected(client))
	{
		new botInfected = client;
		bHasBeenShoved[client] = 0;
		switch (GetInfectedClass(botInfected))
		{
			case 3:
			{
				return Hunter_OnSpawn(botInfected);
			}
			case 5:
			{
				return Jockey_OnSpawn(botInfected);
			}
			case 6:
			{
				return Charger_OnSpawn(botInfected);
			}
			default:
			{
				return Action:3;
			}
		}
	}
	return Action:3;
}

public Action:OnAbilityUse(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid", 0));
	if (IsBotInfected(client))
	{
		new bot = client;
		bHasBeenShoved[bot] = 0;
		new String:abilityName[32];
		GetEventString(event, "ability", abilityName, 32, "");
		if (StrEqual(abilityName, "ability_lunge", true))
		{
			return Hunter_OnPounce(bot);
		}
		if (StrEqual(abilityName, "ability_charge", true))
		{
			Charger_OnCharge(bot);
		}
	}
	return Action:3;
}

bool:IsTargetWatchingAttacker(attacker, offsetThreshold)
{
	new bool:isWatching = 1;
	new var1;
	if (GetClientTeam(attacker) == 3 && IsPlayerAlive(attacker))
	{
		new target = GetClientAimTarget(attacker, true);
		if (IsSurvivor(target))
		{
			new aimOffset = RoundToNearest(GetPlayerAimOffset(target, attacker));
			if (aimOffset <= offsetThreshold)
			{
				isWatching = true;
			}
			else
			{
				isWatching = false;
			}
		}
	}
	return isWatching;
}

Float:GetPlayerAimOffset(attacker, target)
{
	new var1;
	if (!IsClientConnected(attacker) || !IsClientInGame(attacker) || !IsPlayerAlive(attacker))
	{
		ThrowError("Client is not Alive.");
	}
	new var2;
	if (!IsClientConnected(target) || !IsClientInGame(target) || !IsPlayerAlive(target))
	{
		ThrowError("Target is not Alive.");
	}
	decl Float:attackerPos[3];
	decl Float:targetPos[3];
	decl Float:aimVector[3];
	decl Float:directVector[3];
	decl Float:resultAngle;
	GetClientEyeAngles(attacker, aimVector);
	new var3 = 0.0;
	aimVector[2] = var3;
	aimVector[0] = var3;
	GetAngleVectors(aimVector, aimVector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(aimVector, aimVector);
	GetClientAbsOrigin(target, targetPos);
	GetClientAbsOrigin(attacker, attackerPos);
	new var4 = 0.0;
	targetPos[2] = var4;
	attackerPos[2] = var4;
	MakeVectorFromPoints(attackerPos, targetPos, directVector);
	NormalizeVector(directVector, directVector);
	resultAngle = RadToDeg(ArcCosine(GetVectorDotProduct(aimVector, directVector)));
	return resultAngle;
}

 