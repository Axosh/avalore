require("scripts/vscripts/items/mercs_super_creeps/merc_spawn_common")
require(REQ_LIB_TIMERS)

item_merc_ent = class({})

function item_merc_ent:GetBehavior()
    return MercSpawnCommon:Merc_GetBehavior()
end

function item_merc_ent:OnAbilityPhaseInterrupted()
    return MercSpawnCommon:OnAbilityPhaseInterrupted()
end

function item_merc_ent:OnAbilityPhaseStart()
    return MercSpawnCommon:OnAbilityPhaseStart()
end

function item_merc_ent:CastFilterResultLocation(location)
    return MercSpawnCommon:Merc_CastFilterResultLocation(location, self:GetEntityIndex())
end

function item_merc_ent:OnSpellStart()
    MercSpawnCommon:Merc_OnSpellStart(self, "npc_avalore_merc_ent", 1)
end