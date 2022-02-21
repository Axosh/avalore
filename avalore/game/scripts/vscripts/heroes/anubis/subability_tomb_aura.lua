subability_tomb_aura = subability_tomb_aura or class({})

LinkLuaModifier("modifier_tomb_aura",    "scripts/vscripts/heroes/anubis/modifier_tomb_aura.lua", LUA_MODIFIER_MOTION_NONE)

function subability_tomb_aura:GetIntrinsicModifierName()
    return "modifier_tomb_aura"
end