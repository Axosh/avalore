require("references")
require(REQ_UTIL)
modifier_faction_water = class({})

function modifier_faction_water:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_faction_water:IsHidden() return false end
function modifier_faction_water:IsDebuff() return false end
function modifier_faction_water:IsPurgable() return false end
function modifier_faction_water:RemoveOnDeath() return false end

function modifier_faction_water:GetTexture()
    --PrintTable(self)
    local base = "factions/water/modifier_faction_water_"
    local num = 3
    --print(tostring(self:GetStackCount()))
    if self:GetStackCount() < 2 then
        num = 1
    elseif self:GetStackCount() == 2 then
        num = 2
    end

    local texture = base .. tostring(num)
    --print("isActive = " .. tostring(self.isActive))
    --if self.isActive then
    --if self:GetParent():GetAbsOrigin().z <=0.5 then
    if self:IsActive() then
        texture = texture .. "_active"
    end

    --print("Texture = " .. texture)
    return texture
end

function modifier_faction_water:OnCreated( kv )
    --self:SetParent(kv.caster)

    

	-- references
	self.bonus_speed = 10
    self.isActive = false

    if not IsServer() then return end

    local player_team = self:GetCaster():GetTeamNumber()
    -- find how many allied heroes are part of this alliance
    self:RefreshFactionStacks(player_team, self)
end

function modifier_faction_water:RefreshFactionStacks2(faction_team, modifier)
    local heroes = HeroList:GetAllHeroes()
    self.allies = {}

    for _, unit in pairs(heroes) do
        if unit:GetTeam() == faction_team and unit:IsRealHero() and not unit:IsClone() and not unit:IsTempestDouble() then
            table.insert(self.allies, unit)
        end
    end
end

function modifier_faction_water:RefreshFactionStacks(faction_team, modifier)
    --print()
    local stack_count = 0
    local faction_heroes = {} -- track heroes in array
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                --local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                local hero = PlayerResource:GetPlayer(playerID):GetAssignedHero()
                if hero:GetTeam() == faction_team then
                    -- if instance of modifier on team
                    if (hero:FindModifierByName(modifier:GetName())) then
                        print("Found on Hero: " .. hero:GetName())
                        --faction_heroes[stack_count] = hero --store ref to hero so we can update last_targeted
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
    --PrintTable(faction_heroes)
    for _, hero in ipairs(faction_heroes) do
        --print("Modifier = " .. modifier:GetName())
        --print("Found? ... " .. tostring(hero:FindModifierByName(modifier:GetName())))
        hero:FindModifierByName(modifier:GetName()):SetStackCount(stack_count)
    end
end

function modifier_faction_water:IsActive()
    return self:GetParent():GetAbsOrigin().z <=0.5
    -- if IsServer() then 
    --     -- river is low ground
    --     --print("Z-Index = " .. tostring(self:GetParent():GetOrigin().z))
    --     if self:GetParent():GetAbsOrigin().z <=0.5 then
    --         --print("Active")
    --         self.isActive = true
    --         return true
    --     else
    --         self.isActive = false
    --         return false
    --     end
    -- end

    -- return self.isActive
end

function modifier_faction_water:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_faction_water:GetModifierMoveSpeedBonus_Percentage()
    if self:IsActive() then
        --print("Active Bonus = " .. tostring(self.bonus_speed))
        return self.bonus_speed * self:GetStackCount()
    end
    -- --print("Checking Speed")
    -- if IsServer() then 
    --     --print("Server")
    --     if self:IsActive() then
    --         --print("Speed Amp = " .. tostring(self.bonus_speed))
    --         return self.bonus_speed
    --     end
    -- end
    -- if self.isActive then
	--     return self.bonus_speed
    -- end
end

function modifier_faction_water:CheckState()
	local state = {
	    [MODIFIER_STATE_NO_UNIT_COLLISION] = self:IsActive(),
	}

	return state
end

function modifier_faction_water:GetEffectName()
    if self:IsActive() then
        return "particles/units/heroes/hero_slardar/slardar_sprint_river.vpcf"
	    --return "particles/units/heroes/hero_slardar/slardar_sprint.vpcf"
    end
end

function modifier_faction_water:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end