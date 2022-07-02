ability_immortality = class({})

LinkLuaModifier("modifier_wukong_immortality", "heroes/sun_wukong/modifier_wukong_immortality.lua", LUA_MODIFIER_MOTION_NONE)
--TALENTS
LinkLuaModifier("modifier_talent_rez_no_mana", "heroes/sun_wukong/modifier_talent_rez_no_mana.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_multiple_immortality", "heroes/sun_wukong/modifier_talent_multiple_immortality.lua", LUA_MODIFIER_MOTION_NONE)

function ability_immortality:GetIntrinsicModifierName()
    return "modifier_wukong_immortality"
end

function ability_immortality:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function ability_immortality:GetManaCost(level)
    if self:GetCaster():HasTalent("talent_rez_no_mana") then
        return 0
    else
        return self:GetSpecialValueFor("mana_cost")
    end
end

-- NOTE: apparently none of this stuff works via code, have to fall back to modifier system
-- function ability_immortality:GetMaxAbilityCharges(level)
--     return self:GetCaster():FindTalentValue("talent_multiple_immortality", "extra_rez_count")
-- end

-- function ability_immortality:GetInitialAbilityCharges(level)
--     return self:GetCaster():FindTalentValue("talent_multiple_immortality", "extra_rez_count")
-- end