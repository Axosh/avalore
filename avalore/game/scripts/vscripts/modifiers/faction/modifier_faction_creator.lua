require("references")
require(REQ_UTIL)
modifier_faction_creator = class({})

LinkLuaModifier("modifier_faction_creator_buff",    "modifiers/faction/modifier_faction_creator.lua",    LUA_MODIFIER_MOTION_NONE)

function modifier_faction_creator:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_faction_creator:IsHidden() return false end
function modifier_faction_creator:IsDebuff() return false end
function modifier_faction_creator:IsPurgable() return false end
function modifier_faction_creator:RemoveOnDeath() return false end
function modifier_faction_creator:IsAura() return true end

function modifier_faction_creator:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_faction_creator:GetAuraSearchType()
	return DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO
end

function modifier_faction_creator:GetModifierAura()
    return "modifier_faction_creator_buff"
end

function modifier_faction_creator:GetAuraRadius()
    return 600
end


function modifier_faction_creator:GetTexture()
    return "factions/creator/modifier_faction_creator"
end

function modifier_faction_creator:OnCreated( kv )
    --self.regen_aura = 1

    if not IsServer() then return end

    local player_team = self:GetCaster():GetTeamNumber()
    -- find how many allied heroes are part of this alliance
    self:RefreshFactionStacks(player_team, self)
end

function modifier_faction_creator:RefreshFactionStacks2(faction_team, modifier)
    local heroes = HeroList:GetAllHeroes()
    self.allies = {}

    for _, unit in pairs(heroes) do
        if unit:GetTeam() == faction_team and unit:IsRealHero() and not unit:IsClone() and not unit:IsTempestDouble() then
            table.insert(self.allies, unit)
        end
    end
end

function modifier_faction_creator:RefreshFactionStacks(faction_team, modifier)
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

function modifier_faction_creator:Precahce(context)
    PrecacheResource("particle", "particles/units/heroes/hero_hoodwink/hoodwink_scurry_aura_ground.vpcf")
end

function modifier_faction_creator:GetEffectName()
    return "particles/units/heroes/hero_hoodwink/hoodwink_scurry_aura_ground.vpcf"
end

function modifier_faction_creator:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

-- =============================================
-- AURA BUFF
-- ===========================================
modifier_faction_creator_buff = modifier_faction_creator_buff or class({})

function modifier_faction_creator_buff:IsHidden() return false end
function modifier_faction_creator_buff:IsPurgable() return false end
function modifier_faction_creator_buff:IsDebuff() return false end
-- stack with self
function modifier_faction_creator_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_faction_creator_buff:GetTexture()
    return "factions/creator/modifier_faction_creator_buff"
end

function modifier_faction_creator_buff:OnCreated()
    self.regen_aura_base = 1
    self.modifier = nil
    
    -- stuff that only is available server-side (not client-side)
    if not IsServer() then return end
    self.modifier = self:GetAuraOwner():FindModifierByName("modifier_faction_creator")
    self:SetStackCount(self.modifier:GetStackCount())
end

function modifier_faction_creator_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT }
end

function modifier_faction_creator_buff:GetModifierConstantHealthRegen()
    return (self.regen_aura_base * self:GetStackCount())
end