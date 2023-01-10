require("references")
require("spawners")
require(REQ_LIB_TIMERS)
require(REQ_CONSTANTS)

item_merc_super_djinn = class({})

function item_merc_super_djinn:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED
end

-- check if the location vector is in a lane that this merc spawner can target
function item_merc_super_djinn:CastFilterResultLocation(location)
    --if not IsServer() then return end
    --print("item_merc_super_djinn:CastFilterResult(location)")
    --print("Item AbsOrigin => (" .. tostring(self:GetAbsOrigin().x) .. ", " .. tostring(self:GetAbsOrigin().y)  .. ")")
    local team = self:GetCaster():GetTeamNumber()
    local lane = ""
    -- Item AbsOrigin is shared with its parent (i.e. the merc camp)
    if self:GetAbsOrigin() ==  Vector(-7232, -5888, 256) then
        lane = Constants.KEY_RADIANT_TOP
    elseif self:GetAbsOrigin() ==  Vector(-5888, -7232, 256) then
        lane = Constants.KEY_RADIANT_BOT
    elseif self:GetAbsOrigin() ==  Vector(5888, 7232, 256) then
        lane = GetAbsOrigin.KEY_DIRE_TOP
    elseif self:GetOriginAbs() ==  Vector(7232, 5888, 256) then
        lane = Constants.KEY_DIRE_BOT
    end
    -- for key, value in pairs(Spawners.MercCamps[team]) do
    --     print("Value: " .. tostring(value))
    --     -- check to see which merc camp this is
    --     if self:GetOwner() == value then
    --         lane = key
    --     end
    -- end

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

    return UF_FAIL_INVALID_LOCATION
end

function item_merc_super_djinn:OnSpellStart()
    print("item_merc_super_djinn:OnSpellStart()")
    if not IsServer() then return end

    local caster = self:GetCaster()
    -- print("Caster is => " .. caster:GetName())
    -- print("TEST => " .. tostring(caster.position_x))
    local team = caster:GetTeam()
    local unit = "npc_avalore_merc_djinn"
    --local target = self:GetCursorPosition()--self:GetCursorTarget() --self:GetCursorPosition()
    --local target = caster:GetCursorPosition()
    local target_temp = Vector(caster.target_x, caster.target_y, 0) -- this comes in from the OrderFilter capturing the player's cursor
    local target = GetGroundPosition(target_temp, nil) -- get z-coord


    -- 1) validate location
    local lane = ""
    for key, value in pairs(Spawners.MercCamps[team]) do
        print("Value: " .. tostring(value))
        -- check to see which merc camp this is
        if self:GetOwner() == value then
            lane = key
        end
    end
    print("lane = " .. lane)

    -- 2) validate enough gold 
    --    and deal with gold and stuff later for this proof of concept

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

    Timers:CreateTimer(2.0, function()
        GridNav:DestroyTreesAroundPoint(target * 180, 180, false)
    
        self.unit = CreateUnitByName(unit, target, true, nil, nil, team)
        -- local summon_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_summon_familiars.vpcf", PATTACH_ABSORIGIN, self.unit)
        -- ParticleManager:ReleaseParticleIndex(summon_particle)

    -- 4) send unit to its first waypoint
        -- hardcode this for now => later on search for closest or use heuristics with x,y pos
        self.unit:SetInitialGoalEntity(Entities:FindByName(nil, init_target)) --dire_path_top_2
    end)

    -- 5) make sure to update shared cooldowns

    local items = Entities:FindAllByName(self:GetName())
    for _,item in pairs(items) do
        if item:GetTeamNumber() == self:GetTeamNumber() then
            item:StartCooldown(self:GetCooldown(self:GetLevel()))
        end
    end
end

-- function FindLane(team)
--     local lane = ""
--     for key, value in pairs(Spawners.MercCamps[team]) do
--         print("Value: " .. tostring(value))
--         if merc_camp_building == value then
--             lane = key
--         end
--     end
-- end
