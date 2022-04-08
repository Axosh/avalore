-- tracking modifier for the talent
modifier_talent_self_inflicted_wounds = class({})

function modifier_talent_self_inflicted_wounds:IsHidden() 		return true end
function modifier_talent_self_inflicted_wounds:IsPurgable() 	return false end
function modifier_talent_self_inflicted_wounds:RemoveOnDeath() 	return false end