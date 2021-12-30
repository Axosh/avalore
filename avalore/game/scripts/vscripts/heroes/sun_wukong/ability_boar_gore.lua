ability_boar_gore = ability_boar_gore or class({})

LinkLuaModifier("modifier_boar_gore" ,        "heroes/sun_wukong/modifier_boar_gore",        LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boar_gore_debuff" , "heroes/sun_wukong/modifier_boar_gore_debuff", LUA_MODIFIER_MOTION_NONE)

function ability_boar_gore:GetIntrinsicModifierName()
	return "modifier_boar_gore"
end
