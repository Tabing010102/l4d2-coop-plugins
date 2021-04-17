enum L4D2GlowType
{
    L4D2Glow_None = 0,
    L4D2Glow_OnUse,
    L4D2Glow_OnLookAt,
    L4D2Glow_Constant
}

/**
 * Set entity glow. This is consider safer and more robust over setting each glow
 * property on their own because glow offset will be check first.
 *
 * @param entity			Entity index.
 * @parma type				Glow type.
 * @param iRange			Glow max range, 0 for unlimited.
 * @param iMinRange			Glow min range.
 * @param iColorOverride	Glow color, RGB.
 * @param bFlashing			Whether the glow will be flashing.
 *
 * @return					True if glow was set, false if entity does not support
 *							glow.
 */
stock bool L4D2_SetEntGlow(int entity, L4D2GlowType type, int iRange, int iMinRange, int iColorOverride[3], bool bFlashing)
{
	if (entity < 1 || !IsValidEntity(entity) || !IsValidEdict(entity))
	{
		return false;
	}
	
	char sEntityNetClass[128];
	GetEntityNetClass(entity, sEntityNetClass, sizeof(sEntityNetClass));
	if (FindSendPropInfo(sEntityNetClass, "m_iGlowType") != -1)
	{
		L4D2_SetEntGlow_Type(entity, type);
		L4D2_SetEntGlow_Range(entity, iRange);
		L4D2_SetEntGlow_MinRange(entity, iMinRange);
		L4D2_SetEntGlow_ColorOverride(entity, iColorOverride);
		L4D2_SetEntGlow_Flashing(entity, bFlashing);
		
		return true;
	}
	
	return false;
}

/**
 * Set entity glow type.
 *
 * @param entity		Entity index.
 * @param type			Glow type.
 *
 * @noreturn
 * @error				Invalid entity index or entity does not support glow.
 */
stock void L4D2_SetEntGlow_Type(int entity, L4D2GlowType type)
{
	SetEntProp(entity, Prop_Send, "m_iGlowType", type);
}

/**
 * Set entity glow range.
 *
 * @param entity        Entity index.
 * @parma iRange		Glow range.
 *
 * @noreturn
 * @error				Invalid entity index or entity does not support glow.
 */
stock void L4D2_SetEntGlow_Range(int entity, int iRange)
{
	SetEntProp(entity, Prop_Send, "m_nGlowRange", iRange);
}

/**
 * Set entity glow min range.
 *
 * @param entity		Entity index.
 * @parma iMinRange		Glow min range.
 *
 * @noreturn
 * @error				Invalid entity index or entity does not support glow.
 */
stock void L4D2_SetEntGlow_MinRange(int entity, int iMinRange)
{
	SetEntProp(entity, Prop_Send, "m_nGlowRangeMin", iMinRange);
}

/**
 * Set entity glow color.
 *
 * @param entity			Entity index.
 * @parma iColorOverride	Glow color, RGB.
 *
 * @noreturn
 * @error					Invalid entity index or entity does not support glow.
 */
stock void L4D2_SetEntGlow_ColorOverride(int entity, int iColorOverride[3])
{
	SetEntProp(entity, Prop_Send, "m_glowColorOverride", iColorOverride[0] + (iColorOverride[1] * 256) + (iColorOverride[2] * 65536));
}

/**
 * Set entity glow flashing state.
 *
 * @param entity        Entity index.
 * @parma bFlashing		Whether glow will be flashing.
 *
 * @noreturn
 * @error				Invalid entity index or entity does not support glow.
 */
stock void L4D2_SetEntGlow_Flashing(int entity, bool bFlashing)
{
	SetEntProp(entity, Prop_Send, "m_bFlashing", bFlashing);
}

