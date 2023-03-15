require("references")
require(REQ_UTIL)
modifier_faction_psychopomp = class({})

function modifier_faction_psychopomp:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_faction_psychopomp:IsHidden() return false end
function modifier_faction_psychopomp:IsDebuff() return false end
function modifier_faction_psychopomp:IsPurgable() return false end
function modifier_faction_psychopomp:RemoveOnDeath() return false end

function modifier_faction_psychopomp:GetTexture()
    return "factions/psychopomp/modifier_faction_psychopomp"
end

function modifier_faction_psychopomp:OnCreated( kv )
--	self.bonus_speed_base = 10
    self.radius = 900
    self.buff_stack_duration = 5.0

    if not IsServer() then return end

    local player_team = self:GetCaster():GetTeamNumber()
    -- find how many allied heroes are part of this alliance
    self:RefreshFactionStacks(player_team, self)
end

function modifier_faction_psychopomp:DecalreFunctions()
    return { MODIFIER_EVENT_ON_DEATH }
end

function modifier_faction_psychopomp:OnDeath(params)
    -- only regular units
    if not params.unit:IsIllusion() and not params.unit:IsTempestDouble() and not params.unit:IsRoshan() and not params.unit:IsOther() and not params.unit:IsBuilding() then
        -- make sure its not the parent
        if not (params.unit == self:GetParent()) then
            -- check radius
            if DistanceBetweenVectors(self:GetParent():GetAbsOrigin(), params.unit:GetAbsOrigin()) <= self.radius then
                self:GetParent():AddNewModifier(self:GetOwner(), nil, "modifier_soul_guide", {duration = self.buff_stack_duration})
            end
        end
    end
end

function modifier_faction_psychopomp:RefreshFactionStacks2(faction_team, modifier)
    local heroes = HeroList:GetAllHeroes()
    self.allies = {}

    for _, unit in pairs(heroes) do
        if unit:GetTeam() == faction_team and unit:IsRealHero() and not unit:IsClone() and not unit:IsTempestDouble() then
            table.insert(self.allies, unit)
        end
    end
end

function modifier_faction_psychopomp:RefreshFactionStacks(faction_team, modifier)
    --print()
    local stack_count = 0
    local faction_heroes = {} -- track heroes in array
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                --local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                local hero = PlayerResource:GetPlayer(playerID):GetAssignedHero()
                if hero and hero:GetTeam() == faction_team then
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
    for _, hero in ipairs(faction_heroes) do
        hero:FindModifierByName(modifier:GetName()):SetStackCount(stack_count)
    end
end

-- =========================================================
-- INTRINSIC MOD
-- =========================================================
modifier_soul_guide = modifier_soul_guide or class({})

function modifier_soul_guide:IsHidden() return false end
function modifier_soul_guide:IsDebuff() return false end
function modifier_soul_guide:IsPurgable() return false end
--function modifier_soul_guide:RemoveOnDeath() return false end
function modifier_soul_guide:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_soul_guide:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_soul_guide:GetModifierMoveSpeedBonus_Percentage()
    return self.bonus_speed * self:GetStackCount()
end
