-- require("buildings/hire_queue")
-- require("controllers/demi_hero_manager")
require("scripts/vscripts/items/mercs_super_creeps/merc_spawn_common")
require(REQ_LIB_TIMERS)

ability_merc_train_yeti = class({})

-- function ability_merc_train_yeti:OnSpellStart()
--     if not IsServer() then return end
    
--     local caster = self:GetCaster()
--     local team = caster:GetTeam()
--     local unit = "npc_avalore_merc_demi_hero_yeti"

--     --local gold_cost = 500 + (DemiHeroManager:GetDemiHeroLevel(team, unit) * 100)
--     local gold_cost = 0 -- for testing
    
--     HireUnit(unit, team, gold_cost, self:GetOwner())
-- end

-- function ability_merc_train_yeti:GetCooldown(level)

-- end

-- function ability_merc_train_yeti:GetGoldCost(level)

-- end

-- function ability_merc_train_yeti:GetBehavior()
--     return MercSpawnCommon:Merc_GetBehavior()
-- end

-- function ability_merc_train_yeti:OnAbilityPhaseStart()
--     print("TEST")
--     return true
-- end

function ability_merc_train_yeti:CastFilterResultLocation(location)
    -- print("test")
    return MercSpawnCommon:Merc_CastFilterResultLocation(location, self:GetEntityIndex())
    --return UF_SUCCESS
end

function ability_merc_train_yeti:OnSpellStart()
    print("ability_merc_train_yeti:OnSpellStart()")
    MercSpawnCommon:Merc_OnSpellStart(self, "npc_avalore_merc_demi_hero_yeti", 1)
end

-- function ability_merc_train_yeti:AbilitySharedWithTeammates()
--     return true
-- end