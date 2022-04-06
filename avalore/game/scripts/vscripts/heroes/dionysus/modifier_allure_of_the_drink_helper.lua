
modifier_allure_of_the_drink_helper = class({})

function modifier_allure_of_the_drink_helper:IsHidden()		return true end
function modifier_allure_of_the_drink_helper:IsPurgable()		return false end
function modifier_allure_of_the_drink_helper:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_allure_of_the_drink_helper:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

-- Going to use this hacky method to determine channel time on UI
-- During the brief time before the ability actually casts, record the target's status resistance * 100 into its intrinsic modifier, then use that divided by 100 as the channel time
function modifier_allure_of_the_drink_helper:OnAbilityExecuted(keys)
	if not IsServer() then return end
	
	if keys.ability == self:GetAbility() and keys.target then
		if keys.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
			if not keys.target:IsCreep() then
				self:SetStackCount(self:GetAbility():GetSpecialValueFor("duration") * (1 - keys.target:GetStatusResistance()) * 100)
			else
				self:SetStackCount(self:GetAbility():GetSpecialValueFor("duration") * (100 - self:GetAbility():GetSpecialValueFor("creep_channel_reduction")) * 0.01 * (1 - keys.target:GetStatusResistance()) * 100)
			end
		else
			if not keys.target:IsCreep() then
				self:SetStackCount(self:GetAbility():GetSpecialValueFor("duration") * 100)
			else
				self:SetStackCount(self:GetAbility():GetSpecialValueFor("duration") * (100 - self:GetAbility():GetSpecialValueFor("creep_channel_reduction")))
			end
		end
	else
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("duration") * 100)
	end
end
