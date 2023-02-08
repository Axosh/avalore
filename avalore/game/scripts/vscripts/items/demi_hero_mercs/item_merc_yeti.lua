require("buildings/hire_queue")
require("controllers/demi_hero_manager")
require("scripts/vscripts/items/mercs_super_creeps/merc_spawn_common")
require(REQ_LIB_TIMERS)

item_merc_yeti = class({})

-- function item_merc_yeti:OnSpellStart()
--     if not IsServer() then return end
    
--     local caster = self:GetCaster()
--     local team = caster:GetTeam()
--     local unit = "npc_avalore_merc_demi_hero_yeti"

--     --local gold_cost = 500 + (DemiHeroManager:GetDemiHeroLevel(team, unit) * 100)
--     local gold_cost = 0 -- for testing
    
--     HireUnit(unit, team, gold_cost, self:GetOwner())
-- end

-- function item_merc_yeti:GetCooldown(level)

-- end

-- function item_merc_yeti:GetGoldCost(level)

-- end

function item_merc_yeti:GetBehavior()
    return MercSpawnCommon:Merc_GetBehavior()
end

function item_merc_yeti:CastFilterResultLocation(location)
    return MercSpawnCommon:Merc_CastFilterResultLocation(location, self:GetEntityIndex())
end

function item_merc_yeti:OnSpellStart()
    print("item_merc_yeti:OnSpellStart()")
    MercSpawnCommon:Merc_OnSpellStart(self, "npc_avalore_merc_demi_hero_yeti", 3)
end