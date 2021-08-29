ability_avalore_marksmanship = class({})
LinkLuaModifier( "modifier_avalore_marksmanship", "heroes/robin_hood/modifier_avalore_marksmanship.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_marksmanship_debuff", "heroes/robin_hood/modifier_marksmanship_debuff.lua", LUA_MODIFIER_MOTION_NONE )

function ability_avalore_marksmanship:GetIntrinsicModifierName()
	--if self:GetCaster():GetAbilityByIndex(0):GetLevel() < 1 and self:GetCaster():GetAbilityByIndex(0):GetToggleState() == false then
	return "modifier_avalore_marksmanship"
	--end
end
