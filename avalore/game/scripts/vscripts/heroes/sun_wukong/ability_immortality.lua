ability_immortality = class({})

LinkLuaModifier("modifier_wukong_immortality", "heroes/sun_wukong/modifier_wukong_immortality.lua", LUA_MODIFIER_MOTION_NONE)

function ability_immortality:GetIntrinsicModifierName()
    return "modifier_wukong_immortality"
end

function ability_immortality:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
end