modifier_faction_forest = class({})

-- ====================================================================
-- This modifier basically works as a coordinator for the faction buff
-- If multiple heroes on the same team are part of the faction, then
-- the buff stack is incremented and the image changes.
-- If the hero is standing near trees, gives them the forest fade buff
-- ====================================================================

LinkLuaModifier("modifier_faction_forest_fade",     "modifiers/faction/modifier_faction_forest_fade.lua",       LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_faction_forest_cooldown", "modifiers/faction/modifier_faction_forest_cooldown.lua",   LUA_MODIFIER_MOTION_NONE)

-- stacks with self based on how many allies have it
function modifier_faction_forest:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_faction_forest:IsHidden() return false end
function modifier_faction_forest:IsDebuff() return false end
function modifier_faction_forest:IsPurgable() return false end
function modifier_faction_forest:RemoveOnDeath() return false end

function modifier_faction_forest:GetTexture()
    if self:GetStackCount() < 2 then
        return "modifier_faction_forest_1"
    elseif self:GetStackCount() == 2 then
        return "modifier_faction_forest_2"
    else
        return "modifier_faction_forest_3"
    end

end

-- function modifier_faction_forest:DeclareFunctions()
--     return {
--         --DOTA_ABILITY_BEHAVIOR_PASSIVE,
--         MODIFIER_EVENT_ON_ATTACK_LANDED --,
--         --MODIFIER_PROPERTY_INVISIBILITY_LEVEL
--     }
-- end

function modifier_faction_forest:OnCreated(kv)
    if not IsServer() then return end
    local player_team = self:GetCaster():GetTeamNumber()
    -- find how many allied heroes are part of this alliance
    self:RefreshFactionStacks(player_team, self)

    self.interval = FrameTime()
    self.radius = 200
    self.cd_offset = 5          -- 5sec - however many allies are the same faction
    self.grace_time = 1
    self.grace_time_counter = 0

    self:OnIntervalThink()
	self:StartIntervalThink(self.interval)
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

-- function modifier_faction_forest:OnAttackLanded(kv)
--     if kv.target == self:GetParent() and kv.damage > 0 and (kv.attacker:GetPlayerOwnerID() or kv.attacker:IsRoshan()) then
--         if self:GetParent():HasModifier("modifier_faction_forest_fade") and not GridNav:IsNearbyTree(self:GetParent():GetAbsOrigin(), self.radius, false) then
--             -- -- play sound if fade cd is started
--             -- if not self:GetParent():HasModifier("modifier_faction_forest_cooldown") then
--             --     self:GetParent():EmitSound("Hero_Treant.NaturesGuise.Off")
--             -- end

--             self:GetParent():EmitSound("Hero_Treant.NaturesGuise.Off")
--             self:GetParent():RemoveModifierByName("modifier_faction_forest_fade")
--         end

--         -- reset cd if hit before fade is done
--         -- if not self:GetParent():HasModifier("modifier_faction_forest_fade") or not GridNav:IsNearbyTree(self:GetParent():GetAbsOrigin(), self.radius, false) then
--         --     -- if they have the cd modifier, reset it
--         --     if self:GetParent():HasModifier("modifier_faction_forest_fade") then
--         --         self:GetParent():FindModifierByName("modifier_faction_forest_fade"):SetStackCount(self.cd_offset - self:GetStackCount()) -- the more allies, the lower the cd
--         --     else
--         --         self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_faction_forest_cooldown", {cooldown = self.cd_offset - self:GetStackCount()})
--         --     end
--         -- end
--     end
-- end

-- regularly check for nearby trees to trigger passive
function modifier_faction_forest:OnIntervalThink()
    -- if we're near trees, give them the buff and let the buff do the heavy lifting
    if GridNav:IsNearbyTree(self:GetParent():GetAbsOrigin(), self.radius, false) then
        if not self:GetParent():HasModifier("modifier_faction_forest_fade") then
            self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_faction_forest_fade", nil)
        end
    else
        if self:GetParent():HasModifier("modifier_faction_forest_fade") then
            --give a little grace time, but if over the limit remove the buff
            self.grace_time_counter = self.grace_time_counter + self.interval
            
            if self.grace_time_counter >= self.grace_time then 
                self:GetParent():RemoveModifierByName("modifier_faction_forest_fade")
                self.grace_time_counter = 0 --reset for next time
            end
        end
    end
end