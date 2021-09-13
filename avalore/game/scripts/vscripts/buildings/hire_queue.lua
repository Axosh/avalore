require("score")
require("spawners")

hire_queue = class({})
avalore_merc_train_melee_creep = class({})

-- function HireQueue:Init(building)
--     print("HireQueue:Init()")
-- end

-- -- Static function
-- function Enqueue(event)
--     print("Enqueue()")
--     local caster = event.caster
--     local ability = event.ability
--     local playerID = caster:GetPlayerOwnerID()
--     local gold_cost = ability:GetGoldCost( ability:GetLevel() - 1 )

--     if not self.queue then
--         self.queue = {}
--     end

--     -- TODO: don't hard-code this
--     if not Score.RadiSharedGoldCurr >= gold_cost then
--         SendErrorMessage(playerID, "#error_not_enough_gold_radiant")
--     end

--     -- TODO: limit how many units can be hired
-- end

function avalore_merc_train_melee_creep:OnSpellStart()
    print("HireQueue:OnSpellStart()")
    local caster = self:GetCaster()
    local team = caster:GetTeam()
    local lane = self:GetParent().lane
    local gold_cost = self:GetSpecialValueFor("gold_cost")
    local unit = ""

    if team == DOTA_TEAM_GOODGUYS then
        if not Score.RadiSharedGoldCurr > gold_cost then
            print("[HireQueue:OnSpellStart()] Not enough gold")
            SendErrorMessage(playerID, "#error_not_enough_gold_radiant")
            return
        end
        unit = self:GetSpecialValueFor("unit_radi")
    else
        if not Score.DireSharedGoldCurr > gold_cost then
            print("[HireQueue:OnSpellStart()] Not enough gold")
            SendErrorMessage(playerID, "#error_not_enough_gold_dire")
            return
        end
        unit = self:GetSpecialValueFor("unit_dire")
    end

    if not Spawners.MercQueue[lane] then
        Spawners.MercQueue[lane] = {}
    end

    --local unit_to_queue = self:MapUnit()
    print("Queueing up a " .. unit)
    table.insert(Spawners.MercQueue[lane], unit)

end

-- function DequeueUnit( event )
--     -- TODO
-- end

function avalore_merc_train_melee_creep:MapUnit(unit, team)
    local prefix = ""
    if team == DOTA_TEAM_GOODGUYS then
        prefix = "npc_dota_creep_goodguys_"
    else
        prefix = "npc_dota_creep_badguys_"
    end

    if unit == "melee" or unit == "ranged" then
        return (prefix .. unit)
    end
end