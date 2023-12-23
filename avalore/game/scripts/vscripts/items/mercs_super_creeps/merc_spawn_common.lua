require("references")
require("spawners")
require(REQ_LIB_TIMERS)
require(REQ_CONSTANTS)
require("score")

if MercSpawnCommon == nil then
    MercSpawnCommon = {}
end

function MercSpawnCommon:Merc_GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED
end

function MercSpawnCommon:OnAbilityPhaseInterrupted()
    print("MercSpawnCommon:OnAbilityPhaseInterrupted()")
end

function MercSpawnCommon:OnAbilityPhaseStart()
    print("MercSpawnCommon:OnAbilityPhaseStart()")
end

-- 
function MercSpawnCommon:Merc_CastFilterResultLocation(location, merc_camp_index)
    --if not IsServer() then return end
    print("[DEBUG] MercSpawnCommon:Merc_CastFilterResultLocation ⇒ Start")
    print("index = " .. tostring(merc_camp_index))
    -- this happens when someone tries to drag/drop an item in another inventory
    -- just throw the command out so it doesn't produce the error message
    if location and location == Vector(0,0,0) then
        print("[DEBUG] invalid loc")
        return
    end
    -- if Spawners.MercCamps == nil then
    --     print("Spawners not initialized yet")
    -- end

    print("[DEBUG] MercSpawnCommon:Merc_CastFilterResultLocation => " .. tostring(location))
    local merc_camp = EntIndexToHScript(merc_camp_index)
    local team = merc_camp:GetCaster():GetTeamNumber()
    local lane = ""


    if not merc_camp then
        print("[DEBUG] MercSpawnCommon:Merc_CastFilterResultLocation => null")
        return
    end

    -- somewhere around a patch in late 2023, this all broke because of how client and server initialize
    -- -- determine which merc camp this is
    -- if merc_camp:GetAbsOrigin() ==  Spawners.MercCamps[DOTA_TEAM_GOODGUYS][Constants.KEY_RADIANT_TOP]:GetAbsOrigin() then --Vector(-7232, -5888, 256) then
    --     lane = Constants.KEY_RADIANT_TOP
    -- elseif merc_camp:GetAbsOrigin() ==  Spawners.MercCamps[DOTA_TEAM_GOODGUYS][Constants.KEY_RADIANT_BOT]:GetAbsOrigin() then --Vector(-5888, -7232, 256) then
    --     lane = Constants.KEY_RADIANT_BOT
    -- elseif merc_camp:GetAbsOrigin() ==  Spawners.MercCamps[DOTA_TEAM_BADGUYS][Constants.KEY_DIRE_TOP]:GetAbsOrigin() then --Vector(5888, 7232, 256) then
    --     lane = GetAbsOrigin.KEY_DIRE_TOP
    -- elseif merc_camp:GetAbsOrigin() ==  Spawners.MercCamps[DOTA_TEAM_BADGUYS][Constants.KEY_DIRE_BOT]:GetAbsOrigin() then --Vector(7232, 5888, 256) then
    --     lane = Constants.KEY_DIRE_BOT
    -- else
    --     print("[DEBUG] MercSpawnCommon:Merc_CastFilterResultLocation => DOES NOT MATCH ANY MERC CAMP")
    -- end

    -- so now, just sort of ballpark it
    --print("Unit? => " .. merc_camp:GetName())
    --print("Parent? => " .. merc_camp:GetOwner():GetName())
    print("Merc Camp Vector ===>" .. tostring(merc_camp:GetAbsOrigin().x) .. ", " .. tostring(merc_camp:GetAbsOrigin().y))
    --PrintVector(merc_camp:GetAbsOrigin())
    -- this didn't work => these are items/abilities so the abs origin seems to be relative to the parent container or something????
    -- if merc_camp:GetAbsOrigin().y > 7000 then
    --     lane = Constants.KEY_DIRE_TOP
    --     print("Dire Top")
    -- elseif merc_camp:GetAbsOrigin().y > 5000 then
    --     lane = Constants.KEY_DIRE_BOT
    --     print("Dire Bot")
    -- elseif merc_camp:GetAbsOrigin().y > -6000 then
    --     lane = Constants.KEY_RADIANT_TOP
    --     print("Radi Top")
    -- else
    --     lane = Constants.KEY_RADIANT_BOT
    --     print("Radi Bot")
    -- end

    -- Radi Bot
    -- Merc Camp Vector ===>0.0009765625, -0.00048828125
    -- Radi Top
    -- Merc Camp Vector ===>0, 0
    -- Dire Top
    -- Merc Camp Vector ===>-0.001953125, -0.00244140625
    -- Dire Bot
    -- Merc Camp Vector ===>0.0029296875, 0.00146484375
    if merc_camp:GetAbsOrigin().x > 0.002 then
        lane = Constants.KEY_DIRE_BOT
        --print("Dire Top")
    elseif merc_camp:GetAbsOrigin().x < 0 then
        lane = Constants.KEY_DIRE_TOP
        --print("Dire Bot")
    elseif merc_camp:GetAbsOrigin().x == 0 then
        lane = Constants.KEY_RADIANT_TOP
        --print("Radi Top")
    else
        lane = Constants.KEY_RADIANT_BOT
        --print("Radi Bot")
    end

    if team == DOTA_TEAM_GOODGUYS then 
        if lane == Constants.KEY_RADIANT_TOP then
            if IsRadiantTopLane(location.x, location.y) then 
                --print("RADI TOP SUCCESS")
                return UF_SUCCESS
            end
        elseif lane == Constants.KEY_RADIANT_BOT then
            if IsRadiantBotLane(location.x, location.y) then 
                --print("RADI BOT SUCCESS")
                return UF_SUCCESS
            end
        end
    elseif team == DOTA_TEAM_BADGUYS then
        if lane == Constants.KEY_DIRE_TOP then
            if IsDireTopLane(location.x, location.y) then 
                --print("DIRE TOP SUCCESS")
                return UF_SUCCESS
            end
        elseif lane == Constants.KEY_DIRE_BOT then
            if IsDireBotLane(location.x, location.y) then 
                --print("DIRE BOT SUCCESS")
                return UF_SUCCESS
            end
        end
    end

    --print("FAILED")
    return UF_FAIL_INVALID_LOCATION
end

-- ========================================================================
-- IMPORTANT!!!!!!!
-- UPDATE CAvaloreGameMode:OrderFilter(keys) with new mercs
-- ========================================================================
function MercSpawnCommon:Merc_OnSpellStart(item, unit, quantity)
    if not IsServer() then return end
    print("Merc_OnSpellStart => " .. item:GetName() .. ", " .. unit .. ", " .. tostring(quantity))

    --local caster = self:GetCaster()
    local caster = item:GetCaster()
    print("Caster => " .. caster:GetName())
    local team = item:GetTeam()
    print("Team => " .. tostring(team))

    local target_temp = Vector(caster.target_x, caster.target_y, 0) -- this comes in from the OrderFilter capturing the player's cursor
    print("Target => " .. tostring(target_temp))
    local target = GetGroundPosition(target_temp, nil) -- get z-coord

    -- 1) validate location
    local lane = ""
    for key, value in pairs(Spawners.MercCamps[team]) do
        print("Value: " .. tostring(value))
        -- check to see which merc camp this is
        if item:GetOwner() == value then
            lane = key
        end
    end
    print("lane = " .. lane)

    -- 2) validate enough gold 
    --    and deal with gold and stuff later for this proof of concept
    if not (self:GoldTransactionSucceeded(item, team)) then
        return
    end

    -- 3) create unit after a short spawn-in period
    local particle_cast = "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf"
    local particle_cast_fx = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(particle_cast_fx, 0 , target)
    ParticleManager:SetParticleControl(particle_cast_fx, 1 , target)
    ParticleManager:SetParticleControl(particle_cast_fx, 2 , target)
    ParticleManager:SetParticleControl(particle_cast_fx, 3 , target)
    ParticleManager:ReleaseParticleIndex(particle_cast_fx)

    local init_target = ""
    if team == DOTA_TEAM_GOODGUYS then 
        if lane == Constants.KEY_RADIANT_TOP then
            if IsRadiantTopLane(caster.target_x, caster.target_y) then 
                init_target = "radiant_path_top_1"
            end
        elseif lane == Constants.KEY_RADIANT_BOT then
            if IsRadiantBotLane(caster.target_x, caster.target_y) then 
                init_target = "radiant_path_bot_1"
            end
        end
    elseif team == DOTA_TEAM_BADGUYS then
        if lane == Constants.KEY_DIRE_TOP then
            if IsDireTopLane(caster.target_x, caster.target_y) then 
                init_target = "dire_path_top_1"
            end
        elseif lane == Constants.KEY_DIRE_BOT then
            if IsDireBotLane(caster.target_x, caster.target_y) then 
                init_target = "dire_path_bot_1"
            end
        end
    end
    print("init target => " .. init_target)

    -- Handle Demi Hero Levels
    if string.find(unit, "demi_hero") then
        print("is demi hero")
        DemiHeroManager:HireDemiHero(team, unit)

        for key, value in pairs(Spawners.MercCamps[team]) do
            local item_ability = value:FindAbilityByName(item:GetName())
            -- check item_ability to filter out arcanery
            if item_ability and item_ability:GetLevel() < item_ability:GetMaxLevel() then
                item_ability:SetLevel(item_ability:GetLevel() + 1)
            end
        end
    end

    -- SPAWNING
    local spawns = {}
    for i = quantity,1,-1 do      
        print(tostring(i) .. ". Making " .. unit)
        Timers:CreateTimer(2.0, function()
            print("in callback")
            GridNav:DestroyTreesAroundPoint(target * 180, 180, false)
        
                --self.temp_unit = CreateUnitByName(unit, target, true, nil, nil, team)
                -- local summon_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_summon_familiars.vpcf", PATTACH_ABSORIGIN, self.unit)
                -- ParticleManager:ReleaseParticleIndex(summon_particle)

            -- 4) send unit to its first waypoint
                -- hardcode this for now => later on search for closest or use heuristics with x,y pos
                print("Unit => " .. unit)
                print("Target => " .. tostring(target))
                print("Team => " .. tostring(team))
                print(Entities:FindByName(nil, init_target))
                
            --self.temp_unit:SetInitialGoalEntity(Entities:FindByName(nil, init_target)) --dire_path_top_2
            -- trying arrays just in case there's some dumbassery going on with callbacks
            spawns[i] = CreateUnitByName(unit, target, true, nil, nil, team)
            --print(tostring(spawns[i]))
            spawns[i]:SetMustReachEachGoalEntity(true)
            spawns[i]:SetInitialGoalEntity(Entities:FindByName(nil, init_target)) --dire_path_top_2

            -- for demi-heroes, make sure they're the right level
            if string.find(spawns[i]:GetUnitName(), "demi_hero") then
                spawns[i]:CreatureLevelUp(DemiHeroManager:GetDemiHeroLevel(team, spawns[i]:GetUnitName()) - 1)
            end
        end)
    end

    -- 5) make sure to update shared cooldowns

    local items = Entities:FindAllByName(item:GetName())
    for _,item_inst in pairs(items) do
        if item_inst:GetTeamNumber() == item:GetTeamNumber() then
            item_inst:StartCooldown(item:GetCooldown(item:GetLevel()))
        end
    end
end

function MercSpawnCommon:GoldTransactionSucceeded(itemOrAbility, team)
    local gold_cost = itemOrAbility:GetSpecialValueFor("gold_cost")
    local team_gold = {}
    local bNotEnoughGold = false
    if team == DOTA_TEAM_GOODGUYS then
        if not (Score.RadiSharedGoldCurr >= gold_cost) then
            print("[MercSpawnCommon:GoldTransactionSucceeded()] Not enough gold")
            bNotEnoughGold = true
        else
            Score.RadiSharedGoldCurr = Score.RadiSharedGoldCurr - gold_cost
            team_gold.gold = Score.RadiSharedGoldCurr
        end
    else
        if not (Score.DireSharedGoldCurr >= gold_cost) then
            print("[MercSpawnCommon:GoldTransactionSucceeded()] Not enough gold")
            bNotEnoughGold = true
        else
            Score.DireSharedGoldCurr = Score.DireSharedGoldCurr - gold_cost
            team_gold.gold = Score.DireSharedGoldCurr
        end
    end

    print("Player Issuer => " .. tostring(itemOrAbility.PlayerCaster))
    if bNotEnoughGold then
        local broadcast_obj = 
                {
                    msg = "#error_not_enough_team_gold_mercenary",
                    time = 5,
                    elaboration = "",
                    type = MSG_TYPE_ERROR
                };
                CustomGameEventManager:Send_ServerToTeam(team, "broadcast_message", broadcast_obj )
                --CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(itemOrAbility.PlayerCaster), "broadcast_message", broadcast_obj )
        return false
    end

    CustomGameEventManager:Send_ServerToTeam(team, "update_team_gold", team_gold)
    return true
end