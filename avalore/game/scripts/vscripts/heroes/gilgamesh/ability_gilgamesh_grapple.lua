ability_gilgamesh_grapple = ability_gilgamesh_grapple or class({})

LinkLuaModifier("modifier_grapple_self",    "scripts/vscripts/heroes/gilgamesh/modifier_grapple_self.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_grapple_target",  "scripts/vscripts/heroes/gilgamesh/modifier_grapple_target.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_talent_tag_team", "scripts/vscripts/heroes/gilgamesh/modifier_talent_tag_team.lua", LUA_MODIFIER_MOTION_NONE )

function ability_gilgamesh_grapple:GetBehavior()
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_CHANNELLED
end

function ability_gilgamesh_grapple:CastFilterResultTarget(target)
    return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, self:GetCaster():GetTeamNumber())
end

-- function ability_gilgamesh_grapple:GetIntrinsicModifierName()
-- 	return "modifier_grapple_self"
-- end

-- function ability_gilgamesh_grapple:GetChannelTime()
-- 	return self:GetCaster():GetModifierStackCount("modifier_ability_grapple_helper", self:GetCaster()) * 0.01
-- end

function ability_gilgamesh_grapple:OnSpellStart()
    if not IsServer() then return end

    self.target = self:GetCursorTarget()

    if not self.target:TriggerSpellAbsorb(self) then
        self.target:AddNewModifier(self:GetCaster(), self, "modifier_grapple_target", {duration = self:GetChannelTime()})
    end
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
        enk_ref:GetAbilityByIndex(0):SetLevel(self:GetLevel())
    end

    -- units = Entities:FindAllByName("enkidu")

    -- -- units = self:GetCaster():GetAdditionalOwnedUnits()
    -- for _,unit in pairs(units) do
    --     print(unit:GetName())
    --     if unit:GetUnitLabel() == "enkidu" and unit:GetLevel() > 2 then --and unit:GetOwner() == self:GetOwner() then
    --         unit:GetAbilityByIndex(0):SetLevel(self:GetLevel())
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