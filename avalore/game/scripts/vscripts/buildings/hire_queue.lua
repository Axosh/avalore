require("score")
require("spawners")
require("utility_functions")

hire_queue = class({})


-- ==================================================================
-- SHARED FUNCTIONS
-- ==================================================================

function HireUnit(unit, team, gold_cost, merc_camp_building)

    -- check that they have enough gold and append correct unit to spawn
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
        unit = unit .. "radi"
    else
        if not (Score.DireSharedGoldCurr > gold_cost) then
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
        unit = unit .. "dire"
    end

    local lane = ""
    --print("==== FIND LANE OF QUEUE ====")
    --print("Owner: " .. tostring(self:GetOwner()))
    for key, value in pairs(Spawners.MercCamps[team]) do
        print("Value: " .. tostring(value))
        if merc_camp_building == value then
            lane = key
        end
    end

    print("Queueing up a " .. unit .. " in lane " .. lane)
    table.insert(Spawners.MercQueue[team][lane], unit)

    PrintTable(Spawners.MercQueue[team][lane])
end

-- ==================================================================
-- TRAIN MELEE
-- ==================================================================

avalore_merc_train_melee_creep = class({})

function avalore_merc_train_melee_creep:OnSpellStart()
    if not IsServer() then return end
    print("HireQueue:OnSpellStart()")
    local caster = self:GetCaster()
    -- if caster then
    --     print(caster:GetPlayer())
    -- end
    local team = caster:GetTeam()
    local gold_cost = self:GetSpecialValueFor("gold_cost")
    local unit = "npc_avalore_merc_melee_"

   HireUnit(unit, team, gold_cost, self:GetOwner())
end

-- ==================================================================
-- TRAIN RANGED
-- ==================================================================

avalore_merc_train_ranged_creep = class({})

function avalore_merc_train_ranged_creep:OnSpellStart()
    if not IsServer() then return end
    print("HireQueue:OnSpellStart()")
    local caster = self:GetCaster()
    -- if caster then
    --     print(caster:GetPlayer())
    -- end
    local team = caster:GetTeam()
    local gold_cost = self:GetSpecialValueFor("gold_cost")
    local unit = "npc_avalore_merc_ranged_"

   HireUnit(unit, team, gold_cost, self:GetOwner())
end

-- ==================================================================
-- TRAIN HULK
-- ==================================================================

avalore_merc_train_hulk_creep = class({})

function avalore_merc_train_hulk_creep:OnSpellStart()
    if not IsServer() then return end
    print("HireQueue:OnSpellStart()")
    local caster = self:GetCaster()
    -- if caster then
    --     print(caster:GetPlayer())
    -- end
    local team = caster:GetTeam()
    local gold_cost = self:GetSpecialValueFor("gold_cost")
    local unit = "npc_avalore_merc_hulk_"

   HireUnit(unit, team, gold_cost, self:GetOwner())
end

-- ==================================================================
-- OTHER
-- ==================================================================

-- function DequeueUnit( event )
--     -- TODO
-- end

-- function avalore_merc_train_melee_creep:MapUnit(unit, team)
--     local prefix = ""
--     if team == DOTA_TEAM_GOODGUYS then
--         prefix = "npc_dota_creep_goodguys_"
--     else
--         prefix = "npc_dota_creep_badguys_"
--     end

--     if unit == "melee" or unit == "ranged" then
--         return (prefix .. unit)
--     end
-- end