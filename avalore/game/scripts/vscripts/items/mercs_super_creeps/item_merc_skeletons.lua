require("scripts/vscripts/items/mercs_super_creeps/merc_spawn_common")
require(REQ_LIB_TIMERS)

item_merc_skeletons = class({})

function item_merc_skeletons:GetBehavior()
    return MercSpawnCommon:Merc_GetBehavior()
end

function item_merc_skeletons:CastFilterResultLocation(location)
    return MercSpawnCommon:Merc_CastFilterResultLocation(location, self:GetEntityIndex())
end

function item_merc_skeletons:OnSpellStart()
    MercSpawnCommon:Merc_OnSpellStart(self, "npc_avalore_merc_skeleton", 3)
end