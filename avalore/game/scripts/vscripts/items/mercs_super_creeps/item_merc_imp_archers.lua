require("scripts/vscripts/items/mercs_super_creeps/merc_spawn_common")
require(REQ_LIB_TIMERS)

item_merc_imp_archers = class({})

function item_merc_imp_archers:GetBehavior()
    return MercSpawnCommon:Merc_GetBehavior()
end

function item_merc_imp_archers:OnAbilityPhaseInterrupted()
    return MercSpawnCommon:OnAbilityPhaseInterrupted()
end

function item_merc_imp_archers:OnAbilityPhaseStart()
    return MercSpawnCommon:OnAbilityPhaseStart()
end

function item_merc_imp_archers:CastFilterResultLocation(location)
    return MercSpawnCommon:Merc_CastFilterResultLocation(location, self:GetEntityIndex())
end

function item_merc_imp_archers:OnSpellStart()
    MercSpawnCommon:Merc_OnSpellStart(self, "npc_avalore_merc_imp_archer", 2)
end