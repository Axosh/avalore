ability_allure_of_the_drink = class({})

LinkLuaModifier("modifier_allure_of_the_drink", "heroes/dionysus/modifier_allure_of_the_drink", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_allure_of_the_drink_helper", "heroes/dionysus/modifier_allure_of_the_drink_helper", LUA_MODIFIER_MOTION_NONE)

function ability_allure_of_the_drink:GetIntrinsicModifierName()
	return "modifier_allure_of_the_drink_helper"
end

-- function ability_allure_of_the_drink:GetBehavior()
-- 	if not self:GetCaster():HasScepter() then
-- 		return self.BaseClass.GetBehavior(self)
-- 	else
-- 		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
-- 	end
-- end

-- function ability_allure_of_the_drink:GetChannelTime()
-- 	return self:GetCaster():GetModifierStackCount("modifier_allure_of_the_drink", self:GetCaster()) * 0.01
-- end

function ability_allure_of_the_drink:OnSpellStart()
	self.caster			= self:GetCaster()
	self.target			= self:GetCursorTarget()

	--if not self.caster:HasScepter() and self.target:TriggerSpellAbsorb(self) then self.caster:Interrupt() return end
	if self.target:TriggerSpellAbsorb(self) then self.caster:Interrupt() return end

	-- AbilitySpecial
	self.duration					= self:GetSpecialValueFor("duration")

	self.caster:EmitSound("Hero_Lich.SinisterGaze.Cast")


    self.target:EmitSound("Hero_Lich.SinisterGaze.Target")

	--self.caster:AddNewModifier(self:GetCaster(), self, "modifier_allure_of_the_drink", {duration = self:GetChannelTime()})
    self.target:AddNewModifier(self:GetCaster(), self, "modifier_allure_of_the_drink", {duration = self:GetChannelTime()})
    self.target:AddNewModifier(self:GetCaster(), nil, "modifier_truesight", {duration = self:GetChannelTime()})

	if self:GetCaster():HasTalent("talent_beacon") then
			-- find units in radius
			local enemies = FindUnitsInRadius(
				self.caster:GetTeamNumber(),	-- int, your team number
				self.caster:GetAbsOrigin(),	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				self:GetSpecialValueFor("cast_range_tooltip"),	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_CREEP,	-- int, type filter
				DOTA_UNIT_TARGET_FLAG_NONE ,	-- int, flag filter
				0,	-- int, order filter
				false	-- bool, can grow cache
			)

			for _,enemy in pairs(enemies) do
				enemy:AddNewModifier(self:GetCaster(), self, "modifier_allure_of_the_drink", {duration = self:GetChannelTime()})
				enemy:AddNewModifier(self:GetCaster(), nil, "modifier_truesight", {duration = self:GetChannelTime()})
			end
	end

end
