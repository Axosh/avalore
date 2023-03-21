modifier_faction_middle_kingdom = class({})

function modifier_faction_middle_kingdom:IsHidden() return false end
function modifier_faction_middle_kingdom:IsDebuff() return false end
function modifier_faction_middle_kingdom:IsPurgable() return false end
function modifier_faction_middle_kingdom:RemoveOnDeath() return false end
function modifier_faction_middle_kingdom:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_faction_middle_kingdom:GetTexture()
    return "factions/middle_kingdom/middle_kingdom"
end

function modifier_faction_middle_kingdom:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_STATUS_RESISTANCE
        -- should this be MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING ?
    }
end

function modifier_faction_middle_kingdom:OnCreated( kv )
	-- references
	self.base_status_resist = 5

    if not IsServer() then return end
    local player_team = self:GetCaster():GetTeamNumber()
    -- find how many allied heroes are part of this alliance
    self:RefreshFactionStacks(player_team, self)
end

function modifier_faction_middle_kingdom:RefreshFactionStacks(faction_team, modifier)
    local stack_count = 0
    local faction_heroes = {} -- track heroes in array
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                local hero = PlayerResource:GetPlayer(playerID):GetAssignedHero()
                if hero and hero:GetTeam() == faction_team then
                    -- if instance of modifier on team
                    if (hero:FindModifierByName(modifier:GetName())) then
                        --print("Found on Hero: " .. hero:GetName())
                        table.insert(faction_heroes, hero)
                        -- max of 3 stacks
                        if stack_count < 3 then
                            stack_count = stack_count + 1
                        end
                    end
                end
            end
        end
    end
    print("Stack Count = " .. tostring(stack_count))

    -- make sure all heroes of the faction have same stack count
    for _, hero in ipairs(faction_heroes) do
        hero:FindModifierByName(modifier:GetName()):SetStackCount(stack_count)
    end
end

-- should this be GetModifierStatusResistanceStacking()?
function modifier_faction_middle_kingdom:GetModifierStatusResistance()
    return self.base_status_resist * self:GetStackCount()
end