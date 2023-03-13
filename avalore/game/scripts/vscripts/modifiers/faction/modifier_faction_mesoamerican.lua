modifier_faction_mesoamerican = class({})

function modifier_faction_mesoamerican:IsHidden() return false end
function modifier_faction_mesoamerican:IsDebuff() return false end
function modifier_faction_mesoamerican:IsPurgable() return false end
function modifier_faction_mesoamerican:RemoveOnDeath() return false end
function modifier_faction_mesoamerican:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_faction_mesoamerican:GetTexture()
    return "factions/mesoamerican/modifier_faction_mesoamerican"
end

function modifier_faction_mesoamerican:DeclareFunctions()
	return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_TOOLTIP,
        MODIFIER_PROPERTY_TOOLTIP2 
    }
end

function modifier_faction_mesoamerican:OnCreated( kv )
	-- references
	self.base_hp_heal = 5
	self.base_mana_heal = 5

    if not IsServer() then return end
    local player_team = self:GetCaster():GetTeamNumber()
    -- find how many allied heroes are part of this alliance
    self:RefreshFactionStacks(player_team, self)
end

function modifier_faction_mesoamerican:RefreshFactionStacks(faction_team, modifier)
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

function modifier_faction_mesoamerican:OnTooltip()
    return self.base_hp_heal * self:GetStackCount()
end

function modifier_faction_mesoamerican:OnTooltip2()
    return self.base_mana_heal * self:GetStackCount()
end

function modifier_faction_mesoamerican:OnDeath( params )
    if IsServer() then

        local target = params.unit
        local attacker = params.attacker
        if (	attacker == self:GetParent() 
            and target ~= self:GetParent() 
            and attacker:IsAlive() 
            and (not target:IsIllusion()) 
            and (not target:IsBuilding())
            and (not self:GetParent():PassivesDisabled())) then
                attacker:Heal(self.base_hp_heal * self:GetStackCount(), nil)
                attacker:GiveMana(self.base_mana_heal * self:GetStackCount())
                
        end
    end
end