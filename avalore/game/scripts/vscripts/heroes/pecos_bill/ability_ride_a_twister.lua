ability_ride_a_twister = class({})

LinkLuaModifier("modifier_ride_a_twister", "heroes/pecos_bill/modifier_ride_a_twister.lua",        LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_talent_class_5_twister", "heroes/pecos_bill/modifier_talent_class_5_twister.lua",        LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_talent_dust_devil", "heroes/pecos_bill/modifier_talent_dust_devil.lua",        LUA_MODIFIER_MOTION_NONE )

function ability_ride_a_twister:Precache(context)
    PrecacheResource("particle", "particles/units/heroes/hero_invoker/invoker_tornado_funnel.vpcf",         context)
    PrecacheResource("particle", "particles/units/heroes/hero_invoker/invoker_tornado_funnel_detail.vpcf",  context)
end

function ability_ride_a_twister:OnSpellStart()
    local caster = self:GetCaster()
    --local radius = self:GetSpecialValueFor("radius")

    if not IsServer() then return end

    --PrintVector(caster:GetAbsOrigin(), "Before")

    caster:AddNewModifier(caster, self, "modifier_ride_a_twister", {duration = self:GetSpecialValueFor("duration")})
    if caster:HasTalent("talent_dust_devil") then
        caster:AddNewModifier(caster, self, "modifier_dust_devil", {duration = self:GetSpecialValueFor("duration")})
    end
end