ability_wrangle = class({})

LinkLuaModifier("modifier_wrangle_thinker", "heroes/pecos_bill/modifier_wrangle_thinker.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_wrangle_debuff",  "heroes/pecos_bill/modifier_wrangle_debuff.lua",  LUA_MODIFIER_MOTION_HORIZONTAL )

LinkLuaModifier("modifier_talent_rope_em_in", "heroes/pecos_bill/modifier_talent_rope_em_in.lua", LUA_MODIFIER_MOTION_NONE )

function ability_wrangle:Precache(context)
    PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_hoodwink.vsndevts", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_target.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_medusa/medusa_mystic_snake_projectile.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_hoodwink/hoodwink_bushwhack_fail.vpcf", context )
end

function ability_wrangle:Spawn()
    if not IsServer() then return end
end

function ability_wrangle:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function ability_wrangle:GetCastRange()
    return self:GetSpecialValueFor("base_range") + self:GetCaster():FindTalentValue("talent_rope_em_in", "bonus_range")
end

function ability_wrangle:OnSpellStart()
    if not IsServer() then return end
    -- unit identifier
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    PrintVector(point, "Point")

    -- load data
    local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

    -- calculate delay
    local delay = (point-caster:GetOrigin()):Length2D()/projectile_speed

    -- create thinker at location
    local target = CreateModifierThinker(
        caster, -- player source
        self, -- ability source
        "modifier_wrangle_thinker", -- modifier name
        {
            duration = delay,
            --location = point
        }, -- kv
        point,
        caster:GetTeamNumber(),
        false
    )
end