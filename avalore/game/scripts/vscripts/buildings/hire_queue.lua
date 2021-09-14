require("score")
require("spawners")
require("utility_functions")

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
    if not IsServer() then return end
    print("HireQueue:OnSpellStart()")
    local caster = self:GetCaster()
    -- if caster then
    --     print(caster:GetPlayer())
    -- end
    local team = caster:GetTeam()
    local gold_cost = self:GetSpecialValueFor("gold_cost")
    local unit = ""

    if team == DOTA_TEAM_GOODGUYS then
        if not (Score.RadiSharedGoldCurr > gold_cost) then
            print("[HireQueue:OnSpellStart()] Not enough gold")
            -- local broadcast_obj = 
			-- {
			-- 	msg = "#error_not_enough_gold_radiant",
			-- 	time = 5,
			-- 	elaboration = "",
			-- 	type = MSG_TYPE_ERROR
			-- }
			-- CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(caster:GetPlayerID()), "broadcast_message", broadcast_obj )
            return
        end
        unit = "npc_dota_creep_goodguys_melee" --self:GetSpecialValueFor("unit_radi")
    else
        if not (Score.DireSharedGoldCurr > gold_cost) then
            print("[HireQueue:OnSpellStart()] Not enough gold")
            local broadcast_obj = 
			{
				msg = "#error_not_enough_gold_radiant",
				time = 5,
				elaboration = "",
				type = MSG_TYPE_ERROR
			}
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(caster:GetPlayerID()), "broadcast_message", broadcast_obj )
            return
        end
        unit = "npc_dota_creep_badguys_melee" -- self:GetSpecialValueFor("unit_dire")
    end
    

    --local lane = self:GetOwner().lane
    local lane = ""
    if self:GetOwner():GetAbsOrigin().x < 0 then
        if self:GetOwner():GetTeam() == DOTA_TEAM_BADGUYS then
            lane = Constants.KEY_DIRE_TOP
        else
            lane = Constants.KEY_RADIANT_TOP
        end
    else
        if self:GetOwner():GetTeam() == DOTA_TEAM_BADGUYS then
            lane = Constants.KEY_DIRE_BOT
        else
            lane = Constants.KEY_RADIANT_BOT
        end
    end

    -- if not Spawners.MercQueue[lane] then
    --     Spawners.MercQueue[lane] = {}
    -- end

    --local unit_to_queue = self:MapUnit()
    print("Queueing up a " .. unit .. " in lane " .. lane)
    table.insert(Spawners.MercQueue[team][lane], unit)

    PrintTable(Spawners.MercQueue[team][lane])
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