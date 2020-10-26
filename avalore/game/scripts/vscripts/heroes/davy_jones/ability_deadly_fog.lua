ability_deadly_fog = class({})

LinkLuaModifier( "modifier_deadly_fog",         "heroes/davy_jones/modifier_deadly_fog.lua",        LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_deadly_fog_invis",   "heroes/davy_jones/modifier_deadly_fog_invis.lua",  LUA_MODIFIER_MOTION_NONE )

function ability_deadly_fog:Precache( context )
    PrecacheResource("particle", "particles/econ/items/necrolyte/necro_ti9_immortal/necro_ti9_immortal_shroud.vpcf",    context)
    PrecacheResource("particle", "particles/generic_hero_status/status_invisibility_start.vpcf",                        context)
end

function ability_deadly_fog:OnSpellStart()
    local caster = self:GetCaster()
    local modifier_deadly_fog       = "modifier_deadly_fog"
    local modifier_deadly_fog_invis = "modifier_deadly_fog_invis"

    local radius = self:GetSpecialValueFor("radius")

    -- deals AOE damage
    caster:AddNewModifier(caster, self, modifier_deadly_fog,        {duration = self:GetSpecialValueFor("duration")})
    -- grants invis that breaks temporarily on attack
    caster:AddNewModifier(caster, self, modifier_deadly_fog_invis,  {duration = self:GetSpecialValueFor("duration")})
end