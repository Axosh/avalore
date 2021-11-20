ability_tyrant_king = class({})

LinkLuaModifier("modifier_tyrant_king_aura",    "scripts/vscripts/heroes/gilgamesh/modifier_tyrant_king_aura.lua", LUA_MODIFIER_MOTION_NONE)

function ability_tyrant_king:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local ability = self
    local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(  caster,
                            ability,
                            "modifier_tyrant_king_aura",
                            {duration = duration})
end

function ability_tyrant_king:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end