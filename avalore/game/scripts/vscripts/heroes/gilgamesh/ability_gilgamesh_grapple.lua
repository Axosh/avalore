ability_gilgamesh_grapple = ability_gilgamesh_grapple or class({})

--LinkLuaModifier("modifier_grapple_self",    "scripts/vscripts/heroes/gilgamesh/modifier_grapple_self.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_grapple_target",  "scripts/vscripts/heroes/gilgamesh/modifier_grapple_target.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_tag_team", "scripts/vscripts/heroes/gilgamesh/modifier_talent_tag_team.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_talent_endurance", "scripts/vscripts/heroes/gilgamesh/modifier_talent_endurance.lua", LUA_MODIFIER_MOTION_NONE )

function ability_gilgamesh_grapple:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_CHANNELLED
end

function ability_gilgamesh_grapple:CastFilterResultTarget(target)
    -- local target = DOTA_UNIT_TARGET_FLAG_NONE
    -- if self:GetCaster():HasModifier("modifier_talent_grappling_hold") then
    --     target = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
    -- end
    if self:GetCaster():HasModifier("modifier_talent_grappling_hold") then
        return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber())
    else
        return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
    end
end

function ability_gilgamesh_grapple:GetChannelTime()

    if IsClient() then
        return self:GetSpecialValueFor("channel_time") + self:GetCaster():FindTalentValue("talent_endurance", "bonus_duration")
    else
        -- handle it this way due to client/server nonsense with talent values
        if not self.main_hero then
            self.main_hero = PlayerResource:GetSelectedHeroEntity(self:GetCaster():GetMainControllingPlayer())
        end
        return self:GetSpecialValueFor("channel_time") + self.main_hero:FindTalentValue("talent_endurance", "bonus_duration")
    end
end

-- function ability_gilgamesh_grapple:GetIntrinsicModifierName()
-- 	return "modifier_grapple_self"
-- end

-- function ability_gilgamesh_grapple:GetChannelTime()
-- 	return self:GetCaster():GetModifierStackCount("modifier_ability_grapple_helper", self:GetCaster()) * 0.01
-- end

function ability_gilgamesh_grapple:OnSpellStart()
    if not IsServer() then return end

    if not self.main_hero then
        self.main_hero = PlayerResource:GetSelectedHeroEntity(self:GetCaster():GetMainControllingPlayer())
    end
    self.target = self:GetCursorTarget()
    --local main_hero = PlayerResource:GetSelectedHeroEntity(self:GetCaster():GetMainControllingPlayer())
    -- do it this way because client-side reads from a table, server-side reads from abilities (which Enkidu doesn't have)
    local dur = self:GetSpecialValueFor("channel_time") + self.main_hero:FindTalentValue("talent_endurance", "bonus_duration")
    --print("Ability Dur = ")

    if self.target:TriggerSpellAbsorb(self) then return end
    
    self.target:AddNewModifier(self:GetCaster(), self, "modifier_grapple_target", {duration = dur})
end

function ability_gilgamesh_grapple:OnUpgrade()
    if not IsServer() then return end

    print("ability_gilgamesh_grapple:OnUpgrade()")

    -- sync Grapple Level if Gilgamesh upgraded (since both have ref to the ability)
    -- (not sure if force leveling triggers OnUpgrade)
    if self:GetOwner():GetUnitLabel() == "enkidu" then
        return
    end

    local enk_ability = self:GetOwner():GetAbilityByIndex(0)
    local enk_ref = enk_ability:GetEnkiduRef()
    if enk_ref and enk_ref:GetLevel() > 2 then
        enk_ref:GetAbilityByIndex(1):SetLevel(self:GetLevel())
    end

    -- units = Entities:FindAllByName("enkidu")

    -- -- units = self:GetCaster():GetAdditionalOwnedUnits()
    -- for _,unit in pairs(units) do
    --     print(unit:GetName())
    --     if unit:GetUnitLabel() == "enkidu" and unit:GetLevel() > 2 then --and unit:GetOwner() == self:GetOwner() then
    --         unit:GetAbilityByIndex(1):SetLevel(self:GetLevel())
    --     end
    -- end
end

function ability_gilgamesh_grapple:OnChannelFinish(bool_interrupted)
    if not IsServer() then return end

    if self.target then
        --self.target:StopSound("Hero_ShadowShaman.Shackles.Cast")
        if self.target:FindModifierByNameAndCaster("modifier_grapple_target", self:GetCaster()) then
			self.target:RemoveModifierByNameAndCaster("modifier_grapple_target", self:GetCaster())
        end
    end
end