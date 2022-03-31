ability_marksmanship = class({})
LinkLuaModifier( "modifier_marksmanship", "heroes/robin_hood/modifier_marksmanship.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_marksmanship_debuff", "heroes/robin_hood/modifier_marksmanship_debuff.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_talent_chink_in_the_armor", "heroes/robin_hood/modifier_talent_chink_in_the_armor.lua", LUA_MODIFIER_MOTION_NONE )

function ability_marksmanship:GetIntrinsicModifierName()
	return "modifier_marksmanshp"
end
