ability_deadly_fog = class({})

LinkLuaModifier( "modifier_deadly_fog", "heroes/davy_jones/modifier_deadly_fog.lua", LUA_MODIFIER_MOTION_NONE )

function ability_deadly_fog:Precache( context )
    PrecacheResource("particle", "particles/units/heroes/hero_visage/visage_grave_chill_fog.vpcf", context)
end

function ability_deadly_fog:OnSpellStart()
    local caster = self:GetCaster()
    local modifier_deadly_fog       = "modifier_deadly_fog"
    local modifier_deadly_fog_invis = "modifier_deadly_fog_invis"

    local radius = self:GetSpecialValueFor("radius")

    caster:AddNewModifier(caster, self, modifier_deadly_fog,        {duration = self:GetSpecialValueFor("duration")})
    caster:AddNewModifier(caster, self, modifier_deadly_fog_invis,  nil)
end