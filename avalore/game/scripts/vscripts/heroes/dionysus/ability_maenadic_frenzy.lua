ability_maenadic_frenzy = class({})

LinkLuaModifier("modifier_maenadic_frenzy_aura", "heroes/dionysus/modifier_maenadic_frenzy_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_limit_break", "heroes/dionysus/modifier_talent_limit_break.lua", LUA_MODIFIER_MOTION_NONE )

function ability_maenadic_frenzy:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local ability = self
    local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(  caster,
                            ability,
                            "modifier_maenadic_frenzy_aura",
                            {duration = duration})

    -- CreateModifierThinker(  caster, 
    --                         ability, 
    --                         "modifier_maenadic_frenzy_aura", 
    --                         {duration = duration}, 
    --                         caster:get, nTeamNumber, bPhantomBlocker)
end

function ability_maenadic_frenzy:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end 