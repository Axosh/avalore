modifier_rainstorm_aura = class({})

LinkLuaModifier( "modifier_wet", "scripts/vscripts/modifiers/elemental_status/modifier_wet.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_rainstorm_aura:IsPurgable() return false end
function modifier_rainstorm_aura:IsAura() return true end

function modifier_rainstorm_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH
    --return DOTA_UNIT_TARGET_TEAM_ENEMY
end

-- function modifier_rainstorm_aura:GetAuraSearchFlags()
--     return 
-- end

function modifier_rainstorm_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_OTHER 
end

function modifier_rainstorm_aura:GetModifierAura()
    return "modifier_wet"
end

function modifier_rainstorm_aura:GetAuraRadius()
    return self.radius
end

function modifier_rainstorm_aura:OnCreated(kv)
    self.radius = kv.radius
end