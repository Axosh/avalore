modifier_faction_sharpshooter = class({})

function modifier_faction_sharpshooter:IsHidden() return false end
function modifier_faction_sharpshooter:IsDebuff() return false end
function modifier_faction_sharpshooter:IsPurgable() return false end
function modifier_faction_sharpshooter:RemoveOnDeath() return false end
function modifier_faction_sharpshooter:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_faction_sharpshooter:GetTexture()
    return "factions/sharpshooter/sharpshooter"
end

function modifier_faction_sharpshooter:DeclareFunctions()
	return {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_TOOLTIP
    }
end

function modifier_faction_sharpshooter:OnCreated( kv )
	-- references
	self.base_range_bonus = 50

    if not IsServer() then return end
    local player_team = self:GetCaster():GetTeamNumber()
    -- find how many allied heroes are part of this alliance
    self:RefreshFactionStacks(player_team, self)
end

function modifier_faction_sharpshooter:RefreshFactionStacks(faction_team, modifier)
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

function modifier_faction_sharpshooter:OnTooltip()
    return self.base_range_bonus
end

function modifier_faction_sharpshooter:GetModifierAttackRangeBonus()
    -- have to do this because Robin Hood can switch
    --if self:GetParent():GetAttackCapability() == DOTA_UNIT_CAP_RANGED_ATTACK then
    if self:GetParent():IsRangedAttacker() then
        return self.base_range_bonus * self:GetStackCount()
    else
        return 0
    end
end