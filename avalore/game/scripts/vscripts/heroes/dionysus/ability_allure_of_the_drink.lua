ability_allure_of_the_drink = class({})

LinkLuaModifier("modifier_allure_of_the_drink", "heroes/dionysus/modifier_allure_of_the_drink", LUA_MODIFIER_MOTION_NONE)

function ability_allure_of_the_drink:GetIntrinsicModifierName()
	return "modifier_allure_of_the_drink"
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

	if not self.caster:HasScepter() and self.target:TriggerSpellAbsorb(self) then self.caster:Interrupt() return end

	-- AbilitySpecial
	self.duration					= self:GetSpecialValueFor("duration")

	self.caster:EmitSound("Hero_Lich.SinisterGaze.Cast")


    self.target:EmitSound("Hero_Lich.SinisterGaze.Target")

    self.target:AddNewModifier(self:GetCaster(), self, "modifier_allure_of_the_drink", {duration = self:GetChannelTime()})
    self.target:AddNewModifier(self:GetCaster(), nil, "modifier_truesight", {duration = self:GetChannelTime()})

end
