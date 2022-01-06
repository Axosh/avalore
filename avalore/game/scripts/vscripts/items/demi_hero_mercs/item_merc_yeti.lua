require("buildings/hire_queue")
require("controllers/demi_hero_manager")

item_merc_yeti = class({})

function item_merc_yeti:OnSpellStart()
    if not IsServer() then return end
    
    local caster = self:GetCaster()
    local team = caster:GetTeam()
    local unit = "npc_avalore_merc_demi_hero_yeti"

    --local gold_cost = 500 + (DemiHeroManager:GetDemiHeroLevel(team, unit) * 100)
    local gold_cost = 0 -- for testing
    
    HireUnit(unit, team, gold_cost, self:GetOwner())
end

-- function item_merc_yeti:GetCooldown(level)

-- end

-- function item_merc_yeti:GetGoldCost(level)

-- end