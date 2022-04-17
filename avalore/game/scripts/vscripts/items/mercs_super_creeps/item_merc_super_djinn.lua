require("references")
require("spawners")
require(REQ_LIB_TIMERS)

item_merc_super_djinn = class({})

function item_merc_super_djinn:CastFilterResult()
    return UF_SUCCESS
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

    Timers:CreateTimer(2.0, function()
        GridNav:DestroyTreesAroundPoint(target * 180, 180, false)
    
        self.unit = CreateUnitByName("npc_avalore_merc_djinn", target, true, nil, nil, team)
        -- local summon_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_visage/visage_summon_familiars.vpcf", PATTACH_ABSORIGIN, self.unit)
        -- ParticleManager:ReleaseParticleIndex(summon_particle)

    -- 4) send unit to its first waypoint
        -- hardcode this for now => later on search for closest or use heuristics with x,y pos
        self.unit:SetInitialGoalEntity(Entities:FindByName(nil, "radiant_path_top_1")) --dire_path_top_2
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
