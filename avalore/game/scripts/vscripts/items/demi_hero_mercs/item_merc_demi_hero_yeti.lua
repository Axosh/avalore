require("scripts/vscripts/buildings/hire_queue")
require("scripts/vscripts/controllers/demi_hero_manager")

item_merc_demi_hero_yeti = class({})

function item_merc_demi_hero_yeti:OnSpellStart()
    if not IsServer() then return end
    print("item_merc_demi_hero_yeti:OnSpellStart()")
    
    local caster = self:GetCaster()
    local team = caster:GetTeam()
    local unit = "npc_avalore_merc_demi_hero_yeti"

    --local gold_cost = 500 + (DemiHeroManager:GetDemiHeroLevel(team, unit) * 100)
    local gold_cost = 0 -- for testing

    HireUnit(unit, team, gold_cost, self:GetOwner())

    local items = Entities:FindAllByName(self:GetName())
    for _,item in pairs(items) do
        if item:GetTeamNumber() == self:GetTeamNumber() then
            item:StartCooldown(self:GetCooldown(self:GetLevel()))
        end
    end
end

-- function item_merc_demi_hero_yeti:GetCooldown(level)

-- end

-- function item_merc_demi_hero_yeti:GetGoldCost(level)

-- end