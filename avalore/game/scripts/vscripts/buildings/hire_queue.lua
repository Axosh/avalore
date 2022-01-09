require("score")
require("spawners")
require("utility_functions")

hire_queue = class({})


-- ==================================================================
-- SHARED FUNCTIONS
-- ==================================================================

function HireUnit(unit, team, gold_cost, merc_camp_building)
    print("HireUnit(unit, team, gold_cost, merc_camp_building)")
    local team_gold = {}
    local is_demi_hero = false
    if string.find(unit, "demi_hero") then
        is_demi_hero = true
    end
    -- check that they have enough gold and append correct unit to spawn
    if team == DOTA_TEAM_GOODGUYS then
        if not (Score.RadiSharedGoldCurr >= gold_cost) then
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
        else
            Score.RadiSharedGoldCurr = Score.RadiSharedGoldCurr - gold_cost
            team_gold.gold = Score.RadiSharedGoldCurr
        end
        if not is_demi_hero then
            unit = unit .. "radi"
        end
    else
        if not (Score.DireSharedGoldCurr >= gold_cost) then
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
        else
            Score.DireSharedGoldCurr = Score.DireSharedGoldCurr - gold_cost
            team_gold.gold = Score.DireSharedGoldCurr
        end
        if not is_demi_hero then
            unit = unit .. "dire"
        end
    end

    CustomGameEventManager:Send_ServerToTeam(team, "update_team_gold", team_gold)

    local lane = ""
    --print("==== FIND LANE OF QUEUE ====")
    --print("Owner: " .. tostring(self:GetOwner()))
    for key, value in pairs(Spawners.MercCamps[team]) do
        print("Value: " .. tostring(value))
        if merc_camp_building == value then
            lane = key
        end
    end

    if is_demi_hero then
        DemiHeroManager:HireDemiHero(team, unit)
    end

    print("Queueing up a " .. unit .. " in lane " .. lane)
    table.insert(Spawners.MercQueue[team][lane], unit)
    local queue_obj = {}
    queue_obj.img = unit -- note: these images are used to lookup a classname (avalore_hire_queue.css) on the front end which have the image set to the background
    queue_obj.loc = lane
    CustomGameEventManager:Send_ServerToTeam(team, "add_to_hire_queue", queue_obj)

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
-- TRAIN Flying
-- ==================================================================

avalore_merc_train_flying_creep = class({})

function avalore_merc_train_flying_creep:OnSpellStart()
    if not IsServer() then return end
    
    local caster = self:GetCaster()
    -- if caster then
    --     print(caster:GetPlayer())
    -- end
    local team = caster:GetTeam()
    local gold_cost = self:GetSpecialValueFor("gold_cost")
    local unit = "npc_avalore_merc_flying_"

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