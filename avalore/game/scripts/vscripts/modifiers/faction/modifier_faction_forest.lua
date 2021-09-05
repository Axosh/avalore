modifier_faction_forest = class({})

LinkLuaModifier("modifier_faction_forest_fade",     "modifiers/faction/modifier_faction_forest_fade.lua",       LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_faction_forest_cooldown", "modifiers/faction/modifier_faction_forest_cooldown.lua",   LUA_MODIFIER_MOTION_NONE)

-- stacks with self based on how many allies have it
function modifier_faction_forest:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_faction_forest:IsHidden() return false end
function modifier_faction_forest:IsDebuff() return false end
function modifier_faction_forest:IsPurgable() return false end
function modifier_faction_forest:RemoveOnDeath() return false end

function modifier_faction_forest:GetTexture()
    return "modifier_faction_forest"
end

function modifier_faction_forest:DeclareFunctions()
    return {
        --DOTA_ABILITY_BEHAVIOR_PASSIVE,
        MODIFIER_EVENT_ON_ATTACK_LANDED --,
        --MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }
end

function modifier_faction_forest:OnCreated(kv)
    if not IsServer() then return end
    local player_team = self:GetCaster():GetTeamNumber()
    -- find how many allied heroes are part of this alliance
    self:RefreshFactionStacks(player_team, self)
end

function modifier_faction_forest:RefreshFactionStacks(faction_team, modifier)
    local stack_count = 0
    local faction_heroes = {} -- track heroes in array
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                local hero = PlayerResource:GetSelectedHeroEntity(playerID)
                if hero:GetTeam() == player_team then
                    -- if instance of modifier on team
                    if (hero:FindModifierByName(modifier:GetName())) then
                        faction_heroes[stack_count] = hero --store ref to hero so we can update later
                        -- max of 3 stacks
                        if stack_count < 3 then
                            stack_count = stack_count + 1
                        end
                    end
                end
            end
        end
    end

    -- make sure all heroes of the faction have same stack count
    for _, hero in ipairs(faction_heroes) do
        hero:FindModifierByName(modifier:GetName()):SetStackCount(stack_count)
    end
end

function modifier_faction_forest:OnAttackLanded(kv)
    if kv.target == self:GetParent() and kv.damage > 0 and (kv.attacker:GetPlayerOwnerID() or kv.attacker:IsRoshan()) then
        if self:GetParent():HasModifier("modifier_faction_forest_fade") and not GridNav:IsNearbyTree(self:GetParent():GetAbsOrigin(), 150, false) then
            -- play sound if fade cd is started
            if not self:GetParent():HasModifier("modifier_faction_forest_cooldown") then
                self:GetParent():EmitSound("Hero_Treant.NaturesGuise.Off")
            end

            self:GetParent():RemoveModifierByName("modifier_faction_forest_fade")
        end

        -- reset cd if hit before fade is done
        if not self:GetParent():HasModifier("modifier_faction_forest_fade") or not GridNav:IsNearbyTree(self:GetParent():GetAbsOrigin(), 150, false) then
            -- if they have the cd modifier, reset it
            if self:GetParent():HasModifier("modifier_faction_forest_fade") then
                self:GetParent():FindModifierByName("modifier_faction_forest_fade"):SetStackCount(4 - self:GetStackCount()) -- the more allies, the lower the cd
            else
                self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_faction_forest_cooldown", {cooldown = 4 - self:GetStackCount()})
            end
        end
    end
end