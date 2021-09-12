require("score")

if not HireQueue then
    HireQueue = class({})
end

function HireQueue:Init(building)
    print("HireQueue:Init()")
end

-- Static function
function Enqueue(event)
    print("Enqueue()")
    local caster = event.caster
    local ability = event.ability
    local playerID = caster:GetPlayerOwnerID()
    local gold_cost = ability:GetGoldCost( ability:GetLevel() - 1 )

    if not self.queue then
        self.queue = {}
    end

    -- TODO: don't hard-code this
    if not Score.RadiSharedGoldCurr >= gold_cost then
        SendErrorMessage(playerID, "#error_not_enough_gold_radiant")
    end

    -- TODO: limit how many units can be hired
end

function DequeueUnit( event )
    -- TODO
end