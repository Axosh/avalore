require("references")
require("spawners")
require(REQ_LIB_TIMERS)
require(REQ_CONSTANTS)

item_merc_wendigo = class({})

function item_merc_wendigo:GetBehavior()
    return MercSpawnCommon:Merc_GetBehavior()
end

function item_merc_wendigo:OnAbilityPhaseInterrupted()
    return MercSpawnCommon:OnAbilityPhaseInterrupted()
end

function item_merc_wendigo:OnAbilityPhaseStart()
    return MercSpawnCommon:OnAbilityPhaseStart()
end

function item_merc_wendigo:CastFilterResultLocation(location)
    return MercSpawnCommon:Merc_CastFilterResultLocation(location, self:GetEntityIndex())
end

function item_merc_wendigo:OnSpellStart()
    MercSpawnCommon:Merc_OnSpellStart(self, "npc_avalore_merc_wendigo", 1)
end