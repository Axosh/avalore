-- tracking modifier for the talent
modifier_talent_benevolence = class({})

function modifier_talent_benevolence:IsHidden() 		return true end
function modifier_talent_benevolence:IsPurgable() 	return false end
function modifier_talent_benevolence:RemoveOnDeath() 	return false end