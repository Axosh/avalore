require("references")
require(REQ_UTIL)
modifier_faction_demigod = class({})

LinkLuaModifier("modifier_faction_demigod_buff",    "modifiers/faction/modifier_faction_demigod.lua",    LUA_MODIFIER_MOTION_NONE)

function modifier_faction_demigod:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_faction_demigod:IsHidden() return false end
function modifier_faction_demigod:IsDebuff() return false end
function modifier_faction_demigod:IsPurgable() return false end
function modifier_faction_demigod:RemoveOnDeath() return false end
function modifier_faction_demigod:IsAura() return true end

function modifier_faction_demigod:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_faction_demigod:GetAuraSearchType()
	return DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO
end

function modifier_faction_demigod:GetModifierAura()
    return "modifier_faction_demigod_buff"
end

function modifier_faction_demigod:GetAuraRadius()
    return 900
end


function modifier_faction_demigod:GetTexture()
    return "factions/demigod/modifier_faction_demigod"
end

function modifier_faction_demigod:OnCreated( kv )
    --self.regen_aura = 1

    if not IsServer() then return end

    local player_team = self:GetCaster():GetTeamNumber()
    -- find how many allied heroes are part of this alliance
    self:RefreshFactionStacks(player_team, self)
end

function modifier_faction_demigod:RefreshFactionStacks2(faction_team, modifier)
    local heroes = HeroList:GetAllHeroes()
    self.allies = {}

    for _, unit in pairs(heroes) do
        if unit:GetTeam() == faction_team and unit:IsRealHero() and not unit:IsClone() and not unit:IsTempestDouble() then
            table.insert(self.allies, unit)
        end
    end
end

function modifier_faction_demigod:RefreshFactionStacks(faction_team, modifier)
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

-- function modifier_faction_demigod:Precahce(context)
--     PrecacheResource("particle", "particles/units/heroes/hero_hoodwink/hoodwink_scurry_aura_ground.vpcf")
-- end

-- function modifier_faction_demigod:GetEffectName()
--     return "particles/units/heroes/hero_hoodwink/hoodwink_scurry_aura_ground.vpcf"
-- end

-- function modifier_faction_demigod:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end

-- =============================================
-- AURA BUFF
-- ===========================================
modifier_faction_demigod_buff = modifier_faction_demigod_buff or class({})

function modifier_faction_demigod_buff:IsHidden() return false end
function modifier_faction_demigod_buff:IsPurgable() return false end
function modifier_faction_demigod_buff:IsDebuff() return false end
-- stack with self
function modifier_faction_demigod_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_faction_demigod_buff:GetTexture()
    return "factions/demigod/modifier_faction_demigod_buff"
end

function modifier_faction_demigod_buff:OnCreated()
    self.dmg_pct_base = 5
    self.modifier = nil
    
    -- stuff that only is available server-side (not client-side)
    if not IsServer() then return end
    self.modifier = self:GetAuraOwner():FindModifierByName("modifier_faction_demigod")
    self:SetStackCount(self.modifier:GetStackCount())
end

-- function modifier_faction_demigod_buff:DeclareFunctions()
--     return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
-- end

-- function modifier_faction_demigod_buff:GetModifierPreAttack_BonusDamage()
--     return (self.regen_aura_base * self:GetStackCount())
-- end

function modifier_faction_demigod_buff:DeclareFunctions()
    return { MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE }
end

function modifier_faction_demigod_buff:GetModifierDamageOutgoing_Percentage()
    return (self.dmg_pct_base * self:GetStackCount())
end