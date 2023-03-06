require("scripts/vscripts/items/mercs_super_creeps/merc_spawn_common")
require(REQ_LIB_TIMERS)

item_merc_tower = class({})

function item_merc_tower:GetBehavior()
    return MercSpawnCommon:Merc_GetBehavior()
end

function item_merc_tower:OnAbilityPhaseInterrupted()
    return MercSpawnCommon:OnAbilityPhaseInterrupted()
end

function item_merc_tower:OnAbilityPhaseStart()
    return MercSpawnCommon:OnAbilityPhaseStart()
end

function item_merc_tower:CastFilterResultLocation(location)
    return MercSpawnCommon:Merc_CastFilterResultLocation(location, self:GetEntityIndex())
end

function item_merc_tower:OnSpellStart()
    MercSpawnCommon:Merc_OnSpellStart(self, "npc_avalore_merc_building_watch_tower", 1)
end