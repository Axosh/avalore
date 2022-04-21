-- tracking modifier for the talent
modifier_talent_limit_break = class({})

function modifier_talent_limit_break:IsHidden() 		return true end
function modifier_talent_limit_break:IsPurgable() 	return false end
function modifier_talent_limit_break:RemoveOnDeath() 	return false end