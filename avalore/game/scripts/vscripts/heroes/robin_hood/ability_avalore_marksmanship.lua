ability_avalore_marksmanship = class({})
LinkLuaModifier( "modifier_avalore_marksmanship", "heroes/robin_hood/modifier_avalore_marksmanship.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_marksmanship_debuff", "heroes/robin_hood/modifier_marksmanship_debuff.lua", LUA_MODIFIER_MOTION_NONE )

function ability_avalore_marksmanship:GetIntrinsicModifierName()
	return "modifier_avalore_marksmanship"
end
