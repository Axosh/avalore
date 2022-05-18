-- tracking modifier for the talent
modifier_talent_second_bloom = class({})

function modifier_talent_second_bloom:IsHidden() 		return true end
function modifier_talent_second_bloom:IsPurgable() 		return false end
function modifier_talent_second_bloom:RemoveOnDeath() 	return false end