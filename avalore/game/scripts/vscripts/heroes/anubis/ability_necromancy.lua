ability_necromancy = class({})

LinkLuaModifier("modifier_necromancy_aura", "heroes/anubis/modifier_necromancy_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_necromancy_aura_buff", "heroes/anubis/modifier_necromancy_aura_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_necromancy_aura_buff_form", "heroes/anubis/modifier_necromancy_aura_buff_form", LUA_MODIFIER_MOTION_NONE)


function ability_necromancy:GetIntrinsicModifierName()
    return "modifier_necromancy_aura"
end