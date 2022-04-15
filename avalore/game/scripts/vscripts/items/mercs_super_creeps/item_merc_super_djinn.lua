item_merc_super_djinn = class({})

function item_merc_super_djinn:OnSpellStart()
    if not IsServer() then return end
    print("item_merc_super_djinn:OnSpellStart()")

    local caster = self:GetCaster()
    local team = caster:GetTeam()
    local unit = "npc_avalore_merc_djinn"
    local target = self:GetCursorTarget()

    -- 1) validate location

    -- 2) validate enough gold 
    --    and deal with gold and stuff later for this proof of concept

    -- 3) create unit after a short spawn-in period
    self.unit = CreateUnitByName("npc_avalore_merc_djinn", target, true, nil, nil, team)

    -- 4) send unit to its first waypoint
    -- hardcode this for now => later on search for closest or use heuristics with x,y pos
    self.unit:SetInitialGoalEntity(Entities:FindByName(nil, "radiant_path_top_1")) --dire_path_top_2

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
